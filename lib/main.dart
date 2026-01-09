import 'dart:io';
import 'package:ai_remodeling/in_app_purchase/credit_manager.dart';
import 'package:ai_remodeling/provider/Ad_provider.dart';
import 'package:ai_remodeling/provider/auth_provider.dart';
import 'package:ai_remodeling/provider/image_provider.dart';
import 'package:ai_remodeling/provider/navbar_provider.dart';
import 'package:ai_remodeling/provider/upload_provider.dart' show UploadProvider;
import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:ai_remodeling/screens/main_screen.dart';
import 'package:ai_remodeling/services/auth_gate.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  await _requestTrackingPermission();
  await MobileAds.instance.initialize();

  runApp(MyApp());
}

Future<void> _requestTrackingPermission() async {
  if (!Platform.isIOS) return;
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (e) {
    debugPrint("ATT not available on this device: $e");
  }
}

Future<void> initTracking() async {
  try {
    // Wait a bit for the native side to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    print('📱 Current tracking status: $status');

    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
      print('📱 New tracking status: $newStatus');
    }
  } catch (e) {
    print('❌ App Tracking Transparency failed: $e');
    // Don't rethrow - continue without tracking
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageDataProvider()),
        ChangeNotifierProvider(create: (_) => NavbarProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      /*  ChangeNotifierProvider(create: (_) => CreditManager()),
        ChangeNotifierProvider(create: (_) => AdProvider(creditManager: CreditManager())),*/
        // ✅ FIRST create CreditManager
        ChangeNotifierProvider(create: (_) => CreditManager()),

        // ✅ THEN create AdProvider with the SAME CreditManager instance
        ChangeNotifierProxyProvider<CreditManager, AdProvider>(
          create: (context) => AdProvider(
            creditManager: Provider.of<CreditManager>(context, listen: false),
          ),
          update: (context, creditManager, previous) =>
          previous ?? AdProvider(creditManager: creditManager),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/main': (context) => MainScreen(),
        },

      ),
    );
  }
}