
import 'package:ai_remodeling/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../in_app_purchase/credit.dart' show CreditsCard; // KEEP THIS IMPORT
import '../in_app_purchase/credit_manager.dart';
import '../provider/auth_provider.dart';
import 'edit_screen.dart';
import 'login_screen.dart';
import '../utils/theme.dart';
import 'faq_screen.dart';
import 'feedback_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
      _refreshCredits(); // ✅ Add this
    });
  }
  void _refreshUserData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.getFirebaseUser();
    if (user != null) {
      auth.fetchUserFromFirestore(user.uid);
    }
  }

// ✅ Add this new method
  void _refreshCredits() {
    final creditManager = Provider.of<CreditManager>(context, listen: false);
    creditManager.refreshCredits();
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    String? photoData = user?.photoUrl;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        toolbarHeight: AppTheme.appBarHeight(context),
        foregroundColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.secondaryColor,
        iconTheme: AppTheme.appBarIconTheme(context),
        title: Text(
          "Profile",
          style: AppTheme.appBarTitleStyle(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.responsivePadding(context)),
        child: Column(
          children: [
            SizedBox(height: AppTheme.responsiveSize(context, phone: 10, tablet: 20)),

            // Profile Image with Edit Icon
            Stack(
              children: [
                Container(
                  width: AppTheme.responsiveSize(context, phone: 120, tablet: 150),
                  height: AppTheme.responsiveSize(context, phone: 120, tablet: 150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: AppTheme.responsiveSize(context, phone: 3, tablet: 4),
                    ),
                  ),
                  child: _buildProfileImage(photoData),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 6, tablet: 8)),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: AppTheme.responsiveSize(context, phone: 2, tablet: 3),
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: AppTheme.responsiveSize(context, phone: 16, tablet: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),

            // User Name - Primary Color
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              child: Text(
                user?.name ?? 'User',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: AppTheme.responsiveFont(context, phone: 24, tablet: 28),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Premium Badge (only for paid users)
            Consumer<CreditManager>(
              builder: (context, creditManager, _) {
                if (!creditManager.hasPurchased) return const SizedBox(height: 6);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'Premium User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: AppTheme.responsiveSize(context, phone: 15, tablet: 22)),


            // Email Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.responsiveSize(context, phone: 20, tablet: 28),
                vertical: AppTheme.responsiveSize(context, phone: 12, tablet: 16),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.secondaryColor,
                    AppTheme.secondaryColor1,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email,
                    color: AppTheme.primaryColor, // Primary color icon
                  size: AppTheme.responsiveSize(context, phone: 18, tablet: 22),
                  ),
                SizedBox(width: AppTheme.responsiveSize(context, phone: 10, tablet: 14)),
                  Expanded(
                    child: Text(
                      user?.email ?? 'No email',
                      style: TextStyle(
                        color: AppTheme.primaryColor, // Primary color text
                      fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 18),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),

            // Divider below email
            Divider(
              color: AppTheme.primaryColor.withOpacity(0.2),
              thickness: 1,
            ),

            SizedBox(height: AppTheme.responsiveSize(context, phone: 20, tablet: 28)),



            // DIRECT CALL CreditsCard HERE
            CreditsCard(), // YAHI CHANGE HAI - DIRECT CALL

            const SizedBox(height: 25),

            // Tiles Section (Credits tile REMOVED)
            _buildProfileTile(
              context,
              Icons.person_outline,
              'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildProfileTile(
              context,
              Icons.history,
              'History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildProfileTile(
              context,
              Icons.feedback_outlined,
              'Feedback',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildProfileTile(
              context,
              Icons.help_outline,
              'FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildProfileTile(
              context,
              Icons.remove_red_eye,
              'Privacy Policy',
              onTap: () =>
                  _launchExternalLink('https://vectorlabzlimited.com/privacy-policy/'),
            ),
            const SizedBox(height: 12),

            _buildProfileTile(
              context,
              Icons.gavel,
              'Terms of Use',
              onTap: () =>
                  _launchExternalLink('https://vectorlabzlimited.com/terms-of-use/'),
            ),

            const SizedBox(height: 25),

            // Delete and Logout Combined Button
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showDeleteConfirmation(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color: AppTheme.secondaryColor,
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showLogoutConfirmation(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppTheme.secondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Footer
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Powered by Vector Labs Ltd",
                style: TextStyle(
                  color: AppTheme.primaryColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? photoData) {
    if (photoData == null || photoData.isEmpty) {
      return CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
        child: Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
      );
    }

    try {
      bool isBase64 = photoData.startsWith('/9j/') ||
          photoData.startsWith('iVBORw0KGgo') ||
          photoData.length > 1000;

      if (isBase64) {
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(photoData)),
        );
      } else {
        return CircleAvatar(
          backgroundImage: NetworkImage(photoData),
        );
      }
    } catch (e) {
      return CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
        child: Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
      );
    }
  }

  Widget _buildProfileTile(
      BuildContext context,
      IconData icon,
      String title, {
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.tilescolor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.stokecolor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: Text(
          'Delete Account',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveSize(context, phone: 16, tablet: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              _signOutAndRedirect(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _signOutAndRedirect(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: Text(
          'Confirm Logout',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to continue.',
          style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveSize(context, phone: 16, tablet: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _signOutAndRedirect(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchExternalLink(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link. Please try again later.')),
        );
      }
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
