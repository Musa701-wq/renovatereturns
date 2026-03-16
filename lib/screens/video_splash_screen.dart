import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import '../services/auth_gate.dart';
import '../utils/theme.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    
    // Force ATT on Splash Screen - Best for first-load reliability
    _initTracking();

    _controller = VideoPlayerController.asset("assets/video/splash_video.mp4")
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _controller.setLooping(false);
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration && _controller.value.duration != Duration.zero) {
        _navigateToNext();
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  Future<void> _initTracking() async {
    if (!Platform.isIOS) return;

    try {
      // 1 second delay ensures the native UI is ready to receive the dialog signal
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint("❌ Splash ATT Error: $e");
    }
  }

  void _navigateToNext() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Video (Full Screen)
          if (_initialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const SizedBox.expand(
              child: ColoredBox(color: Colors.black),
            ),

          // Overall Soft Blur (As requested)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: getLogoSize(),
                    height: getLogoSize(),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(getLogoBorderRadius()),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.auto_awesome,
                        size: getLogoSize() * 0.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    "AI Remodeling",
                    style: TextStyle(
                      fontSize: getTitleFontSize(),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Transform your spaces with AI",
                    style: TextStyle(
                      fontSize: getSubtitleFontSize(),
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Powered by: ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const TextSpan(
                          text: "Vector Labs FZE LLC",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
