import 'dart:typed_data';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../provider/auth_provider.dart';
import '../services/database_services.dart';
import '../widgets/full_screen_view.dart';
import '../widgets/history_card.dart';
import '../widgets/loading_overlay.dart';

class HistoryScreen extends StatefulWidget {
  final bool showBackButton;
  const HistoryScreen({super.key, this.showBackButton = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _historyItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String? _error;

  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Interior',
    'Exterior',
    'Wall Design',
    'Floor Design',
    'Object Remove',
    'Replace',
    'Fill Space',
    'Reference Transform',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistoryItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _dbHelper.getAllImages();
      setState(() {
        _historyItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredItems = _historyItems;
      } else {
        _filteredItems = _historyItems.where((item) {
          final itemCategory = item['category']?.toString().toLowerCase() ?? '';
          final selectedCategory = category.toLowerCase();

          if (itemCategory == selectedCategory) {
            return true;
          }

          if (selectedCategory == 'interior') {
            if (itemCategory.isEmpty) {
              final name = item['name']?.toString().toLowerCase() ?? '';
              final desc = item['description']?.toString().toLowerCase() ?? '';
              if (!name.contains('exterior') && !name.contains('wall design') &&
                  !name.contains('floor design') && !name.contains('object removal') &&
                  !desc.contains('exterior') && !desc.contains('wall design') &&
                  !desc.contains('floor design') && !desc.contains('object removal')) {
                return true;
              }
            }
            return itemCategory == 'interior';
          }

          return itemCategory.contains(selectedCategory);
        }).toList();
      }
    });
  }

