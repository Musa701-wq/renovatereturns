import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../utils/theme.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // Simple fade in after 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });

    // Automatically navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
        context,
      //MaterialPageRoute(builder: (context) =>MainScreen())
       MaterialPageRoute(builder: (context) =>LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth >= 800;
    final double contentWidth = isTablet ? screenWidth * 0.6 : screenWidth * 0.9;
    final double titleFontSize = isTablet ? 64.0 : 36.0;
    final double subtitleFontSize = isTablet ? 22.0 : 16.0;

    // Check if user is already logged in
    if (auth.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen())
        );
      });
      return Scaffold(
        backgroundColor: AppTheme.secondaryColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Background Image with Lighter Primary Color Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                AppTheme.primaryColor.withOpacity(0.9), // THORA DARK
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/Splash.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content with simple fade animation
          AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: Duration(milliseconds: 800),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "AI Remodeling",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      letterSpacing: 2.5,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    "Transform Your Images with AI Magic",
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryColor.withOpacity(0.9),
                      letterSpacing: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  Container(
                    width: isTablet ? 220 : 150,
                    height: isTablet ? 220 : 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.responsiveSize(
                        context,
                        phone: 24,
                        tablet: 28,
                      )),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white,
                          child: Icon(
                            Icons.auto_awesome,
                            size: isTablet ? 100 : 70,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  Text(
                    "Turn Your Space Into Dream House",
                    style: TextStyle(
                      fontSize: isTablet ? 48.0 : 40.0,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      letterSpacing: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.08),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Powered by: ",
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: AppTheme.secondaryColor.withOpacity(0.9),
                          ),
                        ),
                        TextSpan(
                          text: "Vector Labs FZE LLC",
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}