import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../in_app_purchase/credit_manager.dart';
import '../in_app_purchase/i_ap_manager.dart';
import '../utils/theme.dart';

class WatermarkUpsell {
  static Future<String?> show(BuildContext context) async {
    final iapManager = IAPManager();
    final creditManager = Provider.of<CreditManager>(context, listen: false);

    // Check if already paid
    if (creditManager.hasPurchased) {
      return 'purchased';
    }

    // Ensure IAP loaded
    if (!iapManager.isAvailable || iapManager.products.isEmpty) {
      return 'watermark';
    }

    ProductDetails? targetProduct;
    try {
      targetProduct = iapManager.products.firstWhere((p) => p.id == 'com.vectorioslabs.renovaeai.starter.pack');
    } catch (e) {
      if (iapManager.products.isNotEmpty) {
        targetProduct = iapManager.products.first;
      }
    }

    if (targetProduct == null) {
      return 'watermark';
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: true, // Allow tapping outside to close (null return)
      builder: (BuildContext dialogContext) {
        bool isPurchasing = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.transparent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Content Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.workspace_premium, size: 48, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Remove Watermark?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Upgrade to the Starter Pack to save your AI designs without any watermarks permanently.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700], fontSize: 16, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        
                        // Product Highlight Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      targetProduct!.title.split('(').first.trim(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const Text(
                                      'Instant Activation',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                targetProduct.price,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Actions
                        if (isPurchasing)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 2,
                                ),
                                onPressed: () async {
                                  setState(() => isPurchasing = true);
                                  bool success = await iapManager.purchaseProduct(targetProduct!);
                                  
                                  if (success) {
                                    await Future.delayed(const Duration(seconds: 2));
                                    if (Navigator.canPop(dialogContext)) {
                                      Navigator.of(dialogContext).pop('purchased');
                                    }
                                  } else {
                                    setState(() => isPurchasing = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Purchase failed or cancelled')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Upgrade Now',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop('watermark'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                                child: const Text(
                                  'Continue with Watermark',
                                  style: TextStyle(decoration: TextDecoration.underline, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  // Close Button
                  Positioned(
                    top: -10,
                    right: -10,
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                          ],
                        ),
                        child: Icon(Icons.close, size: 20, color: Colors.grey[800]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
