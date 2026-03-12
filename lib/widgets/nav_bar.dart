import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../provider/navbar_provider.dart';
import '../utils/theme.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavbarProvider>(
      builder: (context, navbarProvider, child) {
        return CurvedNavigationBar(
          index: navbarProvider.currentIndex,
          height: AppTheme.responsiveSize(context, phone: 60, tablet: 60),
          items: navbarProvider.navItems.map((item) {
            return Icon(
              item.icon,
              size: AppTheme.responsiveSize(context, phone: 30, tablet: 28),
              color: navbarProvider.currentIndex == item.index 
                  ? AppTheme.secondaryColor 
                  : AppTheme.primaryColor,
            );
          }).toList(),
          color: AppTheme.tilescolor,
          buttonBackgroundColor: AppTheme.primaryColor,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) {
            navbarProvider.setCurrentIndex(index);
          },
          letIndexChange: (index) => true,
        );
      },
    );
  }
}