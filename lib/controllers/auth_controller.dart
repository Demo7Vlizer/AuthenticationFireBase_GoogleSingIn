// ignore_for_file: unused_catch_stack

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Change to late initialization
  late final Rx<User?> user;

  @override
  void onInit() {
    super.onInit();
    // Initialize user
    user = Rx<User?>(_auth.currentUser);
    // Bind stream after initialization
    ever(user, _handleAuthChanged);
    user.bindStream(_auth.authStateChanges());
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      if (Get.currentRoute != '/login' && Get.currentRoute != '/signup') {
        Get.offAllNamed('/login');
      }
    } else {
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    }
  }

  // Email/Password Sign Up
  Future<void> signUp(String email, String password, String name) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        // Update profile
        await userCredential.user?.updateDisplayName(name.trim());

        // Add user to Firestore
        final userData = {
          'email': email.trim(),
          'name': name.trim(),
          'provider': 'email',
          'photoUrl': null,
          'lastSignIn': FieldValue.serverTimestamp(),
        };

        final dbService = Get.find<DatabaseService>();
        await dbService.addUser(userCredential.user!.uid, userData);
      }

      Get.back(); // Close loading
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

      Get.offAllNamed('/login');
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to create account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  // Email/Password Sign In
  Future<void> signIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter email and password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = _auth.currentUser;
      if (user != null) {
        await Get.find<DatabaseService>().updateUserLoginTime(user.uid);
      }

      Get.back(); // Close loading dialog
    } on FirebaseAuthException catch (e) {
      Get.back(); // Close loading dialog
      _handleAuthError(e);
    }
  }

  // Add error handler method
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Wrong password';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      default:
        message = e.message ?? 'An error occurred';
    }
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Sign out of any previous sessions
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.back();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        try {
          final userData = {
            'email': user.email ?? '',
            'name': user.displayName ?? '',
            'photoUrl': user.photoURL,
            'provider': 'google',
            'lastSignIn': FieldValue.serverTimestamp(),
          };

          await Get.find<DatabaseService>().addUser(user.uid, userData);
          Get.offAllNamed('/home');
        } catch (e) {
          print('Database Error: $e');
        }
      }
      Get.back();
    } catch (e) {
      print('Google Sign In Error: $e');
      Get.back();
    }
  }

  // Apple Sign In
  Future<void> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      await _auth.signInWithCredential(oauthCredential);
      Get.snackbar('Success', 'Sign in successful');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  // Helper method for Apple Sign In
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Add this method to AuthController
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    size: 32,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Check Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                // Email Address
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                // Steps
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStep(1, 'Check your email'),
                      const SizedBox(height: 12),
                      _buildStep(2, 'Click the reset link'),
                      const SizedBox(height: 12),
                      _buildStep(3, 'Set your new password'),
                      const SizedBox(height: 12),
                      _buildStep(4, 'Come back and login'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send password reset email: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Widget _buildStep(int number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
