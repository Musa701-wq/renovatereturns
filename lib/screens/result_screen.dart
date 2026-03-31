import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../services/database_services.dart';
import '../services/image_utils.dart';
import '../in_app_purchase/credit_manager.dart';
import '../widgets/watermark_upsell_dialog.dart';
import '../widgets/create_new_button.dart';
import 'package:provider/provider.dart';
import '../provider/upload_provider.dart';
import '../widgets/save_button.dart';
import '../widgets/share_button.dart';
import '../widgets/full_screen_view.dart';
import '../widgets/before_after_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatefulWidget {
  final List<String> generatedImageUrls;
  final String roomType;
  final String style;
  final String budget;
  final String prompt;
  final String? beforeImageUrl;

  const ResultScreen({
    super.key,
    required this.generatedImageUrls,
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
  bool _isLoading = false;
  bool _isAutoSaved = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Uint8List?> _imagesBytes = [];
  String? _autoBeforeImageUrl;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _autoBeforeImageUrl =
        widget.beforeImageUrl ??
        Provider.of<UploadProvider>(context, listen: false).selectedImage?.path;
    _loadImage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future _loadImage() async {
    setState(() => _isLoading = true);
    for (String url in widget.generatedImageUrls) {
      Uint8List? bytes = await _getImageBytesFromUrl(url);
      _imagesBytes.add(bytes);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _autoSaveImages();
    }
  }

  Future<Uint8List?> _getImageBytesFromUrl(String url) async {
    try {
      if (url.startsWith('data:image')) {
        String base64Data = url.split(',').last;
        return base64Decode(base64Data);
      } else if (url.startsWith('http')) {
        final response = await HttpClient().getUrl(Uri.parse(url));
        final res = await response.close();
        return await consolidateHttpClientResponseBytes(res);
      }
    } catch (e) {
      print('Image bytes error for $url: $e');
    }
    return null;
  }

  Future _autoSaveImages() async {
    try {
      if (_isAutoSaved || _imagesBytes.isEmpty) return;

      String category = _determineCategory();
      
      final prefs = await SharedPreferences.getInstance();
      final bool isPublic = prefs.getBool('share_to_community') ?? true;

      for (int i = 0; i < _imagesBytes.length; i++) {
        if (_imagesBytes[i] == null) continue;

        await _dbHelper.insertImage(
          name:
              '${widget.roomType} - ${widget.style} ${widget.generatedImageUrls.length > 1 ? "(Var ${i + 1})" : ""}',
          imageData: _imagesBytes[i]!,
          description: 'Budget: ${widget.budget}\nPrompt: ${widget.prompt}',
          category: category,
          isPublic: isPublic,
        );
      }
      _isAutoSaved = true;
    } catch (e) {
      print('Auto save error: $e');
    }
  }

  Future _saveDesign(Uint8List? bytes) async {
    if (bytes == null) return;

    Future<void> performSave(Uint8List finalBytes) async {
      try {
        final result = await ImageGallerySaver.saveImage(
          finalBytes,
          name: 'AI_Design_${DateTime.now().millisecondsSinceEpoch}.png',
          quality: 100,
        );

        if (mounted) {
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
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
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
      // If result is null (closed), do nothing (no performSave called)
    } else {
      await performSave(bytes);
    }
  }

  Future _shareDesign(Uint8List? bytes) async {
    if (bytes == null) return;

    Future<void> performShare(Uint8List finalBytes) async {
      try {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imagePath = '${directory.path}/ai_design_$timestamp.png';
        final file = File(imagePath);

        await file.writeAsBytes(finalBytes);

        final xFile = XFile(imagePath);
        await Share.shareXFiles([xFile]);

        Future.delayed(const Duration(seconds: 10), () async {
          if (await file.exists()) await file.delete();
        });
      } catch (e) {
        print('Share error: $e');
      }
    }

    final isPremium = Provider.of<CreditManager>(context, listen: false).hasPurchased;

    if (!isPremium) {
      // Auto-watermark for share with no dialog as requested
      final watermarkedBytes = await ImageUtils.addWatermarkToBytes(bytes);
      await performShare(watermarkedBytes);
    } else {
      await performShare(bytes);
    }
  }

  void _generateAnother() {
    Navigator.pop(context);
  }

  void _openFullScreenImage(Uint8List? bytes) {
    if (bytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageData: bytes,
            title: '${widget.roomType} - ${widget.style}',
            description: 'Budget: ${widget.budget}\nPrompt: ${widget.prompt}',
          ),
        ),
      );
    }
  }

  String _determineCategory() {
    String styleLower = widget.style.toLowerCase();
    String roomLower = widget.roomType.toLowerCase();

    if (styleLower.contains('exterior')) return 'Exterior';
    if (styleLower.contains('floor design')) return 'Floor Design';
    if (styleLower.contains('style transfer') ||
        roomLower == 'reference transform')
      return 'Reference Transform';
    if (styleLower.contains('wall design')) return 'Wall Design';
    if (styleLower.contains('object replacement') || roomLower == 'replace')
      return 'Replace';
    if (styleLower.contains('space filling') || roomLower == 'fill space')
      return 'Fill Space';
    if (roomLower.contains('object removal')) return 'Object Remove';

    return 'Interior';
  }

  @override
  Widget build(BuildContext context) {
    bool isMultiple = widget.generatedImageUrls.length > 1;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: Text(
          isMultiple ? 'Design Variations' : 'AI Generated Design',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 24),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.secondaryColor,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: AppTheme.primaryColor,
            size: AppTheme.backButtonIconSize(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : isMultiple
                ? _buildMultipleVariationsUI()
                : _buildSingleResultUI(),
          ),
          if (!_isLoading) _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(
            radius: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Refining your designs...',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleVariationsUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Variation ${_currentPage + 1} of ${widget.generatedImageUrls.length}',
            style: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.generatedImageUrls.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildVariationPage(index);
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildPageIndicator(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVariationPage(int index) {
    Uint8List? bytes = _imagesBytes.length > index ? _imagesBytes[index] : null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.responsivePadding(context),
      ),
      child: GestureDetector(
        onTap: () => _openFullScreenImage(bytes),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.tilescolor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _currentPageContent(index, bytes),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleResultUI() {
    Uint8List? bytes = _imagesBytes.isNotEmpty ? _imagesBytes[0] : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            height: AppTheme.responsiveSize(context, phone: 20, tablet: 30),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.responsivePadding(context),
            ),
            child: GestureDetector(
              onTap: () => _openFullScreenImage(bytes),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.tilescolor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryColor, width: 2.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: _currentPageContent(0, bytes),
                ),
              ),
            ),
          ),
          if (widget.roomType != 'Partial Remodel') ...[
            SizedBox(height: 25),
            _buildDetailsRow(),
          ],
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _currentPageContent(int index, Uint8List? bytes) {
    if (_autoBeforeImageUrl != null && widget.generatedImageUrls.length == 1) {
      return BeforeAfterSlider(
        beforeImageUrl: _autoBeforeImageUrl,
        afterImage: bytes ?? widget.generatedImageUrls[index],
        height: AppTheme.responsiveSize(context, phone: 350, tablet: 450),
      );
    }
    return SizedBox(
      height: AppTheme.responsiveSize(context, phone: 350, tablet: 450),
      child: _buildImageContent(index, bytes),
    );
  }

  Widget _buildImageContent(int index, Uint8List? bytes) {
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity);
    }

    String url = widget.generatedImageUrls[index];
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (_, child, prog) => prog == null
            ? child
            : const Center(child: CupertinoActivityIndicator()),
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 50,
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.generatedImageUrls.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsRow() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.responsivePadding(context),
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem('Room', widget.roomType),
          _buildDetailItem('Style', widget.style),
          _buildDetailItem(
            'Budget',
            widget.budget == "Not Specified" ? "-" : widget.budget,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.primaryColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    Uint8List? currentBytes = _imagesBytes.length > _currentPage
        ? _imagesBytes[_currentPage]
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        15,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SaveButton(
                  isLoading: false,
                  onPressed: () => _saveDesign(currentBytes),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ShareButton(
                  isLoading: false,
                  onPressed: () => _shareDesign(currentBytes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          CreateAnotherButton(onPressed: _generateAnother),
        ],
      ),
    );
  }
}
