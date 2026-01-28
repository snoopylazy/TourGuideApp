import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/network_image_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/notification_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';

class Placedetailscreen extends StatelessWidget {
  const Placedetailscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final placeId = args != null ? args['placeId'] as String? : null;
    final auth = Get.find<AuthController>();
    final uid = auth.firebaseUser.value?.uid;
    final profileCtrl = Get.put(ProfileController());

    if (placeId == null) {
      return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              child: const Text(
                'No place selected',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }

    if (uid != null) {
      profileCtrl.loadProfile(uid);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return GradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        if (!snap.hasData || !snap.data!.exists) {
          return GradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: const Text(
                    'Place not found',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryDark,
                      ),
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
                                  .doc('${uid}_$placeId')
                                  .snapshots()
                            : null,
                        builder: (context, favSnap) {
                          final bool isFavorite =
                              favSnap.hasData &&
                              (favSnap.data?.exists ?? false);

                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
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
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade100,
                                  colorText: Colors.red.shade900,
                                );
                                return;
                              }

                              try {
                                final favId = '${currentUser.uid}_$placeId';
                                final favRef = FirebaseFirestore.instance
                                    .collection('favorites')
                                    .doc(favId);
                                if (isFavorite) {
                                  await favRef.delete();
                                  Get.snackbar(
                                    'Removed',
                                    'Removed from favorites',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } else {
                                  await favRef.set({
                                    'userId': currentUser.uid,
                                    'placeId': placeId,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));
                                  Get.snackbar(
                                    'Added',
                                    'Added to favorites',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              } catch (e) {
                                print("Favorite error: $e");
                                String msg = "Failed to update favorite";
                                if (e.toString().contains(
                                  "permission-denied",
                                )) {
                                  msg =
                                      "Permission denied - check Firestore rules";
                                }
                                Get.snackbar(
                                  'Error',
                                  msg,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red.shade100,
                                  colorText: Colors.red.shade900,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkImageWidget(
                          url: data['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (data['categoryName'] != null)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        data['categoryName'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  data['description'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassContainer(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Latitude',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${data['lat']}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
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
                                              fontSize: 13,
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${data['lng']}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
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
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassContainer(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Reviews',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: _buildReviewsSection(
                                  placeId,
                                  uid,
                                  profileCtrl,
                                ),
                              ),
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
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final reviews = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reviews.isEmpty)
              Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
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
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                (reviewData['userName'] as String? ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
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
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
        return Center(child: CircularProgressIndicator(color: Colors.white));
      }

      final user = profileCtrl.user.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Add Your Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: commentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final comment = commentController.text.trim();
                  if (comment.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Comment cannot be empty',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.red.shade900,
                    );
                    return;
                  }

                  try {
                    final placeDoc = await FirebaseFirestore.instance
                        .collection('places')
                        .doc(placeId)
                        .get();
                    final placeData = placeDoc.data();
                    final placeTitle = placeData?['title'] ?? 'Unknown Place';

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
                    Get.snackbar(
                      'Success',
                      'Review added successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade100,
                      colorText: Colors.green.shade900,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to add review: $e',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade100,
                      colorText: Colors.red.shade900,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
