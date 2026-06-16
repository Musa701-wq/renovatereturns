import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:ai_remodeling/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../provider/auth_provider.dart';
import '../provider/navbar_provider.dart';
import '../widgets/nav_bar.dart';
import 'generate_screen.dart' show GenerateScreen;
import 'community_screen.dart';
import 'history_screen.dart';
import 'chatbot_screen.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../in_app_purchase/credit_manager.dart';
import '../provider/image_provider.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final creditManager = Provider.of<CreditManager>(context, listen: false);
        IAPManager().init(creditManager);

        final imageProvider = Provider.of<ImageDataProvider>(context, listen: false);
        imageProvider.fetchHistory();
        imageProvider.fetchPublicGallery();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;

    return Consumer<NavbarProvider>(
      builder: (context, navbarProvider, child) {
        final List<Widget> _screens = [
          GenerateScreen(),
          CommunityScreen(),
          HistoryScreen(showBackButton: false),
          CreditsPurchaseScreen(showBackButton: false),
          ProfileScreen(),
        ];

        return Scaffold(
          body: Container(
            child: _screens[navbarProvider.currentIndex],
          ),
          bottomNavigationBar: const CustomNavBar(),
        );
      },
    );
  }

  // Keep this method if you want to use it elsewhere
  Widget _buildAppBarProfileImage(String? photoData) {
    if (photoData == null || photoData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      );
    }

    try {
      bool isBase64 = photoData.startsWith('/9j/') || // JPEG
          photoData.startsWith('iVBORw0KGgo') || // PNG
          photoData.length > 1000; // Base64 strings are long

      if (isBase64) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundImage: MemoryImage(base64Decode(photoData)),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(photoData),
          ),
        );
      }
    } catch (e) {
      print('Error loading app bar profile image: $e');
      return const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      );
    }
  }
}