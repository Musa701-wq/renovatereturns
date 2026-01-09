import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  @override
  void initState() {
    super.initState();
    requestTrackingPermission();
  }

  Future<void> requestTrackingPermission() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Jab tak SharedPreferences load ho rahi ho
    if (auth.currentUser == null && auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ User already logged in
    if (auth.currentUser != null) {
      return const MainScreen();
    }

    // ❌ User not logged in
    return const WelcomeScreen();
  }
}
