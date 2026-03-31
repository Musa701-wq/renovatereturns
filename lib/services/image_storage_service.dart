import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageStorageService {
  static String get _apiUrl => dotenv.env['S3_UPLOAD_URL'] ?? 'https://s3-upload.mirdemy.com/upload';
  static String get _apiKey => dotenv.env['S3_API_KEY'] ?? '';

  /// Uploads a base64 image to the external S3 API and stores the resulting URL
  /// in the Firestore `images` collection under the current user's uid.
  /// Returns [true] if the image was shared to the community, [false] otherwise.
  static Future<bool> uploadAndStore(String base64Image, {String type = 'generated'}) async {
    bool wasShared = false;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ [ImageStorage] No logged-in user.');
        return false;
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
          
          // Securely check actual tier from database
          bool isPremium = false;
          try {
            final creditDoc = await FirebaseFirestore.instance.collection('user_credits').doc(user.uid).get();
            if (creditDoc.exists) {
              final data = creditDoc.data()!;
              final transactions = data['transactions'] as List<dynamic>? ?? [];
              isPremium = transactions.any((t) => t['type'] == 'credit' && (t['reason']?.toString().contains('iap') ?? false));
            }
          } catch(e) {
            debugPrint("Failed to check user tier: $e");
          }
          
          final String actualTier = isPremium ? 'premium' : 'free';
          
          final prefs = await SharedPreferences.getInstance();
          // Default to true if not set, but respect the toggle
          final bool shouldShareToCommunity = prefs.getBool('share_to_community') ?? true;

          // Prepare Firestore record
          final Map<String, dynamic> imageRecord = {
            'uid': user.uid,
            'url': uploadedUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'tier': actualTier,
            'type': 'generation', // Standardized type for My Creations
            'isPublic': shouldShareToCommunity, // Set based on user preference
            'favBy': [],
            'userName': user.displayName ?? 'AI Designer',
            'userPhoto': user.photoURL,
          };

          // ALWAYS save to Firestore so it shows in "My Creations"
          // ONLY shows in Community if isPublic is true
          await FirebaseFirestore.instance.collection('images').add(imageRecord);
          
          wasShared = shouldShareToCommunity;
          debugPrint('✅ [ImageStorage] Stored in Firestore (isPublic: $shouldShareToCommunity): $uploadedUrl');
        } else {
          debugPrint('❌ [ImageStorage] No url in API response.');
        }
      } else {
        debugPrint('❌ [ImageStorage] Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [ImageStorage] Error: $e');
    }
    return wasShared;
  }
}
