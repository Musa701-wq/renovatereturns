import 'package:flutter/material.dart';

class AppTheme {

  // Primary Colors
  static const Color primaryColor =Color(0xFF833B61);

  // Secondary Colors
  static const Color secondaryColor = Colors.white;
  static const Color secondaryColor1 = Color(0xFFE9DBDD);
  static const Color stokecolor=Color(0xFFB18399);
  static const Color tilescolor=Color(0xFFE9DBDD);


  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF5F5F5);

  // Responsive helpers (phone/tablet)
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;
  static bool isPhone(BuildContext context) => MediaQuery.of(context).size.width < 600;

  // Enlarge tablet values globally
  static const double _tabletScale = 1.25;

  static double responsiveSize(BuildContext context, {required double phone, required double tablet}) =>
      isTablet(context) ? (tablet * _tabletScale) : phone;

  static double responsivePadding(BuildContext context) =>
      responsiveSize(context , phone: 20, tablet: 32);

  static double responsiveFont(BuildContext context, {required double phone, required double tablet}) =>
      responsiveSize(context, phone: phone, tablet: tablet);

  // AppBar helpers
  static double appBarHeight(BuildContext context) =>
      responsiveSize(context, phone: kToolbarHeight, tablet: 72);

  static TextStyle appBarTitleStyle(BuildContext context) => TextStyle(
        fontSize: responsiveFont(context, phone: 20, tablet: 24),
        fontWeight: FontWeight.w600,
        color: primaryColor,
      );

  static IconThemeData appBarIconTheme(BuildContext context) => IconThemeData(
        size: responsiveSize(context, phone: 24, tablet: 28),
        color: primaryColor,
      );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: background,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),



      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
