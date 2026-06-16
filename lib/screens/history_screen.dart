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
import '../provider/image_provider.dart';
import '../services/backend_api_service.dart';
import '../models/image_model.dart';

class HistoryScreen extends StatefulWidget {
  final bool showBackButton;
  const HistoryScreen({super.key, this.showBackButton = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ImageComparison> _filteredItems = [];
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
      final imageProvider = Provider.of<ImageDataProvider>(context, listen: false);
      await imageProvider.fetchHistory();
      
      if (mounted) {
        setState(() {
          _filteredItems = imageProvider.historyList;
          _isLoading = false;
        });
        // Apply current filter after load
        _filterByCategory(_selectedCategory);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      final allItems = Provider.of<ImageDataProvider>(context, listen: false).historyList;
      
      if (category == 'All') {
        _filteredItems = allItems;
      } else {
        _filteredItems = allItems.where((item) {
          final itemCategory = item.subtitle.toLowerCase();
          final selectedCategory = category.toLowerCase();

          return itemCategory.contains(selectedCategory) || 
                 selectedCategory.contains(itemCategory);
        }).toList();
      }
    });
  }

  void _deleteItem(ImageComparison item) {
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
                final imageProvider = Provider.of<ImageDataProvider>(context, listen: false);
                
                // 1. Remove locally immediately for better UI feedback
                if (mounted) {
                  setState(() {
                    _filteredItems.removeWhere((i) => i.id == item.id);
                  });
                }

                final backendId = item.id;
                if (backendId != null) {
                  print('🗑️ Deleting from backend: $backendId');
                  await BackendApiService.deleteHistory(backendId);
                }
                
                // 2. Refresh the provider in background
                imageProvider.fetchHistory();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  Future<void> _shareToCommunity(ImageComparison item) async {
    if (item.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot share: Image ID missing.')),
      );
      return;
    }

    if (item.isPublic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This image is already in the Community Gallery.')),
      );
      return;
    }

    LoadingOverlay.show(context, message: 'Sharing to Community...');

    try {
      final success = await BackendApiService.shareHistory(item.id!);

      if (mounted) {
        LoadingOverlay.hide(context);
        if (success) {
          setState(() {
            item.isPublic = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Design shared with community!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh gallery in background
          Provider.of<ImageDataProvider>(context, listen: false).fetchPublicGallery();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share design. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  void _openFullScreenImage(ImageComparison item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: item.afterImage,
          title: item.title,
          description: item.subtitle,
        ),
      ),
    );
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
                Consumer<ImageDataProvider>(
                  builder: (context, imageProvider, _) => Text(
                    '${imageProvider.historyList.length} items',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isTablet || isDesktop ? 14 : 12,
                    ),
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
                  : Consumer<ImageDataProvider>(
                      builder: (context, imageProvider, child) {
                        final historyItems = _filteredItems;

                        if (historyItems.isEmpty && !_isLoading) {
                          return _buildEmptyState(isTablet, isDesktop);
                        }

                        // Default flat grid (reverted from grouped view)
                        return GridView.builder(
                          padding: getPadding(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: getCrossAxisCount(),
                            crossAxisSpacing: getGridSpacing(),
                            mainAxisSpacing: getGridSpacing(),
                            childAspectRatio: getChildAspectRatio(),
                          ),
                          itemCount: historyItems.length,
                          itemBuilder: (context, index) {
                            final item = historyItems[index];

                            return HistoryCardWidget(
                              imageUrl: item.afterImage,
                              title: item.title,
                              date: 'Recently',
                              onTap: () => _openFullScreenImage(item),
                              onDelete: () => _deleteItem(item),
                              onShare: () => _shareToCommunity(item),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
              'Start generating some designs!',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: isTablet || isDesktop ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}