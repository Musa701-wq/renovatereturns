import 'package:ai_remodeling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AppBar(
      toolbarHeight: AppTheme.appBarHeight(context),
      title: Text(
        "RenovateAI: Smart Home Decor",
        style: AppTheme.appBarTitleStyle(context).copyWith(color: AppTheme.primaryColor),
      ),
      backgroundColor: AppTheme.secondaryColor,
      foregroundColor: AppTheme.primaryColor,
      iconTheme: AppTheme.appBarIconTheme(context),
      actions: [
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