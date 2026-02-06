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
import '../controllers/language_controller.dart';
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
  bool _areasLoaded = false;

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
              title: Text(
                'settings'.tr,
                style: const TextStyle(color: AppColors.textLight),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textLight),
              actions: [_buildSettingsMenu()],
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
              title: Text(
                'settings'.tr,
                style: const TextStyle(color: AppColors.textLight),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textLight),
              actions: [_buildSettingsMenu()],
            ),
            body: Center(
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'no_profile_loaded'.tr,
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
          length: isAdmin ? 4 : 1,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'settings'.tr,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [_buildSettingsMenu()],
              bottom: isAdmin
                  ? TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(text: 'profile'.tr),
                        Tab(text: 'places'.tr),
                        Tab(text: 'areas'.tr),
                        Tab(text: 'categories'.tr),
                      ],
                    )
                  : null,
            ),
            body: isAdmin
                ? TabBarView(
                    children: [
                      _buildProfileTab(user),
                      _buildPlacesTab(),
                      _buildAreasTab(),
                      _buildCategoriesTab(),
                    ],
                  )
                : _buildProfileTab(user),
          ),
        );
      }),
    );
  }

  Widget _buildSettingsMenu() {
    final themeCtrl = Get.find<ThemeController>();
    final langCtrl = Get.find<LanguageController>();

    return Obx(
      () => PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        color: themeCtrl.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == 'theme') {
            themeCtrl.toggleTheme();
          } else if (value == 'language_km') {
            langCtrl.setLanguage(const Locale('km', 'KH'));
          } else if (value == 'language_en') {
            langCtrl.setLanguage(const Locale('en', 'US'));
          }
        },
        itemBuilder: (BuildContext context) => [
          // Theme option
          PopupMenuItem<String>(
            value: 'theme',
            child: Obx(
              () => Row(
                children: [
                  Icon(
                    themeCtrl.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: themeCtrl.isDarkMode
                        ? Colors.amber.shade300
                        : Colors.grey.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    themeCtrl.isDarkMode
                        ? 'switch_to_dark'.tr
                        : 'switch_to_light'.tr,
                    style: TextStyle(
                      color: themeCtrl.isDarkMode
                          ? Colors.white
                          : Colors.grey.shade900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          // Language header
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              'language'.tr,
              style: TextStyle(
                color: themeCtrl.isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Khmer option
          PopupMenuItem<String>(
            value: 'language_km',
            child: Obx(
              () => Row(
                children: [
                  Icon(
                    Icons.language,
                    color: langCtrl.isKhmer
                        ? Colors.blue
                        : (themeCtrl.isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey.shade400),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'khmer'.tr,
                    style: TextStyle(
                      color: langCtrl.isKhmer
                          ? Colors.blue
                          : (themeCtrl.isDarkMode
                                ? Colors.white70
                                : Colors.grey.shade700),
                      fontSize: 14,
                      fontWeight: langCtrl.isKhmer
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (langCtrl.isKhmer) ...[
                    const Spacer(),
                    Icon(Icons.check, color: Colors.blue, size: 18),
                  ],
                ],
              ),
            ),
          ),
          // English option
          PopupMenuItem<String>(
            value: 'language_en',
            child: Obx(
              () => Row(
                children: [
                  Icon(
                    Icons.language,
                    color: langCtrl.isEnglish
                        ? Colors.blue
                        : (themeCtrl.isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey.shade400),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'english'.tr,
                    style: TextStyle(
                      color: langCtrl.isEnglish
                          ? Colors.blue
                          : (themeCtrl.isDarkMode
                                ? Colors.white70
                                : Colors.grey.shade700),
                      fontSize: 14,
                      fontWeight: langCtrl.isEnglish
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (langCtrl.isEnglish) ...[
                    const Spacer(),
                    Icon(Icons.check, color: Colors.blue, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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
                  child: Text(
                    'profile_info'.tr,
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
                      labelText: 'full_name'.tr,
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
                      labelText: 'profile_photo_url'.tr,
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
                            'error'.tr,
                            'name_cannot_be_empty'.tr,
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
                      child: Text(
                        'save_changes'.tr,
                        style: const TextStyle(
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
                  child: Text(
                    'change_password'.tr,
                    style: const TextStyle(
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
                      labelText: 'current_password'.tr,
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
                      labelText: 'new_password'.tr,
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
                      labelText: 'confirm_password'.tr,
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
                      label: Text('save_changes'.tr),
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
                            'error'.tr,
                            'passwords_do_not_match'.tr,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        if (newPasswordController.text.length < 6) {
                          Get.snackbar(
                            'error'.tr,
                            'password_must_be_at_least_6_characters'.tr,
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
                            'success'.tr,
                            'password_updated'.tr,
                            backgroundColor: Colors.blue.shade100,
                            colorText: Colors.blue.shade900,
                          );
                          currentPasswordController.clear();
                          newPasswordController.clear();
                          confirmPasswordController.clear();
                        } catch (e) {
                          Get.snackbar(
                            'error'.tr,
                            'failed_to_update_password'.tr + ' $e',
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
              label: Text('logout'.tr, style: TextStyle(color: Colors.white)),
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
                  label: Text('add_place'.tr),
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
                        child: Text(
                          'no_places_found'.tr,
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
                      final imageUrl = p['imageUrl'];
                      final firstImage = imageUrl is List
                          ? (imageUrl.isNotEmpty ? imageUrl[0] : '')
                          : (imageUrl ?? '');

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
                              child: NetworkImageWidget(url: firstImage),
                            ),
                          ),
                          title: Text(
                            p['title'] ?? 'no_title'.tr,
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

  Widget _buildAreasTab() {
    if (!_areasLoaded) {
      _areasLoaded = true;
      adminCtrl.fetchAreas();
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
      final areas = adminCtrl.areas;

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
                    icon: const Icon(Icons.add_location),
                    label: Text('add_area'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _showAddAreaDialog,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: areas.isEmpty
                ? Center(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'no_areas_found'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      final a = areas[index];
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  a['name'] ?? 'no_name'.tr,
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
                              onPressed: () => _showEditAreaDialog(a),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteAreaConfirmation(a),
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
                    label: Text('add_category'.tr),
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
                      child: Text(
                        'no_categories_found'.tr,
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
                                  c['name'] ?? 'no_name'.tr,
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
    final List<TextEditingController> imageCtrls = [imageCtrl];
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final searchPlaceCtrl = TextEditingController();

    String? selectedCategoryId;
    String? selectedCategoryName;
    String? selectedAreaId;
    String? selectedAreaName;
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
                  child: Text(
                    'add_place'.tr,
                    style: const TextStyle(
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
                              labelText: 'title'.tr,
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
                              labelText: 'description'.tr,
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
                        // Image URL fields with add/remove buttons
                        Column(
                          children: [
                            for (int i = 0; i < imageCtrls.length; i++)
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: imageCtrls[i],
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: '${'image_url'.tr} ${i + 1}',
                                    hintText: i == 0
                                        ? 'https://example.com/img1.jpg'
                                        : 'https://example.com/img2.jpg',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.image,
                                      color: Colors.white70,
                                    ),
                                    // First row: add button (cannot delete)
                                    // Other rows: remove button
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (i == 0)
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            color: Colors.white70,
                                            tooltip: 'add_url'.tr,
                                            onPressed: () {
                                              setStateSB(() {
                                                imageCtrls.add(
                                                  TextEditingController(),
                                                );
                                              });
                                            },
                                          ),
                                        if (i > 0)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            color: Colors.redAccent,
                                            tooltip: 'remove_url'.tr,
                                            onPressed: () {
                                              setStateSB(() {
                                                imageCtrls[i].dispose();
                                                imageCtrls.removeAt(i);
                                              });
                                            },
                                          ),
                                      ],
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
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'areas'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Obx(() {
                          final areasList = adminCtrl.areas;
                          return DropdownButtonFormField<String>(
                            value: selectedAreaId,
                            dropdownColor: Colors.blue.shade800,
                            style: const TextStyle(color: Colors.white),
                            items: areasList
                                .map(
                                  (a) => DropdownMenuItem<String>(
                                    value: a['id'] as String,
                                    child: Text(a['name'] ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setStateSB(() {
                                selectedAreaId = val;
                                final match = areasList.firstWhereOrNull(
                                  (a) => a['id'] == val,
                                );
                                selectedAreaName = match != null
                                    ? match['name'] as String?
                                    : null;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'select_area'.tr,
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
                          child: Text(
                            'categories'.tr,
                            style: const TextStyle(
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
                              labelText: 'select_category'.tr,
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
                          child: Text(
                            'find_location'.tr,
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
                                        : 'no_location_selected'.tr,
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
                                  label: Text('pick_location_on_map'.tr),
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
                          child: Text(
                            'or_enter_lat_lng'.tr,
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
                                    labelText: 'latitude'.tr,
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
                                    labelText: 'longitude'.tr,
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
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(color: Colors.white70),
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
                              'error'.tr,
                              'title_required'.tr,
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
                                'error'.tr,
                                'Latitude/Longitude must be valid numbers',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                              );
                              return;
                            }
                            if (parsedLat < -90 || parsedLat > 90) {
                              Get.snackbar(
                                'error'.tr,
                                'Latitude must be between -90 and 90',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                              );
                              return;
                            }
                            if (parsedLng < -180 || parsedLng > 180) {
                              Get.snackbar(
                                'error'.tr,
                                'Longitude must be between -180 and 180',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                              );
                              return;
                            }
                            lat = parsedLat;
                            lng = parsedLng;
                          }

                          final imageUrls = imageCtrls
                              .map((c) => c.text.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          final data = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'imageUrl': imageUrls,
                          };
                          if (selectedCategoryId != null) {
                            data['categoryId'] = selectedCategoryId;
                          }
                          if (selectedCategoryName != null) {
                            data['categoryName'] = selectedCategoryName;
                          }
                          if (selectedAreaId != null) {
                            data['areaId'] = selectedAreaId;
                          }
                          if (selectedAreaName != null) {
                            data['areaName'] = selectedAreaName;
                          }

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
                        child: Text('save'.tr),
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
    // Handle both String and List formats without breaking data URLs
    final imageUrl = place['imageUrl'];
    final List<String> initialImageUrls;

    if (imageUrl is List) {
      // Already a list in Firestore
      initialImageUrls = imageUrl
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (imageUrl is String) {
      // If it's a data URL, keep it as a single entry (it contains a comma)
      if (imageUrl.trim().startsWith('data:image')) {
        initialImageUrls = [imageUrl.trim()];
      } else {
        // Old format: comma‑separated normal URLs
        initialImageUrls = imageUrl
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      initialImageUrls = [];
    }
    final List<TextEditingController> imageCtrls = initialImageUrls.isNotEmpty
        ? initialImageUrls
              .map((url) => TextEditingController(text: url))
              .toList()
        : [TextEditingController()];

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (ctx, setStateSB) => GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'edit_place'.tr,
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
                              labelText: 'title'.tr,
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
                              labelText: 'description'.tr,
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
                        // Image URL fields with add/remove buttons
                        Column(
                          children: [
                            for (int i = 0; i < imageCtrls.length; i++)
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: imageCtrls[i],
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: '${'image_url'.tr} ${i + 1}',
                                    labelStyle: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.image,
                                      color: Colors.white70,
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (i == 0)
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            color: Colors.white70,
                                            tooltip: 'Add image URL',
                                            onPressed: () {
                                              setStateSB(() {
                                                imageCtrls.add(
                                                  TextEditingController(),
                                                );
                                              });
                                            },
                                          ),
                                        if (i > 0)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            color: Colors.redAccent,
                                            tooltip: 'Remove image URL',
                                            onPressed: () {
                                              setStateSB(() {
                                                imageCtrls[i].dispose();
                                                imageCtrls.removeAt(i);
                                              });
                                            },
                                          ),
                                      ],
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
                        const SizedBox(height: 16),

                        // Container(
                        //   padding: const EdgeInsets.all(10),
                        //   child: const Text(
                        //     'តំបន់',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final areasList = adminCtrl.areas;
                          String? currentAreaId = place['areaId'] as String?;

                          return DropdownButtonFormField<String>(
                            value: currentAreaId,
                            dropdownColor: Colors.blue.shade800,
                            style: const TextStyle(color: Colors.white),
                            items: areasList
                                .map(
                                  (a) => DropdownMenuItem<String>(
                                    value: a['id'] as String,
                                    child: Text(a['name'] ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              final match = areasList.firstWhereOrNull(
                                (a) => a['id'] == val,
                              );
                              currentAreaId = val;
                              // Update place data
                              place['areaId'] = val;
                              place['areaName'] = match != null
                                  ? match['name'] as String?
                                  : null;
                            },
                            decoration: InputDecoration(
                              labelText: 'select_area'.tr,
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
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () async {
                          final imageUrls = imageCtrls
                              .map((c) => c.text.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          final updateData = {
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'imageUrl': imageUrls,
                          };

                          // Add area data if present
                          if (place['areaId'] != null) {
                            updateData['areaId'] = place['areaId'];
                          }
                          if (place['areaName'] != null) {
                            updateData['areaName'] = place['areaName'];
                          }

                          final ok = await adminCtrl.updatePlace(
                            place['id'],
                            updateData,
                          );
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
                        child: Text('save'.tr),
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
                child: Text(
                  'add_category'.tr,
                  style: const TextStyle(
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
                    labelText: 'category_name'.tr,
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
                      child: Text(
                        'cancel'.tr,
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
                            'error'.tr,
                            'name_required'.tr,
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
                      child: Text('save'.tr),
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
                child: Text(
                  'edit_category'.tr,
                  style: const TextStyle(
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
                    labelText: 'category_name'.tr,
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
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(color: Colors.white70),
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
                            'error'.tr,
                            'name_required'.tr,
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
                      child: Text('save'.tr),
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
                child: Text(
                  'delete_place'.tr,
                  style: const TextStyle(
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
                  // 'confirm_delete_place'.trParams({
                  //   'place': place['title'] ?? 'this place',
                  // }),
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
                      child: Text(
                        'cancel'.tr,
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
                      child: Text('ok'.tr),
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
                child: Text(
                  'delete_category'.tr,
                  style: const TextStyle(
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
                  // 'confirm_delete_category'.trParams({
                  //   'category': category['name'] ?? 'this category',
                  // }),
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
                      child: Text(
                        'cancel'.tr,
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
                      child: Text('ok'.tr),
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

  void _showAddAreaDialog() {
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
                child: Text(
                  'add_area'.tr,
                  style: const TextStyle(
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
                    labelText: 'area_name'.tr,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.location_city,
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
                      child: Text(
                        'cancel'.tr,
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
                            'error'.tr,
                            'name_required'.tr,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        final ok = await adminCtrl.addArea(
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
                      child: Text('save'.tr),
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

  void _showEditAreaDialog(Map<String, dynamic> area) {
    final nameCtrl = TextEditingController(text: area['name'] ?? '');

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
                child: Text(
                  'edit_area'.tr,
                  style: const TextStyle(
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
                    labelText: 'area_name'.tr,
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.location_city,
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
                      child: Text(
                        'cancel'.tr,
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
                            'error'.tr,
                            'name_required'.tr,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }
                        final ok = await adminCtrl.updateArea(area['id'], {
                          'name': nameCtrl.text.trim(),
                        });
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
                      child: Text('save'.tr),
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

  void _showDeleteAreaConfirmation(Map<String, dynamic> area) {
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
                child: Text(
                  'delete_area'.tr,
                  style: const TextStyle(
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
                  'តើអ្នកប្រាកដជាចង់លុប "${area['name'] ?? 'តំបន់នេះ'}" ឬ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
                  // 'confirm_delete_area'.trParams({
                  //   'area': area['name'] ?? 'this area',
                  // }),
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
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        adminCtrl.deleteArea(area['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('ok'.tr),
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
