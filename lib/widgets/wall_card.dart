/*
// widgets/waal_design_card.dart
import 'package:flutter/material.dart';

class WallDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const WallDesignCard({
    Key? key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
// widgets/wall_design_card.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart'; // Import your theme

class WallDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const WallDesignCard({
    Key? key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // IMAGE CONTAINER - Separate
          Container(
            width: 100, // Same width as FloorDesignCard
            height: 120, // Same height as FloorDesignCard
            margin: const EdgeInsets.only(right: 12), // Same margin
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover, // Makes image fill the entire container
              ),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent, // Primary color
                width: 2,
              ),
            ),
          ),

          // SPACE between image and text container
          const SizedBox(height: 8),

          // TEXT CONTAINER - Separate (below image) with background
          Container(
            width: 100, // Same width as FloorDesignCard
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
                fontSize: 10, // Same font size
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
// widgets/wall_design_card.dart
/*
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class WallDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const WallDesignCard({
    Key? key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // IMAGE CONTAINER - Separate with overlay when selected
          Stack(
            children: [
              // Image container with error handling
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
                    image, // Changed from NetworkImage to Image.asset
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

class WallDesignCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const WallDesignCard({
    Key? key,
    required this.name,
    required this.image,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppTheme.responsiveSize(
      context,
      phone: 100,
      tablet: 130,
    );
    final double cardHeight = AppTheme.responsiveSize(
      context,
      phone: 120,
      tablet: 150,
    );
    final double cardMargin = AppTheme.responsiveSize(
      context,
      phone: 12,
      tablet: 16,
    );
    final double textPadding = AppTheme.responsiveSize(
      context,
      phone: 10,
      tablet: 14,
    );
    final double spacing = AppTheme.responsiveSize(
      context,
      phone: 8,
      tablet: 10,
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: cardWidth,
                height: cardHeight,
                margin: EdgeInsets.only(right: cardMargin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    width: cardWidth,
                    height: cardHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: AppTheme.responsiveSize(
                                  context,
                                  phone: 24,
                                  tablet: 30,
                                ),
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: spacing / 2),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: AppTheme.responsiveFont(
                                    context,
                                    phone: 9,
                                    tablet: 11,
                                  ),
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

              if (isSelected)
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  margin: EdgeInsets.only(right: cardMargin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
            ],
          ),

          SizedBox(height: spacing),

          Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: cardMargin),
            padding: EdgeInsets.symmetric(vertical: textPadding, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.secondaryColor
                    : AppTheme.primaryColor,
                fontSize: AppTheme.responsiveFont(
                  context,
                  phone: 10,
                  tablet: 12,
                ),
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
