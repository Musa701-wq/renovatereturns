/*
// widgets/floor_design_card.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FloorDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorDesignCard({
    super.key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // IMAGE CONTAINER - Separate
          Container(
            width: 100,
            height: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover, // Makes image fill the entire container
              ),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),

          // SPACE between image and text container
          const SizedBox(height: 8),

          // TEXT CONTAINER - Separate (below image)
          Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.3), // Primary color with opacity
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: AppTheme.primaryColor, // Primary color text
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}*/
/*
// widgets/floor_design_card.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FloorDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorDesignCard({
    super.key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // IMAGE CONTAINER - Separate with overlay when selected
          Stack(
            children: [
              Container(
                width: 100,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),

              // Black shade overlay when selected
              if (isSelected)
                Container(
                  width: 100,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.3), // Black shade overlay
                  ),
                ),
            ],
          ),

          // SPACE between image and text container
          const SizedBox(height: 8),

          // TEXT CONTAINER - Separate (below image)
          Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.secondaryColor : AppTheme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
*/
// widgets/floor_design_card.dart
/*
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FloorDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorDesignCard({
    super.key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // IMAGE CONTAINER - Separate with overlay when selected
          Stack(
            children: [
              Container(
                width: 100,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3), // Default border with opacity
                    width: 2,
                  ),
                ),
              ),

              // Black shade overlay when selected
              if (isSelected)
                Container(
                  width: 100,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.3), // Black shade overlay
                  ),
                ),
            ],
          ),

          // SPACE between image and text container
          const SizedBox(height: 8),

          // TEXT CONTAINER - Separate (below image)
          Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.secondaryColor : AppTheme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
*/
// widgets/floor_design_card.dart
/*
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FloorDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;


  const FloorDesignCard({
    super.key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // IMAGE CONTAINER - Separate with overlay when selected
          Stack(
            children: [
              // Image with error handling
              Container(
                width: 100,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 30, color: Colors.grey[600]),
                              SizedBox(height: 4),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Black shade overlay when selected
              if (isSelected)
                Container(
                  width: 100,
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
            ],
          ),

          // SPACE between image and text container
          const SizedBox(height: 8),

          // TEXT CONTAINER - Separate (below image)
          Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.secondaryColor : AppTheme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class FloorDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const FloorDesignCard({
    super.key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = AppTheme.responsiveSize(context, phone: 100, tablet: 140);
    final cardHeight = AppTheme.responsiveSize(context, phone: 120, tablet: 160);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              // Image container with safe loading
              Container(
                width: cardWidth,
                height: cardHeight,
                margin: EdgeInsets.only(right: AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withOpacity(0.3),
                    width: AppTheme.responsiveSize(context, phone: 2, tablet: 3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 10, tablet: 16)),
                  child: _safeLoadImage(image, name, cardWidth, cardHeight, context),
                ),
              ),

              // Selected overlay
              if (isSelected)
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  margin: EdgeInsets.only(right: AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.responsiveSize(context, phone: 8, tablet: 12)),

          // Text below image
          Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: AppTheme.responsiveSize(context, phone: 12, tablet: 18)),
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
              horizontal: AppTheme.responsiveSize(context, phone: 4, tablet: 8),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 8, tablet: 12)),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.secondaryColor : AppTheme.primaryColor,
                fontSize: AppTheme.responsiveFont(context, phone: 10, tablet: 14),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Load asset safely with loading indicator and icon fallback
  Widget _safeLoadImage(String path, String name, double width, double height, BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadAsset(path, name, width, height, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return _iconPlaceholder(name, width, height, context);
        } else {
          return snapshot.data!;
        }
      },
    );
  }

  // Try to load the asset
  Future<Widget> _loadAsset(String path, String name, double width, double height, BuildContext context) async {
    try {
      // Optional delay to simulate decoding
      await Future.delayed(const Duration(milliseconds: 50));
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _iconPlaceholder(name, width, height, context),
      );
    } catch (e) {
      return _iconPlaceholder(name, width, height, context);
    }
  }

  // Built-in icon placeholder
  Widget _iconPlaceholder(String name, double width, double height, BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: AppTheme.responsiveSize(context, phone: 30, tablet: 42),
              color: Colors.grey,
            ),
            SizedBox(height: AppTheme.responsiveSize(context, phone: 4, tablet: 8)),
            Text(
              name,
              style: TextStyle(
                fontSize: AppTheme.responsiveFont(context, phone: 9, tablet: 13),
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

