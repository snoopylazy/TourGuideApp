import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import '../widgets/network_image_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/notification_service.dart';

class Placedetailscreen extends StatelessWidget {
  const Placedetailscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final placeId = args != null ? args['placeId'] as String? : null;
    final auth = Get.find<AuthController>();
    final uid = auth.firebaseUser.value?.uid;
    final profileCtrl = Get.put(
      ProfileController(),
    ); // Ensure profile controller is available

    if (placeId == null) {
      return const Scaffold(body: Center(child: Text('No place selected')));
    }

    if (uid != null) {
      profileCtrl.loadProfile(uid); // Load profile if logged in
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.blue.shade900,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(body: Center(child: Text('Place not found')));
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.blue.shade900,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue.shade900),
                    onPressed: () => Get.back(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: uid != null
                          ? FirebaseFirestore.instance
                                .collection('favorites')
                                .doc('${uid}_${placeId}')
                                .snapshots()
                          : null,
                      builder: (context, favSnap) {
                        final bool isFavorite =
                            favSnap.hasData && (favSnap.data?.exists ?? false);

                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : Colors.grey.shade700,
                            size: 28,
                          ),
                          onPressed: () async {
                            final currentUser = auth.firebaseUser.value;
                            if (currentUser == null) {
                              Get.snackbar(
                                'Login Required',
                                'Please login to use favorites',
                              );
                              return;
                            }

                            try {
                              final favId = '${currentUser.uid}_${placeId}';
                              final favRef = FirebaseFirestore.instance
                                  .collection('favorites')
                                  .doc(favId);
                              if (isFavorite) {
                                await favRef.delete();
                                Get.snackbar(
                                  'Removed',
                                  'Removed from favorites',
                                );
                              } else {
                                await favRef.set({
                                  'userId': currentUser.uid,
                                  'placeId': placeId,
                                  'createdAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));
                                Get.snackbar('Added', 'Added to favorites');
                              }
                            } catch (e) {
                              // ignore: avoid_print
                              print("Favorite error: $e");
                              String msg = "Failed to update favorite";
                              if (e.toString().contains("permission-denied")) {
                                msg =
                                    "Permission denied - check Firestore rules";
                              }
                              Get.snackbar(
                                'Error',
                                msg,
                                backgroundColor: Colors.red.shade100,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: NetworkImageWidget(
                    url: data['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (data['categoryName'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['categoryName'],
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        data['description'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
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
                                  Icons.location_on,
                                  color: Colors.blue.shade900,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Latitude',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${data['lat']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Longitude',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${data['lng']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () => Get.toNamed(
                                  '/mapselect',
                                  arguments: {
                                    'viewOnly': true,
                                    'lat': data['lat'],
                                    'lng': data['lng'],
                                  },
                                ),
                                icon: const Icon(Icons.map),
                                label: const Text('View on Map'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
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
                                  Icons.star,
                                  color: Colors.blue.shade900,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Reviews',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildReviewsSection(placeId, uid, profileCtrl),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection(
    String placeId,
    String? uid,
    ProfileController profileCtrl,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reviews.isEmpty)
              Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            if (reviews.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final reviewData =
                      reviews[index].data() as Map<String, dynamic>;
                  final timestamp = reviewData['createdAt'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(timestamp.toDate())
                      : 'Unknown date';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                (reviewData['userName'] as String? ?? 'U')[0]
                                    .toUpperCase(),
                                style: TextStyle(color: Colors.blue.shade900),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reviewData['userName'] ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
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
                        const SizedBox(height: 12),
                        Text(
                          reviewData['comment'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            if (uid != null) _buildReviewForm(placeId, uid, profileCtrl),
            if (uid == null)
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed('/login'),
                  child: Text(
                    'Login to add a review',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewForm(
    String placeId,
    String uid,
    ProfileController profileCtrl,
  ) {
    final TextEditingController commentController = TextEditingController();

    return Obx(() {
      if (profileCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = profileCtrl.user.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Your Review',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                if (comment.isEmpty) {
                  Get.snackbar('Error', 'Comment cannot be empty');
                  return;
                }

                try {
                  // Get place data for notification
                  final placeDoc = await FirebaseFirestore.instance
                      .collection('places')
                      .doc(placeId)
                      .get();
                  final placeData = placeDoc.data();
                  final placeTitle = placeData?['title'] ?? 'Unknown Place';

                  // Add review
                  final reviewRef = await FirebaseFirestore.instance
                      .collection('places')
                      .doc(placeId)
                      .collection('reviews')
                      .add({
                        'userId': uid,
                        'userName': user.name,
                        'comment': comment,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                  // Create notification for admin
                  final notificationService =
                      Get.isRegistered<NotificationService>()
                      ? Get.find<NotificationService>()
                      : Get.put(NotificationService());
                  await notificationService.createReviewNotification(
                    reviewId: reviewRef.id,
                    placeId: placeId,
                    placeTitle: placeTitle,
                    userId: uid,
                    userName: user.name,
                    comment: comment,
                  );

                  commentController.clear();
                  Get.snackbar('Success', 'Review added successfully');
                } catch (e) {
                  Get.snackbar('Error', 'Failed to add review: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Review',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    });
  }
}
