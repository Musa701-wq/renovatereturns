import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BackendApiService {
  static String get _baseUrl {
    String? envUrl = dotenv.env['BACKEND_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // Fallback for local development
    // Android emulator uses 10.0.2.2 to access host's localhost
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  static String get _apiKey => dotenv.env['BACKEND_API_KEY'] ?? '';

  static Map<String, String> get _headers {
    final user = FirebaseAuth.instance.currentUser;
    return {
      'Content-Type': 'application/json',
      'x-api-key': _apiKey,
      if (user != null) 'x-user-id': user.uid,
    };
  }

  static Future<Map<String, dynamic>> chat({
    required String message,
  }) async {
    return _post('/process/chat', {
      'message': message,
    });
  }

  static Future<Map<String, dynamic>> detectObjects({
    required String imageBase64,
  }) async {
    return _post('/process/detect-objects', {
      'image_base64': imageBase64,
    });
  }

  // --- AI Processing ---

  static Future<Map<String, dynamic>> remodel({
    required String prompt,
    required String imageBase64,
    required String mimeType,
  }) async {
    return _post('/process/remodel', {
      'prompt': prompt,
      'image_base64': imageBase64,
      'mime_type': mimeType,
    });
  }

  static Future<Map<String, dynamic>> inpaint({
    required String prompt,
    required String imageBase64,
    required String mimeType,
  }) async {
    return _post('/process/inpaint', {
      'prompt': prompt,
      'image_base64': imageBase64,
      'mime_type': mimeType,
    });
  }

  static Future<Map<String, dynamic>> styleTransfer({
    required String prompt,
    required String imageBase64,
    required String mimeType,
  }) async {
    return _post('/process/style-transfer', {
      'prompt': prompt,
      'image_base64': imageBase64,
      'mime_type': mimeType,
    });
  }

  // --- Storage ---

  static Future<String?> uploadImage(File file) async {
    final fileBytes = await file.readAsBytes();
    return _uploadBytes(fileBytes, file.path.split('/').last);
  }

  static Future<String?> uploadBase64Image(String base64Image, String filename) async {
    String cleanBase64 = base64Image;
    if (base64Image.contains(',')) {
      cleanBase64 = base64Image.split(',')[1];
    }
    final imageBytes = base64Decode(cleanBase64);
    return _uploadBytes(imageBytes, filename);
  }

  static Future<String?> _uploadBytes(Uint8List bytes, String filename) async {
    try {
      final url = '$_baseUrl/storage/upload-url?filename=$filename';
      print('🌐 [BackendAPI] GET: $url');
      // 1. Get upload URL
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        debugPrint('❌ Failed to get upload URL: ${response.statusCode}');
        return null;
      }

      print('📦 Upload URL Response: ${response.body}');
      final data = jsonDecode(response.body);
      final uploadUrl = data['upload_url'];
      print('📦 S3 URL: $uploadUrl');
      final headers = Map<String, String>.from(data['headers'] ?? {});

      print('🌐 [BackendAPI] PUT (S3): $uploadUrl');
      // 2. Upload to S3
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          ...headers,
          'Content-Type': 'image/jpeg',
        },
        body: bytes,
      );

      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
        print('✅ [BackendAPI] S3 Upload Success: ${uploadResponse.body}');
        // Use public_url if available, otherwise construct full S3 URL
        String finalUrl;
        if (data['public_url'] != null) {
          finalUrl = data['public_url'];
        } else {
          final baseUrl = uploadUrl.split('?').first;
          finalUrl = baseUrl.endsWith('/') ? '$baseUrl$filename' : '$baseUrl/$filename';
        }
        print('🔗 [BackendAPI] Final Image URL: $finalUrl');
        return finalUrl;
      } else {
        print('❌ [BackendAPI] S3 upload failed: ${uploadResponse.statusCode}');
        print('   - Response: ${uploadResponse.body}');
        return null;
      }
    } catch (e) {
      print('❌ [BackendAPI] Error in _uploadBytes: $e');
      return null;
    }
  }

  // --- History & Gallery ---

  static Future<List<dynamic>> getHistory() async {
    final url = '$_baseUrl/history';
    print('🌐 [BackendAPI] GET: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> saveHistory(Map<String, dynamic> data) async {
    final url = '$_baseUrl/history';
    print('🌐 [BackendAPI] POST: $url');
    print('📝 [BackendAPI] Data: ${jsonEncode(data)}');
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );
    final success = response.statusCode == 200 || response.statusCode == 201;
    print('📦 [BackendAPI] saveHistory Response (${response.statusCode}): ${response.body}');
    return success;
  }

  static Future<bool> deleteHistory(String id) async {
    final url = '$_baseUrl/history/$id';
    print('🌐 [BackendAPI] DELETE: $url');
    final response = await http.delete(
      Uri.parse(url),
      headers: _headers,
    );
    final success = response.statusCode == 200 || response.statusCode == 204;
    print('📦 [BackendAPI] deleteHistory Response (${response.statusCode}): ${response.body}');
    return success;
  }

  static Future<bool> shareHistory(String id) async {
    final url = '$_baseUrl/history/$id/share';
    print('🌐 [BackendAPI] POST (Share): $url');
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
    );
    final success = response.statusCode == 200 || response.statusCode == 201;
    print('📦 [BackendAPI] shareHistory Response (${response.statusCode}): ${response.body}');
    return success;
  }

  static Future<List<dynamic>> getPublicGallery() async {
    final url = '$_baseUrl/gallery/public';
    print('🌐 [BackendAPI] GET: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // --- Helper methods ---

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final url = '$_baseUrl$path';
      print('🌐 [BackendAPI] POST: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('📦 [BackendAPI] POST $path Success Body: ${response.body}');
        return jsonDecode(response.body);
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in POST $path: $e');
      rethrow;
    }
  }
}
