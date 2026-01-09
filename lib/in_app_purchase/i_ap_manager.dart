// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';
//
// import 'credit_manager.dart';
//
//
// class IAPManager {
//   static final IAPManager _instance = IAPManager._internal();
//   factory IAPManager() => _instance;
//   IAPManager._internal();
//
//   final InAppPurchase _iap = InAppPurchase.instance;
//   StreamSubscription<List<PurchaseDetails>>? _subscription;
//
//   bool _available = false;
//   List<ProductDetails> _products = [];
//   bool _isLoading = false;
//   CreditManager? _creditManager;
//
//   // Transaction tracking
//   final Set<String> _processedTransactionIds = {};
//   Completer<RestoreResult>? _restoreCompleter;
//
//   // Local storage keys
//   static const String _processedTxnKey = 'processed_transactions';
//   static const String _purchaseHistoryKey = 'purchase_history';
//
//   bool get isAvailable => _available;
//   List<ProductDetails> get products => _products;
//   bool get isLoading => _isLoading;
//
//   /// Product IDs - Must match App Store Connect exactly
//   static const Map<String, int> productCredits = {
//     'com.vectorioslabs.renovaeai.starter.pack': 250,
//     'com.vectorioslabs.renovaeai.basic.pack': 1000,
//     'com.vectorioslabs.renovaeai.pro.pack': 2500,
//     'com.vectorioslabs.renovaeai.enterprise.pack': 5000,
//   };
//
//   static const Set<String> _productIds = {
//     'com.vectorioslabs.renovaeai.starter.pack',
//     'com.vectorioslabs.renovaeai.basic.pack',
//     'com.vectorioslabs.renovaeai.pro.pack',
//     'com.vectorioslabs.renovaeai.enterprise.pack',
//   };
//
//   /// Initialize IAP
//   Future<void> init(CreditManager creditManager) async {
//     try {
//       debugPrint("🛒 [IAP] Initializing In-App Purchase...");
//
//       _creditManager = creditManager;
//
//       // Load processed transactions from storage
//       await _loadProcessedTransactions();
//
//       // Check availability
//       _available = await _iap.isAvailable();
//
//       if (!_available) {
//         debugPrint("⚠️ [IAP] In-App Purchase not available");
//         return;
//       }
//
//       debugPrint("✅ [IAP] In-App Purchase is available");
//
//       // Set up purchase stream BEFORE anything else
//       _subscription?.cancel();
//       _subscription = _iap.purchaseStream.listen(
//             (purchases) => _handlePurchaseUpdates(purchases, creditManager),
//         onDone: () {
//           debugPrint("🔚 [IAP] Purchase stream closed");
//           _subscription?.cancel();
//         },
//         onError: (error) {
//           debugPrint("❌ [IAP] Stream error: $error");
//         },
//       );
//
//       // Load products
//       await loadProducts();
//
//       // Handle pending iOS transactions
//       if (Platform.isIOS) {
//         await _handlePendingIOSTransactions();
//       }
//
//       debugPrint("🎉 [IAP] Initialization complete");
//     } catch (e, stackTrace) {
//       debugPrint("❌ [IAP] Init error: $e");
//       debugPrint("Stack trace: $stackTrace");
//     }
//   }
//
//   /// Load processed transactions from local storage
//   Future<void> _loadProcessedTransactions() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final List<String> stored = prefs.getStringList(_processedTxnKey) ?? [];
//       _processedTransactionIds.addAll(stored);
//       debugPrint("📂 [IAP] Loaded ${_processedTransactionIds.length} processed transactions");
//     } catch (e) {
//       debugPrint("❌ [IAP] Error loading processed transactions: $e");
//     }
//   }
//
//   /// Save processed transaction to local storage
//   Future<void> _saveProcessedTransaction(String transactionId) async {
//     try {
//       _processedTransactionIds.add(transactionId);
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setStringList(_processedTxnKey, _processedTransactionIds.toList());
//
//       // Also save to purchase history with timestamp
//       await _savePurchaseToHistory(transactionId);
//
//       debugPrint("💾 [IAP] Transaction saved: $transactionId");
//     } catch (e) {
//       debugPrint("❌ [IAP] Error saving transaction: $e");
//     }
//   }
//
//   /// Save purchase to history for fraud detection
//   Future<void> _savePurchaseToHistory(String transactionId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final List<String> history = prefs.getStringList(_purchaseHistoryKey) ?? [];
//
//       final entry = jsonEncode({
//         'txnId': transactionId,
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//
//       history.add(entry);
//
//       // Keep only last 100 transactions
//       if (history.length > 100) {
//         history.removeRange(0, history.length - 100);
//       }
//
//       await prefs.setStringList(_purchaseHistoryKey, history);
//     } catch (e) {
//       debugPrint("❌ [IAP] Error saving to history: $e");
//     }
//   }
//
//   /// Handle pending iOS transactions
//   Future<void> _handlePendingIOSTransactions() async {
//     try {
//       final paymentWrapper = SKPaymentQueueWrapper();
//       final transactions = await paymentWrapper.transactions();
//       debugPrint("🔍 [IAP] Found ${transactions.length} pending iOS transactions");
//
//       for (var transaction in transactions) {
//         final productId = transaction.payment.productIdentifier;
//         final transactionId = transaction.transactionIdentifier ?? '';
//
//         debugPrint("   - Transaction: $productId - State: ${transaction.transactionState}");
//
//         // Skip if already processed
//         if (transactionId.isNotEmpty && _processedTransactionIds.contains(transactionId)) {
//           debugPrint("⏭️ [IAP] Already processed, finishing...");
//           await paymentWrapper.finishTransaction(transaction);
//           continue;
//         }
//
//         if (transaction.transactionState == SKPaymentTransactionStateWrapper.purchased ||
//             transaction.transactionState == SKPaymentTransactionStateWrapper.restored) {
//
//           if (_creditManager != null && productId.isNotEmpty) {
//             final credits = productCredits[productId] ?? 0;
//             if (credits > 0) {
//               final success = await _creditManager!.addCredits(
//                 credits,
//                 reason: 'iap_pending_$productId',
//               );
//
//               if (success && transactionId.isNotEmpty) {
//                 await _saveProcessedTransaction(transactionId);
//                 debugPrint("✅ [IAP] Awarded $credits credits for pending transaction");
//               }
//             }
//           }
//
//           await paymentWrapper.finishTransaction(transaction);
//           debugPrint("✅ [IAP] Finished pending transaction");
//
//         } else if (transaction.transactionState == SKPaymentTransactionStateWrapper.failed) {
//           await paymentWrapper.finishTransaction(transaction);
//           debugPrint("🗑️ [IAP] Cleaned up failed transaction");
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ [IAP] Error handling pending transactions: $e");
//     }
//   }
//
//   /// Load products from store
//   Future<void> loadProducts() async {
//     try {
//       debugPrint("📦 [IAP] Loading products...");
//       _isLoading = true;
//
//       final response = await _iap.queryProductDetails(_productIds);
//
//       if (response.error != null) {
//         debugPrint("❌ [IAP] Load products error: ${response.error}");
//         _isLoading = false;
//         return;
//       }
//
//       if (response.notFoundIDs.isNotEmpty) {
//         debugPrint("⚠️ [IAP] Products not found: ${response.notFoundIDs}");
//       }
//
//       _products = response.productDetails;
//       _isLoading = false;
//
//       debugPrint("✅ [IAP] Loaded ${_products.length} products");
//       for (var product in _products) {
//         debugPrint("   - ${product.id}: ${product.price}");
//       }
//     } catch (e, stackTrace) {
//       debugPrint("❌ [IAP] Load products error: $e");
//       debugPrint("Stack trace: $stackTrace");
//       _isLoading = false;
//     }
//   }
//
//   /// Purchase a product
//   Future<bool> purchaseProduct(ProductDetails product) async {
//     try {
//       debugPrint("💳 [IAP] Initiating purchase: ${product.id}");
//
//       if (_subscription == null || _subscription!.isPaused) {
//         debugPrint("⚠️ [IAP] Purchase stream not active, reinitializing...");
//         if (_creditManager != null) {
//           await init(_creditManager!);
//         }
//       }
//
//       final purchaseParam = PurchaseParam(productDetails: product);
//
//       // Use buyConsumable for consumable products (credits)
//       final result = await _iap.buyConsumable(
//         purchaseParam: purchaseParam,
//         autoConsume: true, // Important: Auto-consume for credits
//       );
//
//       debugPrint("💳 [IAP] Purchase initiated: $result");
//       return result;
//     } catch (e, stackTrace) {
//       debugPrint("❌ [IAP] Purchase error: $e");
//       debugPrint("Stack trace: $stackTrace");
//       return false;
//     }
//   }
//
//   /// Restore purchases
//   Future<RestoreResult> restorePurchases(CreditManager creditManager) async {
//     try {
//       debugPrint("🔄 [IAP] Restoring purchases...");
//
//       if (_subscription == null) {
//         await init(creditManager);
//       }
//
//       _restoreCompleter = Completer<RestoreResult>();
//
//       await _iap.restorePurchases();
//       debugPrint("✅ [IAP] Restore initiated, waiting for completion...");
//
//       final result = await _restoreCompleter!.future.timeout(
//         const Duration(seconds: 15),
//         onTimeout: () {
//           debugPrint("⏱️ [IAP] Restore timeout - assuming no purchases");
//           return RestoreResult(success: true, creditsRestored: 0);
//         },
//       );
//
//       _restoreCompleter = null;
//       return result;
//
//     } catch (e, stackTrace) {
//       debugPrint("❌ [IAP] Restore error: $e");
//       debugPrint("Stack trace: $stackTrace");
//       _restoreCompleter?.completeError(e);
//       _restoreCompleter = null;
//       rethrow;
//     }
//   }
//
//   /// Handle purchase updates
//   Future<void> _handlePurchaseUpdates(
//       List<PurchaseDetails> purchases,
//       CreditManager creditManager,
//       ) async {
//
//     int totalCreditsRestored = 0;
//     bool hasRestoredPurchases = false;
//     bool allRestoresProcessed = true;
//
//     for (var purchase in purchases) {
//       debugPrint("🔔 [IAP] Purchase update: ${purchase.productID} - ${purchase.status}");
//
//       try {
//         final transactionId = purchase.purchaseID ??
//             '${purchase.productID}_${DateTime.now().millisecondsSinceEpoch}';
//
//         if (purchase.status == PurchaseStatus.pending) {
//           debugPrint("⏳ [IAP] Purchase pending: ${purchase.productID}");
//           allRestoresProcessed = false;
//
//         } else if (purchase.status == PurchaseStatus.error) {
//           debugPrint("❌ [IAP] Purchase failed: ${purchase.productID}");
//           debugPrint("   Error: ${purchase.error}");
//
//           if (purchase.pendingCompletePurchase) {
//             await _iap.completePurchase(purchase);
//           }
//
//         } else if (purchase.status == PurchaseStatus.purchased ||
//             purchase.status == PurchaseStatus.restored) {
//
//           hasRestoredPurchases = purchase.status == PurchaseStatus.restored;
//
//           debugPrint("✅ [IAP] Purchase ${purchase.status == PurchaseStatus.restored ? 'restored' : 'successful'}: ${purchase.productID}");
//
//           // Check if already processed (CRITICAL for duplicate prevention)
//           if (_processedTransactionIds.contains(transactionId)) {
//             debugPrint("⏭️ [IAP] Transaction already processed: $transactionId");
//
//             if (purchase.pendingCompletePurchase) {
//               await _iap.completePurchase(purchase);
//             }
//             continue;
//           }
//
//           // Verify purchase (enhanced client-side validation)
//           final isValid = await _verifyPurchase(purchase);
//
//           if (isValid) {
//             final credits = productCredits[purchase.productID] ?? 0;
//
//             if (credits > 0) {
//               debugPrint("💰 [IAP] Awarding $credits credits for ${purchase.productID}");
//
//               final success = await creditManager.addCredits(
//                 credits,
//                 reason: purchase.status == PurchaseStatus.restored
//                     ? 'iap_restored_${purchase.productID}'
//                     : 'iap_${purchase.productID}',
//               );
//
//               if (success) {
//                 debugPrint("✅ [IAP] Successfully added $credits credits");
//                 await _saveProcessedTransaction(transactionId);
//
//                 if (purchase.status == PurchaseStatus.restored) {
//                   totalCreditsRestored += credits;
//                 }
//               } else {
//                 debugPrint("⚠️ [IAP] Failed to add credits");
//                 allRestoresProcessed = false;
//               }
//             }
//           } else {
//             debugPrint("❌ [IAP] Purchase verification failed: ${purchase.productID}");
//             allRestoresProcessed = false;
//           }
//
//           if (purchase.pendingCompletePurchase) {
//             await _iap.completePurchase(purchase);
//             debugPrint("✅ [IAP] Purchase completed: ${purchase.productID}");
//           }
//         }
//       } catch (e, stackTrace) {
//         debugPrint("❌ [IAP] Error processing purchase ${purchase.productID}: $e");
//         debugPrint("Stack trace: $stackTrace");
//         allRestoresProcessed = false;
//
//         if (purchase.pendingCompletePurchase) {
//           try {
//             await _iap.completePurchase(purchase);
//           } catch (completeError) {
//             debugPrint("❌ [IAP] Error completing purchase: $completeError");
//           }
//         }
//       }
//     }
//
//     // Complete restore operation if in progress
//     if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       _restoreCompleter!.complete(RestoreResult(
//         success: allRestoresProcessed,
//         creditsRestored: totalCreditsRestored,
//       ));
//     }
//   }
//
//   /// Enhanced client-side receipt verification
//   ///
//   /// NOTE: This is NOT as secure as backend verification, but:
//   /// ✅ Acceptable for App Store Review
//   /// ✅ Prevents basic tampering
//   /// ✅ Works without backend server
//   /// ⚠️ Can be bypassed by sophisticated attackers
//   Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
//     try {
//       debugPrint("🔐 [IAP] Verifying purchase: ${purchase.productID}");
//
//       // 1. Check receipt data exists
//       final receiptData = purchase.verificationData.localVerificationData;
//       if (receiptData.isEmpty) {
//         debugPrint("❌ [IAP] No receipt data found");
//         return false;
//       }
//
//       // 2. Platform-specific validation
//       if (Platform.isIOS) {
//         return await _verifyIOSPurchase(purchase, receiptData);
//       } else if (Platform.isAndroid) {
//         return await _verifyAndroidPurchase(purchase);
//       }
//
//       debugPrint("⚠️ [IAP] Unknown platform");
//       return false;
//
//     } catch (e, stackTrace) {
//       debugPrint("❌ [IAP] Verification error: $e");
//       debugPrint("Stack trace: $stackTrace");
//       return false;
//     }
//   }
//
//   /// Verify iOS purchase
//   Future<bool> _verifyIOSPurchase(PurchaseDetails purchase, String receiptData) async {
//     try {
//       // Basic checks
//       if (receiptData.length < 100) {
//         debugPrint("❌ [IAP] Receipt too short");
//         return false;
//       }
//
//       // Check if it's valid base64
//       try {
//         base64Decode(receiptData);
//       } catch (e) {
//         debugPrint("❌ [IAP] Invalid base64 receipt");
//         return false;
//       }
//
//       // Verify product ID is in our list
//       if (!productCredits.containsKey(purchase.productID)) {
//         debugPrint("❌ [IAP] Unknown product ID: ${purchase.productID}");
//         return false;
//       }
//
//       // Check purchase date is reasonable (not in future, not too old)
//       if (purchase.transactionDate != null) {
//         final purchaseDate = DateTime.parse(purchase.transactionDate!);
//         final now = DateTime.now();
//
//         if (purchaseDate.isAfter(now)) {
//           debugPrint("❌ [IAP] Purchase date in future");
//           return false;
//         }
//
//         // Don't accept purchases older than 90 days during restore
//         if (purchase.status == PurchaseStatus.restored) {
//           final daysSincePurchase = now.difference(purchaseDate).inDays;
//           if (daysSincePurchase > 90) {
//             debugPrint("⚠️ [IAP] Purchase too old (${daysSincePurchase} days)");
//             // Still return true but log warning
//           }
//         }
//       }
//
//       // Additional iOS-specific checks using StoreKit data
//       if (purchase is AppStorePurchaseDetails) {
//         final skPayment = SKPaymentWrapper(
//           productIdentifier: purchase.productID,
//         );
//
//         // Verify the product identifier matches
//         if (skPayment.productIdentifier != purchase.productID) {
//           debugPrint("❌ [IAP] Product ID mismatch");
//           return false;
//         }
//       }
//
//       debugPrint("✅ [IAP] iOS purchase verification passed");
//       return true;
//
//     } catch (e) {
//       debugPrint("❌ [IAP] iOS verification error: $e");
//       return false;
//     }
//   }
//
//   /// Verify Android purchase
//   Future<bool> _verifyAndroidPurchase(PurchaseDetails purchase) async {
//     try {
//       // Check server verification data
//       final serverData = purchase.verificationData.serverVerificationData;
//       if (serverData.isEmpty) {
//         debugPrint("❌ [IAP] No server verification data");
//         return false;
//       }
//
//       // Verify product ID
//       if (!productCredits.containsKey(purchase.productID)) {
//         debugPrint("❌ [IAP] Unknown product ID: ${purchase.productID}");
//         return false;
//       }
//
//       // Parse purchase data (JSON format from Google Play)
//       try {
//         final purchaseData = jsonDecode(serverData);
//
//         // Verify product ID matches
//         if (purchaseData['productId'] != purchase.productID) {
//           debugPrint("❌ [IAP] Product ID mismatch");
//           return false;
//         }
//
//         // Check purchase state (0 = purchased)
//         if (purchaseData['purchaseState'] != 0) {
//           debugPrint("❌ [IAP] Invalid purchase state");
//           return false;
//         }
//
//       } catch (e) {
//         debugPrint("⚠️ [IAP] Could not parse purchase data: $e");
//         // Continue with basic validation
//       }
//
//       debugPrint("✅ [IAP] Android purchase verification passed");
//       return true;
//
//     } catch (e) {
//       debugPrint("❌ [IAP] Android verification error: $e");
//       return false;
//     }
//   }
//
//   /// Get purchase history (for debugging/support)
//   Future<List<Map<String, dynamic>>> getPurchaseHistory() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final List<String> history = prefs.getStringList(_purchaseHistoryKey) ?? [];
//
//       return history.map((entry) {
//         try {
//           return jsonDecode(entry) as Map<String, dynamic>;
//         } catch (e) {
//           return <String, dynamic>{};
//         }
//       }).where((item) => item.isNotEmpty).toList();
//     } catch (e) {
//       debugPrint("❌ [IAP] Error getting history: $e");
//       return [];
//     }
//   }
//
//   /// Clear processed transactions (for testing only)
//   Future<void> clearProcessedTransactions() async {
//     try {
//       _processedTransactionIds.clear();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_processedTxnKey);
//       await prefs.remove(_purchaseHistoryKey);
//       debugPrint("🧹 [IAP] Cleared all processed transactions");
//     } catch (e) {
//       debugPrint("❌ [IAP] Error clearing transactions: $e");
//     }
//   }
//
//   /// Dispose
//   void dispose() {
//     debugPrint("🗑️ [IAP] Disposing IAP Manager");
//     _subscription?.cancel();
//     _subscription = null;
//     _creditManager = null;
//     _restoreCompleter?.completeError(Exception('IAP Manager disposed'));
//     _restoreCompleter = null;
//   }
// }
//
// /// Result of restore purchases operation
// class RestoreResult {
//   final bool success;
//   final int creditsRestored;
//
//   RestoreResult({
//     required this.success,
//     required this.creditsRestored,
//   });
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'credit_manager.dart';