  void _deleteItem(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: Text(
          'Delete Item',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
          style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveSize(context, phone: 16, tablet: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _dbHelper.deleteImage(id);
                await _loadHistoryItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToCommunity(Map<String, dynamic> item, Uint8List? imageData) async {
    if (imageData == null || imageData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image data found to share.')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.getFirebaseUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to share with community.')),
      );
      return;
    }

    LoadingOverlay.show(context, message: 'Sharing to Community...');

    try {
      // 1. Check if already shared (using local SQLite column)
      if (item['is_public'] == 1) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This masterpiece is already in the community!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        return;
      }

      // Check Firestore as fallback (using local ID as a reference)
      final existing = await FirebaseFirestore.instance
          .collection('images')
          .where('original_history_id', isEqualTo: item['id'])
          .where('uid', isEqualTo: user.uid)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update local database to match Firestore ground truth
        await _dbHelper.updateImagePublicStatus(item['id'] as int, true);
        
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This image has already been shared!')),
        );
        _loadHistoryItems(); // Refresh UI
        return;
      }

      // 2. Upload to S3 API (similar to ImageStorageService)
      final apiUrl = dotenv.env['S3_UPLOAD_URL'] ?? 'https://s3-upload.mirdemy.com/upload';
      final apiKey = dotenv.env['S3_API_KEY'] ?? '';

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['x-api-key'] = apiKey;
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageData,
        filename: 'community_${DateTime.now().millisecondsSinceEpoch}.png',
        contentType: MediaType('image', 'png'),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String? uploadedUrl = data['url'];

        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          // 3. Save to Firestore as Public
          await FirebaseFirestore.instance.collection('images').add({
            'uid': user.uid,
            'url': uploadedUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'isPublic': true,
            'original_history_id': item['id'],
            'type': 'community_share',
            'favBy': [],
            'userName': user.displayName ?? 'AI Designer',
            'userPhoto': user.photoURL,
          });

          // 4. Update local SQLite ground truth
          await _dbHelper.updateImagePublicStatus(item['id'] as int, true);

          if (mounted) {
            LoadingOverlay.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Masterpiece shared with community!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadHistoryItems(); // Refresh UI to show updated status
          }
        } else {
          throw Exception('Failed to get upload URL');
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openFullScreenImage(Map<String, dynamic> item) {
    final dynamic imageDataValue = item['image_data'];
    Uint8List? imageData;

    if (imageDataValue is Uint8List) {
      imageData = imageDataValue;
    } else if (imageDataValue is List<int>) {
      imageData = Uint8List.fromList(imageDataValue);
    }

    if (imageData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
            imageData: imageData!,
            title: item['name']?.toString() ?? 'AI Design',
            description: item['description']?.toString() ?? '',
          ),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return Icons.all_inclusive;
      case 'Interior':
        return Icons.room;
      case 'Exterior':
        return Icons.house;
      case 'Wall Design':
        return Icons.wallpaper;
      case 'Floor Design':
        return Icons.square_foot;
      case 'Object Remove':
        return Icons.remove_circle;
      case 'Replace':
        return Icons.swap_horiz;
      case 'Fill Space':
        return Icons.auto_fix_high;
      case 'Reference Transform':
        return Icons.compare_arrows;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    final isLargeDesktop = screenWidth >= 1200;

    int getCrossAxisCount() {
      if (isLargeDesktop) return 4;
      if (isDesktop) return 3;
      if (isTablet) return 2;
      return 2;
    }

    double getGridSpacing() {
      if (isDesktop) return 16.0;
      if (isTablet) return 12.0;
      return 8.0;
    }

    EdgeInsets getPadding() {
      if (isDesktop) return const EdgeInsets.all(20.0);
      if (isTablet) return const EdgeInsets.all(16.0);
      return const EdgeInsets.all(12.0);
    }

    double getChildAspectRatio() {
      if (isDesktop) return isPortrait ? 0.85 : 1.0;
      return isPortrait ? 0.8 : 0.9;
    }

    double getCategoryItemWidth() {
      if (isDesktop) return 120.0;
      if (isTablet) return 100.0;
      return 80.0;
    }

    final double categoriesSectionHeight =
    AppTheme.responsiveSize(context, phone: 110, tablet: 100);

    double getExpandedHeight() {
      final double topPadding = MediaQuery.of(context).padding.top;
      final double appBarHeight = kToolbarHeight;
      return topPadding + appBarHeight + categoriesSectionHeight;
    }

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: Text(
          'Recent Images',
          style: AppTheme.appBarTitleStyle(context).copyWith(color: AppTheme.primaryColor),
        ),
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton ? IconButton(
          icon: Icon(
            AppTheme.backButtonIcon,
            size: AppTheme.backButtonIconSize(context),
          ),
          onPressed: () => Navigator.pop(context),
        ) : null,
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.secondaryColor,
            height: categoriesSectionHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.responsiveSize(context, phone: 12, tablet: 18),
                vertical: AppTheme.responsiveSize(context, phone: 8, tablet: 10),
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () => _filterByCategory(category),
                  child: Container(
                    width: getCategoryItemWidth(),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(context, phone: 4, tablet: 8),
                    ),
                    padding: EdgeInsets.all(
                      AppTheme.responsiveSize(context, phone: 8, tablet: 10),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                      ),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                        width: isSelected
                            ? AppTheme.responsiveSize(context, phone: 1.5, tablet: 2)
                            : AppTheme.responsiveSize(context, phone: 1, tablet: 1.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: isSelected ? Colors.white : Colors.grey,
                          size: AppTheme.responsiveSize(context, phone: 18, tablet: 24),
                        ),
                        SizedBox(
                          height: AppTheme.responsiveSize(context, phone: 4, tablet: 6),
                        ),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: AppTheme.responsiveFont(context, phone: 11, tablet: 13),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: EdgeInsets.only(
              left: isTablet || isDesktop ? 20 : 16,
              right: isTablet || isDesktop ? 20 : 16,
              top: 8,
              bottom: 12,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isTablet || isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredItems.length} items',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isTablet || isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              color: Colors.white,
              child: _isLoading
                  ? GridView.builder(
                      padding: getPadding(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(),
                        crossAxisSpacing: getGridSpacing(),
                        mainAxisSpacing: getGridSpacing(),
                        childAspectRatio: getChildAspectRatio(),
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      },
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: getPadding(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading history',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: isTablet || isDesktop ? 18.0 : 16.0,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isTablet || isDesktop ? 14.0 : 12.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            SizedBox(
                              height: 48.0,
                              width: screenWidth * 0.4,
                              child: ElevatedButton(
                                onPressed: _loadHistoryItems,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: isTablet || isDesktop ? 16.0 : 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: getPadding(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: isTablet || isDesktop ? 80 : 60,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isTablet || isDesktop ? 20.0 : 18.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different category',
                              style: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.7),
                                fontSize: isTablet || isDesktop ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: getPadding(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(),
                        crossAxisSpacing: getGridSpacing(),
                        mainAxisSpacing: getGridSpacing(),
                        childAspectRatio: getChildAspectRatio(),
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final dynamic imageDataValue = item['image_data'];
                        Uint8List? imageData;

                        if (imageDataValue is Uint8List) {
                          imageData = imageDataValue;
                        } else if (imageDataValue is List<int>) {
                          imageData = Uint8List.fromList(imageDataValue);
                        }

                        return HistoryCardWidget(
                          imageData: imageData,
                          title: item['name']?.toString() ?? 'AI Design',
                          date: item['created_at']?.toString() ?? '',
                          onTap: () => _openFullScreenImage(item),
                          onDelete: () => _deleteItem(item['id'] as int),
                          onShare: () => _shareToCommunity(item, imageData),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}