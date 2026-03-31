

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CreditManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;
  bool _isInitInProgress = false;
  Completer<void>? _initCompleter;

  static const int _initialCredits = 10;

  int _credits = 0;
  bool _isLoading = true;
  bool _hasPurchased = false; 

  int get credits => _credits;
  bool get isLoading => _isLoading;
  //bool get hasPurchased => _hasPurchased;

  bool get hasPurchased => false;

  CreditManager() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        init();
      } else {
        _resetState();
      }
    });

    if (_auth.currentUser != null) {
      init();
    }
  }

  /// Initialize credit manager - fetch from Firestore
  Future<void> init() async {
    if (_isInitInProgress) {
      return _initCompleter?.future ?? Future.value();
    }
    _isInitInProgress = true;
    _isLoading = true;
    _initCompleter = Completer<void>();
    notifyListeners();

    try {
      debugPrint("💳 [CreditManager] Initializing...");

      final user = _auth.currentUser;
      if (user == null) {
        debugPrint("❌ [CreditManager] No user logged in");
        return;
      }

      // ✅ FIXED: Use 'user_credits' collection consistently
      final docRef = _firestore.collection('user_credits').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // First time user - create document with initial credits
        debugPrint("🎁 [CreditManager] First time user - giving $_initialCredits free credits");

        await docRef.set({
          'credits': _initialCredits,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'transactions': [],
        });

        _credits = _initialCredits;
      } else {
        // Existing user - load credits
        final data = docSnapshot.data() as Map<String, dynamic>;
        _credits = data['credits'] ?? 0;
        
        // Check if any transaction is a purchase
        final List<dynamic> transactions = data['transactions'] ?? [];
        _hasPurchased = transactions.any((t) => t['type'] == 'credit' && (t['reason']?.toString().contains('iap') ?? false));
        
        debugPrint("💰 [CreditManager] Loaded credits: $_credits");
        if (_hasPurchased) {
          debugPrint("💎 [CreditManager] PAID TIER — user has purchased.");
        } else {
          debugPrint("🆓 [CreditManager] FREE TIER — no purchase found.");
        }

      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Init error: $e");
      _credits = 0;
    } finally {
      _isLoading = false;
      _isInitInProgress = false;
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
      _initCompleter = null;
      notifyListeners();
    }
  }

  /// Add credits to Firestore
  /// ✅ FIXED: Now uses 'user_credits' collection
  Future<bool> addCredits(int amount, {String? reason}) async {
    try {
      final user = _auth.currentUser;
      print("💰 [CreditManager] Adding $amount credits for user: ${user?.uid}");
      print("💰 [CreditManager] Reason: $reason");

      if (user == null) {
        print("❌ [CreditManager] No user logged in");
        return false;
      }

      // ✅ FIXED: Use 'user_credits' collection
      final docRef = _firestore.collection('user_credits').doc(user.uid);

      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Credit document doesn't exist. Call init() first.");
        }

        final currentCredits = snapshot.data()?['credits'] ?? 0;
        final newCredits = currentCredits + amount;

        // Create transaction record
        final transactionRecord = {
          'type': 'credit',
          'amount': amount,
          'reason': reason ?? 'purchase',
          'timestamp': DateTime.now().toIso8601String(),
          'balanceAfter': newCredits,
        };

        transaction.update(docRef, {
          'credits': newCredits,
          'updatedAt': FieldValue.serverTimestamp(),
          'transactions': FieldValue.arrayUnion([transactionRecord]),
        });
      });

      // Update local state
      _credits += amount;
      if (reason != null && reason.contains('iap')) {
        _hasPurchased = true;
        
        // Also update the users collection to set subscription to true
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'subscription': true,
          }, SetOptions(merge: true));
          print("✅ [CreditManager] User subscription status updated to true in Firestore");
        } catch (e) {
          print("❌ [CreditManager] Error updating user subscription status: $e");
        }
      }
      print("✅ [CreditManager] Credits added. New balance: $_credits");
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ [CreditManager] Error adding credits: $e");
      return false;
    }
  }

  /// Deduct credits from Firestore
  Future<bool> deductCredits(int amount, {String reason = 'usage'}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint("❌ [CreditManager] No user logged in");
        return false;
      }

      if (_credits < amount) {
        debugPrint("⚠️ [CreditManager] Insufficient credits. Need: $amount, Have: $_credits");
        return false;
      }

      debugPrint("➖ [CreditManager] Deducting $amount credits (reason: $reason)");

      final docRef = _firestore.collection('user_credits').doc(user.uid);

      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Credit document doesn't exist");
        }

        final currentCredits = snapshot.data()?['credits'] ?? 0;

        if (currentCredits < amount) {
          throw Exception("Insufficient credits in Firestore");
        }

        final newCredits = currentCredits - amount;

        // Create transaction record
        final transactionRecord = {
          'type': 'debit',
          'amount': amount,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
          'balanceAfter': newCredits,
        };

        transaction.update(docRef, {
          'credits': newCredits,
          'updatedAt': FieldValue.serverTimestamp(),
          'transactions': FieldValue.arrayUnion([transactionRecord]),
        });
      });

      // Update local state
      _credits -= amount;
      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Deduct credits error: $e");
      return false;
    }
  }

  /// Check if user has enough credits
  bool hasEnoughCredits(int required) {
    return _credits >= required;
  }

  /// Refresh credits from Firestore
  /// ✅ FIXED: Now uses 'user_credits' collection
  Future<void> refreshCredits() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore.collection('user_credits').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _credits = data['credits'] ?? 0;
        debugPrint("🔄 [CreditManager] Refreshed credits: $_credits");
      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Refresh error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final docRef = _firestore.collection('user_credits').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final transactions = data['transactions'] as List<dynamic>? ?? [];

        return transactions
            .map((t) => t as Map<String, dynamic>)
            .toList()
            .reversed
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ [CreditManager] Get history error: $e");
      return [];
    }
  }

  /// Reset purchase status - removes all IAP transactions from Firestore
  /// Use this to reset a test account back to FREE tier
  Future<void> resetPurchaseStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint("🔄 [CreditManager] Resetting purchase status to FREE TIER");

      final docRef = _firestore.collection('user_credits').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> transactions = data['transactions'] ?? [];

        // Remove all IAP credit transactions
        final filteredTransactions = transactions.where((t) {
          final reason = t['reason']?.toString() ?? '';
          return !(t['type'] == 'credit' && reason.contains('iap'));
        }).toList();

        await docRef.update({
          'transactions': filteredTransactions,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _hasPurchased = false;
      notifyListeners();
      debugPrint("✅ [CreditManager] Purchase status reset. User is now FREE TIER.");
    } catch (e) {
      debugPrint("❌ [CreditManager] Reset purchase error: $e");
    }
  }

  /// Reset credits (for testing only - remove in production)
  Future<void> resetCredits() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint("🔄 [CreditManager] Resetting credits");

      final docRef = _firestore.collection('user_credits').doc(user.uid);
      await docRef.delete();

      _credits = 0;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [CreditManager] Reset error: $e");
    }
  }

  void _resetState() {
    _credits = 0;
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

