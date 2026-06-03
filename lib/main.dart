import 'dart:io';
import 'package:ai_remodeling/in_app_purchase/credit_manager.dart';
import 'package:ai_remodeling/provider/auth_provider.dart';
import 'package:ai_remodeling/provider/image_provider.dart';
import 'package:ai_remodeling/provider/navbar_provider.dart';
import 'package:ai_remodeling/provider/upload_provider.dart' show UploadProvider;
import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:ai_remodeling/screens/main_screen.dart';
import 'package:ai_remodeling/screens/video_splash_screen.dart';
import 'package:ai_remodeling/services/auth_gate.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> requestATTIfNeeded() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('ATT request failed: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await requestATTIfNeeded();
  
  try {
    await Firebase.initializeApp();
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ Initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageDataProvider()),
        ChangeNotifierProvider(create: (_) => NavbarProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CreditManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const VideoSplashScreen(),
        routes: {
          '/auth': (context) => const AuthGate(),
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}