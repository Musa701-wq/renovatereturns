import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  static const String _imageGenEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";
  static const String _variationEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";
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

      // ✅ YEH ENDPOINT CHANGE KARO - gemini-pro-vision use karo
      const String _dualImageEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image:generateContent";
      // OR: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent"

      // DONO images ko read karo
      List<int> referenceImageBytes = await referenceImageFile.readAsBytes();
      List<int> targetImageBytes = await targetImageFile.readAsBytes();

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
                  "data": referenceBase64  // Reference image
                }
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": targetBase64  // Target image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 2048,
        }
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

// ==========================================
// BAS! ITNA HI ADD KARNA HAI
// Baaki sab existing code same rahega
// ==========================================
  static Future<String> generateImageFromPrompt({
    required String prompt,
    required File imageFile,
  }) async {
    try {
      if (_apiKey == null) {
        throw Exception('Gemini API key not found in .env file');
      }

      print('🔑 Using API Key: ${_apiKey!.substring(0, 10)}...');
      print('🚀 Starting Gemini 2.5 Flash Image Generation...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        }
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

        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;

      } else {
        print('❌ Gemini 2.5 Flash API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Gemini Image Generation Failed: $e');
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
      print('🚀 Starting Gemini 2.5 Flash Image Generation (Variations)...');
      print('📝 Prompt: ${prompt.substring(0, 100)}...');

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.9,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 2048,
        }
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
        String generatedImage = _extractGeneratedImage(data);
        return generatedImage;
      } else {
        print('❌ Gemini 2.5 Flash API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Gemini API Error: ${response.statusCode} - ${response.body}');
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
          if (part['inlineData'] != null && part['inlineData']['data'] != null) {
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

  static Future<void> _saveAPIResponse(String prompt, Map<String, dynamic> response) async {
    try {
      final directory = Directory.current;
      final file = File('${directory.path}/gemini_2.5_responses.txt');

      String timestamp = DateTime.now().toString().split('.')[0];
      String savedText = '''
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