// lib/widgets/dual_image_selection_widget.dart
// Yeh poori file copy karo - kuch change nahi karna

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/upload_provider.dart';
import '../utils/theme.dart';
import 'full_screen_view.dart';

class DualImageSelectionWidget extends StatelessWidget {
  const DualImageSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Images',
              style: TextStyle(
                fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 24),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 12)),

            Text(
              'Choose a reference image (A) and target image (B)',
              style: TextStyle(
                fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ),

            SizedBox(height: AppTheme.responsiveSize(context, phone: 16, tablet: 20)),

            // IMAGE A
            _buildImageSelector(
              context: context,
              uploadProvider: uploadProvider,
              imageType: 'A',
              label: 'Reference Image (A)',
              subtitle: 'The style/look you want to copy',
              image: uploadProvider.selectedImage,
              onCameraPressed: () async {
                try {
                  await uploadProvider.openCamera();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Camera error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              onGalleryPressed: () async {
                try {
                  await uploadProvider.openGallery();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gallery error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              onDelete: () {
                uploadProvider.setSelectedImage(null);
                uploadProvider.setSelectedImageSource(null);
              },
            ),

            SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 26)),

            // IMAGE B
            _buildImageSelector(
              context: context,
              uploadProvider: uploadProvider,
              imageType: 'B',
              label: 'Target Image (B)',
              subtitle: 'The image you want to transform',
              image: uploadProvider.secondaryImage,
              onCameraPressed: () async {
                try {
                  await uploadProvider.openSecondaryCamera();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Camera error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              onGalleryPressed: () async {
                try {
                  await uploadProvider.openSecondaryGallery();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gallery error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              onDelete: () {
                uploadProvider.setSecondaryImage(null);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageSelector({
    required BuildContext context,
    required UploadProvider uploadProvider,
    required String imageType,
    required String label,
    required String subtitle,
    required File? image,
    required VoidCallback onCameraPressed,
    required VoidCallback onGalleryPressed,
    required VoidCallback onDelete,
  }) {
    final bool hasImage = image != null;
    final double containerPadding = hasImage ? 0 : AppTheme.responsiveSize(context, phone: 16, tablet: 24);
    final double borderRadius = AppTheme.responsiveSize(context, phone: 12, tablet: 16);
    final double imageRadius = AppTheme.responsiveSize(context, phone: 10, tablet: 14);
    final double imageHeight = AppTheme.responsiveSize(context, phone: 160, tablet: 200);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasImage)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
                vertical: AppTheme.responsiveSize(context, phone: 4, tablet: 6),
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
              ),
              child: Text(
                'Image $imageType',
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          if (!hasImage) SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 12)),

          hasImage
              ? Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  await _showFullScreenImage(context, image);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(imageRadius),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Image $imageType',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.responsiveFont(context, phone: 10, tablet: 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                  ),
                ),
              ),
            ],
          )
              : Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: AppTheme.responsiveSize(context, phone: 4, tablet: 6)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
              Icon(
                Icons.add_photo_alternate,
                size: AppTheme.responsiveSize(context, phone: 40, tablet: 55),
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCameraPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.responsiveSize(context, phone: 8, tablet: 12),
                          ),
                        ),
                      ),
                      icon: Icon(Icons.camera_alt, size: AppTheme.responsiveSize(context, phone: 18, tablet: 24)),
                      label: Text('Camera', style: TextStyle(fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18))),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onGalleryPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.responsiveSize(context, phone: 8, tablet: 12),
                          ),
                        ),
                      ),
                      icon: Icon(Icons.photo_library, size: AppTheme.responsiveSize(context, phone: 18, tablet: 24)),
                      label: Text('Gallery', style: TextStyle(fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showFullScreenImage(BuildContext context, File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageData: bytes,
          title: 'Selected Image',
          description: 'Preview',
          showActions: false,
        ),
      ),
    );
  }
}