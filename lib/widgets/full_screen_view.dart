import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../widgets/save_button.dart';
import '../widgets/share_button.dart';
import '../widgets/watermark_upsell_dialog.dart';
import '../services/image_utils.dart';
import '../in_app_purchase/credit_manager.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';

class FullScreenImageView extends StatefulWidget {
  final Uint8List? imageData;
  final String? imageUrl;
  final String title;
  final String description;
  final bool showActions;

  const FullScreenImageView({
    super.key,
    this.imageData,
    this.imageUrl,
    required this.title,
    required this.description,
    this.showActions = true,
  }) : assert(imageData != null || imageUrl != null, 'Must provide either imageData or imageUrl');

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  bool _isSaving = false;
  bool _isSharing = false;
  Uint8List? _cachedNetworkBytes;

  Future<Uint8List?> _getBytes() async {
    if (widget.imageData != null) return widget.imageData;
    if (_cachedNetworkBytes != null) return _cachedNetworkBytes;
    
    try {
      final response = await HttpClient().getUrl(Uri.parse(widget.imageUrl!));
      final res = await response.close();
      _cachedNetworkBytes = await consolidateHttpClientResponseBytes(res);
      return _cachedNetworkBytes;
    } catch (e) {
      print('Error fetching image bytes: $e');
      return null;
    }
  }

  Future<void> _saveImage() async {
    final bytes = await _getBytes();
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load image for saving')),
        );
      }
      return;
    }

    Future<void> performSave(Uint8List finalBytes) async {
      setState(() {
        _isSaving = true;
      });

      try {
        final result = await ImageGallerySaver.saveImage(
          finalBytes,
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }

    final isPremium = Provider.of<CreditManager>(context, listen: false).hasPurchased;

    if (!isPremium) {
      final String? result = await WatermarkUpsell.show(context);
      if (result == 'watermark') {
        final watermarkedBytes = await ImageUtils.addWatermarkToBytes(bytes);
        await performSave(watermarkedBytes);
      } else if (result == 'purchased') {
        await performSave(bytes);
      }
    } else {
      await performSave(bytes);
    }
  }

  Future<void> _shareImage() async {
    final bytes = await _getBytes();
    if (bytes == null) return;
    Future<void> performShare(Uint8List finalBytes) async {
      setState(() {
        _isSharing = true;
      });

      try {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);

        await file.writeAsBytes(finalBytes);

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

    final isPremium = Provider.of<CreditManager>(context, listen: false).hasPurchased;

    if (!isPremium) {
      final watermarkedBytes = await ImageUtils.addWatermarkToBytes(bytes);
      await performShare(watermarkedBytes);
    } else {
      await performShare(bytes);
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
                    icon: Icon(
                      AppTheme.backButtonIcon,
                      color: Colors.white,
                      size: AppTheme.backButtonIconSize(context),
                    ),
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
                  child: widget.imageData != null 
                      ? Image.memory(widget.imageData!, fit: BoxFit.contain)
                      : Image.network(widget.imageUrl!, fit: BoxFit.contain),
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
