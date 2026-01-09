// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// GOOGLE LOGIN
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Google sign in error: $e");
      rethrow;
    }
  }

  /// APPLE LOGIN (SIMPLIFIED - NO NAME HANDLING FOR NOW)
  Future<User?> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available
      if (!await SignInWithApple.isAvailable()) {
        throw Exception("Apple Sign-In is not available on this device");
      }

      // Request credentials - email only for now
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
        ],
      );

      // Create OAuth credential for Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      return userCredential.user;
    } catch (e) {
      print("Apple sign in error: $e");
      rethrow;
    }
  }
}