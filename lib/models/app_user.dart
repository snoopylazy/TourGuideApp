import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String profileImageUrl;
  final String role;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.role,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        profileImageUrl: m['profileImageUrl'] ?? '',
        role: m['role'] ?? 'user',
        createdAt: m['createdAt'] != null && m['createdAt'] is Timestamp ? (m['createdAt'] as Timestamp).toDate() : null,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'role': role,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      };
}
