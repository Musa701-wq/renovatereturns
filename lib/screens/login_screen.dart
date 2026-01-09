/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  // Media Query for responsive design
  late double screenWidth;
  late double screenHeight;
  late bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Responsive calculations
    double getLogoSize() {
      if (screenWidth > 800) return 160.0;
      if (screenWidth > 600) return 140.0;
      return 120.0;
    }

    double getLogoBorderRadius() {
      if (screenWidth > 800) return 30.0;
      if (screenWidth > 600) return 28.0;
      return 25.0;
    }

    double getTitleFontSize() {
      if (screenWidth > 800) return 42.0;
      if (screenWidth > 600) return 36.0;
      return 32.0;
    }

    double getSubtitleFontSize() {
      if (screenWidth > 800) return 20.0;
      if (screenWidth > 600) return 18.0;
      return 16.0;
    }

    double getButtonHeight() {
      if (screenWidth > 800) return 64.0;
      if (screenWidth > 600) return 60.0;
      return 56.0;
    }

    double getButtonFontSize() {
      if (screenWidth > 800) return 18.0;
      if (screenWidth > 600) return 16.0;
      return 15.0;
    }

    double getButtonIconSize() {
      if (screenWidth > 800) return 28.0;
      if (screenWidth > 600) return 26.0;
      return 24.0;
    }

    double getFooterFontSize() {
      if (screenWidth > 800) return 14.0;
      if (screenWidth > 600) return 13.0;
      return 12.0;
    }

    EdgeInsets getScreenPadding() {
      if (screenWidth > 900) {
        return EdgeInsets.symmetric(horizontal: screenWidth * 0.12, vertical: 40);
      } else if (screenWidth > 600) {
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
      } else {
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
      }
    }

    double getSpacing() {
      if (screenWidth > 800) return 30.0;
      if (screenWidth > 600) return 25.0;
      return 20.0;
    }

    double getButtonSpacing() {
      if (screenWidth > 800) return 20.0;
      if (screenWidth > 600) return 18.0;
      return 16.0;
    }

    final bool isTablet = screenWidth >= 600;
    final bool isWide = screenWidth >= 900;
    final double sectionSpacing = isWide ? 36.0 : getSpacing();

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: isTablet ? 32 : 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
              child: Padding(
                padding: getScreenPadding(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: getLogoSize(),
                      height: getLogoSize(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(getLogoBorderRadius()),
                        color: AppTheme.primaryColor,
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          width: screenWidth > 600 ? 3.0 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(getLogoBorderRadius()),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.auto_awesome,
                                size: screenWidth > 800 ? 70.0 : screenWidth > 600 ? 60.0 : 50.0,
                                color: AppTheme.secondaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: sectionSpacing),

                    Text(
                      'AI Remodeling',
                      style: TextStyle(
                        fontSize: getTitleFontSize(),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: screenWidth > 600 ? 1.0 : 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Transform your spaces with AI',
                      style: TextStyle(
                        fontSize: getSubtitleFontSize(),
                        color: AppTheme.primaryColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: sectionSpacing),

                    SizedBox(
                      width: double.infinity,
                      height: getButtonHeight(),
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading || _isAppleLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isGoogleLoading = true;
                                });

                                try {
                                  bool success = await auth.loginWithGoogle();
                                  if (success && context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/main');
                                  }
                                } catch (e) {
                                  print("Google login error: $e");
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Login failed: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isGoogleLoading = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                        child: _isGoogleLoading
                            ? SizedBox(
                                width: screenWidth > 600 ? 28.0 : 24.0,
                                height: screenWidth > 600 ? 28.0 : 24.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppTheme.secondaryColor,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.g_mobiledata,
                                    size: getButtonIconSize(),
                                  ),
                                  SizedBox(width: screenWidth > 600 ? 12 : 10),
                                  Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      fontSize: getButtonFontSize(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: getButtonSpacing()),

                    SizedBox(
                      width: double.infinity,
                      height: getButtonHeight(),
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading || _isAppleLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isAppleLoading = true;
                                });

                                try {
                                  bool success = await auth.loginWithApple();
                                  if (success && context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/main');
                                  }
                                } catch (e) {
                                  print("Apple login error: $e");
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Login failed: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isAppleLoading = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tilescolor,
                          foregroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: _isAppleLoading
                            ? SizedBox(
                                width: screenWidth > 600 ? 28.0 : 24.0,
                                height: screenWidth > 600 ? 28.0 : 24.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    size: getButtonIconSize(),
                                  ),
                                  SizedBox(width: screenWidth > 600 ? 12 : 10),
                                  Text(
                                    "Continue with Apple",
                                    style: TextStyle(
                                      fontSize: getButtonFontSize(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: getSpacing()),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 600 ? 40.0 : 20.0,
                      ),
                      child: Text(
                        "By continuing, you agree to our Terms of Service and Privacy Policy",
                        style: TextStyle(
                          fontSize: getFooterFontSize(),
                          color: AppTheme.primaryColor.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: getSpacing()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../in_app_purchase/credit_manager.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  late double screenWidth;
  late double screenHeight;
  late bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final creditManager = Provider.of<CreditManager>(context, listen: false);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    double getLogoSize() {
      if (screenWidth > 800) return 160.0;
      if (screenWidth > 600) return 140.0;
      return 120.0;
    }

    double getLogoBorderRadius() {
      if (screenWidth > 800) return 30.0;
      if (screenWidth > 600) return 28.0;
      return 25.0;
    }

    double getTitleFontSize() {
      if (screenWidth > 800) return 42.0;
      if (screenWidth > 600) return 36.0;
      return 32.0;
    }

    double getSubtitleFontSize() {
      if (screenWidth > 800) return 20.0;
      if (screenWidth > 600) return 18.0;
      return 16.0;
    }

    double getButtonHeight() {
      if (screenWidth > 800) return 64.0;
      if (screenWidth > 600) return 60.0;
      return 56.0;
    }

    double getButtonFontSize() {
      if (screenWidth > 800) return 18.0;
      if (screenWidth > 600) return 16.0;
      return 15.0;
    }

    double getButtonIconSize() {
      if (screenWidth > 800) return 28.0;
      if (screenWidth > 600) return 26.0;
      return 24.0;
    }

    double getFooterFontSize() {
      if (screenWidth > 800) return 14.0;
      if (screenWidth > 600) return 13.0;
      return 12.0;
    }

    EdgeInsets getScreenPadding() {
      if (screenWidth > 900) {
        return EdgeInsets.symmetric(horizontal: screenWidth * 0.12, vertical: 40);
      } else if (screenWidth > 600) {
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
      } else {
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
      }
    }

    double getSpacing() {
      if (screenWidth > 800) return 30.0;
      if (screenWidth > 600) return 25.0;
      return 20.0;
    }

    double getButtonSpacing() {
      if (screenWidth > 800) return 20.0;
      if (screenWidth > 600) return 18.0;
      return 16.0;
    }

    final bool isTablet = screenWidth >= 600;
    final bool isWide = screenWidth >= 900;
    final double sectionSpacing = isWide ? 36.0 : getSpacing();

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: isTablet ? 32 : 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
              child: Padding(
                padding: getScreenPadding(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: getLogoSize(),
                      height: getLogoSize(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(getLogoBorderRadius()),
                        color: AppTheme.primaryColor,
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          width: screenWidth > 600 ? 3.0 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(getLogoBorderRadius()),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.auto_awesome,
                                size: screenWidth > 800 ? 70.0 : screenWidth > 600 ? 60.0 : 50.0,
                                color: AppTheme.secondaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: sectionSpacing),

                    Text(
                      'AI Remodeling',
                      style: TextStyle(
                        fontSize: getTitleFontSize(),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: screenWidth > 600 ? 1.0 : 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Transform your spaces with AI',
                      style: TextStyle(
                        fontSize: getSubtitleFontSize(),
                        color: AppTheme.primaryColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: sectionSpacing),

                    SizedBox(
                      width: double.infinity,
                      height: getButtonHeight(),
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading || _isAppleLoading
                            ? null
                            : () async {
                          setState(() {
                            _isGoogleLoading = true;
                          });

                          try {
                            // ✅ Pass creditManager to loginWithGoogle
                            bool success = await auth.loginWithGoogle(creditManager);
                            if (success && context.mounted) {
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                          } catch (e) {
                            print("Google login error: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Login failed: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isGoogleLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                        child: _isGoogleLoading
                            ? SizedBox(
                          width: screenWidth > 600 ? 28.0 : 24.0,
                          height: screenWidth > 600 ? 28.0 : 24.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppTheme.secondaryColor,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.g_mobiledata,
                              size: getButtonIconSize(),
                            ),
                            SizedBox(width: screenWidth > 600 ? 12 : 10),
                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: getButtonFontSize(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: getButtonSpacing()),

                    SizedBox(
                      width: double.infinity,
                      height: getButtonHeight(),
                      child: ElevatedButton(
                        onPressed: _isGoogleLoading || _isAppleLoading
                            ? null
                            : () async {
                          setState(() {
                            _isAppleLoading = true;
                          });

                          try {
                            // ✅ Pass creditManager to loginWithApple
                            bool success = await auth.loginWithApple(creditManager);
                            if (success && context.mounted) {
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                          } catch (e) {
                            print("Apple login error: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Login failed: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isAppleLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tilescolor,
                          foregroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: _isAppleLoading
                            ? SizedBox(
                          width: screenWidth > 600 ? 28.0 : 24.0,
                          height: screenWidth > 600 ? 28.0 : 24.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppTheme.primaryColor,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apple,
                              size: getButtonIconSize(),
                            ),
                            SizedBox(width: screenWidth > 600 ? 12 : 10),
                            Text(
                              "Continue with Apple",
                              style: TextStyle(
                                fontSize: getButtonFontSize(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: getSpacing()),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 600 ? 40.0 : 20.0,
                      ),
                      child: Text(
                        "By continuing, you agree to our Terms of Service and Privacy Policy",
                        style: TextStyle(
                          fontSize: getFooterFontSize(),
                          color: AppTheme.primaryColor.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: getSpacing()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}