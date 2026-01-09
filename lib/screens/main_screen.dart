import 'package:ai_remodeling/screens/login_screen.dart';
import 'package:ai_remodeling/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../provider/auth_provider.dart';
import '../provider/navbar_provider.dart';
import '../widgets/nav_bar.dart';
import 'generate_screen.dart' show GenerateScreen;
import 'history_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;





if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen())
        );
      });
      return Scaffold(
        backgroundColor: const Color(0xFF192338),
        body: Center(child: CircularProgressIndicator()),
      );
    }



    return Consumer<NavbarProvider>(
      builder: (context, navbarProvider, child) {
        final List<Widget> _screens = [
          GenerateScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ];

        return Scaffold(

          // To use the custom app bar, uncomment below:
          // appBar: CustomAppBar(),

          // Original app bar (commented):
          /* appBar: AppBar(
            title: Text(
              currentUser.name ?? "Welcome",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:AppTheme.secondaryColor,
            foregroundColor: AppTheme.primaryColor,
            leading: _buildAppBarProfileImage(currentUser.photoUrl),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await auth.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen())
                  );
                },
              ),
            ],
          ),*/

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
        // It's a URL from Google/Apple login
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(photoData),
          ),
        );
      }
    } catch (e) {
      // If any error, show default avatar
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