/// ya bilkul thk ha aur jo last wala ha wo improvment ha lakin usy check karna ka purchase aur restore thk kaam kar raha ka ni
class IAPManager {
  static final IAPManager _instance = IAPManager._internal();
  factory IAPManager() => _instance;
  IAPManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;
  CreditManager? _creditManager;

  // Track restored purchases
  final Set<String> _processedTransactionIds = {};
  Completer<RestoreResult>? _restoreCompleter;

  bool get isAvailable => _available;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;

  /// Product IDs - Must match App Store Connect exactly
  static const Map<String, int> productCredits = {
    'com.vectorioslabs.renovaeai.starter.pack': 250,
    'com.vectorioslabs.renovaeai.basic.pack': 1000,
    'com.vectorioslabs.renovaeai.pro.pack': 2500,
    'com.vectorioslabs.renovaeai.enterprise.pack': 5000,
  };

  static const Set<String> _productIds = {
    'com.vectorioslabs.renovaeai.starter.pack',
    'com.vectorioslabs.renovaeai.basic.pack',
    'com.vectorioslabs.renovaeai.pro.pack',
    'com.vectorioslabs.renovaeai.enterprise.pack',
  };

  /// Initialize IAP
  Future<void> init(CreditManager creditManager) async {
    try {
      debugPrint("🛒 [IAP] Initializing In-App Purchase...");

      _creditManager = creditManager;

      // Check availability first
      _available = await _iap.isAvailable();

      if (!_available) {
        debugPrint("⚠️ [IAP] In-App Purchase not available");
        return;
      }

      debugPrint("✅ [IAP] In-App Purchase is available");

      // Set up purchase stream BEFORE anything else
      _subscription?.cancel();
      _subscription = _iap.purchaseStream.listen(
            (purchases) => _handlePurchaseUpdates(purchases, creditManager),
        onDone: () {
          debugPrint("🔚 [IAP] Purchase stream closed");
          _subscription?.cancel();
        },
        onError: (error) {
          debugPrint("❌ [IAP] Stream error: $error");
        },
      );

      // Load products
      await loadProducts();

      // Handle pending purchases on iOS
      if (Platform.isIOS) {
        await _handlePendingIOSTransactions();
      }

      debugPrint("🎉 [IAP] Initialization complete");
    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Init error: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  /// Handle pending iOS transactions
  Future<void> _handlePendingIOSTransactions() async {
    try {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      debugPrint("🔍 [IAP] Found ${transactions.length} pending iOS transactions");

      for (var transaction in transactions) {
        debugPrint("   - Transaction: ${transaction.payment.productIdentifier} - State: ${transaction.transactionState}");

        final transactionId = transaction.transactionIdentifier ?? '';

        // Skip if already processed
        if (transactionId.isNotEmpty && _processedTransactionIds.contains(transactionId)) {
          debugPrint("⏭️ [IAP] Transaction already processed, finishing...");
          await paymentWrapper.finishTransaction(transaction);
          continue;
        }

        // Only finish completed or restored transactions
        if (transaction.transactionState == SKPaymentTransactionStateWrapper.purchased ||
            transaction.transactionState == SKPaymentTransactionStateWrapper.restored) {

          // Award credits if not already awarded
          if (_creditManager != null && transaction.payment.productIdentifier.isNotEmpty) {
            final credits = productCredits[transaction.payment.productIdentifier] ?? 0;
            if (credits > 0) {
              await _creditManager!.addCredits(
                credits,
                reason: 'iap_pending_${transaction.payment.productIdentifier}',
              );
              debugPrint("✅ [IAP] Awarded $credits credits for pending transaction");

              // Mark as processed
              if (transactionId.isNotEmpty) {
                _processedTransactionIds.add(transactionId);
              }
            }
          }

          await paymentWrapper.finishTransaction(transaction);
          debugPrint("✅ [IAP] Finished pending transaction: ${transaction.payment.productIdentifier}");
        } else if (transaction.transactionState == SKPaymentTransactionStateWrapper.failed) {
          await paymentWrapper.finishTransaction(transaction);
          debugPrint("🗑️ [IAP] Cleaned up failed transaction");
        }
      }
    } catch (e) {
      debugPrint("❌ [IAP] Error handling pending transactions: $e");
    }
  }

  /// Load products from App Store
  Future<void> loadProducts() async {
    try {
      debugPrint("📦 [IAP] Loading products...");
      _isLoading = true;

      final response = await _iap.queryProductDetails(_productIds);

      if (response.error != null) {
        debugPrint("❌ [IAP] Load products error: ${response.error}");
        _isLoading = false;
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("⚠️ [IAP] Products not found: ${response.notFoundIDs}");
      }

      _products = response.productDetails;
      _isLoading = false;

      debugPrint("✅ [IAP] Loaded ${_products.length} products");
      for (var product in _products) {
        debugPrint("   - ${product.id}: ${product.price}");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Load products error: $e");
      debugPrint("Stack trace: $stackTrace");
      _isLoading = false;
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      debugPrint("💳 [IAP] Initiating purchase: ${product.id}");

      // Verify purchase stream is active
      if (_subscription == null || _subscription!.isPaused) {
        debugPrint("⚠️ [IAP] Purchase stream not active, reinitializing...");
        if (_creditManager != null) {
          await init(_creditManager!);
        }
      }

      final purchaseParam = PurchaseParam(productDetails: product);

      final result = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      debugPrint("💳 [IAP] Purchase initiated: $result");
      return result;
    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Purchase error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  /// Restore purchases with proper completion handling
  Future<RestoreResult> restorePurchases(CreditManager creditManager) async {
    try {
      debugPrint("🔄 [IAP] Restoring purchases...");

      // Ensure purchase stream is active
      if (_subscription == null) {
        await init(creditManager);
      }

      // Create a completer to track restoration completion
      _restoreCompleter = Completer<RestoreResult>();

      // Start the restore
      await _iap.restorePurchases();
      debugPrint("✅ [IAP] Restore initiated, waiting for completion...");

      // Wait for restoration to complete (with timeout)
      final result = await _restoreCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint("⏱️ [IAP] Restore timeout - assuming no purchases to restore");
          return RestoreResult(success: true, creditsRestored: 0);
        },
      );

      _restoreCompleter = null;
      return result;

    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Restore error: $e");
      debugPrint("Stack trace: $stackTrace");
      _restoreCompleter?.completeError(e);
      _restoreCompleter = null;
      rethrow;
    }
  }

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases,
      CreditManager creditManager,
      ) async {

    int totalCreditsRestored = 0;
    bool hasRestoredPurchases = false;
    bool allRestoresProcessed = true;

    for (var purchase in purchases) {
      debugPrint("🔔 [IAP] Purchase update: ${purchase.productID} - ${purchase.status}");

      try {
        // Generate a unique transaction ID for tracking
        final transactionId = purchase.purchaseID ?? '${purchase.productID}_${DateTime.now().millisecondsSinceEpoch}';

        if (purchase.status == PurchaseStatus.pending) {
          debugPrint("⏳ [IAP] Purchase pending: ${purchase.productID}");
          allRestoresProcessed = false;

        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint("❌ [IAP] Purchase failed: ${purchase.productID}");
          debugPrint("   Error: ${purchase.error}");

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }

        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {

          hasRestoredPurchases = purchase.status == PurchaseStatus.restored;

          debugPrint("✅ [IAP] Purchase ${purchase.status == PurchaseStatus.restored ? 'restored' : 'successful'}: ${purchase.productID}");

          // Check if already processed
          if (_processedTransactionIds.contains(transactionId)) {
            debugPrint("⏭️ [IAP] Transaction already processed: $transactionId");

            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            continue;
          }

          // Verify purchase receipt
          final isValid = await _verifyPurchase(purchase);

          if (isValid) {
            final credits = productCredits[purchase.productID] ?? 0;

            if (credits > 0) {
              debugPrint("💰 [IAP] Awarding $credits credits for ${purchase.productID}");

              final success = await creditManager.addCredits(
                credits,
                reason: purchase.status == PurchaseStatus.restored
                    ? 'iap_restored_${purchase.productID}'
                    : 'iap_${purchase.productID}',
              );

              if (success) {
                debugPrint("✅ [IAP] Successfully added $credits credits");
                _processedTransactionIds.add(transactionId);

                if (purchase.status == PurchaseStatus.restored) {
                  totalCreditsRestored += credits;
                }
              } else {
                debugPrint("⚠️ [IAP] Failed to add credits");
                allRestoresProcessed = false;
              }
            }
          } else {
            debugPrint("❌ [IAP] Purchase verification failed: ${purchase.productID}");
            allRestoresProcessed = false;
          }

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
            debugPrint("✅ [IAP] Purchase completed: ${purchase.productID}");
          }
        }
      } catch (e, stackTrace) {
        debugPrint("❌ [IAP] Error processing purchase ${purchase.productID}: $e");
        debugPrint("Stack trace: $stackTrace");
        allRestoresProcessed = false;

        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (completeError) {
            debugPrint("❌ [IAP] Error completing purchase: $completeError");
          }
        }
      }
    }

    // Complete the restore operation if one is in progress
    if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
      // Give a small delay to ensure all purchases are processed
      await Future.delayed(const Duration(milliseconds: 500));

      _restoreCompleter!.complete(RestoreResult(
        success: allRestoresProcessed,
        creditsRestored: totalCreditsRestored,
      ));
    }
  }

  /// Verify purchase receipt
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      debugPrint("🔐 [IAP] Verifying purchase: ${purchase.productID}");

      if (purchase.verificationData.localVerificationData.isEmpty) {
        debugPrint("❌ [IAP] No receipt data found");
        return false;
      }

      if (Platform.isIOS) {
        final receiptData = purchase.verificationData.localVerificationData;
        debugPrint("📄 [IAP] iOS receipt length: ${receiptData.length} chars");
        return receiptData.isNotEmpty;
      }

      if (Platform.isAndroid) {
        return purchase.verificationData.serverVerificationData.isNotEmpty;
      }

      debugPrint("⚠️ [IAP] Unknown platform for verification");
      return false;

    } catch (e, stackTrace) {
      debugPrint("❌ [IAP] Verification error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  /// Dispose
  void dispose() {
    debugPrint("🗑️ [IAP] Disposing IAP Manager");
    _subscription?.cancel();
    _subscription = null;
    _creditManager = null;
    _restoreCompleter?.completeError(Exception('IAP Manager disposed'));
    _restoreCompleter = null;
    _processedTransactionIds.clear();
  }
}

/// Result of restore purchases operation
class RestoreResult {
  final bool success;
  final int creditsRestored;

  RestoreResult({
    required this.success,
    required this.creditsRestored,
  });
}