import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';
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
  bool _attHandled = false;
  bool _readyToNavigate = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀🚀 ATT FORCED SPLASH SCREEN STARTED');
    
    // Start the heavy lifting sequence
    _forceAttAndInitialize();
  }

  Future<void> _forceAttAndInitialize() async {
    _attHandled = true;

    // STEP 2: Now it's safe to start Firebase & Video
    debugPrint('📱 STEP 2: Initializing Firebase and Video...');
    await _initializeServicesAndVideo();
  }

  Future<void> _initializeServicesAndVideo() async {
    try {
      // Initialize Firebase strictly AFTER ATT
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized');
    } catch (e) {
      debugPrint("❌ Firebase App Init Error: $e");
    }

    // Initialize Video Player
    _controller = VideoPlayerController.asset("assets/video/splash_video.mp4");
    
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
        _controller.setLooping(false);
      }
      
      // Navigate when video finishes
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration && _controller.value.duration != Duration.zero) {
          _readyToNavigate = true;
          _checkAndNavigate();
        }
      });
      
      // Fallback timer just in case video hangs
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _readyToNavigate = true;
          _checkAndNavigate();
        }
      });
      
    } catch (e) {
      debugPrint("❌ Video Init Error: $e");
      // If video fails, just proceed
      if (mounted) {
        _readyToNavigate = true;
        _checkAndNavigate();
      }
    }
  }

  void _checkAndNavigate() {
    if (_attHandled && _readyToNavigate && mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
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
                        'assets/images/new_logo.png',
                        fit: BoxFit.cover,
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
                          text: "Vector Labs LTD",
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
