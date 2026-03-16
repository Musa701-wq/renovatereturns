import 'dart:io';
import 'package:ai_remodeling/in_app_purchase/credit_manager.dart';
import 'package:ai_remodeling/provider/ad_provider.dart';
import 'package:ai_remodeling/provider/auth_provider.dart';
import 'package:ai_remodeling/provider/image_provider.dart';
import 'package:ai_remodeling/provider/navbar_provider.dart';
import 'package:ai_remodeling/provider/upload_provider.dart' show UploadProvider;
import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:ai_remodeling/screens/main_screen.dart';
import 'package:ai_remodeling/screens/video_splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();

  runApp(MyApp());
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
        ChangeNotifierProvider(create: (_) => CreditManager()),
        ChangeNotifierProxyProvider<CreditManager, AdProvider>(
          create: (context) => AdProvider(
            creditManager: Provider.of<CreditManager>(context, listen: false),
          )..initialize(),
          update: (context, creditManager, previous) =>
              previous ?? AdProvider(creditManager: creditManager)..initialize(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const VideoSplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/main': (context) => MainScreen(),
        },
      ),
    );
  }
}