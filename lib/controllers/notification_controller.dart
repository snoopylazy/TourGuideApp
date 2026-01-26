import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final RxList<NotificationModel> adminNotifications =
      <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      _loadAdminNotifications();
      _loadUnreadCount();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  void _loadAdminNotifications() {
    _notificationService.getAdminNotifications().listen((notifications) {
      adminNotifications.value = notifications;
    });
  }

  void _loadUnreadCount() {
    _notificationService.getUnreadCountForAdmin().listen((count) {
      unreadCount.value = count;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // Update local state
      final index = adminNotifications.indexWhere(
        (n) => n.id == notificationId,
      );
      if (index != -1) {
        adminNotifications[index] = NotificationModel(
          id: adminNotifications[index].id,
          type: adminNotifications[index].type,
          title: adminNotifications[index].title,
          message: adminNotifications[index].message,
          placeId: adminNotifications[index].placeId,
          placeTitle: adminNotifications[index].placeTitle,
          reviewId: adminNotifications[index].reviewId,
          userId: adminNotifications[index].userId,
          userName: adminNotifications[index].userName,
          comment: adminNotifications[index].comment,
          adminResponse: adminNotifications[index].adminResponse,
          isRead: true,
          createdAt: adminNotifications[index].createdAt,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read: $e');
    }
  }

  // FCM removed: in-app notifications are driven by Firestore only.
}
