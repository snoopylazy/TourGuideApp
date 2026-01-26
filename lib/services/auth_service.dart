import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<fb.User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  /// Sign in with either an email or a username.
  /// If [identifier] contains '@' it's treated as email, otherwise we
  /// look up the user's email by `name` in the `users` collection.
  Future<fb.User?> signInWithUsernameOrEmail(String identifier, String password) async {
    String? email;
    if (identifier.contains('@')) {
      email = identifier.trim();
    } else {
      final q = await _firestore.collection('users').where('name', isEqualTo: identifier).limit(1).get();
      if (q.docs.isNotEmpty) {
        final data = q.docs.first.data();
        email = data['email'] as String?;
      }
    }
    if (email == null || email.isEmpty) {
      throw Exception('No account found for that username');
    }
    return await signInWithEmail(email, password);
  }

  Future<fb.User?> registerWithEmail(String name, String email, String password, {String profileImageUrl = ''}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user != null) {
      final appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
        role: 'user',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
    }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
