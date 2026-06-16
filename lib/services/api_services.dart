import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'exception_handler.dart';
import 'image_utils.dart';
import 'prompt_v2.dart';

import 'backend_api_service.dart';

class GeminiService {
  static Future<List<Map<String, dynamic>>> detectObjects({
    required File imageFile,
  }) async {
    try {
      print('🚀 Starting object detection via Backend API...');
      
      File compressed = await ImageUtils.compressImage(
        imageFile,
        quality: 80,
        maxDimension: 768,
      );
      String base64Img = base64Encode(await compressed.readAsBytes());

      final result = await BackendApiService.detectObjects(
        imageBase64: base64Img,
      );

      return List<Map<String, dynamic>>.from(result['objects'] ?? []);
    } catch (e) {
      print('Object detection failed: $e');
      return [];
    }
  }

  /// Chatbot text generation using Gemini
  static Future<String> getChatbotResponse({required String userMessage}) async {
    try {
      print('🚀 Starting chatbot via Backend API...');
      
      final result = await BackendApiService.chat(
        message: userMessage,
      );

      return result['result'] as String;
    } catch (e) {
      print('Chatbot error: $e');
      return "An error occurred while generating a response: $e";
    }
  }

  // GeminiService class ke andar, generateImageFromPrompt() method ke BAAD
  // yeh naya method add kar do:

  /// 2-Step Reference Style Transfer:
  /// Step 1: Analyze the reference image to extract a rich style description.
  /// Step 2: Use that description + target image to generate the transformed output.
  static Future<String> generateImageFromDualPrompt({
    required String prompt,
    required File referenceImageFile,
    required File targetImageFile,
  }) async {
    try {
      print('🚀 Starting style transfer via Backend API...');
      
      final imageBytes = await targetImageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final result = await BackendApiService.styleTransfer(
        prompt: prompt,
        imageBase64: base64Image,
        mimeType: 'image/jpeg',
      );

      return result['result'];
    } catch (e) {
      print('❌ Style Transfer Failed: $e');
      throw Exception('Style transfer failed: $e');
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
      print('🚀 Starting inpainting via Backend API...');
      
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Note: Masking logic currently simplified to pass the original image
      // Backend should handle mask if provided in body or handled separately
      final result = await BackendApiService.inpaint(
        prompt: prompt,
        imageBase64: base64Image,
        mimeType: 'image/jpeg',
      );

      return 'data:image/jpeg;base64,${result['result']}';
    } catch (e) {
      print('❌ Inpainting Failed: $e');
      throw Exception('Inpainting failed: $e');
    }
  }

  /// Optimized image generation for free tier users
  /// Compresses image by 30-35% and limits output to 1000 tokens
  static Future<String> generateImageFreeTier({
    required String prompt,
    required File imageFile,
  }) async {
    return generateImageFromPrompt(prompt: prompt, imageFile: imageFile);
  }

  // ==========================================
  // BAS! ITNA HI ADD KARNA HAI
  // Baaki sab existing code same rahega
  // ==========================================
  static Future<String> generateImageFromPrompt({
    required String prompt,
    required File imageFile,
    double? temperature,
  }) async {
    try {
      print('🚀 Starting remodeling via Backend API...');
      
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final result = await BackendApiService.remodel(
        prompt: prompt,
        imageBase64: base64Image,
        mimeType: 'image/jpeg',
      );

      return result['result'];
    } catch (e) {
      print('❌ Remodeling Failed: $e');
      throw Exception('Remodeling failed: $e');
    }
  }

  static Future<String> generateImageFromVariationPrompt({
    required String prompt,
    required File imageFile,
    double? temperature,
  }) async {
    return generateImageFromPrompt(prompt: prompt, imageFile: imageFile);
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
