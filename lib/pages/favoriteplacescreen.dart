import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/network_image_widget.dart';
import '../widgets/glass_container.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';

class Favoriteplacescreen extends StatefulWidget {
  const Favoriteplacescreen({super.key});

  @override
  State<Favoriteplacescreen> createState() => _FavoriteplacescreenState();
}

class _FavoriteplacescreenState extends State<Favoriteplacescreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final uid = auth.firebaseUser.value?.uid;

    if (uid == null) {
      return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please login to view favorites',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Search bar - matching home screen style
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      hintText: 'ស្វែងរកទីកន្លែងដែលអ្នកចូលចិត្ត',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('favorites')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const ShimmerListTile(),
                      );
                    }

                    var docs = snap.data?.docs ?? [];

                    // Sort by createdAt descending (most recent first)
                    docs.sort((a, b) {
                      final ad = a.data() as Map<String, dynamic>;
                      final bd = b.data() as Map<String, dynamic>;
                      final at = ad['createdAt'];
                      final bt = bd['createdAt'];
                      if (at == null && bt == null) return 0;
                      if (at == null) return 1;
                      if (bt == null) return -1;
                      try {
                        return (bt as Timestamp).compareTo(at as Timestamp);
                      } catch (_) {
                        return 0;
                      }
                    });

                    if (docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return FutureBuilder<List<Map<String, dynamic>>>(
                      // We preload all place documents once
                      future: _fetchAllPlaces(docs),
                      builder: (context, placeSnapshot) {
                        if (placeSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: 5,
                            itemBuilder: (context, index) =>
                                const ShimmerListTile(),
                          );
                        }

                        final placeMap = placeSnapshot.data ?? [];

                        // Filter based on search query
                        final filteredPlaces = placeMap.where((place) {
                          final title = (place['title'] ?? '')
                              .toString()
                              .toLowerCase();
                          return _searchQuery.isEmpty ||
                              title.contains(_searchQuery);
                        }).toList();

                        // Limit to 10 items for better performance
                        final displayPlaces = filteredPlaces.take(10).toList();

                        if (displayPlaces.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'No matching favorites',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try a different place name.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: displayPlaces.length,
                          itemBuilder: (c, i) {
                            final placeData = displayPlaces[i];
                            final favDocId = placeData['favDocId'] as String;

                            return GlassContainer(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12.0),
                              child: InkWell(
                                onTap: () => Get.toNamed(
                                  '/placedetails',
                                  arguments: {'placeId': placeData['placeId']},
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: NetworkImageWidget(
                                          url: placeData['imageUrl'] ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            placeData['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            placeData['description'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (placeData['categoryName'] !=
                                              null) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                placeData['categoryName'],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('favorites')
                                            .doc(favDocId)
                                            .delete();
                                        Get.snackbar(
                                          'Removed',
                                          'Removed from favorites',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor:
                                              Colors.orange.shade100,
                                          colorText: Colors.orange.shade900,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 16),
            Text(
              'មិនទាន់មានទីកន្លែងដែលអ្នកចូលចិត្ត',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                'ចុចលើប៊ូតុងចិត្តស្រឡាញ់នៅលើទីកន្លែងដើម្បីបន្ថែមទីកន្លែងទៅក្នុងបញ្ជីនេះ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllPlaces(
    List<QueryDocumentSnapshot> favDocs,
  ) async {
    final List<Map<String, dynamic>> results = [];

    for (final fav in favDocs) {
      final placeId = fav['placeId'] as String?;
      if (placeId == null) continue;

      try {
        final placeSnap = await FirebaseFirestore.instance
            .collection('places')
            .doc(placeId)
            .get();
        if (!placeSnap.exists) continue;

        final data = placeSnap.data()!;
        results.add({
          'placeId': placeId,
          'favDocId': fav.id,
          'title': data['title'] ?? 'Unnamed place',
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'categoryName': data['categoryName'],
        });
      } catch (e) {
        // silently skip broken records
      }
    }

    return results;
  }
}
