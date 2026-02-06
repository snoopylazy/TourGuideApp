import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rxn<fb.User> firebaseUser = Rxn<fb.User>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    firebaseUser.bindStream(fb.FirebaseAuth.instance.authStateChanges());
    // Removed automatic navigation to /login - let splash screen handle initial routing
    super.onInit();
  }

  Future<bool> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.signInWithUsernameOrEmail(
        identifier,
        password,
      );
      isLoading.value = false;
      if (user != null) {
        // Ensure a users document exists for this auth uid. If there is an
        // existing users document with the same email (but different id),
        // copy it to a document with the auth uid so profile-dependent
        // features (profile load by uid) work.
        try {
          final docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);
          final doc = await docRef.get();
          if (!doc.exists) {
            final q = await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: user.email)
                .limit(1)
                .get();
            if (q.docs.isNotEmpty) {
              final data = Map<String, dynamic>.from(q.docs.first.data());
              data['uid'] = user.uid;
              // Set/overwrite the document with the same fields but correct uid
              await docRef.set(data);
            } else {
              await docRef.set({
                'uid': user.uid,
                'name': user.email?.split('@').first ?? 'user',
                'email': user.email,
                'profileImageUrl': '',
                'role': 'user',
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
          // Ensure admin role for hardcoded admin credentials
          if (identifier == 'admin' && password == '123456') {
            try {
              await docRef.set({
                'role': 'admin',
                'name': 'admin',
              }, SetOptions(merge: true));
            } catch (_) {}
          }
        } catch (e) {
          // Non-fatal: proceed even if profile sync fails
        }
        Get.snackbar(
          'success'.tr,
          'welcome_back_logged_in'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        Get.offAllNamed('/home');
        return true;
      }
      Get.snackbar('error'.tr, 'login_failed'.tr);
      return false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('error'.tr, e.toString());
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    String profileImageUrl = '',
  }) async {
    try {
      isLoading.value = true;
      final user = await _authService.registerWithEmail(
        name,
        email,
        password,
        profileImageUrl: profileImageUrl,
      );
      isLoading.value = false;
      if (user != null) {
        Get.snackbar(
          'success'.tr,
          'account_created_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        Get.offAllNamed('/home');
        return true;
      }
      Get.snackbar('error'.tr, 'registration_failed'.tr);
      return false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('error'.tr, e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed('/login');
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
    Get.snackbar('success'.tr, 'password_reset_email_sent'.tr);
  }

  /// Reset by identifier (username or email). If identifier is username,
  /// resolve it to the user's email via the `users` collection.
  Future<void> resetPasswordForIdentifier(String identifier) async {
    String? email;
    if (identifier.contains('@')) {
      email = identifier;
    } else {
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: identifier)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        email = q.docs.first.data()['email'] as String?;
      }
    }
    if (email == null || email.isEmpty) {
      Get.snackbar('error'.tr, 'no_account_found_for_that_username'.tr);
      return;
    }
    await resetPassword(email);
  }
}
