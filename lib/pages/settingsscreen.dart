// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import '../controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/network_image_widget.dart';
import '../widgets/glass_container.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final auth = Get.find<AuthController>();
  final profileCtrl = Get.find<ProfileController>();
  final adminCtrl = Get.find<AdminController>();

  late TextEditingController nameController;
  late TextEditingController imageUrlController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  bool _placesLoaded = false;
  bool _categoriesLoaded = false;

  // initial setup when the screen starts.
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    imageUrlController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    final uid = auth.firebaseUser.value?.uid;
    if (uid != null) profileCtrl.loadProfile(uid);
  }

  // dispose controllers when the screen is closed.
  @override
  void dispose() {
    nameController.dispose();
    imageUrlController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Obx(() {
        if (profileCtrl.isLoading.value) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                'ការកំណត់',
                style: TextStyle(color: AppColors.textLight),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textLight),
              // actions: [
              //   Obx(() {
              //     final themeCtrl = Get.find<ThemeController>();
              //     return IconButton(
              //       icon: Icon(
              //         themeCtrl.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              //         color: AppColors.textLight,
              //       ),
              //       onPressed: () => themeCtrl.toggleTheme(),
              //       tooltip: themeCtrl.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              //     );
              //   }),
              // ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const ShimmerCircle(size: 140),
                  const SizedBox(height: 20),
                  ShimmerLoading(
                    width: 200,
                    height: 20,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 40),
                  ...List.generate(
                    5,
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
            ),
          );
        }

        final user = profileCtrl.user.value;
        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                'ការកំណត់',
                style: TextStyle(color: AppColors.textLight),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textLight),
              actions: [
                Obx(() {
                  final themeCtrl = Get.find<ThemeController>();
                  return IconButton(
                    icon: Icon(
                      themeCtrl.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: AppColors.textLight,
                    ),
                    onPressed: () => themeCtrl.toggleTheme(),
                    tooltip: themeCtrl.isDarkMode
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                  );
                }),
              ],
            ),
            body: Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: const Text(
                  'No profile loaded',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          );
        }

        nameController.text = user.name;
        imageUrlController.text = user.profileImageUrl;

        final isAdmin = user.role == 'admin';

        return DefaultTabController(
          length: isAdmin ? 3 : 1,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                'ការកំណត់',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              bottom: isAdmin
                  ? TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      tabs: const [
                        Tab(text: 'ប្រវត្តិរូប'),
                        Tab(text: 'ទីកន្លែង'),
                        Tab(text: 'ប្រភេទ'),
                      ],
                    )
                  : null,
            ),
            body: isAdmin
                ? TabBarView(
                    children: [
                      _buildProfileTab(user),
                      _buildPlacesTab(),
                      _buildCategoriesTab(),
                    ],
                  )
                : _buildProfileTab(user),
          ),
        );
      }),
    );
  }

  Widget _buildProfileTab(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.blue.shade300,
                  backgroundImage: NetworkImage(
                    user.profileImageUrl.isNotEmpty
                        ? user.profileImageUrl
                        : 'https://ui-avatars.com/api/?name=${user.name}&background=0D47A1&color=fff',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),

          // Edit name & photo
          GlassContainer(
            padding: const EdgeInsets.all(10),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'ព័ត៌មានប្រវត្តិរូប',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
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
                      labelText: 'Profile Photo URL (optional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.link, color: Colors.white70),
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
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name is required',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        await profileCtrl.updateProfile(user.uid, {
                          'name': nameController.text.trim(),
                          'profileImageUrl': imageUrlController.text.trim(),
                        });
                        // Get.snackbar(
                        //   'Success',
                        //   'Profile updated',
                        //   backgroundColor: Colors.blue.shade100,
                        //   colorText: Colors.blue.shade900,
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'រក្សាទុកការផ្លាស់ប្តូរ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Change Password Section
          GlassContainer(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
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
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.lock_reset,
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
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.lock_reset,
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
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.password),
                      label: const Text('រក្សាទុកការផ្លាស់ប្តូរ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          Get.snackbar(
                            'Error',
                            'Passwords do not match',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        if (newPasswordController.text.length < 6) {
                          Get.snackbar(
                            'Error',
                            'Password must be at least 6 characters',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }

                        try {
                          final credential = fb.EmailAuthProvider.credential(
                            email: user.email,
                            password: currentPasswordController.text,
                          );
                          await fb.FirebaseAuth.instance.currentUser
                              ?.reauthenticateWithCredential(credential);
                          await fb.FirebaseAuth.instance.currentUser
                              ?.updatePassword(newPasswordController.text);

                          Get.snackbar(
                            'Success',
                            'Password updated successfully',
                            backgroundColor: Colors.blue.shade100,
                            colorText: Colors.blue.shade900,
                          );
                          currentPasswordController.clear();
                          newPasswordController.clear();
                          confirmPasswordController.clear();
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to update password: $e',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'ចាកចេញ',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => auth.logout(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPlacesTab() {
    if (!_placesLoaded) {
      _placesLoaded = true;
      adminCtrl.fetchPlaces();
      adminCtrl.fetchCategories();
    }
    return Obx(() {
      if (adminCtrl.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerListTile(),
        );
      }
      final places = adminCtrl.places;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: GlassContainer(
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('បន្ថែមទីកន្លែង'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _showAddPlaceDialog,
                ),
              ),
            ),
          ),
          Expanded(
            child: places.isEmpty
                ? Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          'គ្មានទីកន្លែងដែលត្រូវបានរកឃើញ',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final p = places[index];
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: NetworkImageWidget(
                                url: p['imageUrl'] ?? '',
                              ),
                            ),
                          ),
                          title: Text(
                            p['title'] ?? 'No title',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            p['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showEditPlaceDialog(p),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _showDeletePlaceConfirmation(p),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoriesTab() {
    if (!_categoriesLoaded) {
      _categoriesLoaded = true;
      adminCtrl.fetchCategories();
    }
    return Obx(() {
      if (adminCtrl.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerLoading(
              width: double.infinity,
              height: 70,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
      final cats = adminCtrl.categories;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: GlassContainer(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('បន្ថែមប្រភេទ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _showAddCategoryDialog,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: cats.isEmpty
                ? Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'គ្មានប្រភេទដែលត្រូវបានរកឃើញ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final c = cats[index];
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  c['name'] ?? 'No name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _showEditCategoryDialog(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _showDeleteCategoryConfirmation(c),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  static Future<void> _searchPlace(
    String query,
    void Function(void Function()) setStateSB,
    void Function(bool) setLoading,
    void Function(List<Map<String, dynamic>>) setResults,
  ) async {
    if (query.isEmpty) {
      setResults([]);
      return;
    }
    setLoading(true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'TourGuideApp/1.0'},
      );
      if (resp.statusCode != 200) {
        setResults([]);
        return;
      }
      final list = jsonDecode(resp.body) as List<dynamic>? ?? [];
      setResults(list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
    } catch (_) {
      setResults([]);
    } finally {
      setLoading(false);
    }
  }

  void _showAddPlaceDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final searchPlaceCtrl = TextEditingController();

    String? selectedCategoryId;
    String? selectedCategoryName;
    double? lat;
    double? lng;
    bool searchPlaceLoading = false;
    List<Map<String, dynamic>> searchPlaceResults = [];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setStateSB) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'បន្ថែមទីកន្លែង',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: titleCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'ចំណងជើង',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.title,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: descCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'ការពិពណ៌នា',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.description,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: imageCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'URL រូបភាព',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.image,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'ប្រភេទ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Obx(() {
                          final categories = adminCtrl.categories;
                          return DropdownButtonFormField<String>(
                            value: selectedCategoryId,
                            dropdownColor: Colors.blue.shade800,
                            style: const TextStyle(color: Colors.white),
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c['id'] as String,
                                    child: Text(c['name'] ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setStateSB(() {
                                selectedCategoryId = val;
                                final match = categories.firstWhereOrNull(
                                  (c) => c['id'] == val,
                                );
                                selectedCategoryName = match != null
                                    ? match['name'] as String?
                                    : null;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'ជ្រើសរើសប្រភេទ',
                              labelStyle: const TextStyle(
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'ស្វែងរកទីកន្លែង',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchPlaceCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Angkor Wat, Siem Reap',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
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
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) {
                                    setStateSB(() => searchPlaceResults = []);
                                    _searchPlace(
                                      searchPlaceCtrl.text.trim(),
                                      setStateSB,
                                      (loading) => setStateSB(
                                        () => searchPlaceLoading = loading,
                                      ),
                                      (results) => setStateSB(
                                        () => searchPlaceResults = results,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: searchPlaceLoading
                                    ? null
                                    : () {
                                        setStateSB(
                                          () => searchPlaceResults = [],
                                        );
                                        _searchPlace(
                                          searchPlaceCtrl.text.trim(),
                                          setStateSB,
                                          (loading) => setStateSB(
                                            () => searchPlaceLoading = loading,
                                          ),
                                          (results) => setStateSB(
                                            () => searchPlaceResults = results,
                                          ),
                                        );
                                      },
                                icon: searchPlaceLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (searchPlaceResults.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            constraints: const BoxConstraints(maxHeight: 160),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchPlaceResults.length,
                              itemBuilder: (context, idx) {
                                final r = searchPlaceResults[idx];
                                final name = r['display_name'] as String? ?? '';
                                final latVal = double.tryParse(
                                  (r['lat'] ?? '').toString(),
                                );
                                final lonVal = double.tryParse(
                                  (r['lon'] ?? '').toString(),
                                );
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.place,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    if (latVal != null && lonVal != null) {
                                      setStateSB(() {
                                        lat = latVal;
                                        lng = lonVal;
                                        latCtrl.text = latVal.toStringAsFixed(
                                          6,
                                        );
                                        lngCtrl.text = lonVal.toStringAsFixed(
                                          6,
                                        );
                                        searchPlaceResults = [];
                                        searchPlaceCtrl.clear();
                                        if (titleCtrl.text.trim().isEmpty) {
                                          titleCtrl.text = name;
                                        }
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Expanded(
                                  child: Text(
                                    lat != null && lng != null
                                        ? 'Lat: ${lat!.toStringAsFixed(6)}\nLng: ${lng!.toStringAsFixed(6)}'
                                        : 'No location selected',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.map),
                                  label: const Text('Pick on Map'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade800,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final res = await Get.toNamed(
                                      '/mapselect',
                                      arguments: {'viewOnly': false},
                                    );
                                    if (res is Map) {
                                      setStateSB(() {
                                        lat = (res['lat'] as num?)?.toDouble();
                                        lng = (res['lng'] as num?)?.toDouble();
                                        if (lat != null) {
                                          latCtrl.text = lat!.toStringAsFixed(
                                            6,
                                          );
                                        }
                                        if (lng != null) {
                                          lngCtrl.text = lng!.toStringAsFixed(
                                            6,
                                          );
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'ឬបញ្ចូល កូអរដោនេ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: latCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Latitude',
                                    labelStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.my_location,
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
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    final parsed = double.tryParse(v.trim());
                                    setStateSB(() => lat = parsed);
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: lngCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Longitude',
                                    labelStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.place,
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
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    final parsed = double.tryParse(v.trim());
                                    setStateSB(() => lng = parsed);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: Get.back,
                        child: const Text(
                          'បោះបង់',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Title is required',
                              backgroundColor: Colors.red.shade100,
                              colorText: Colors.red.shade900,
                            );
                            return;
                          }
                          // Validate manual coordinates if provided
                          final latText = latCtrl.text.trim();
                          final lngText = lngCtrl.text.trim();
                          if (latText.isNotEmpty || lngText.isNotEmpty) {
                            final parsedLat = double.tryParse(latText);
                            final parsedLng = double.tryParse(lngText);
                            if (parsedLat == null || parsedLng == null) {
                              Get.snackbar(
                                'Error',
                                'Latitude/Longitude must be valid numbers',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                              );
                              return;
                            }
                            if (parsedLat < -90 || parsedLat > 90) {
                              Get.snackbar(
                                'Error',
                                'Latitude must be between -90 and 90',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                              );
                              return;
                            }
                            if (parsedLng < -180 || parsedLng > 180) {
                              Get.snackbar(
                                'Error',
                                'Longitude must be between -180 and 180',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                              );
                              return;
                            }
                            lat = parsedLat;
                            lng = parsedLng;
                          }
                          final data = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'imageUrl': imageCtrl.text.trim(),
                          };
                          if (selectedCategoryId != null)
                            data['categoryId'] = selectedCategoryId;
                          if (selectedCategoryName != null)
                            data['categoryName'] = selectedCategoryName;

                          final ok = await adminCtrl.addPlaceWithCoords(
                            data,
                            lat,
                            lng,
                          );
                          if (ok && context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('រក្សាទុក'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditPlaceDialog(Map<String, dynamic> place) {
    final titleCtrl = TextEditingController(text: place['title'] ?? '');
    final descCtrl = TextEditingController(text: place['description'] ?? '');
    final imageCtrl = TextEditingController(text: place['imageUrl'] ?? '');

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Builder(
          builder: (ctx) => GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'កែសម្រួលទីកន្លែង',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: titleCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'ចំណងជើង',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.title,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: descCtrl,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'ការពិពណ៌នា',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.description,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: imageCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'URL រូបភាព',
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.image,
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
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: Get.back,
                        child: const Text(
                          'បោះបង់',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () async {
                          final ok = await adminCtrl.updatePlace(place['id'], {
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'imageUrl': imageCtrl.text.trim(),
                          });
                          if (ok && ctx.mounted) {
                            Navigator.of(ctx, rootNavigator: true).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('រក្សាទុក'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'បន្ថែមប្រភេទថ្មី',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'ឈ្មោះប្រភេទ',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.category,
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
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: Get.back,
                      child: const Text(
                        'បោះបង់',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name is required',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        final ok = await adminCtrl.addCategory(
                          nameCtrl.text.trim(),
                        );
                        if (ok && (Get.isDialogOpen ?? false)) {
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('រក្សាទុក'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final nameCtrl = TextEditingController(text: category['name'] ?? '');

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'កែសម្រួលប្រភេទ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'ឈ្មោះប្រភេទ',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.category,
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
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: Get.back,
                      child: const Text(
                        'បោះបង់',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name is required',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        adminCtrl.updateCategory(category['id'], {
                          'name': nameCtrl.text.trim(),
                        });
                        if (Get.isDialogOpen ?? false) {
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('រក្សាទុក'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletePlaceConfirmation(Map<String, dynamic> place) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'លុបទីកន្លែង',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'តើអ្នកប្រាកដជាចង់លុប "${place['title'] ?? 'ទីកន្លែងនេះ'}" ឬ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: Get.back,
                      child: const Text(
                        'បោះបង់',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        adminCtrl.deletePlace(place['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('យល់ព្រម'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteCategoryConfirmation(Map<String, dynamic> category) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'លុបប្រភេទ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'តើអ្នកប្រាកដជាចង់លុប "${category['name'] ?? 'ប្រភេទនេះ'}" ឬ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: Get.back,
                      child: const Text(
                        'បោះបង់',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        adminCtrl.deleteCategory(category['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('យល់ព្រម'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
