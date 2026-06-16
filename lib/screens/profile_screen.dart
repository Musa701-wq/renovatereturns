import 'package:ai_remodeling/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../in_app_purchase/credit.dart' show CreditsCard;
import '../in_app_purchase/credit_manager.dart';
import '../provider/auth_provider.dart';
import '../widgets/full_screen_view.dart';
import 'edit_screen.dart';
import 'login_screen.dart';
import '../utils/theme.dart';
import 'faq_screen.dart';
import 'feedback_screen.dart';
import 'community_screen.dart';
import 'my_creations_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'other_user_profile_screen.dart'; // To use FullScreenImageView
import 'other_products_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isCommunityShareEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
      _refreshCredits();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCommunityShareEnabled = prefs.getBool('share_to_community') ?? false;
    });
  }

  void _refreshUserData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.getFirebaseUser();
    if (user != null) {
      auth.fetchUserFromFirestore(user.uid);
    }
  }

  void _refreshCredits() {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    creditManager.refreshCredits();
  }

  Future<void> _deleteImage(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('images').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    String? photoData = user?.photoUrl;
    final uid = auth.getFirebaseUser()?.uid;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        toolbarHeight: AppTheme.appBarHeight(context),
        foregroundColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.secondaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: AppTheme.appBarIconTheme(context),
        title: Text(
          "Profile",
          style: AppTheme.appBarTitleStyle(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.secondaryColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // User Header (Centered)
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: AppTheme.responsiveSize(context, phone: 3, tablet: 4),
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: AppTheme.responsiveSize(context, phone: 50, tablet: 70),
                                      child: ClipOval(child: _buildProfileImage(photoData)),
                                    ),
                                  ),
                                ),
                                  if (user != null)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user?.name ?? 'User',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: AppTheme.responsiveFont(context, phone: 24, tablet: 32),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI Space Designer',
                              style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            CreditsCard(),
                            const SizedBox(height: 20),
                            // Compact Settings Toggle
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.tilescolor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppTheme.stokecolor, width: 1.5),
                              ),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppTheme.primaryColor,
                                title: const Text('Share to Community', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                value: _isCommunityShareEnabled,
                                onChanged: (val) async {
                                  setState(() => _isCommunityShareEnabled = val);
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('share_to_community', val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      
                      // Account Settings Items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildProfileTile(context, Icons.auto_awesome_outlined, 'My Creations', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCreationsScreen()))),
                            const SizedBox(height: 12),
                            _buildProfileTile(context, Icons.history, 'History', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
                            const SizedBox(height: 12),
                            _buildProfileTile(context, Icons.feedback_outlined, 'Feedback', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()))),
                            const SizedBox(height: 12),
                            _buildProfileTile(context, Icons.help_outline, 'FAQ', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen()))),
                            const SizedBox(height: 12),
                            _buildProfileTile(context, Icons.apps_outlined, 'Other Products', 
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OtherProductsScreen()))),
                            const SizedBox(height: 30),
                            
                            if (user != null)
                              _buildLogoutDeleteRow(context)
                            else
                              _buildLoginButton(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text("Powered by Vector Labs Ltd", 
                        style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.5), fontSize: 12)),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed _buildImageGrid and related deletion logic as it moved to MyCreationsScreen.

  Widget _buildProfileImage(String? photoData) {
    if (photoData == null || photoData.isEmpty) {
      return Icon(Icons.person, size: 50, color: AppTheme.primaryColor);
    }
    try {
      if (photoData.startsWith('http')) {
        return Image.network(photoData, fit: BoxFit.cover);
      } else {
        return Image.memory(base64Decode(photoData), fit: BoxFit.cover);
      }
    } catch (_) {
      return Icon(Icons.person, size: 50, color: AppTheme.primaryColor);
    }
  }

  Widget _buildProfileTile(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.tilescolor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.stokecolor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Login / Sign Up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutDeleteRow(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showDeleteConfirmation(context),
                child: Container(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.delete, color: AppTheme.primaryColor, size: 20), const SizedBox(width: 8), const Text('Delete Account')])),
                ),
              ),
            ),
            Container(width: 1, color: AppTheme.primaryColor),
            Expanded(
              child: GestureDetector(
                onTap: () => _showLogoutConfirmation(context),
                child: Container(
                  color: AppTheme.primaryColor,
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.logout, color: Colors.white, size: 20), const SizedBox(width: 8), const Text('Logout', style: TextStyle(color: Colors.white))])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: Text('Delete Account', style: TextStyle(color: AppTheme.primaryColor)),
        content: Text('Are you sure? This cannot be undone.', style: TextStyle(color: AppTheme.primaryColor)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel', style: TextStyle(color: AppTheme.primaryColor))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _signOutAndRedirect(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: Text('Confirm Logout', style: TextStyle(color: AppTheme.primaryColor)),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: AppTheme.primaryColor)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel', style: TextStyle(color: AppTheme.primaryColor))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _signOutAndRedirect(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Logout', style: TextStyle(color: AppTheme.secondaryColor)),
          ),
        ],
      ),
    );
  }

  void _signOutAndRedirect(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.signOut();
    // AuthGate will handle the state change and transition back to Guest state
  }
}
