import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../utils/theme.dart';
import '../services/image_storage_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadCommunityScreen extends StatefulWidget {
  const UploadCommunityScreen({super.key});

  @override
  State<UploadCommunityScreen> createState() => _UploadCommunityScreenState();
}

class _UploadCommunityScreenState extends State<UploadCommunityScreen> {
  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    bool shareEnabled = prefs.getBool('share_to_community') ?? true;

    if (!shareEnabled) {
      if (!mounted) return;
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          title: Text("Community Sharing is OFF", style: TextStyle(color: AppTheme.primaryColor)),
          content: Text("To upload this image, your profile's community sharing toggle must be turned ON. Turn it ON now?", style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7))),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text("Cancel", style: TextStyle(color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text("Turn ON & Upload", style: TextStyle(color: AppTheme.secondaryColor)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        await prefs.setBool('share_to_community', true);
      } else {
        return; // User canceled the dialog
      }
    }

    setState(() => _isUploading = true);

    try {
      final bytes = await _image!.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final creditManager = Provider.of<CreditManager>(context, listen: false);
      
      await ImageStorageService.uploadAndStore(base64String, type: 'uploaded');
      
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Shared to Community!",
          backgroundColor: AppTheme.primaryColor,
          textColor: AppTheme.secondaryColor,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        Fluttertoast.showToast(msg: "Upload failed: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: Text("Upload Custom Image", style: AppTheme.appBarTitleStyle(context)),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Share Your Masterpiece",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Pick an image from your gallery and let the community see your amazing ideas.",
                style: TextStyle(
                  color: AppTheme.primaryColor.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Image Preview / Picker
              Expanded(
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.tilescolor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _image == null ? AppTheme.stokecolor : AppTheme.primaryColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _image != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                              if (!_isUploading)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _image = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 60, color: AppTheme.primaryColor.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                "Tap to select an image",
                                style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7), fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Upload Button
              ElevatedButton(
                onPressed: (_image != null && !_isUploading) ? _uploadImage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: _isUploading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text(
                        "Upload to Community",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
