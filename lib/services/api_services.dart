import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'exception_handler.dart';
import 'image_utils.dart';
import 'prompt_v2.dart';

class GeminiService {
  static final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  static const String _imageGenEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";
  static const String _variationEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";
  // ==========================================
  // api_services.dart - SIRF YEH METHOD ADD KARO
  // ==========================================

  /// Detects objects in an image and returns a list of bounding boxes.
  static Future<List<Map<String, dynamic>>> detectObjects({
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) throw Exception('API key not found');

      File compressed = await ImageUtils.compressImage(
        imageFile,
        quality: 80,
        maxDimension: 768,
      );
      String base64Img = base64Encode(await compressed.readAsBytes());

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Detect all prominent objects for remodeling (furniture, windows, doors, floor, walls, ceiling) and return a JSON list of objects with their normalized coordinates [ymin, xmin, ymax, xmax] in the format: {'objects': [{'label': 'sofa', 'box_2d': [ymin, xmin, ymax, xmax]}]}. Return ONLY the JSON.",
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Img},
              },
            ],
          },
        ],
        "generationConfig": {"temperature": 0.1},
      };

      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON from potential markdown code blocks
        if (text.contains('```json')) {
          text = text.split('```json')[1].split('```')[0];
        } else if (text.contains('```')) {
          text = text.split('```')[1].split('```')[0];
        }

        final result = jsonDecode(text);
        return List<Map<String, dynamic>>.from(result['objects'] ?? []);
      }
      return [];
    } catch (e) {
      print('Object detection failed: $e');
      return [];
    }
  }

  // GeminiService class ke andar, generateImageFromPrompt() method ke BAAD
  // yeh naya method add kar do:

  static Future<String> generateImageFromDualPrompt({
    required String prompt,
    required File referenceImageFile,
    required File targetImageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🔑 Using API Key: ${_apiKey!.substring(0, 10)}...');
      print('🚀 Starting Gemini PRO VISION for Dual Image Generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');
      print('🖼️ Reference Image: ${referenceImageFile.path}');
      print('🖼️ Target Image: ${targetImageFile.path}');

      const String _dualImageEndpoint =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image:generateContent";

      // Compress & Resize images for global optimization (Quality 85%, Max 1024px)
      File compressedReference = await ImageUtils.compressImage(
        referenceImageFile,
        quality: 85,
        maxDimension: 1024,
      );
      File compressedTarget = await ImageUtils.compressImage(
        targetImageFile,
        quality: 85,
        maxDimension: 1024,
      );

      // DONO images ko read karo
      List<int> referenceImageBytes = await compressedReference.readAsBytes();
      List<int> targetImageBytes = await compressedTarget.readAsBytes();

      // DONO ko base64 mein convert karo
      String referenceBase64 = base64Encode(referenceImageBytes);
      String targetBase64 = base64Encode(targetImageBytes);

      // ✅ SIMPLIFIED REQUEST BODY - Gemini ke format mein
      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": referenceBase64, // Reference image
                },
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": targetBase64, // Target image
                },
              },
            ],
          },
        ],
        "generationConfig": {"temperature": 0.7, "maxOutputTokens": 2048},
      };

      print('📤 Sending dual-image request to Gemini Pro Vision...');

      // ✅ CORRECT ENDPOINT USE KARO
      final response = await http.post(
        Uri.parse('$_dualImageEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Gemini Dual Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage:');
          print(
            '   Input Tokens (Prompt Text + Image): ${usage["promptTokenCount"]}',
          );
          print(
            '   Output Tokens (Generated Content): ${usage["candidatesTokenCount"]}',
          );
          print('   Total Tokens: ${usage["totalTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Dual Image Generation Failed: $e');
      throw Exception('Reference transform generation failed: $e');
    }
  }

  /// Smart inpainting: crops the selected region, transforms it via Gemini,
  /// then composites the result back onto the original image at the exact location.
  static Future<String> generateImageInpaint({
    required String prompt,
    required File imageFile,
    required File maskFile,
  }) async {
    try {
      if (_apiKey == null) throw Exception('Gemini API key not found');

      print('🚀 Starting Crop-Transform-Composite Inpainting...');

      // ── Step 1: Decode original image and mask ─────────────────────────
      final imgBytes = await imageFile.readAsBytes();
      final maskBytes = await maskFile.readAsBytes();

      final img.Image? originalImg = img.decodeImage(imgBytes);
      final img.Image? maskImg = img.decodeImage(maskBytes);
      if (originalImg == null || maskImg == null)
        throw Exception('Failed to decode images');

      // ── Step 2: Scale mask to original image dimensions (v4 API) ─────────
      final img.Image scaledMask = img.copyResize(
        maskImg,
        width: originalImg.width,
        height: originalImg.height,
      );

      // ── Step 3: Find bounding box of white area in mask (v4 pixel API) ───
      int minX = originalImg.width,
          minY = originalImg.height,
          maxX = 0,
          maxY = 0;
      for (int y = 0; y < scaledMask.height; y++) {
        for (int x = 0; x < scaledMask.width; x++) {
          final pixel = scaledMask.getPixel(x, y);
          // v4: pixel.r, pixel.g, pixel.b are num values 0-255
          final double brightness = (pixel.r + pixel.g + pixel.b) / 3.0;
          if (brightness > 128) {
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x > maxX) maxX = x;
            if (y > maxY) maxY = y;
          }
        }
      }

      if (maxX <= minX || maxY <= minY)
        throw Exception('No valid selection area found in mask');

      // Add padding around selection so Gemini has context
      final int padX = ((maxX - minX) * 0.1).toInt().clamp(5, 80);
      final int padY = ((maxY - minY) * 0.1).toInt().clamp(5, 80);
      final int cropX = (minX - padX).clamp(0, originalImg.width - 1);
      final int cropY = (minY - padY).clamp(0, originalImg.height - 1);
      final int cropW = ((maxX - minX) + padX * 2).clamp(
        10,
        originalImg.width - cropX,
      );
      final int cropH = ((maxY - minY) + padY * 2).clamp(
        10,
        originalImg.height - cropY,
      );

      print('🖼  Crop region: ($cropX, $cropY) ${cropW}x${cropH}');

      // ── Step 4: Crop the region (v4 uses named params) ──────────────────
      final img.Image cropped = img.copyCrop(
        originalImg,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );
      final List<int> croppedJpg = img.encodeJpg(cropped, quality: 90);
      final String croppedBase64 = base64Encode(croppedJpg);

      // ── Step 5: Send cropped region to Gemini ───────────────────────────
      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "CRITICAL INSTRUCTION: You are given a tightly cropped image of a specific area from a room. Your ONLY task is to apply this change: \"$prompt\" inside this cropped region. Completely replace whatever is currently in this crop with what the user requested, OR modify it exactly as asked. DO NOT change the perspective or lighting. The output must be EXACTLY the same size and shape as the input crop, containing ONLY the new requested item blending into the existing background.",
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": croppedBase64,
                },
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.4,
          "topK": 32,
          "topP": 0.95,
          "maxOutputTokens": 2048,
          "responseModalities": ["IMAGE"],
        },
      };

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(
          '❌ Gemini Inpainting Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Gemini API Error: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String transformedBase64 = _extractRawBase64Image(data);
      final Uint8List transformedBytes = base64Decode(transformedBase64);
      img.Image? transformedImg = img.decodeImage(transformedBytes);
      if (transformedImg == null)
        throw Exception('Failed to decode transformed image');

      // ── Step 6: Resize transformed region to match crop dimensions (v4) ──
      transformedImg = img.copyResize(
        transformedImg,
        width: cropW,
        height: cropH,
      );

      // ── Step 7: Composite back onto a clone of the original (v4 API) ─────
      final img.Image result = originalImg.clone();
      img.compositeImage(result, transformedImg, dstX: cropX, dstY: cropY);

      // ── Step 8: Encode and return ────────────────────────────────────────
      final List<int> resultJpg = img.encodeJpg(result, quality: 90);
      return 'data:image/jpeg;base64,${base64Encode(resultJpg)}';
    } catch (e) {
      print('❌ Inpainting Failed: $e');
      throw Exception('Inpainting generation failed: $e');
    }
  }

  /// Optimized image generation for free tier users
  /// Compresses image by 30-35% and limits output to 1000 tokens
  static Future<String> generateImageFreeTier({
    required String prompt,
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🚀 Starting Free Tier Optimized Image Generation...');

      // 1. Compress & Resize image for all tiers (Quality 85%, Max 1024px)
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      print(
        '📦 Image compressed & resized for free tier: ${compressedFile.path}',
      );

      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      // Both tiers use 1024px resolution for consistency as requested
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "IMAGE",
      ];
      (requestBody["generationConfig"] as Map<String, dynamic>)["imageConfig"] =
          {"aspectRatio": "1:1", "imageSize": "1024"};

      print('📤 Sending restricted request to Gemini (Free Tier)...');

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Free Tier Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage (FREE TIER):');
          print('   Input Tokens: ${usage["promptTokenCount"]}');
          print('   Output Tokens: ${usage["candidatesTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini Free Tier API Error: ${response.statusCode}');
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Gemini Free Tier Failed: $e');
      throw Exception('Free tier generation failed: $e');
    }
  }

  // ==========================================
  // BAS! ITNA HI ADD KARNA HAI
  // Baaki sab existing code same rahega
  // ==========================================
  static Future<String> generateImageFromPrompt({
    required String prompt,
    required File imageFile,
  }) async {
    /*
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // Compress & Resize image for global optimization (Quality 85%, Max 1024px)
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      print('📦 Image compressed & resized: ${compressedFile.path}');

      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      // Add imageConfig for standard/paid requests to use higher resolution
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "TEXT",
        "IMAGE",
      ];
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["imageConfig"] = {
        "aspectRatio": "1:1",
        "imageSize": "1K", // 1024x1024 or higher for premium
      };

      print('📤 Sending request to Gemini 2.5 Flash Image...');

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Gemini 2.5 Flash Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage:');
          print(
            '   Input Tokens (Prompt Text + Image): ${usage["promptTokenCount"]}',
          );
          print(
            '   Output Tokens (Generated Content): ${usage["candidatesTokenCount"]}',
          );
          print('   Total Tokens: ${usage["totalTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini 2.5 Flash API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Gemini Image Generation Failed: $e');
      throw Exception('Image generation failed: $e');
    }
    */

    // TEMPORARY: Use Free Tier logic inside Paid Tier as requested by user
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🚀 Starting TEMPORARY Free Tier Logic for Paid users...');

      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "IMAGE",
      ];
      (requestBody["generationConfig"] as Map<String, dynamic>)["imageConfig"] =
          {"aspectRatio": "1:1", "imageSize": "1024"};

      print(
        '📤 Sending restricted request to Gemini (Temporary Paid->Free)...',
      );

      final response = await http.post(
        Uri.parse('$_imageGenEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Temporary Free Tier (Paid) Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage (TEMPORARY PAID):');
          print('   Input Tokens: ${usage["promptTokenCount"]}');
          print('   Output Tokens: ${usage["candidatesTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        throw Exception('Gemini API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Generation Failed: $e');
      throw Exception('Image generation failed: $e');
    }
  }

  static Future<String> generateImageFromVariationPrompt({
    required String prompt,
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🔑 Using API Key: ${_apiKey!.substring(0, 10)}...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      // Compress & Resize image for global optimization (Quality 85%, Max 1024px)
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 85,
        maxDimension: 1024,
      );
      print(
        '📦 Image compressed & resized (Variations): ${compressedFile.path}',
      );

      List<int> imageBytes = await compressedFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
        "generationConfig": <String, dynamic>{
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        },
      };

      // Add imageConfig for standard/paid variations requests to use higher resolution
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "TEXT",
        "IMAGE",
      ];
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["imageConfig"] = {
        "aspectRatio": "1:1",
        "imageSize": "1K", // 1024x1024 or higher for premium
      };

      print('📤 Sending request to Gemini 2.5 Flash Image (Variations)...');

      final response = await http.post(
        Uri.parse('$_variationEndpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('✅ Gemini 2.5 Flash Image Generation Success!');

        if (data['usageMetadata'] != null) {
          final usage = data['usageMetadata'];
          print('📊 Token Usage:');
          print(
            '   Input Tokens (Prompt Text + Image): ${usage["promptTokenCount"]}',
          );
          print(
            '   Output Tokens (Generated Content): ${usage["candidatesTokenCount"]}',
          );
          print('   Total Tokens: ${usage["totalTokenCount"]}');
        }

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini 2.5 Flash API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Gemini Image Generation Failed: $e');
      throw Exception('Image generation failed: $e');
    }
  }

  /// Extracts just the raw base64 string (without the data: prefix).
  /// Used for crop-composite inpainting so we can decode the image directly.
  static String _extractRawBase64Image(Map<String, dynamic> data) {
    try {
      final parts = data['candidates'][0]['content']['parts'] as List;
      for (final part in parts) {
        if (part['inlineData'] != null && part['inlineData']['data'] != null) {
          return part['inlineData']['data'] as String;
        }
      }
    } catch (_) {}
    throw Exception('No image found in Gemini response');
  }

  static String _extractGeneratedImage(Map<String, dynamic> data) {
    try {
      print('🔍 Extracting generated image from response...');

      if (data['candidates'] != null &&
          data['candidates'].isNotEmpty &&
          data['candidates'][0]['content'] != null &&
          data['candidates'][0]['content']['parts'] != null &&
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        var parts = data['candidates'][0]['content']['parts'];

        for (var part in parts) {
          if (part['inlineData'] != null &&
              part['inlineData']['data'] != null) {
            String base64Image = part['inlineData']['data'];
            String mimeType = part['inlineData']['mimeType'] ?? 'image/png';

            if (base64Image.isNotEmpty) {
              print('✅ Found generated image: ${mimeType}');
              return 'data:$mimeType;base64,$base64Image';
            }
          }

          if (part['text'] != null) {
            String text = part['text'];
            if (text.isNotEmpty) {
              print('📄 Text response length: ${text.length}');

              if (text.contains('data:image')) {
                List<String> imageParts = text.split('data:image');
                if (imageParts.length > 1) {
                  String imageData = 'data:image${imageParts[1]}';
                  return imageData;
                }
              }
            }
          }
        }
      }

      print('❌ No valid image data found in response');
      throw Exception('No image data received from Gemini API');
    } catch (e) {
      print('❌ Error extracting image: $e');
      throw Exception('Image extraction failed: $e');
    }
  }

  static Future<void> _saveAPIResponse(
    String prompt,
    Map<String, dynamic> response,
  ) async {
    try {
      final directory = Directory.current;
      final file = File('${directory.path}/gemini_2.5_responses.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText =
          '''
=== GEMINI 2.5 FLASH RESPONSE - $timestamp ===
PROMPT:
$prompt

FULL RESPONSE:
${jsonEncode(response)}
================================
\n
''';

      await file.writeAsString(savedText, mode: FileMode.append);
      print('💾 API response saved to: ${file.path}');
    } catch (e) {
      print('❌ Error saving API response: $e');
    }
  }
}
