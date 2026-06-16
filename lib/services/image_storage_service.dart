import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend_api_service.dart';

class ImageStorageService {
  // static String get _apiUrl => dotenv.env['S3_UPLOAD_URL'] ?? 'https://s3-upload.mirdemy.com/upload';
  // static String get _apiKey => dotenv.env['S3_API_KEY'] ?? '';

  /// Uploads a base64 image to the external S3 API via BackendApiService
  /// and stores the resulting record in history.
  /// Returns the uploaded S3 URL if successful, otherwise null.
  static Future<String?> uploadAndStore(String base64Image, {String type = 'generated', Map<String, dynamic>? historyData}) async {
    String? uploadedUrl;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ [ImageStorage] No logged-in user. Saving to history skipped.');
        return null;
      }
      print('👤 [ImageStorage] User logged in: ${user.uid}');

      final filename = 'gen_${DateTime.now().millisecondsSinceEpoch}.jpg';
      uploadedUrl = await BackendApiService.uploadBase64Image(base64Image, filename);

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        debugPrint('✅ [ImageStorage] Uploaded to S3: $uploadedUrl');

        if (historyData != null) {
          print('📝 [ImageStorage] Attempting to save to backend history...');
          
          // Apply global "Share to Community" preference from Profile
          final prefs = await SharedPreferences.getInstance();
          bool shareEnabled = prefs.getBool('share_to_community') ?? true;
          historyData['isPublic'] = shareEnabled;
          print('🔒 [ImageStorage] Global Sharing Setting: ${shareEnabled ? "PUBLIC" : "PRIVATE"}');

          // If history data is provided, save it to the backend history
          historyData['afterImageUrl'] = uploadedUrl;
          final success = await BackendApiService.saveHistory(historyData);
          if (success) {
            print('✅ [ImageStorage] Successfully saved to backend history');
          } else {
            print('❌ [ImageStorage] Failed to save to backend history API');
          }
        }

        // Keep legacy Firestore logic for now if needed by other parts of the app
        // (Optional: remove if backend handles everything)
        /*
        final Map<String, dynamic> imageRecord = {
          'uid': user.uid,
          'url': uploadedUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'tier': 'free', // Simplified
          'type': 'generation',
          'isPublic': true,
          'favBy': [],
        };
        await FirebaseFirestore.instance.collection('images').add(imageRecord);
        */

        // wasShared = true; (Legacy)
      } else {
        debugPrint('❌ [ImageStorage] Upload failed.');
      }
    } catch (e) {
      debugPrint('❌ [ImageStorage] Error: $e');
    }
    return uploadedUrl;
  }
}
