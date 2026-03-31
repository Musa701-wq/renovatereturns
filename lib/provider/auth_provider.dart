

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../services/database_services.dart';
import '../in_app_purchase/credit_manager.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  UserModel? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    _currentUser = await UserModel.getFromPrefs();
    _isLoading = false;
    notifyListeners();
  }

  Future<UserModel?> fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel(
          uid: data['uid'] ?? uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'])
              : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print("Error fetching user from Firestore: $e");
      return null;
    }
  }

  Future<void> _storeUserData(User user, CreditManager creditManager) async {
    try {
      final uid = user.uid;

      // Check existing user
      UserModel? existingUser = await fetchUserFromFirestore(uid);

      UserModel userModel;

      if (existingUser != null) {
        // Existing user
        userModel = existingUser.copyWith(
          photoUrl: existingUser.photoUrl?.isNotEmpty == true
              ? existingUser.photoUrl
              : user.photoURL,
        );
      } else {
        // New user
        userModel = UserModel.fromFirebaseUser(user);
      }

      // Save to Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': userModel.name,
        'email': userModel.email,
        'photoUrl': userModel.photoUrl,
        'createdAt': userModel.createdAt?.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Save to local preferences
      await userModel.saveToPrefs();
      _currentUser = userModel;

      // ✅ IMPORTANT: Initialize credits after user data is stored
      await creditManager.init();

      notifyListeners();

    } catch (e) {
      print("Error storing user data: $e");
      rethrow;
    }
  }

  Future<bool> loginWithGoogle(CreditManager creditManager) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.signInWithGoogle();
      if (user == null) return false;

      await _storeUserData(user, creditManager);
      return true;
    } catch (e) {
      print("Google login error in provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithApple(CreditManager creditManager) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.signInWithApple();
      if (user == null) return false;

      await _storeUserData(user, creditManager);
      return true;
    } catch (e) {
      print("Apple login error in provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await UserModel.clearPrefs();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print("Sign out error: $e");
    }
  }


  Future<void> _clearLocalDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteAllImages();
      print('Local database cleared successfully');
    } catch (e) {
      print('Error clearing local database: $e');
    }
  }

  User? getFirebaseUser() {
    return _auth.currentUser;
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? photoBase64,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_currentUser == null) throw Exception('No user logged in');

      final Map<String, dynamic> updateData = {
        'name': name,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (photoBase64 != null && photoBase64.isNotEmpty) {
        updateData['photoUrl'] = photoBase64;
      }

      await _firestore.collection('users').doc(_currentUser!.uid).update(updateData);

      final updatedUser = _currentUser!.copyWith(
        name: name,
        photoUrl: photoBase64 ?? _currentUser!.photoUrl,
        updatedAt: DateTime.now(),
      );

      await updatedUser.saveToPrefs();
      _currentUser = updatedUser;
      notifyListeners();

    } catch (e) {
      print('Error updating profile in provider: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final uid = user.uid;

      // Delete user credits
     // await _firestore.collection('user_credits').doc(uid).delete();
      await _auth.signOut();
      await UserModel.clearPrefs();

      _currentUser = null;

      notifyListeners();

    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        throw Exception('requires-recent-login');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}