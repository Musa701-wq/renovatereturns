import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../screens/main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

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

    // ❌ User not logged in - Navigate directly to Login
    return const LoginScreen();
  }
}
