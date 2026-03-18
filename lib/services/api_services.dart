import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

      // 1. Compress & Resize image for free tier (Quality 10%, Max 256px) - minimize input tokens
      File compressedFile = await ImageUtils.compressImage(
        imageFile,
        quality: 10,
        maxDimension: 256,
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
          "temperature": 0.4, // Slightly higher temp for better 560px results
          "topK": 30,
          "topP": 0.7,
          "maxOutputTokens": 1200, // Increased for 560px resolution
        },
      };

      // For free tier, we limit the resolution to 560px
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["responseModalities"] = [
        "IMAGE",
      ];
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["imageConfig"] = {
        "aspectRatio": "1:1",
        "imageSize": "560",
      };

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
        quality: 10,
        maxDimension: 256,
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
      (requestBody["generationConfig"]
          as Map<String, dynamic>)["imageConfig"] = {
        "aspectRatio": "1:1",
        "imageSize": "1024",
      };

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
