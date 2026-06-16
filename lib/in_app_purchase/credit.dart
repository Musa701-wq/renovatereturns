

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'credit_manager.dart';
import 'credit_purchase_screen.dart' show CreditsPurchaseScreen;
import '../utils/theme.dart';
import '../provider/auth_provider.dart';
import '../screens/login_screen.dart';

class CreditsCard extends StatelessWidget {
  final VoidCallback? onGetPressed;

  const CreditsCard({
    Key? key,
    this.onGetPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creditManager = context.watch<CreditManager>();
    final auth = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreditsPurchaseScreen(),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 20, tablet: 26)),
        decoration: BoxDecoration(
          // CHANGED: Your theme colors
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryColor,
              AppTheme.secondaryColor1,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 16, tablet: 20)),
          // ADDED: Border like your other containers
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                  decoration: BoxDecoration(
                    // CHANGED: Your theme color
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 8, tablet: 10)),
                  ),
                  child: Icon(
                    Icons.stars,
                    // CHANGED: Your theme color
                    color: AppTheme.primaryColor,
                    size: AppTheme.responsiveSize(context, phone: 20, tablet: 26),
                  ),
                ),
                SizedBox(width: AppTheme.responsiveSize(context, phone: 12, tablet: 16)),
                Text(
                  'Available Credits',
                  // CHANGED: Your theme color
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.responsiveSize(context, phone: 16, tablet: 22)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (auth.currentUser == null)
                        Text(
                          'Login to see your credits',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 22),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else if (creditManager.isLoading)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        )
                      else
                        Text(
                          '${creditManager.credits}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: AppTheme.responsiveFont(context, phone: 44, tablet: 56),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: AppTheme.responsiveSize(context, phone: 4, tablet: 8)),
                      Text(
                        auth.currentUser == null
                            ? 'Gain access to premium AI features'
                            : 'Use credits for AI styling features',
                        style: TextStyle(
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                          fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (auth.currentUser == null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreditsPurchaseScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.responsiveSize(context, phone: 14, tablet: 20),
                      vertical: AppTheme.responsiveSize(context, phone: 10, tablet: 14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.responsiveSize(context, phone: 8, tablet: 12)),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    auth.currentUser == null ? 'Login' : 'Get More',
                    style: TextStyle(
                      fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}