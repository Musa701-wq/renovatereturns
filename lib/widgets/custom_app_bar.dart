import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../screens/chatbot_screen.dart';
import '../screens/login_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AppBar(
      toolbarHeight: AppTheme.appBarHeight(context),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "RenovateAI",
            style: AppTheme.appBarTitleStyle(context).copyWith(
              color: AppTheme.primaryColor,
              fontSize: AppTheme.responsiveFont(context, phone: 22, tablet: 28),
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Text(
            "Smart Home Decor",
            style: TextStyle(
              fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 15),
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.secondaryColor,
      foregroundColor: AppTheme.primaryColor,
      iconTheme: AppTheme.appBarIconTheme(context),
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/icons/chat-bot.png',
            width: AppTheme.appBarIconTheme(context).size, // Removed +8 for better default fit
            height: AppTheme.appBarIconTheme(context).size,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
        ),
        if (auth.currentUser == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppTheme.primaryColor,
              size: AppTheme.appBarIconTheme(context).size,
            ),
            onPressed: () {
              _showLogoutConfirmation(context, auth);
            },
          ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          title: Text(
            'Confirm Logout',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          content: Text(
            'Are you sure you want to logout? You will need to sign in again to continue.',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveSize(context, phone: 16, tablet: 20),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.secondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}