import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../in_app_purchase/credit_purchase_screen.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../utils/theme.dart';

class CreditDialog extends StatefulWidget {
  final String message;
  final List<ProductDetails> products;

  const CreditDialog({
    super.key,
    required this.message,
    required this.products,
  });

  static void show(BuildContext context, String message, List<ProductDetails> products) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: CreditDialog(
              message: message,
              products: products.isNotEmpty ? products : IAPManager().products,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<CreditDialog> createState() => _CreditDialogState();
}

class _CreditDialogState extends State<CreditDialog> {
  bool _isPurchasing = false;
  List<ProductDetails> _displayProducts = [];

  @override
  void initState() {
    super.initState();
    _displayProducts = widget.products;
    if (_displayProducts.isEmpty) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    final iapManager = IAPManager();
    // If singleton already has products, use them immediately
    if (iapManager.products.isNotEmpty) {
      if (mounted) {
        setState(() => _displayProducts = iapManager.products);
      }
      return;
    }

    // Otherwise, attempt a fetch
    final creditManager = context.read<CreditManager>();
    if (!iapManager.isAvailable) {
      await iapManager.init(creditManager);
    } else {
      await iapManager.loadProducts();
    }

    if (mounted) {
      setState(() => _displayProducts = iapManager.products);
    }
  }

  Future<void> _handleDirectPurchase(ProductDetails product) async {
    setState(() => _isPurchasing = true);
    
    try {
      final iapManager = IAPManager();
      final creditManager = context.read<CreditManager>();
      
      if (!iapManager.isAvailable) {
        await iapManager.init(creditManager);
      }

      final success = await iapManager.purchaseProduct(product);
      
      if (!success && mounted) {
        setState(() => _isPurchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase could not be initiated. Please try again.')),
        );
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPurchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find the cheapest credit product
    ProductDetails? smallestProduct;
    double? lowestPrice;
    for (final p in _displayProducts) {
      final price = p.rawPrice;
      if (lowestPrice == null || price < lowestPrice) {
        lowestPrice = price;
        smallestProduct = p;
      }
    }

    final primaryColor = AppTheme.primaryColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Text(
              "EXCLUSIVE STARTER OFFER",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Star Icon
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    size: 45,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  "Insufficient Credits",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 24),

                // THE SMALLEST PRODUCT CARD (Clickable)
                if (smallestProduct != null)
                  GestureDetector(
                    onTap: _isPurchasing ? null : () => _handleDirectPurchase(smallestProduct!),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.flash_on_rounded, color: primaryColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "STARTER PACK",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  "${IAPManager.productCredits[smallestProduct.id] ?? 250} Credits",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                smallestProduct.price,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                "BUY NOW",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     child: Column(
                       children: [
                         const CircularProgressIndicator(),
                         const SizedBox(height: 12),
                         Text(
                           "Loading exclusive offer...",
                           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                         )
                       ],
                     ),
                   ),

                const SizedBox(height: 28),
                
                // MAIN ACTION BUTTON
                GestureDetector(
                  onTap: _isPurchasing 
                    ? null 
                    : (smallestProduct != null 
                        ? () => _handleDirectPurchase(smallestProduct!) 
                        : () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const CreditsPurchaseScreen(),
                              ),
                            );
                          }),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _isPurchasing 
                      ? const Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                      : Text(
                          smallestProduct != null ? "RESTORE / PURCHASE NOW" : "GO TO STORE",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // View All Packages Link
                if (smallestProduct != null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      "Explore Other Credit Packs",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor.withValues(alpha: 0.7),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CreditsPurchaseScreen(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 4),
                
                // Cancel Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Decide Later",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
