import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Compresses an image by a specific percentage (e.g., 30-35% quality reduction)
  /// for free tier users to save bandwidth and tokens.
  /// Compresses and optionally resizes an image.
  static Future<File> compressImage(File imageFile, {int quality = 35, int? maxDimension}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) return imageFile;

    // Resize if maxDimension is provided and image is larger
    if (maxDimension != null) {
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: maxDimension);
        } else {
          image = img.copyResize(image, height: maxDimension);
        }
      }
    }

    // Compress the image
    final compressedBytes = img.encodeJpg(image, quality: quality);
    
    // Save to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressedBytes);
    
    return tempFile;
  }

  /// Adds a dimmed watermark (assets/images/logo.jpeg) to the bottom-left corner of the base64 image
  static Future<String> addWatermarkToBase64(String base64ImageString) async {
    try {
      print('💧 Adding watermark to generated image...');
      // Extract prefix if it exists
      String base64Data = base64ImageString;
      String prefix = '';
      if (base64Data.contains(',')) {
        List<String> parts = base64Data.split(',');
        prefix = parts[0] + ',';
        base64Data = parts[1];
      }

      // Decode the generated image
      Uint8List imageBytes = base64Decode(base64Data);
      img.Image? decodedImg = img.decodeImage(imageBytes);
      if (decodedImg == null) return base64ImageString;

      // Load watermark from assets
      final ByteData watermarkData = await rootBundle.load('assets/images/new_logo.png');
      final Uint8List watermarkBytes = watermarkData.buffer.asUint8List();
      img.Image? watermarkImg = img.decodeImage(watermarkBytes);
      
      if (watermarkImg != null) {
        // Resize watermark relatively (10% of image width - very subtle)
        int targetWidth = (decodedImg.width * 0.1).toInt();
        if (targetWidth < 30) targetWidth = 30; 
        
        watermarkImg = img.copyResize(watermarkImg, width: targetWidth);
        
        // Dim the watermark
        for (var p in watermarkImg) {
          p.a = p.a * 0.7; // 70% opacity (slightly more visible)
        }

        // Calculate position: bottom-right with margin
        int margin = (decodedImg.width * 0.04).toInt();
        int dstX = decodedImg.width - watermarkImg.width - margin;
        int dstY = decodedImg.height - watermarkImg.height - margin;

        // Draw the watermark on the image
        img.compositeImage(decodedImg, watermarkImg, dstX: dstX, dstY: dstY);
        
        // Convert back to Base64
        final watermarkedBytes = img.encodeJpg(decodedImg, quality: 90);
        String finalBase64 = base64Encode(watermarkedBytes);
        return prefix.isNotEmpty ? '$prefix$finalBase64' : finalBase64;
      }
      
      return base64ImageString;
    } catch (e) {
      print('❌ Error adding watermark: $e');
      return base64ImageString;
    }
  }

  /// Adds a dimmed watermark to raw image bytes directly
  static Future<Uint8List> addWatermarkToBytes(Uint8List imageBytes) async {
    try {
      img.Image? decodedImg = img.decodeImage(imageBytes);
      if (decodedImg == null) return imageBytes;

      final ByteData watermarkData = await rootBundle.load('assets/images/new_logo.png');
      final Uint8List watermarkBytes = watermarkData.buffer.asUint8List();
      img.Image? watermarkImg = img.decodeImage(watermarkBytes);

      if (watermarkImg != null) {
        int targetWidth = (decodedImg.width * 0.1).toInt();
        if (targetWidth < 30) targetWidth = 30;

        watermarkImg = img.copyResize(watermarkImg, width: targetWidth);

        for (var p in watermarkImg) {
          p.a = (p.a * 0.6).toInt(); // 60% opacity for saved images
        }

        int margin = (decodedImg.width * 0.04).toInt();
        int dstX = decodedImg.width - watermarkImg.width - margin;
        int dstY = decodedImg.height - watermarkImg.height - margin;

        img.compositeImage(decodedImg, watermarkImg, dstX: dstX, dstY: dstY);

        return Uint8List.fromList(img.encodeJpg(decodedImg, quality: 100));
      }
      return imageBytes;
    } catch (e) {
      print('❌ Error adding watermark to bytes: $e');
      return imageBytes;
    }
  }
}
