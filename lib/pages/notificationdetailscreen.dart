import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../controllers/notification_controller.dart';
import '../controllers/admin_controller.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final notificationCtrl = Get.find<NotificationController>();
    final adminCtrl = Get.find<AdminController>();
    final responseController = TextEditingController();
    final RxBool isSubmitting = false.obs;

    // Mark as read when opened
    if (!notification.isRead) {
      notificationCtrl.markAsRead(notification.id);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        title: Text('notification_details'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.reviews,
                          color: Colors.blue.shade900,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy • hh:mm a',
                              ).format(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Place Information
            if (notification.placeTitle != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: Colors.blue.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'place'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (notification.placeId != null &&
                            (notification.placeId ?? '').isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              Get.toNamed(
                                '/placedetails',
                                arguments: {'placeId': notification.placeId},
                              );
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: Text('open'.tr),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification.placeTitle!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // User Review
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue.shade900, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'user_review'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (notification.userName != null)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            notification.userName![0].toUpperCase(),
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          notification.userName!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  if (notification.comment != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification.comment!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Admin Response Section
            if (notification.adminResponse != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'admin_response'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification.adminResponse!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (adminCtrl.isAdmin.value) ...[
              // Admin Response Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          color: Colors.blue.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'respond_to_review'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: responseController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'type_your_response'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade900,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting.value
                              ? null
                              : () async {
                                  if (responseController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'error'.tr,
                                      'response_cannot_be_empty'.tr,
                                    );
                                    return;
                                  }

                                  isSubmitting.value = true;
                                  try {
                                    final notificationService =
                                        Get.find<NotificationService>();
                                    await notificationService
                                        .createAdminResponseNotification(
                                          reviewId: notification.reviewId ?? '',
                                          placeId: notification.placeId ?? '',
                                          placeTitle:
                                              notification.placeTitle ?? '',
                                          userId: notification.userId ?? '',
                                          adminResponse: responseController.text
                                              .trim(),
                                        );

                                    // Update review with admin response
                                    if (notification.placeId != null &&
                                        notification.reviewId != null) {
                                      await FirebaseFirestore.instance
                                          .collection('places')
                                          .doc(notification.placeId)
                                          .collection('reviews')
                                          .doc(notification.reviewId)
                                          .update({
                                            'adminResponse': responseController
                                                .text
                                                .trim(),
                                            'adminRespondedAt':
                                                FieldValue.serverTimestamp(),
                                          });
                                    }

                                    Get.snackbar(
                                      'success'.tr,
                                      'response_sent_to_user'.tr,
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.blue.shade100,
                                      colorText: Colors.blue.shade900,
                                    );
                                    Get.back();
                                  } catch (e) {
                                    Get.snackbar(
                                      'error'.tr,
                                      'failed_to_send_response'.tr + ' $e',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red.shade100,
                                      colorText: Colors.red.shade900,
                                    );
                                  } finally {
                                    isSubmitting.value = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'send_response'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
