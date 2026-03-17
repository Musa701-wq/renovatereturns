import 'dart:io';
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
}
