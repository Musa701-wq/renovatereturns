/*

import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ComparisonCardWidget extends StatefulWidget {
  final String beforeImage;
  final String afterImage;
  final String title;
  final String subtitle;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final VoidCallback onArrowPressed;
  final IconData? categoryIcon;
  final List<String>? tags;

  const ComparisonCardWidget({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    required this.title,
    required this.subtitle,
    required this.isLiked,
    required this.onLikePressed,
    required this.onArrowPressed,
    this.categoryIcon = Icons.home_repair_service,
    this.tags,
  });

  @override
  State<ComparisonCardWidget> createState() => _ComparisonCardWidgetState();
}

class _ComparisonCardWidgetState extends State<ComparisonCardWidget> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onArrowPressed();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 160, // ✅ HEIGHT REDUCED from 220 to 160
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // ✅ Reduced from 24
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 2.0, // ✅ Reduced from 3.0
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18), // ✅ Reduced from 21
            child: Stack(
              children: [
                // BEFORE IMAGE - Full card background
                Positioned.fill(
                  child: Stack(
                    children: [
                      Image.network(
                        widget.beforeImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppTheme.primaryColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.error, color: Colors.white),
                          );
                        },
                      ),
                      // Overlay
                      Container(
                        decoration: BoxDecoration(
                          color: isPressed
                              ? const Color(0xFF833b61).withOpacity(0.7)
                              : Colors.black.withOpacity(0.5),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // ✅ Reduced blur
                          child: Container(
                            color: isPressed
                                ? const Color(0xFF833b61).withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // AFTER IMAGE - Left side in frame
                Positioned(
                  left: 10, // ✅ Reduced from 12
                  top: 10, // ✅ Reduced from 12
                  bottom: 10, // ✅ Reduced from 12
                  width: MediaQuery.of(context).size.width * 0.32, // ✅ Reduced from 0.35
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16), // ✅ Reduced from 20
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppTheme.primaryColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2), // ✅ Reduced from 3
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14), // ✅ Reduced from 18
                        child: Image.network(
                          widget.afterImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.error, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // RIGHT SIDE CONTENT
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.54, // ✅ Increased from 0.52
                  child: Padding(
                    padding: const EdgeInsets.all(15), // ✅ Reduced from 20
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon in circle - Smaller
                        Container(
                          padding: const EdgeInsets.all(8), // ✅ Reduced from 10
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.categoryIcon,
                            color: const Color(0xFF8B5A7C),
                            size: 20, // ✅ Reduced from 24
                          ),
                        ),

                        const SizedBox(height: 10), // ✅ Reduced from 16

                        // Title - Smaller font
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18, // ✅ Reduced from 22
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2, // ✅ Limit to 2 lines
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6), // ✅ Reduced from 8

                        // Subtitle - Smaller font
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 11, // ✅ Reduced from 13
                            color: Colors.white.withOpacity(0.95),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2, // ✅ Limit to 2 lines
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8), // ✅ Reduced from 12

                        // Tags - Smaller
                        if (widget.tags != null && widget.tags!.isNotEmpty)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, // ✅ Reduced from 12
                                vertical: 4, // ✅ Reduced from 6
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 0.8, // ✅ Reduced from 1
                                ),
                                borderRadius: BorderRadius.circular(15), // ✅ Reduced from 20
                              ),
                              child: Text(
                                widget.tags!.join(', '),
                                style: TextStyle(
                                  fontSize: 9, // ✅ Reduced from 11
                                  color: Colors.white.withOpacity(0.95),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
/*
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ComparisonCardWidget extends StatefulWidget {
  final String beforeImage;
  final String afterImage;
  final String title;
  final String subtitle;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final VoidCallback onArrowPressed;
  final IconData? categoryIcon;
  final List<String>? tags;

  const ComparisonCardWidget({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    required this.title,
    required this.subtitle,
    required this.isLiked,
    required this.onLikePressed,
    required this.onArrowPressed,
    this.categoryIcon = Icons.home_repair_service,
    this.tags,
  });

  @override
  State<ComparisonCardWidget> createState() => _ComparisonCardWidgetState();
}

class _ComparisonCardWidgetState extends State<ComparisonCardWidget> {
  bool isPressed = false;

  // Helper function to check if image is from assets
  bool isAssetImage(String imagePath) {
    return imagePath.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    // Media query for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 375;
    final bool isTablet = screenWidth >= 600;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onArrowPressed();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.0 : isTablet ? 20.0 : 16.0,
        ),
        height: isSmallScreen ? 140.0 : isTablet ? 220.0 : 160.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 16.0 : isTablet ? 24.0 : 20.0,
            ),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: isSmallScreen ? 1.5 : 2.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 14.0 : isTablet ? 22.0 : 18.0,
            ),
            child: Stack(
              children: [
                // BEFORE IMAGE - Full card background
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Check if image is from assets or network
                      isAssetImage(widget.beforeImage)
                          ? Image.asset(
                        widget.beforeImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: isSmallScreen ? 24.0 : 32.0,
                            ),
                          );
                        },
                      )
                          : Image.network(
                        widget.beforeImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppTheme.primaryColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: isSmallScreen ? 24.0 : 32.0,
                            ),
                          );
                        },
                      ),

                      // Overlay
                      Container(
                        decoration: BoxDecoration(
                          color: isPressed
                              ? const Color(0xFF833b61).withOpacity(0.7)
                              : Colors.black.withOpacity(0.5),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: isPressed
                                ? const Color(0xFF833b61).withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // AFTER IMAGE - Left side in frame
                Positioned(
                  left: isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0,
                  top: isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0,
                  bottom: isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0,
                  width: MediaQuery.of(context).size.width * (isSmallScreen ? 0.34 : isTablet ? 0.30 : 0.32),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 12.0 : isTablet ? 18.0 : 16.0,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppTheme.primaryColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 1.5 : 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 10.0 : isTablet ? 16.0 : 14.0,
                        ),
                        child: isAssetImage(widget.afterImage)
                            ? Image.asset(
                          widget.afterImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.error,
                                color: Colors.white,
                                size: isSmallScreen ? 24.0 : 32.0,
                              ),
                            );
                          },
                        )
                            : Image.network(
                          widget.afterImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.error,
                                color: Colors.white,
                                size: isSmallScreen ? 24.0 : 32.0,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // RIGHT SIDE CONTENT
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * (isSmallScreen ? 0.50 : isTablet ? 0.56 : 0.54),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isSmallScreen ? 10.0 : isTablet ? 24.0 : 15.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon in circle - Responsive size
                        Container(
                          padding: EdgeInsets.all(
                            isSmallScreen ? 6.0 : isTablet ? 10.0 : 8.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.categoryIcon,
                            color: const Color(0xFF8B5A7C),
                            size: isSmallScreen ? 16.0 : isTablet ? 32.0 : 20.0,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 6.0 : isTablet ? 14.0 : 10.0),

                        // Title - Responsive font size
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.0 : isTablet ? 28.0 : 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isSmallScreen ? 4.0 : isTablet ? 8.0 : 6.0),

                        // Subtitle - Responsive font size
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 9.0 : isTablet ? 16.0 : 11.0,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isSmallScreen ? 6.0 : isTablet ? 10.0 : 8.0),

                        // Tags - Responsive
                        if (widget.tags != null && widget.tags!.isNotEmpty)
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6.0 : isTablet ? 10.0 : 8.0,
                                vertical: isSmallScreen ? 3.0 : isTablet ? 6.0 : 4.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: isSmallScreen ? 0.6 : 0.8,
                                ),
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 12.0 : isTablet ? 20.0 : 15.0,
                                ),
                              ),
                              child: Text(
                                widget.tags!.join(', '),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 8.0 : isTablet ? 11.0 : 9.0,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ComparisonCardWidget extends StatefulWidget {
  final String beforeImage;
  final String afterImage;
  final String title;
  final String subtitle;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final VoidCallback onArrowPressed;
  final IconData? categoryIcon;
  final List<String>? tags;

  const ComparisonCardWidget({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    required this.title,
    required this.subtitle,
    required this.isLiked,
    required this.onLikePressed,
    required this.onArrowPressed,
    this.categoryIcon,
    this.tags,
  });

  @override
  State<ComparisonCardWidget> createState() => _ComparisonCardWidgetState();
}

class _ComparisonCardWidgetState extends State<ComparisonCardWidget> {
  bool isPressed = false;

  // Default icon
  static const IconData defaultIcon = Icons.home_repair_service;

  // Helper function to check if image is from assets
  bool isAssetImage(String imagePath) {
    return imagePath.startsWith('assets/');
  }

  // Function to get the icon to display
  IconData getDisplayIcon() {
    // If categoryIcon is provided, use it
    if (widget.categoryIcon != null) {
      return widget.categoryIcon!;
    }
    // Otherwise use default icon
    return defaultIcon;
  }

  @override
  Widget build(BuildContext context) {
    // Get the icon to display
    final IconData displayIcon = getDisplayIcon();

    // Media query for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 375;
    final bool isTablet = screenWidth >= 600;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onArrowPressed();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.0 : isTablet ? 20.0 : 16.0,
        ),
        height: isSmallScreen ? 140.0 : isTablet ? 220.0 : 160.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 16.0 : isTablet ? 24.0 : 20.0,
            ),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: isSmallScreen ? 1.5 : 2.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 14.0 : isTablet ? 22.0 : 18.0,
            ),
            child: Stack(
              children: [
                // BEFORE IMAGE - Full card background
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Check if image is from assets or network
                      isAssetImage(widget.beforeImage)
                          ? Image.asset(
                        widget.beforeImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: isSmallScreen ? 24.0 : 32.0,
                            ),
                          );
                        },
                      )
                          : Image.network(
                        widget.beforeImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppTheme.primaryColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: isSmallScreen ? 24.0 : 32.0,
                            ),
                          );
                        },
                      ),

                      // Overlay
                      Container(
                        decoration: BoxDecoration(
                          color: isPressed
                              ? const Color(0xFF833b61).withOpacity(0.7)
                              : Colors.black.withOpacity(0.5),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: isPressed
                                ? const Color(0xFF833b61).withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // AFTER IMAGE - Left side in frame
                Positioned(
                  left: isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0,
                  top: isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0,
                  bottom: isSmallScreen ? 8.0 : isTablet ? 14.0 : 10.0,
                  width: MediaQuery.of(context).size.width * (isSmallScreen ? 0.34 : isTablet ? 0.30 : 0.32),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 12.0 : isTablet ? 18.0 : 16.0,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppTheme.primaryColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 1.5 : 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 10.0 : isTablet ? 16.0 : 14.0,
                        ),
                        child: isAssetImage(widget.afterImage)
                            ? Image.asset(
                          widget.afterImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.error,
                                color: Colors.white,
                                size: isSmallScreen ? 24.0 : 32.0,
                              ),
                            );
                          },
                        )
                            : Image.network(
                          widget.afterImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Icon(
                                Icons.error,
                                color: Colors.white,
                                size: isSmallScreen ? 24.0 : 32.0,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // RIGHT SIDE CONTENT
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * (isSmallScreen ? 0.50 : isTablet ? 0.56 : 0.54),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isSmallScreen ? 10.0 : isTablet ? 24.0 : 15.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon in circle - Responsive size
                        Container(
                          padding: EdgeInsets.all(
                            isSmallScreen ? 6.0 : isTablet ? 10.0 : 8.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            displayIcon, // Use the displayIcon here
                            color: const Color(0xFF8B5A7C),
                            size: isSmallScreen ? 16.0 : isTablet ? 32.0 : 20.0,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 6.0 : isTablet ? 14.0 : 10.0),

                        // Title - Responsive font size
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.0 : isTablet ? 28.0 : 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isSmallScreen ? 4.0 : isTablet ? 8.0 : 6.0),

                        // Subtitle - Responsive font size
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 9.0 : isTablet ? 16.0 : 11.0,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: isSmallScreen ? 6.0 : isTablet ? 10.0 : 8.0),

                        // Tags - Responsive
                        if (widget.tags != null && widget.tags!.isNotEmpty)
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6.0 : isTablet ? 10.0 : 8.0,
                                vertical: isSmallScreen ? 3.0 : isTablet ? 6.0 : 4.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: isSmallScreen ? 0.6 : 0.8,
                                ),
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 12.0 : isTablet ? 20.0 : 15.0,
                                ),
                              ),
                              child: Text(
                                widget.tags!.join(', '),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 8.0 : isTablet ? 11.0 : 9.0,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}