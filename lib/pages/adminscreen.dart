import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../controllers/notification_controller.dart';
import '../widgets/network_image_widget.dart';

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  void _showNotificationsDialog(BuildContext context) {
    final notificationCtrl = Get.find<NotificationController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: Text('No notifications')),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return InkWell(
                        onTap: () {
                          Get.back();
                          if (!notification.isRead) {
                            notificationCtrl.markAsRead(notification.id);
                          }
                          if (notification.placeId != null &&
                              (notification.placeId ?? '').isNotEmpty) {
                            Get.toNamed(
                              '/placedetails',
                              arguments: {'placeId': notification.placeId},
                            );
                          } else {
                            Get.toNamed(
                              '/notificationdetail',
                              arguments: notification,
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notification.isRead
                                ? Colors.grey.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: notification.isRead
                                  ? Colors.grey.shade200
                                  : Colors.blue.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.reviews,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (notification.userName?.isNotEmpty ?? false)
                                          ? notification.userName!
                                          : notification.title,
                                      style: TextStyle(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.placeTitle ??
                                          notification.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (notification.placeTitle != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.placeTitle!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
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

  void _showEditPlaceDialog(Map<String, dynamic> place) {
    final AdminController admin = Get.find<AdminController>();
    final editTitle = (place['title'] ?? '').obs;
    final editImageUrl = (place['imageUrl'] ?? '').obs;
    final editDescription = (place['description'] ?? '').obs;
    final editSelectedCategoryId = (place['categoryId'] ?? '').obs;
    double? editPickedLat = place['lat']?.toDouble();
    double? editPickedLng = place['lng']?.toDouble();
    final editShowLocationPicked =
        (editPickedLat != null && editPickedLng != null).obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Place',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: (v) => editTitle.value = v,
                        controller: TextEditingController(
                          text: editTitle.value,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Title *',
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
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => editImageUrl.value = v,
                        controller: TextEditingController(
                          text: editImageUrl.value,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Image URL',
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
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => editDescription.value = v,
                        controller: TextEditingController(
                          text: editDescription.value,
                        ),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
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
                      const SizedBox(height: 12),
                      Obx(() {
                        if (admin.categories.isEmpty)
                          return const SizedBox.shrink();
                        return DropdownButtonFormField<String>(
                          value: editSelectedCategoryId.value.isEmpty
                              ? null
                              : editSelectedCategoryId.value,
                          decoration: InputDecoration(
                            labelText: 'Category',
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
                          items: admin.categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c['id'] as String,
                                  child: Text(c['name'] ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              editSelectedCategoryId.value = v ?? '',
                        );
                      }),
                      const SizedBox(height: 16),
                      Obx(
                        () => editShowLocationPicked.value
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Location: ${editPickedLat?.toStringAsFixed(6)}, ${editPickedLng?.toStringAsFixed(6)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        editShowLocationPicked.value = false;
                                        editPickedLat = null;
                                        editPickedLng = null;
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.red.shade400,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final res = await Get.toNamed('/mapselect');
                            if (res != null && res is Map) {
                              final lat = res['lat'];
                              final lng = res['lng'];
                              if (lat is num && lng is num) {
                                editPickedLat = lat.toDouble();
                                editPickedLng = lng.toDouble();
                                editShowLocationPicked.value = true;
                              } else if (lat is String && lng is String) {
                                editPickedLat = double.tryParse(lat);
                                editPickedLng = double.tryParse(lng);
                                if (editPickedLat != null &&
                                    editPickedLng != null) {
                                  editShowLocationPicked.value = true;
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Pick Location'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.blue.shade900),
                            foregroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: Colors.grey.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (editTitle.value.trim().isEmpty) {
                                  Get.snackbar('Error', 'Title required');
                                  return;
                                }

                                final updateData = {
                                  'title': editTitle.value.trim(),
                                  'imageUrl': editImageUrl.value.trim(),
                                  'description': editDescription.value.trim(),
                                };

                                if (editSelectedCategoryId.value.isNotEmpty) {
                                  final cat = admin.categories.firstWhere(
                                    (c) =>
                                        c['id'] == editSelectedCategoryId.value,
                                    orElse: () => {},
                                  );
                                  updateData['categoryId'] =
                                      editSelectedCategoryId.value;
                                  updateData['categoryName'] =
                                      cat['name'] ?? '';
                                } else {
                                  updateData['categoryId'] = null;
                                  updateData['categoryName'] = null;
                                }

                                if (editPickedLat != null &&
                                    editPickedLng != null) {
                                  updateData['lat'] = editPickedLat;
                                  updateData['lng'] = editPickedLng;
                                }

                                await admin.updatePlace(
                                  place['id'] as String,
                                  updateData,
                                );
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Update Place'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AdminController admin = Get.put(AdminController());
    final RxString username = ''.obs;
    final RxString password = ''.obs;
    final RxString title = ''.obs;
    final RxString imageUrl = ''.obs;
    final RxString description = ''.obs;
    final RxString newCategory = ''.obs;
    final RxString selectedCategoryId = ''.obs;
    double? pickedLat;
    double? pickedLng;
    final RxBool showLocationPicked = false.obs;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(() {
            final notificationCtrl = Get.find<NotificationController>();
            final unreadCount = notificationCtrl.unreadCount.value;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showNotificationsDialog(context),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
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
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Obx(
              () => admin.isAdmin.value
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => admin.fetchPlaces(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Places'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => admin.fetchCategories(),
                            icon: const Icon(Icons.category),
                            label: const Text('Categories'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.blue.shade900),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 60,
                            color: Colors.blue.shade900,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Admin Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            onChanged: (v) => username.value = v,
                            decoration: InputDecoration(
                              labelText: 'Admin Username',
                              prefixIcon: const Icon(Icons.person),
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
                          TextField(
                            onChanged: (v) => password.value = v,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Admin Password',
                              prefixIcon: const Icon(Icons.lock),
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
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                final ok = admin.loginAdmin(
                                  username.value.trim(),
                                  password.value.trim(),
                                );
                                if (ok) {
                                  Get.snackbar(
                                    'Success',
                                    'Admin logged in',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green.shade100,
                                    colorText: Colors.green.shade900,
                                  );
                                  admin.fetchPlaces();
                                  admin.fetchCategories();
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Invalid admin credentials',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade900,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Login',
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
                    ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => admin.isAdmin.value
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add Place Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                                        Icons.add_location,
                                        color: Colors.blue.shade900,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Add New Place',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    onChanged: (v) => title.value = v,
                                    decoration: InputDecoration(
                                      labelText: 'Title *',
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
                                  const SizedBox(height: 12),
                                  TextField(
                                    onChanged: (v) => imageUrl.value = v,
                                    decoration: InputDecoration(
                                      labelText: 'Image URL',
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
                                  const SizedBox(height: 12),
                                  TextField(
                                    onChanged: (v) => description.value = v,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: 'Description',
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
                                  const SizedBox(height: 12),
                                  Obx(() {
                                    if (admin.categories.isEmpty)
                                      return const SizedBox.shrink();
                                    return DropdownButtonFormField<String>(
                                      value: selectedCategoryId.value.isEmpty
                                          ? null
                                          : selectedCategoryId.value,
                                      decoration: InputDecoration(
                                        labelText: 'Category',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade900,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      items: admin.categories
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c['id'] as String,
                                              child: Text(c['name'] ?? ''),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          selectedCategoryId.value = v ?? '',
                                    );
                                  }),
                                  const SizedBox(height: 16),
                                  Obx(
                                    () => showLocationPicked.value
                                        ? Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                const Expanded(
                                                  child: Text(
                                                    'Location selected on map',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final res = await Get.toNamed(
                                              '/mapselect',
                                            );
                                            if (res != null && res is Map) {
                                              final lat = res['lat'];
                                              final lng = res['lng'];
                                              print(
                                                'Map result - lat: $lat (${lat.runtimeType}), lng: $lng (${lng.runtimeType})',
                                              );
                                              if (lat is num && lng is num) {
                                                pickedLat = lat.toDouble();
                                                pickedLng = lng.toDouble();
                                                showLocationPicked.value = true;
                                                print(
                                                  'Coordinates set: $pickedLat, $pickedLng',
                                                );
                                              } else if (lat is String &&
                                                  lng is String) {
                                                pickedLat = double.tryParse(
                                                  lat,
                                                );
                                                pickedLng = double.tryParse(
                                                  lng,
                                                );
                                                if (pickedLat != null &&
                                                    pickedLng != null) {
                                                  showLocationPicked.value =
                                                      true;
                                                  print(
                                                    'Coordinates parsed from strings: $pickedLat, $pickedLng',
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.map),
                                          label: const Text('Pick Location'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            side: BorderSide(
                                              color: Colors.blue.shade900,
                                            ),
                                            foregroundColor:
                                                Colors.blue.shade900,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            if (title.value.trim().isEmpty) {
                                              Get.snackbar(
                                                'Error',
                                                'Title required',
                                              );
                                              return;
                                            }
                                            final Map<String, dynamic>
                                            placeData = {
                                              'title': title.value.trim(),
                                              'imageUrl': imageUrl.value.trim(),
                                              'description': description.value
                                                  .trim(),
                                            };
                                            print(
                                              'title.value type: ${title.value.runtimeType}, value: "${title.value}"',
                                            );
                                            print(
                                              'imageUrl.value type: ${imageUrl.value.runtimeType}, value: "${imageUrl.value}"',
                                            );
                                            print(
                                              'description.value type: ${description.value.runtimeType}, value: "${description.value}"',
                                            );
                                            print(
                                              'placeData created: $placeData',
                                            );
                                            print(
                                              'pickedLat: $pickedLat (${pickedLat.runtimeType}), pickedLng: $pickedLng (${pickedLng.runtimeType})',
                                            );
                                            if (selectedCategoryId
                                                .value
                                                .isNotEmpty) {
                                              final cat = admin.categories
                                                  .firstWhere(
                                                    (c) =>
                                                        c['id'] ==
                                                        selectedCategoryId
                                                            .value,
                                                    orElse: () => {},
                                                  );
                                              print('Selected category: $cat');
                                              placeData['categoryId'] =
                                                  selectedCategoryId.value;
                                              placeData['categoryName'] =
                                                  cat['name'] ?? '';
                                            }
                                            print(
                                              'placeData before addPlaceWithCoords: $placeData',
                                            );
                                            final ok = await admin.addPlaceWithCoords(
                                              placeData,
                                              pickedLat,
                                              pickedLng,
                                            );
                                            if (ok) {
                                              title.value = '';
                                              imageUrl.value = '';
                                              description.value = '';
                                              selectedCategoryId.value = '';
                                              showLocationPicked.value = false;
                                              pickedLat = null;
                                              pickedLng = null;
                                            }
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Place'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            title.value = '';
                                            imageUrl.value = '';
                                            description.value = '';
                                            selectedCategoryId.value = '';
                                            showLocationPicked.value = false;
                                            pickedLat = null;
                                            pickedLng = null;
                                          },
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Clear'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade400,
                                            ),
                                            foregroundColor:
                                                Colors.grey.shade700,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final sample = {
                                          'title': 'Angkor Wat',
                                          'imageUrl':
                                              'https://upload.wikimedia.org/wikipedia/commons/9/9b/Angkor_Wat_temple_view.jpg',
                                          'description':
                                              'UNESCO World Heritage Site - Siem Reap, Cambodia',
                                        };
                                        await admin.addPlaceWithCoords(
                                          sample,
                                          13.4125,
                                          103.8667,
                                        );
                                      },
                                      icon: const Icon(Icons.add_location_alt),
                                      label: const Text(
                                        'Add Sample (Angkor Wat)',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        foregroundColor: Colors.grey.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Manage Categories Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                                        Icons.category,
                                        color: Colors.blue.shade900,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Manage Categories',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          onChanged: (v) =>
                                              newCategory.value = v,
                                          decoration: InputDecoration(
                                            labelText: 'New Category Name',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.blue.shade900,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (newCategory.value.trim().isEmpty)
                                            return;
                                          final ok = await admin.addCategory(
                                            newCategory.value,
                                          );
                                          if (ok) {
                                            newCategory.value = '';
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Obx(() {
                                    if (admin.categories.isEmpty) {
                                      return Text(
                                        'No categories yet',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: admin.categories.map((cat) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      cat['name'] ?? '',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .blue
                                                            .shade900,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (cat['status'] ??
                                                                    'active') ==
                                                                'active'
                                                            ? Colors
                                                                  .green
                                                                  .shade100
                                                            : Colors
                                                                  .red
                                                                  .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        (cat['status'] ??
                                                                'active')
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              (cat['status'] ??
                                                                      'active') ==
                                                                  'active'
                                                              ? Colors
                                                                    .green
                                                                    .shade800
                                                              : Colors
                                                                    .red
                                                                    .shade800,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      // Toggle status
                                                      final newStatus =
                                                          (cat['status'] ??
                                                                  'active') ==
                                                              'active'
                                                          ? 'inactive'
                                                          : 'active';
                                                      admin.updateCategory(
                                                        cat['id'] as String,
                                                        {'status': newStatus},
                                                      );
                                                    },
                                                    icon: Icon(
                                                      (cat['status'] ??
                                                                  'active') ==
                                                              'active'
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                      size: 20,
                                                      color:
                                                          Colors.blue.shade700,
                                                    ),
                                                    tooltip:
                                                        (cat['status'] ??
                                                                'active') ==
                                                            'active'
                                                        ? 'Deactivate'
                                                        : 'Activate',
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        admin.deleteCategory(
                                                          cat['id'] as String,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 20,
                                                      color: Colors.red,
                                                    ),
                                                    tooltip: 'Delete',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Places List
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'All Places',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Obx(() {
                                    if (admin.isLoading.value) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      );
                                    }
                                    if (admin.places.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Center(
                                          child: Text(
                                            'No places yet',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: admin.places.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 24),
                                      itemBuilder: (c, i) {
                                        final p = admin.places[i];
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: NetworkImageWidget(
                                                    url: p['imageUrl'] ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            p['title'] ?? '',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                (p['status'] ??
                                                                        'active') ==
                                                                    'active'
                                                                ? Colors
                                                                      .green
                                                                      .shade100
                                                                : Colors
                                                                      .red
                                                                      .shade100,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            (p['status'] ??
                                                                    'active')
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  (p['status'] ??
                                                                          'active') ==
                                                                      'active'
                                                                  ? Colors
                                                                        .green
                                                                        .shade800
                                                                  : Colors
                                                                        .red
                                                                        .shade800,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      p['description'] ?? '',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    if (p['categoryName'] !=
                                                        null) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Category: ${p['categoryName']}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .blue
                                                              .shade900,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () =>
                                                        _showEditPlaceDialog(p),
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 20,
                                                      color: Colors.orange,
                                                    ),
                                                    tooltip: 'Edit',
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Toggle status
                                                      final newStatus =
                                                          (p['status'] ??
                                                                  'active') ==
                                                              'active'
                                                          ? 'inactive'
                                                          : 'active';
                                                      admin.updatePlace(
                                                        p['id'] as String,
                                                        {'status': newStatus},
                                                      );
                                                    },
                                                    icon: Icon(
                                                      (p['status'] ??
                                                                  'active') ==
                                                              'active'
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                      size: 20,
                                                      color:
                                                          Colors.blue.shade700,
                                                    ),
                                                    tooltip:
                                                        (p['status'] ??
                                                                'active') ==
                                                            'active'
                                                        ? 'Deactivate'
                                                        : 'Activate',
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        admin.deletePlace(
                                                          p['id'] as String,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 20,
                                                      color: Colors.red,
                                                    ),
                                                    tooltip: 'Delete',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
