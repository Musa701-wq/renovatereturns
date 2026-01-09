/*
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class CloudinaryService {
  final String cloudName = 'dkr7rka2r';
  final String uploadPreset = 'YOUR_UPLOAD_PRESET';
  final String apiKey = 'Ss8p3mkJW7KPhWu0z8lCsBS3si4';

  Future<String> uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['api_key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath(
            'file',
            imageFile.path
        ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      return jsonResponse['secure_url'];
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}*/
