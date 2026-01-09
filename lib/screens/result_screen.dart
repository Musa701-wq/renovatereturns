import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../services/database_services.dart';
import '../widgets/create_new_button.dart';
import '../widgets/save_button.dart';
import '../widgets/share_button.dart';
import '../widgets/full_screen_view.dart';

class ResultScreen extends StatefulWidget {
  final String generatedImageUrl;
  final String roomType;
  final String style;
  final String budget;
  final String prompt;
  final String? beforeImageUrl;

  const ResultScreen({
    super.key,
    required this.generatedImageUrl,
    required this.roomType,
    required this.style,
    required this.budget,
    required this.prompt,
    this.beforeImageUrl,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSharing = false;
  bool _isAutoSaved = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future _loadImage() async {
    _imageBytes = await _getImageBytes();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _autoSaveImage();
    }
  }

  Future<Uint8List?> _getImageBytes() async {
    try {
      if (widget.generatedImageUrl.startsWith('data:image')) {
        String base64Data = widget.generatedImageUrl.split(',').last;
        return base64Decode(base64Data);
      } else if (widget.generatedImageUrl.startsWith('http')) {
        final response = await HttpClient()
            .getUrl(Uri.parse(widget.generatedImageUrl));
        final res = await response.close();
        return await consolidateHttpClientResponseBytes(res);
      }
    } catch (e) {
      print('Image bytes error: $e');
    }
    return null;
  }

  Future _autoSaveImage() async {
    try {
      if (_isAutoSaved || _imageBytes == null) return;

      // Determine category based on style and roomType
      String category = _determineCategory();

      await _dbHelper.insertImage(
        name: '${widget.roomType} - ${widget.style}',
        imageData: _imageBytes!,
        description: 'Budget: ${widget.budget}\nPrompt: ${widget.prompt}',
        category: category,
      );
      _isAutoSaved = true;
      print('Auto-saved to database with category: $category');
    } catch (e) {
      print('Auto save error: $e');
    }
  }

  Future _saveDesign() async {
    if (_imageBytes == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ImageGallerySaver.saveImage(
        _imageBytes!,
        name: 'AI_Design_${DateTime.now().millisecondsSinceEpoch}.png',
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Design saved to Photos!'),
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

  Future _shareDesign() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image to share'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/ai_design_$timestamp.png';
      final file = File(imagePath);

      await file.writeAsBytes(_imageBytes!);

      if (!await file.exists()) {
        throw Exception('Failed to create temporary file');
      }

      final xFile = XFile(imagePath);

      if (Platform.isAndroid || Platform.isIOS) {
        await Share.shareXFiles([xFile]);
      } else {
        await Share.share('AI Generated Design Image');
      }

      Future.delayed(const Duration(seconds: 10), () async {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting temp file: $e');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Image shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Share error: $e');
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

  void _generateAnother() {
    Navigator.pop(context);
  }

  void _openFullScreenImage() {
    if (_imageBytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageData: _imageBytes!,
            title: '${widget.roomType} - ${widget.style}',
            description: 'Budget: ${widget.budget}\nPrompt: ${widget.prompt}',
          ),
        ),
      );
    }
  }

  String _determineCategory() {
    // Check style first
    if (widget.style.toLowerCase().contains('exterior')) {
      return 'Exterior';
    } else if (widget.style.toLowerCase().contains('floor design')) {
      return 'Floor Design';
    }
    else if (widget.style.toLowerCase().contains('style transfer') ||
        widget.roomType.toLowerCase() == 'reference transform') {
      return 'Reference Transform';
    }
    else if (widget.style.toLowerCase().contains('wall design')) {
      return 'Wall Design';
    } else if (widget.style.toLowerCase().contains('object replacement') ||
        widget.roomType.toLowerCase() == 'replace') {
      return 'Replace';
    } else if (widget.style.toLowerCase().contains('space filling') ||
        widget.roomType.toLowerCase() == 'fill space') {
      return 'Fill Space';
    } else if (widget.roomType.toLowerCase().contains('object removal')) {
      return 'Object Remove';
    }
    // Default to Interior for instant redesign
    return 'Interior';
  }
  Widget _buildImageDisplay() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Loading Design...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (widget.generatedImageUrl.startsWith('data:image')) {
      try {
        String base64Data = widget.generatedImageUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        print('Error displaying base64 image: $e');
        return _buildGeneratedDesign();
      }
    } else if (widget.generatedImageUrl.startsWith('http')) {
      return Image.network(
        widget.generatedImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildGeneratedDesign();
        },
      );
    } else {
      return _buildGeneratedDesign();
    }
  }

  Widget _buildGeneratedDesign() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                const Text(
                  'AI Design',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI Design Generated!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.roomType,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.style} Style • ${widget.budget} Budget',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text('AI Generated Design'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
/*
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showPromptDetails,
          ),
*/
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),
                  GestureDetector(
                    onTap: _openFullScreenImage,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: AppTheme.responsivePadding(context)),
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.responsiveSize(context, phone: 20, tablet: 26),
                        horizontal: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.tilescolor,
                        borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 20, tablet: 24)),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: AppTheme.responsiveSize(context, phone: 2, tablet: 3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: AppTheme.responsiveSize(context, phone: 15, tablet: 20)),
                            child: Text(
                              'After',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 22),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                            child: Container(
                              width: double.infinity,
                              height: AppTheme.responsiveSize(context, phone: 300, tablet: 380),
                              color: Colors.white.withOpacity(0.1),
                              child: _buildImageDisplay(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 26)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.responsivePadding(context)),
                    child: Row(
                      children: [
                        _buildDetailItem('Room', widget.roomType),
                        _buildDetailItem('Style', widget.style),
                        _buildDetailItem('Budget', widget.budget),
                      ],
                    ),
                  ),
                  SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 26)),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 20, tablet: 26)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.responsiveSize(context, phone: 25, tablet: 30)),
                topRight: Radius.circular(AppTheme.responsiveSize(context, phone: 25, tablet: 30)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SaveButton(
                        isLoading: _isSaving,
                        onPressed: _saveDesign,
                      ),
                    ),
                    SizedBox(width: AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                    Expanded(
                      child: ShareButton(
                        isLoading: _isSharing,
                        onPressed: _shareDesign,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.responsiveSize(context, phone: 15, tablet: 20)),
                CreateAnotherButton(
                  onPressed: _generateAnother,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}