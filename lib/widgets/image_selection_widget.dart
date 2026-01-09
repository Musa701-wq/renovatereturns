/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/upload_provider.dart';
import '../utils/theme.dart'; // Import your theme

class ImageSelectionWidget extends StatelessWidget {
  const ImageSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3), // Primary color with 0.3 opacity
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              if (uploadProvider.selectedImage != null)
                Column(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(uploadProvider.selectedImage!),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2,
                            right: 2,
                            child: IconButton(
                              icon: Icon(Icons.close, color: AppTheme.primaryColor), // Primary color icon
                              onPressed: () {
                                uploadProvider.setSelectedImage(null);
                                uploadProvider.setSelectedImageSource(null);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                  ],
                )
              else
                Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 50,
                      color: AppTheme.primaryColor, // Primary color icon
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor, // Primary color text
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Camera: Take a photo | Gallery: Choose from device',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor.withOpacity(0.7), // Primary color with opacity
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await uploadProvider.openCamera();
                              } catch (e) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: uploadProvider.selectedImageSource == 'Camera'
                                  ? AppTheme.primaryColor // Primary color when selected
                                  : AppTheme.primaryColor, // Primary color with opacity
                              foregroundColor: Colors.white, // White text
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            label: Text('Camera', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await uploadProvider.openGallery();
                              } catch (e) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: uploadProvider.selectedImageSource == 'Gallery'
                                  ? AppTheme.primaryColor // Primary color when selected
                                  : AppTheme.primaryColor, // Primary color with opacity
                              foregroundColor: Colors.white, // White text
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.photo_library, color: Colors.white),
                            label: Text('Gallery', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}*/


import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/upload_provider.dart';
import '../utils/theme.dart';
import 'full_screen_view.dart';

class ImageSelectionWidget extends StatelessWidget {
  const ImageSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadProvider>(
      builder: (context, uploadProvider, child) {
        final bool hasImage = uploadProvider.selectedImage != null;
        final double containerPadding =
            hasImage ? 0 : AppTheme.responsiveSize(context, phone: 20, tablet: 32);
        final double borderRadius =
            AppTheme.responsiveSize(context, phone: 15, tablet: 20);
        final double imageRadius = AppTheme.responsiveSize(context, phone: 10, tablet: 14);
        final double imageHeight = AppTheme.responsiveSize(context, phone: 180, tablet: 220);

        return Container(
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: hasImage
              ? Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _showFullScreenImage(context, uploadProvider.selectedImage!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(imageRadius),
                        child: SizedBox(
                          height: imageHeight,
                          width: double.infinity,
                          child: Image.file(
                            uploadProvider.selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 14,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            uploadProvider.setSelectedImage(null);
                            uploadProvider.setSelectedImageSource(null);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: AppTheme.responsiveSize(context, phone: 50, tablet: 70),
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: AppTheme.responsiveSize(context, phone: 10, tablet: 16)),
                    Text(
                      'Select Image Source',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 24),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: AppTheme.responsiveSize(context, phone: 5, tablet: 10)),
                    Text(
                      'Camera: Take a photo | Gallery: Choose from device',
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.responsiveSize(context, phone: 15, tablet: 24)),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await uploadProvider.openCamera();
                              } catch (e) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.responsiveSize(context, phone: 12, tablet: 18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 10, tablet: 16)),
                              ),
                            ),
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: AppTheme.responsiveSize(context, phone: 20, tablet: 28),
                            ),
                            label: Text(
                              'Camera',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await uploadProvider.openGallery();
                              } catch (e) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.responsiveSize(context, phone: 12, tablet: 18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 10, tablet: 16)),
                              ),
                            ),
                            icon: Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: AppTheme.responsiveSize(context, phone: 20, tablet: 28),
                            ),
                            label: Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
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