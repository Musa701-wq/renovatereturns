import 'package:ai_remodeling/screens/onboarding_screen.dart';
import 'package:ai_remodeling/screens/special_offer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/auth_provider.dart';
import '../screens/main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isFirstTime = false;
  bool _checkedFirstTime = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if it's the first time the app is opened
    final firstTime = prefs.getBool('isFirstTimeInstall') ?? true;
    
    // We will update it to false in SpecialOfferScreen or when it's closed
    // to ensure user actually sees it.

    if (mounted) {
      setState(() {
        _isFirstTime = firstTime;
        _checkedFirstTime = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Jab tak SharedPreferences ya Auth state load ho rahi ho
    if ((auth.currentUser == null && auth.isLoading) || !_checkedFirstTime) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ User already logged in
    if (auth.currentUser != null) {
      return const MainScreen();
    }

    // 🎁 First time install - show onboarding flow
    if (_isFirstTime) {
      return const OnboardingScreen();
    }

    // 🔒 Guest Mode - allow browsing MainScreen without login
    return const MainScreen();
  }
}
