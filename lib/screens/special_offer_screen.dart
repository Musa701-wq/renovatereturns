import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/auth_provider.dart';
import '../screens/main_screen.dart';
import '../screens/login_screen.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../utils/theme.dart';
import '../in_app_purchase/credit_purchase_screen.dart';

class SpecialOfferScreen extends StatefulWidget {
  const SpecialOfferScreen({Key? key}) : super(key: key);

  @override
  _SpecialOfferScreenState createState() => _SpecialOfferScreenState();
}

class _SpecialOfferScreenState extends State<SpecialOfferScreen> with SingleTickerProviderStateMixin {
  bool _isPurchasing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _markFirstTimeHandled();
  }

  Future<void> _markFirstTimeHandled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeInstall', false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _buySpecialOffer() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    final iapManager = IAPManager();
    if (!iapManager.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('In-App Purchases are not available.')),
        );
        setState(() {
          _isPurchasing = false;
        });
      }
      return;
    }

    try {
      final product = iapManager.products.firstWhere(
        (p) => p.id == 'com.vectorioslabs.renovaeai.special.offer',
      );
      final result = await iapManager.purchaseProduct(product);
      if (mounted) {
        if (result) {
          if (Navigator.canPop(context)) {
             Navigator.of(context).pop();
          } else {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
          }
        } else {
          setState(() {
            _isPurchasing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Special offer is currently unavailable.')),
        );
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String priceString = '\$1.99';
    final iapManager = IAPManager();
    if (iapManager.isAvailable) {
      try {
        final product = iapManager.products.firstWhere(
          (p) => p.id == 'com.vectorioslabs.renovaeai.special.offer',
        );
        priceString = product.price;
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF), // soft lavender/white
      body: Column(
        children: [
          // Top Image Area
          Stack(
            children: [
              Image.asset(
                'assets/images/inta.jpg',
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100, // Size of the fade
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF8F5FF).withOpacity(0.0),
                        const Color(0xFFF8F5FF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: Text(
                  'Special Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 22),
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppTheme.isTablet(context) ? 600 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.responsiveSize(context, phone: 24, tablet: 40)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'UNLIMITED POTENTIAL',
                                style: TextStyle(
                                  fontSize: AppTheme.responsiveFont(context, phone: 12, tablet: 14),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.black54,
                                ),
                              ),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '100',
                                    style: TextStyle(
                                      fontSize: AppTheme.responsiveFont(context, phone: 56, tablet: 72),
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryColor,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Credits',
                                    style: TextStyle(
                                      fontSize: AppTheme.responsiveFont(context, phone: 18, tablet: 24),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.responsiveSize(context, phone: 20, tablet: 30),
                                  vertical: AppTheme.responsiveSize(context, phone: 8, tablet: 12)
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'One-time payment of ',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 16),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: priceString,
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppTheme.responsiveFont(context, phone: 16, tablet: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  'Unlock professional-grade AI redesigns for your space.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    height: 1.4,
                                    fontSize: AppTheme.responsiveFont(context, phone: 14, tablet: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Sticky Bottom Area
          Container(
            padding: EdgeInsets.fromLTRB(
              AppTheme.responsiveSize(context, phone: 24, tablet: 60),
              16,
              AppTheme.responsiveSize(context, phone: 24, tablet: 60),
              16 + MediaQuery.of(context).padding.bottom
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFA85782), // Lighter, vibrant primary
                          AppTheme.primaryColor,
                          const Color(0xFF4C1F36), // Dark primary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : _buySpecialOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Buy 100 Credits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreditsPurchaseScreen()),
                    );
                  },
                  child: Text(
                    'View another plan',
                    style: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
