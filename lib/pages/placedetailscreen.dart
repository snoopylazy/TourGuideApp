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

class Placedetailscreen extends StatefulWidget {
  const Placedetailscreen({super.key});

  @override
  State<Placedetailscreen> createState() => _PlacedetailscreenState();
}

class _PlacedetailscreenState extends State<Placedetailscreen> {
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
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'No place selected',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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
        final imageUrls = _parseImageUrls(data['imageUrl']);

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
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
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
                              color: isFavorite ? Colors.red : Colors.white,
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
                    background: PlaceImageCarousel(imageUrls: imageUrls),
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
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    if (data['categoryName'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.category,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              data['categoryName'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (data['categoryName'] != null &&
                                        data['areaName'] != null)
                                      const SizedBox(width: 8),
                                    if (data['areaName'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.location_city,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              data['areaName'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
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
                              const SizedBox(height: 10),
                              const Divider(height: 2),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'ទីតាំង',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
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
                                    label: const Text('មើលទីតាំង'),
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
                                  children: const [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'បញ្ចេញមតិ',
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

  List<String> _parseImageUrls(dynamic imageUrlData) {
    if (imageUrlData == null) return [];

    if (imageUrlData is String) {
      return imageUrlData
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (imageUrlData is List) {
      return imageUrlData.map((url) => url.toString().trim()).toList();
    }

    return [];
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
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final reviews = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reviews.isEmpty)
              const Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
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
                  child: const Text(
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
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
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
            child: SizedBox(
              width: double.infinity,
              height: 54,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('បញ្ជូន', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ────────────────────────────────────────────────
//  New separate widget – only this part rebuilds on page change
// ────────────────────────────────────────────────
class PlaceImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const PlaceImageCarousel({super.key, required this.imageUrls});

  @override
  State<PlaceImageCarousel> createState() => _PlaceImageCarouselState();
}

class _PlaceImageCarouselState extends State<PlaceImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const NetworkImageWidget(url: '', fit: BoxFit.cover);
    }

    final hasMultiple = widget.imageUrls.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            if (mounted) {
              setState(() => _currentIndex = index);
            }
          },
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return NetworkImageWidget(
              url: widget.imageUrls[index],
              fit: BoxFit.cover,
            );
          },
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
            ),
          ),
        ),

        // Navigation arrows
        if (hasMultiple)
          Positioned(
            left: 16,
            right: 16,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  _buildNavButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  )
                else
                  const SizedBox(width: 48),

                if (_currentIndex < widget.imageUrls.length - 1)
                  _buildNavButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),

        // Dots
        if (hasMultiple)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == i
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
      ),
    );
  }
}
