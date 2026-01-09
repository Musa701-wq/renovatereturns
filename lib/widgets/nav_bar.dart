/*
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/navbar_provider.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavbarProvider>(
      builder: (context, navbarProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.tilescolor,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final navItem in navbarProvider.navItems)
                  _buildNavItem(
                    navItem.icon,
                    navItem.label,
                    navItem.index,
                    navbarProvider.isSelected(navItem.index),
                        () => navbarProvider.setCurrentIndex(navItem.index),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      IconData icon,
      String label,
      int index,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/navbar_provider.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = AppTheme.isTablet(context);

    return Consumer<NavbarProvider>(
      builder: (context, navbarProvider, child) {
        final horizontalPadding = isTablet ? 22.0 : 20.0;
        final bottomPadding = isTablet ? 18.0 : 20.0;
        final topPadding = isTablet ? 6.0 : 4.0;
        final navHeight = isTablet ? 78.0 : 70.0;
        final borderRadius = isTablet ? 38.0 : 35.0;
        final blurRadius = isTablet ? 18.0 : 20.0;

        return Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: bottomPadding,
            top: topPadding,
          ),
          child: Container(
            height: navHeight,
            decoration: BoxDecoration(
              color: AppTheme.tilescolor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: blurRadius,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < navbarProvider.navItems.length; i++)
                  if (i < navbarProvider.navItems.length - 1) ...[
                    _buildNavItem(
                      context,
                      navbarProvider.navItems[i].icon,
                      navbarProvider.navItems[i].label,
                      navbarProvider.navItems[i].index,
                      navbarProvider.isSelected(navbarProvider.navItems[i].index),
                      () => navbarProvider.setCurrentIndex(navbarProvider.navItems[i].index),
                      isTablet,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ] else
                    _buildNavItem(
                      context,
                      navbarProvider.navItems[i].icon,
                      navbarProvider.navItems[i].label,
                      navbarProvider.navItems[i].index,
                      navbarProvider.isSelected(navbarProvider.navItems[i].index),
                      () => navbarProvider.setCurrentIndex(navbarProvider.navItems[i].index),
                      isTablet,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon,
      String label,
      int index,
      bool isSelected,
      VoidCallback onTap,
      bool isTablet,
      ) {
    final horizontalMargin = isTablet ? 6.0 : 4.0;
    final horizontalPadding = isTablet ? 16.0 : 12.0;
    final verticalPadding = isTablet ? 6.0 : 5.0;
    final borderRadius = isTablet ? 34.0 : 30.0;
    final iconSizeSelected = isTablet ? 26.0 : 24.0;
    final iconSizeUnselected = isTablet ? 24.0 : 22.0;
    final selectedFontSize = isTablet ? 16.0 : 14.0;
    final unselectedFontSize = isTablet ? 14.0 : 13.0;
    final selectedSpacing = isTablet ? 6.0 : 4.0;
    final unselectedSpacing = isTablet ? 6.0 : 4.0;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: isTablet ? 18.0 : 15.0,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: isSelected
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: iconSizeSelected,
              ),
              SizedBox(width: selectedSpacing),
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: selectedFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: iconSizeUnselected,
              ),
              SizedBox(height: unselectedSpacing),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: unselectedFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}