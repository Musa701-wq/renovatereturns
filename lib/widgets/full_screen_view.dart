import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../widgets/save_button.dart';
import '../widgets/share_button.dart';
import '../utils/theme.dart';

class FullScreenImageView extends StatefulWidget {
  final Uint8List imageData;
  final String title;
  final String description;
  final bool showActions;

  const FullScreenImageView({
    super.key,
    required this.imageData,
    required this.title,
    required this.description,
    this.showActions = true,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _saveImage() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ImageGallerySaver.saveImage(
        widget.imageData,
        name: 'AI_Design_${DateTime.now().millisecondsSinceEpoch}.png',
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image saved to Photos!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareImage() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);

      await file.writeAsBytes(widget.imageData);

      final xFile = XFile(imagePath);
      await Share.shareXFiles([xFile]);

      // Cleanup
      Future.delayed(const Duration(seconds: 10), () async {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting temp file: $e');
        }
      });

     /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Image shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );*/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine button width based on screen size
    double getButtonWidth() {
      if (screenWidth > 600) return 160;
      return 140;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back button and title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Image Display Area
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    widget.imageData,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons - Using custom buttons
            if (widget.showActions)
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Save Button using your custom SaveButton widget
                    SaveButton(
                      isLoading: _isSaving,
                      onPressed: _saveImage,
                      label: 'Save',
                      width: getButtonWidth(),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.secondaryColor,
                      borderColor: AppTheme.primaryColor,
                    ),

                    // Share Button using your custom ShareButton widget
                    ShareButton(
                      isLoading: _isSharing,
                      onPressed: _shareImage,
                      label: 'Share',
                      width: getButtonWidth(),
                      backgroundColor: AppTheme.tilescolor,
                      foregroundColor: AppTheme.primaryColor,
                      borderColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}