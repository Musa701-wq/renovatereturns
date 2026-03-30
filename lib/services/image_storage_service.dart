import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageStorageService {
  static String get _apiUrl => dotenv.env['S3_UPLOAD_URL'] ?? 'https://s3-upload.mirdemy.com/upload';
  static String get _apiKey => dotenv.env['S3_API_KEY'] ?? '';

  /// Uploads a base64 image to the external S3 API and stores the resulting URL
  /// in the Firestore `images` collection under the current user's uid.
  static Future<void> uploadAndStore(String base64Image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ [ImageStorage] No logged-in user.');
        return;
      }

      // Strip data URL prefix if present
      String cleanBase64 = base64Image;
      if (base64Image.contains(',')) {
        cleanBase64 = base64Image.split(',')[1];
      }
      final imageBytes = base64Decode(cleanBase64);

      // Build multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.headers['x-api-key'] = _apiKey;
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'gen_${DateTime.now().millisecondsSinceEpoch}.png',
        contentType: MediaType('image', 'png'),
      ));

      debugPrint('📤 [ImageStorage] Uploading image for uid: ${user.uid}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // 📦 Print full API response like Node.js
        debugPrint('📦 [ImageStorage] API Response: {');
        debugPrint("  url: '${data['url']}',");
        debugPrint("  key: '${data['key']}',");
        debugPrint("  originalSizeKB: '${data['originalSizeKB']}',");
        debugPrint("  compressedSizeKB: '${data['compressedSizeKB']}'");
        debugPrint('}');

        final String? uploadedUrl = data['url'];


        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          await FirebaseFirestore.instance.collection('images').add({
            'uid': user.uid,
            'url': uploadedUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'tier': 'free',
            'type': 'generated',
          });
          debugPrint('✅ [ImageStorage] Stored URL in Firestore: $uploadedUrl');
        } else {
          debugPrint('❌ [ImageStorage] No url in API response.');
        }
      } else {
        debugPrint('❌ [ImageStorage] Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [ImageStorage] Error: $e');
    }
  }
}
