import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/network_image_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/notification_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';
import 'favoriteplacescreen.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _search = '';
  String _selectedCategoryId = '';
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  int _totalPages = 1;

  final AudioPlayer _audioPlayer = AudioPlayer();
  // int _previousUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_totalPages > 0) {
        setState(() {
          _currentPage = (_currentPage + 1) % _totalPages;
        });
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    // ADD: Watch unreadCount and play sound only when it INCREASES
    // final notificationCtrl = Get.find<NotificationController>();
    // _previousUnreadCount = notificationCtrl.unreadCount.value;

    // ever(notificationCtrl.unreadCount, (int newCount) {
    //   if (newCount > _previousUnreadCount && _previousUnreadCount >= 0) {
    //     _playNotificationSound();
    //   }
    //   _previousUnreadCount = newCount;
    // });
  }

  // ADD: Helper method to play the sound
  // Future<void> _playNotificationSound() async {
  //   try {
  //     await _audioPlayer.play(AssetSource('alarm.mp3'));
  //   } catch (e) {
  //     debugPrint('Failed to play notification sound: $e');
  //   }
  // }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final uid = auth.firebaseUser.value?.uid;
    final profileCtrl = Get.find<ProfileController>();
    final tabs = <Widget>[
      _buildExploreTab(uid, profileCtrl),
      const Favoriteplacescreen(),
      _buildProfileTab(uid, profileCtrl),
    ];

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _currentIndex == 0
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  _currentIndex == 1 ? 'ការពេញចិត្ត' : 'ប្រវត្តិរូប',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                actions: _currentIndex == 2
                    ? [
                        IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'ការកំណត់',
                          onPressed: () => Get.toNamed('/settings'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: 'ចាកចេញ',
                          onPressed: () => auth.logout(),
                        ),
                      ]
                    : null,
              ),
        body: IndexedStack(index: _currentIndex, children: tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.textLight.withOpacity(0.1),
          indicatorColor: AppColors.textLight.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.explore_outlined,
                color: AppColors.textLight.withOpacity(0.7),
              ),
              selectedIcon: const Icon(
                Icons.explore,
                color: AppColors.textLight,
              ),
              label: 'ទំព័រដើម',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.favorite_border,
                color: AppColors.textLight.withOpacity(0.7),
              ),
              selectedIcon: const Icon(
                Icons.favorite,
                color: AppColors.textLight,
              ),
              label: 'ពេញចិត្ត',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: AppColors.textLight.withOpacity(0.7),
              ),
              selectedIcon: const Icon(
                Icons.person,
                color: AppColors.textLight,
              ),
              label: 'ប្រវត្តិរូប',
            ),
          ],
        ),
      ),
    );
  }

  // Favorite toggle button with live state using favorites doc '${uid}_${placeId}'
  Widget _favoriteToggleButton(
    String? uid,
    String placeId, {
    Color? outlineColor,
  }) {
    final Color outline = outlineColor ?? Colors.blue.shade900;
    if (uid == null) {
      return IconButton(
        icon: Icon(Icons.favorite_border, color: outline),
        onPressed: () {
          Get.snackbar(
            'Login Required',
            'Please login to manage favorites',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        },
      );
    }
    final favDoc = FirebaseFirestore.instance
        .collection('favorites')
        .doc('${uid}_${placeId}');
    return StreamBuilder<DocumentSnapshot>(
      stream: favDoc.snapshots(),
      builder: (ctx, snap) {
        final bool isFavorite = snap.hasData && (snap.data?.exists ?? false);
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : outline,
          ),
          onPressed: () async {
            try {
              if (isFavorite) {
                await favDoc.delete();
                Get.snackbar(
                  'Removed',
                  'Removed from favorites',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                await favDoc.set({
                  'userId': uid,
                  'placeId': placeId,
                  'createdAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
                Get.snackbar(
                  'Success',
                  'Added to favorites',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            } catch (e) {
              Get.snackbar(
                'Error',
                'Failed to update favorite: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildExploreTab(String? uid, ProfileController profileCtrl) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: Colors.blue.shade900,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Obx(() {
                final themeCtrl = Get.find<ThemeController>();
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: themeCtrl.isDarkMode
                          ? AppColors.darkGradient
                          : AppColors.lightGradient,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Obx(() {
                                  final user = profileCtrl.user.value;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'សួរស្ដី${user != null ? ', ${user.name}' : ''}!',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'តោះទៅស្វែងរកកន្លែងថ្មីៗ!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              _buildAdminNotificationButton(profileCtrl),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      hintText: 'ស្វែងរកកន្លែង...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (v) =>
                        setState(() => _search = v.trim().toLowerCase()),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryChips(),
                  const SizedBox(height: 24),
                  _buildFeaturedSection(uid),
                  const SizedBox(height: 24),
                  Text(
                    'ទេសចរណ៍ពេញនិយម',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildPopularPlaces(uid),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .snapshots(),
      builder: (ctx, csnap) {
        final allCats = csnap.data?.docs ?? [];
        // Filter to only show active categories
        final cats = allCats.where((cat) {
          final data = cat.data() as Map<String, dynamic>;
          return (data['status'] ?? 'active') == 'active';
        }).toList();

        if (cats.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (c, i) {
              final cat = cats[i];
              final selected = _selectedCategoryId == cat.id;
              return FilterChip(
                label: Text(cat['name'] ?? ''),
                selected: selected,
                onSelected: (_) => setState(
                  () => _selectedCategoryId = selected ? '' : cat.id,
                ),
                selectedColor: Colors.white.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: selected ? Colors.black : Colors.blue.shade900,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: cats.length,
          ),
        );
      },
    );
  }

  Widget _buildFeaturedSection(String? uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'កន្លែងពិសេស',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(Icons.stars, color: Colors.amber.shade700),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('places')
                .orderBy('createdAt', descending: true)
                // .limit(10)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return Center(
                  child: ShimmerLoading(
                    width: 50,
                    height: 50,
                    borderRadius: BorderRadius.circular(25),
                  ),
                );
              }

              final docs = snap.data!.docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                // Only show active places
                if ((data['status'] ?? 'active') != 'active') return false;

                if (_search.isNotEmpty) {
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final desc = (data['description'] ?? '')
                      .toString()
                      .toLowerCase();
                  if (!title.contains(_search) && !desc.contains(_search))
                    return false;
                }
                if (_selectedCategoryId.isNotEmpty &&
                    data['categoryId'] != _selectedCategoryId) {
                  return false;
                }
                return true;
              }).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'គ្មានកន្លែងពិសេសទេ',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                );
              }

              _totalPages = docs.length;

              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: docs.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (c, i) {
                      final d = docs[i];
                      final data = d.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => Get.toNamed(
                          '/placedetails',
                          arguments: {'placeId': d.id},
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 20,
                            right: 4,
                            left: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
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
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  top: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade900.withOpacity(
                                        0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      data['categoryName'] ?? 'Uncategorized',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: _favoriteToggleButton(
                                      uid,
                                      d.id,
                                      outlineColor: Colors.red,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  bottom: 16,
                                  right: 16,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        data['description'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        docs.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularPlaces(String? uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: List.generate(3, (index) => const ShimmerListTile()),
              ),
            ),
          );
        }

        final docs = snap.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          // Only show active places
          if ((data['status'] ?? 'active') != 'active') return false;

          if (_search.isNotEmpty) {
            final title = (data['title'] ?? '').toString().toLowerCase();
            final desc = (data['description'] ?? '').toString().toLowerCase();
            if (!title.contains(_search) && !desc.contains(_search))
              return false;
          }
          if (_selectedCategoryId.isNotEmpty &&
              data['categoryId'] != _selectedCategoryId) {
            return false;
          }
          return true;
        }).toList();

        if (docs.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'គ្មានកន្លែងពេញនិយមទេ',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((c, i) {
            final d = docs[i];
            final data = d.data() as Map<String, dynamic>;
            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () =>
                    Get.toNamed('/placedetails', arguments: {'placeId': d.id}),
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: NetworkImageWidget(
                          url: data['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
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
                            data['description'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (data['categoryName'] != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                data['categoryName'],
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
                    _favoriteToggleButton(
                      uid,
                      d.id,
                      outlineColor: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }, childCount: docs.length),
        );
      },
    );
  }

  Widget _buildProfileTab(String? uid, ProfileController profileCtrl) {
    return Obx(() {
      if (profileCtrl.isLoading.value) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const ShimmerCircle(size: 120),
              const SizedBox(height: 20),
              ShimmerLoading(
                width: 200,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 40),
              ...List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final user = profileCtrl.user.value;
      if (user == null) {
        return const Center(child: Text('គ្មានប្រើប្រាស់ដែលផ្ទៀងផ្ទាត់ទេ'));
      }

      final nameController = TextEditingController(text: user.name);
      final imageUrlController = TextEditingController(
        text: user.profileImageUrl,
      );

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade900, width: 3),
                  ),
                  child: ClipOval(
                    child: NetworkImageWidget(
                      url: user.profileImageUrl.isEmpty
                          ? 'https://ui-avatars.com/api/?name=${user.name}&size=200&background=0D47A1&color=fff'
                          : user.profileImageUrl,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: imageUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Profile Image URL',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.image_outlined,
                    color: Colors.white70,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Name required');
                    return;
                  }
                  await profileCtrl.updateProfile(user.uid, {
                    'name': nameController.text.trim(),
                    'profileImageUrl': imageUrlController.text.trim(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'រក្សាទុកការផ្លាស់ប្តូរ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAdminNotificationButton(ProfileController profileCtrl) {
    final adminCtrl = Get.find<AdminController>();
    final notificationCtrl = Get.find<NotificationController>();

    return Obx(() {
      final user = profileCtrl.user.value;
      final bool showForAdmin =
          (user?.role == 'admin') || adminCtrl.isAdmin.value;
      if (!showForAdmin) return const SizedBox.shrink();

      final unread = notificationCtrl.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: 'សារថ្មីៗ',
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _showAdminReviewNotificationsDialog(),
          ),
          if (unread > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  void _showAdminReviewNotificationsDialog() {
    final notificationCtrl = Get.find<NotificationController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reviews, color: Colors.white),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'New Reviews',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Obx(() {
                  final notifications = notificationCtrl.adminNotifications;
                  if (notifications.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(28.0),
                      child: Center(child: Text('No review notifications')),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final subtitle = (n.comment ?? '').trim().isEmpty
                          ? n.message
                          : n.comment!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(
                            Icons.rate_review,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        title: Text(
                          '${n.userName ?? 'Someone'} • ${n.placeTitle ?? 'Place'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: n.isRead
                                ? FontWeight.w500
                                : FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: n.isRead
                            ? null
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onTap: () {
                          Get.back();
                          if (!n.isRead) {
                            notificationCtrl.markAsRead(n.id);
                          }
                          if (n.placeId != null &&
                              (n.placeId ?? '').isNotEmpty) {
                            Get.toNamed(
                              '/placedetails',
                              arguments: {'placeId': n.placeId},
                            );
                          } else {
                            Get.toNamed('/notificationdetail', arguments: n);
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
