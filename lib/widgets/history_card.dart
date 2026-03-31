import 'dart:typed_data';
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';

class HistoryCardWidget extends StatelessWidget {
  final Uint8List? imageData;
  final String title;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onShare;
  final bool isSelected;

  const HistoryCardWidget({
    super.key,
    required this.imageData,
    required this.title,
    required this.date,
    required this.onTap,
    required this.onDelete,
    this.onShare,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // MAIN CARD WITH IMAGE
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppTheme.responsiveSize(context, phone: 15, tablet: 20),
              ),
              border: Border.all(
                color: isSelected
                    ? Colors.green
                    : AppTheme.primaryColor,
                width: isSelected
                    ? AppTheme.responsiveSize(context, phone: 2, tablet: 3)
                    : AppTheme.responsiveSize(context, phone: 3, tablet: 4),
              ),
            ),
            child: Stack(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppTheme.responsiveSize(context, phone: 12, tablet: 16),
                  ),
                  child: imageData != null && imageData!.isNotEmpty
                      ? Image.memory(
                    imageData!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorWidget(context);
                    },
                  )
                      : _buildPlaceholderWidget(context),
                ),

                // FOOTER INSIDE IMAGE
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(context, phone: 5, tablet: 8),
                      vertical: AppTheme.responsiveSize(context, phone: 5, tablet: 8),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      border: Border.all(
                        color: Colors.white,
                        width: AppTheme.responsiveSize(context, phone: 1, tablet: 1.5),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.responsiveSize(context, phone: 15, tablet: 20),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(context, phone: 8, tablet: 12),
                      vertical: AppTheme.responsiveSize(context, phone: 3, tablet: 6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE
                        Text(
                          _formatTitle(title),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: AppTheme.responsiveSize(context, phone: 2, tablet: 4)),

                        // DATE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [


                            Text(
                              _formatDate(date),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: AppTheme.responsiveFont(context, phone: 10, tablet: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ACTION BUTTON (Three Dots)
          Positioned(
            top: AppTheme.responsiveSize(context, phone: 8, tablet: 12),
            right: AppTheme.responsiveSize(context, phone: 8, tablet: 12),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'share') {
                  onShare?.call();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              icon: Container(
                padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 4, tablet: 6)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: AppTheme.responsiveSize(context, phone: 18, tablet: 22),
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text('Share to Community'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white,
          size: AppTheme.responsiveSize(context, phone: 40, tablet: 52),
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white,
          size: AppTheme.responsiveSize(context, phone: 40, tablet: 52),
        ),
      ),
    );
  }

  String _formatTitle(String name) {
    if (name.length > 25) {
      return '${name.substring(0, 25)}...';
    }
    return name;
  }

  String _formatDate(String date) {
    try {
      if (date.isEmpty) return 'Unknown Date';
      final parsedDate = DateTime.parse(date);
      final day = parsedDate.day.toString().padLeft(2, '0');
      final month = parsedDate.month.toString().padLeft(2, '0');
      final year = parsedDate.year.toString();
      return '$day/$month/$year';
    } catch (e) {
      return date;
    }
  }
}