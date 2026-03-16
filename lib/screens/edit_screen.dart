import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import '../provider/auth_provider.dart';
import '../utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final fileSize = await imageFile.length() / 1024 / 1024; // Size in MB

        if (fileSize > 5) { // Limit to 5MB
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image size too large. Please select an image under 5MB.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _imageToBase64(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  bool _isBase64String(String? data) {
    if (data == null || data.isEmpty) return false;

    // Check if it starts with common base64 image patterns
    if (data.startsWith('/9j/') || // JPEG
        data.startsWith('iVBORw0KGgo') || // PNG
        data.startsWith('R0lGODlh') || // GIF
        data.startsWith('PHN2Zy') || // SVG base64
        data.contains('base64') || // Contains base64 keyword
        data.startsWith('data:image/')) { // Data URL format
      return true;
    }

    // Try to decode it to confirm
    try {
      base64Decode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateProfile() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      String? photoBase64;

      if (_selectedImage != null) {
        photoBase64 = _imageToBase64(_selectedImage!);
      }

      // Only pass name to updateUserProfile, not email
      await auth.updateUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(), // This is just for reference
        photoBase64: photoBase64,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);

    } on FirebaseException catch (e) {
      // Handle Firebase specific errors
      String errorMessage = 'An error occurred';

      if (e.code == 'invalid-argument') {
        errorMessage = 'Invalid data format. Please check your input.';
      } else if (e.code == 'permission-denied') {
        errorMessage = 'You don\'t have permission to update profile.';
      } else if (e.code == 'not-found') {
        errorMessage = 'User document not found.';
      } else {
        errorMessage = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    String? photoData = user?.photoUrl;

    // Media Query for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive calculations
    double getProfileImageSize() {
      if (screenWidth > 800) return 150.0;
      if (screenWidth > 600) return 130.0;
      return 120.0;
    }

    double getIconSize() {
      if (screenWidth > 800) return 22.0;
      if (screenWidth > 600) return 20.0;
      return 18.0;
    }

    double getCameraIconSize() {
      if (screenWidth > 800) return 24.0;
      if (screenWidth > 600) return 22.0;
      return 20.0;
    }

    double getButtonPadding() {
      if (screenWidth > 800) return 18.0;
      if (screenWidth > 600) return 16.0;
      return 14.0;
    }

    double getFontSize() {
      if (screenWidth > 800) return 18.0;
      if (screenWidth > 600) return 16.0;
      return 14.0;
    }

    double getTitleFontSize() {
      if (screenWidth > 800) return 24.0;
      if (screenWidth > 600) return 22.0;
      return 20.0;
    }

    EdgeInsets getScreenPadding() {
      if (screenWidth > 800) {
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 30);
      } else if (screenWidth > 600) {
        return const EdgeInsets.symmetric(horizontal: 30, vertical: 20);
      } else {
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      }
    }

    double getSpacing() {
      if (screenWidth > 800) return 30.0;
      if (screenWidth > 600) return 25.0;
      return 20.0;
    }

    double getTextFieldPadding() {
      if (screenWidth > 800) return 20.0;
      if (screenWidth > 600) return 18.0;
      return 16.0;
    }

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        foregroundColor: AppTheme.primaryColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: getTitleFontSize(),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: AppTheme.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: getScreenPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: getSpacing()),

            // Profile Image with Primary Color Border
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: getProfileImageSize(),
                    height: getProfileImageSize(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: screenWidth > 600 ? 4.0 : 3.0,
                      ),
                    ),
                    child: _buildProfileImage(photoData),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(screenWidth > 600 ? 8.0 : 6.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.secondaryColor,
                          width: screenWidth > 600 ? 3.0 : 2.0,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppTheme.secondaryColor,
                        size: getCameraIconSize(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: getSpacing() * 1.5),

            // Name Field
            Container(
              decoration: BoxDecoration(
                color: AppTheme.tilescolor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
              child: TextFormField(
                controller: _nameController,
                style: TextStyle(
                //  color: AppTheme.secondaryColor,
                  color: AppTheme.primaryColor,
                  fontSize: getFontSize(),
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: getFontSize() * 0.9,
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                  //  color: AppTheme.secondaryColor,
                    color: AppTheme.primaryColor,
                    size: getIconSize(),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: getTextFieldPadding(),
                    vertical: getTextFieldPadding(),
                  ),
                ),
              ),
            ),

            SizedBox(height: getSpacing()),

            // Email Field
            Container(
              decoration: BoxDecoration(
                color: AppTheme.tilescolor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppTheme.stokecolor,
                  width: 1.5,
                ),
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: getFontSize(),
                ),
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: getFontSize() * 0.9,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: AppTheme.primaryColor,
                    size: getIconSize(),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: getTextFieldPadding(),
                    vertical: getTextFieldPadding(),
                  ),
                ),
              ),
            ),

            SizedBox(height: getSpacing() * 2),

            // Save Button with Primary Color and Secondary Foreground
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.secondaryColor,
                  padding: EdgeInsets.symmetric(vertical: getButtonPadding()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: screenWidth > 600 ? 28.0 : 24.0,
                  height: screenWidth > 600 ? 28.0 : 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.secondaryColor,
                  ),
                )
                    : Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: getFontSize() + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Additional Info Text
            Padding(
              padding: EdgeInsets.only(top: getSpacing()),
              child: Text(
                'Note: Email cannot be changed',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: getFontSize() * 0.85,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? photoData) {
    final screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth > 600 ? 60.0 : 50.0;

    if (photoData == null || photoData.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey.withOpacity(0.3),
        child: Icon(
          Icons.person,
          size: iconSize,
          color: AppTheme.secondaryColor,
        ),
      );
    }

    try {
      if (_selectedImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }

      bool isBase64 = _isBase64String(photoData);

      if (isBase64) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.memory(
            base64Decode(photoData),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.3),
                child: Icon(
                  Icons.person,
                  size: iconSize,
                  color: AppTheme.secondaryColor,
                ),
              );
            },
          ),
        );
      } else {
        // It's a URL from Google/Apple login
        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.network(
            photoData,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.3),
                child: Icon(
                  Icons.person,
                  size: iconSize,
                  color: AppTheme.secondaryColor,
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      print('Error loading profile image in edit screen: $e');
      return CircleAvatar(
        backgroundColor: Colors.grey.withOpacity(0.3),
        child: Icon(
          Icons.person,
          size: iconSize,
          color: AppTheme.secondaryColor,
        ),
      );
    }
  }
}
