/*
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditManager extends ChangeNotifier {
  static const String _creditKey = 'user_credits';
  static const String _firstLaunchKey = 'first_launch';
  static const int _initialCredits = 30;
  static const int _rewardedAdCredits = 3;

  int _credits = 0;
  bool _isLoading = true;

  int get credits => _credits;
  bool get isLoading => _isLoading;

  /// Initialize credit manager
  Future<void> init() async {
    try {
      debugPrint("💳 [CreditManager] Initializing...");
      final prefs = await SharedPreferences.getInstance();

      // Check if first launch
      final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

      if (isFirstLaunch) {
        debugPrint("🎁 [CreditManager] First launch - giving \$\_initialCredits free credits");
        _credits = _initialCredits;
        await prefs.setInt(_creditKey, _initialCredits);
        await prefs.setBool(_firstLaunchKey, false);
      } else {
        _credits = prefs.getInt(_creditKey) ?? 0;
        debugPrint("💰 [CreditManager] Loaded credits: $_credits");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [CreditManager] Init error: $e");
      _credits = 0;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add credits
  Future<bool> addCredits(int amount, {String reason = 'purchase'}) async {
    try {
      debugPrint("➕ [CreditManager] Adding $amount credits (reason: $reason)");

      _credits += amount;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, _credits);

      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Add credits error: $e");
      return false;
    }
  }

  /// Deduct credits
  Future<bool> deductCredits(int amount, {String reason = 'usage'}) async {
    try {
      if (_credits < amount) {
        debugPrint("⚠️ [CreditManager] Insufficient credits. Need: $amount, Have: $_credits");
        return false;
      }

      debugPrint("➖ [CreditManager] Deducting $amount credits (reason: $reason)");

      _credits -= amount;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, _credits);

      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Deduct credits error: $e");
      return false;
    }
  }

  /// Reward user with credits for watching ad
  Future<bool> rewardForAd() async {
    return await addCredits(_rewardedAdCredits, reason: 'rewarded_ad');
  }

  /// Check if user has enough credits
  bool hasEnoughCredits(int required) {
    return _credits >= required;
  }

  /// Get rewarded ad credits amount
  static int get rewardedAdCredits => _rewardedAdCredits;

  /// Reset credits (for testing)
  Future<void> resetCredits() async {
    try {
      debugPrint("🔄 [CreditManager] Resetting credits");
      _credits = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditKey, 0);
      await prefs.setBool(_firstLaunchKey, true);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [CreditManager] Reset error: $e");
    }
  }
}*/


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

  static const int _initialCredits = 30;
  static const int _rewardedAdCredits = 3;

  int _credits = 0;
  bool _isLoading = true;

  int get credits => _credits;
  bool get isLoading => _isLoading;
  static int get rewardedAdCredits => _rewardedAdCredits;

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
        debugPrint("💰 [CreditManager] Loaded credits: $_credits");
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

  /// Reward user with credits for watching ad
  Future<bool> rewardForAd() async {
    return await addCredits(_rewardedAdCredits, reason: 'rewarded_ad');
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

/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int _initialCredits = 30;
  static const int _rewardedAdCredits = 3;
  static const String _creditsKey = 'user_credits_balance';

  int _credits = 0;
  bool _isLoading = true;

  int get credits => _credits;
  bool get isLoading => _isLoading;
  static int get rewardedAdCredits => _rewardedAdCredits;

  /// Initialize credit manager - fetch from Firestore and cache in SharedPreferences
  Future<void> init() async {
    try {
      debugPrint("💳 [CreditManager] Initializing...");

      final user = _auth.currentUser;
      if (user == null) {
        debugPrint("❌ [CreditManager] No user logged in");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // First load from SharedPreferences for instant display
      await _loadFromPrefs();

      // Then fetch from Firestore
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
        debugPrint("💰 [CreditManager] Loaded credits from Firestore: $_credits");
      }

      // Save to SharedPreferences
      await _saveToPrefs();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [CreditManager] Init error: $e");
      _credits = 0;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load credits from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _credits = prefs.getInt(_creditsKey) ?? 0;
      if (_credits > 0) {
        debugPrint("📂 [CreditManager] Loaded from SharedPreferences: $_credits");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Error loading from prefs: $e");
    }
  }

  /// Save credits to SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_creditsKey, _credits);
      debugPrint("💾 [CreditManager] Saved to SharedPreferences: $_credits");
    } catch (e) {
      debugPrint("❌ [CreditManager] Error saving to prefs: $e");
    }
  }

  /// Clear credits from SharedPreferences (on logout)
  static Future<void> clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_creditsKey);
      debugPrint("🗑️ [CreditManager] Cleared SharedPreferences");
    } catch (e) {
      debugPrint("❌ [CreditManager] Error clearing prefs: $e");
    }
  }

  /// Add credits to Firestore and SharedPreferences
  Future<bool> addCredits(int amount, {String? reason}) async {
    try {
      final user = _auth.currentUser;
      debugPrint("💰 [CreditManager] Adding $amount credits for user: ${user?.uid}");
      debugPrint("💰 [CreditManager] Reason: $reason");

      if (user == null) {
        debugPrint("❌ [CreditManager] No user logged in");
        return false;
      }

      final docRef = _firestore.collection('user_credits').doc(user.uid);

      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Credit document doesn't exist");
        }

        final currentCredits = snapshot.data()?['credits'] ?? 0;
        final newCredits = currentCredits + amount;

        // Create transaction record
        final transactionRecord = {
          'type': 'credit',
          'amount': amount,
          'reason': reason ?? 'unknown',
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
      await _saveToPrefs();

      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Add credits error: $e");
      return false;
    }
  }

  /// Deduct credits from Firestore and SharedPreferences
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
      await _saveToPrefs();

      debugPrint("✅ [CreditManager] New balance: $_credits");
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ [CreditManager] Deduct credits error: $e");
      return false;
    }
  }

  /// Reward user with credits for watching ad
  Future<bool> rewardForAd() async {
    return await addCredits(_rewardedAdCredits, reason: 'rewarded_ad');
  }

  /// Check if user has enough credits
  bool hasEnoughCredits(int required) {
    return _credits >= required;
  }

  /// Refresh credits from Firestore
  Future<void> refreshCredits() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore.collection('user_credits').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _credits = data['credits'] ?? 0;
        await _saveToPrefs();

        debugPrint("🔄 [CreditManager] Refreshed credits: $_credits");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ [CreditManager] Refresh error: $e");
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

  /// Reset credits (for testing only - remove in production)
  Future<void> resetCredits() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint("🔄 [CreditManager] Resetting credits");

      final docRef = _firestore.collection('user_credits').doc(user.uid);
      await docRef.delete();

      _credits = 0;
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [CreditManager] Reset error: $e");
    }
  }
}*/
