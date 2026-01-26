import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create notification for admin when user reviews
  Future<void> createReviewNotification({
    required String reviewId,
    required String placeId,
    required String placeTitle,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    try {
      // Create notification in Firestore
      final notificationData = {
        'type': 'review',
        'title': 'New Review',
        'message': '$userName reviewed $placeTitle',
        'placeId': placeId,
        'placeTitle': placeTitle,
        'reviewId': reviewId,
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('notifications').add(notificationData);
    } catch (e) {
      print('Error creating review notification: $e');
    }
  }

  // Create notification for user when admin responds
  Future<void> createAdminResponseNotification({
    required String reviewId,
    required String placeId,
    required String placeTitle,
    required String userId,
    required String adminResponse,
  }) async {
    try {
      // Create notification in Firestore
      final notificationData = {
        'type': 'admin_response',
        'title': 'Admin Response',
        'message': 'Admin responded to your review',
        'placeId': placeId,
        'placeTitle': placeTitle,
        'reviewId': reviewId,
        'userId': userId,
        'adminResponse': adminResponse,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('notifications').add(notificationData);
    } catch (e) {
      print('Error creating admin response notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Get unread notification count for admin
  Stream<int> getUnreadCountForAdmin() {
    return _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'review')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get notifications for admin
  Stream<List<NotificationModel>> getAdminNotifications() {
    return _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'review')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get notifications for user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'admin_response')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

}
