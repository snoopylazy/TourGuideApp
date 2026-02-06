import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isAdmin = false.obs;
  final RxList<Map<String, dynamic>> places = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> areas = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // simple hard-coded admin credentials
  bool loginAdmin(String username, String password) {
    if (username == 'admin' && password == '123456') {
      isAdmin.value = true;
      return true;
    }
    isAdmin.value = false;
    return false;
  }

  Future<void> fetchPlaces() async {
    isLoading.value = true;
    final snapshot = await _firestore
        .collection('places')
        .orderBy('createdAt', descending: true)
        .get();
    places.value = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    isLoading.value = false;
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    final snap = await _firestore
        .collection('categories')
        .orderBy('name')
        .get();
    categories.value = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    isLoading.value = false;
  }

  Future<void> fetchAreas() async {
    isLoading.value = true;
    final snap = await _firestore.collection('areas').orderBy('name').get();
    areas.value = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    isLoading.value = false;
  }

  Future<bool> addPlace(Map<String, dynamic> data) async {
    try {
      // Check if user is authenticated
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      print('Adding place with data: $data'); // Debug log
      isLoading.value = true;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['status'] = 'active'; // Default status
      final docRef = await _firestore.collection('places').add(data);
      print('Place added with ID: ${docRef.id}'); // Debug log
      await fetchPlaces();
      Get.snackbar('success'.tr, 'place_added_successfully'.tr);
      return true;
    } catch (e) {
      print('Error adding place: $e'); // Debug log
      Get.snackbar('error'.tr, 'failed_to_add_place'.tr + ': $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCategory(String name) async {
    if (name.trim().isEmpty) return false;
    try {
      // Check if user is authenticated
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return false;
      }

      isLoading.value = true;
      await _firestore.collection('categories').add({
        'name': name.trim(),
        'status': 'active', // Default status
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchCategories();
      Get.snackbar('success'.tr, 'category_added_successfully'.tr);
      return true;
    } catch (e) {
      print('Error adding category: $e'); // Debug log
      Get.snackbar('error'.tr, 'failed_to_add_category'.tr + ': $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addArea(String name) async {
    if (name.trim().isEmpty) return false;
    try {
      // Check if user is authenticated
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return false;
      }

      isLoading.value = true;
      await _firestore.collection('areas').add({
        'name': name.trim(),
        'status': 'active', // Default status
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchAreas();
      Get.snackbar('success'.tr, 'area_added_successfully'.tr);
      return true;
    } catch (e) {
      print('Error adding area: $e'); // Debug log
      Get.snackbar('Error', 'Failed to add area: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addPlaceWithCoords(
    Map<String, dynamic> data,
    double? lat,
    double? lng,
  ) async {
    print('addPlaceWithCoords called with lat: $lat, lng: $lng');
    print('data: $data');

    final Map<String, dynamic> placeData = {
      'title': data['title'] as String,
      'imageUrl': data['imageUrl'], // Can be String or List
      'description': data['description'] as String,
      'status': 'active',
    };

    // Add category data if present
    if (data['categoryId'] != null) {
      placeData['categoryId'] = data['categoryId'] as String;
    }
    if (data['categoryName'] != null) {
      placeData['categoryName'] = data['categoryName'] as String;
    }

    // Add area data if present (THIS WAS MISSING!)
    if (data['areaId'] != null) {
      placeData['areaId'] = data['areaId'] as String;
    }
    if (data['areaName'] != null) {
      placeData['areaName'] = data['areaName'] as String;
    }

    // Add coordinates if present
    if (lat != null && lng != null) {
      placeData['lat'] = lat.toDouble();
      placeData['lng'] = lng.toDouble();
    }

    print('Final placeData: $placeData');
    return await addPlace(placeData);
  }

  Future<bool> updatePlace(String id, Map<String, dynamic> data) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return false;
      }

      isLoading.value = true;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('places').doc(id).update(data);
      await fetchPlaces();
      Get.snackbar('success'.tr, 'place_updated_successfully'.tr);
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_update_place'.tr + ': $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePlace(String id) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return;
      }

      isLoading.value = true;
      await _firestore.collection('places').doc(id).delete();
      await fetchPlaces();
      Get.snackbar('success'.tr, 'place_deleted_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_delete_place'.tr + ': $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return;
      }

      isLoading.value = true;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('categories').doc(id).update(data);
      await fetchCategories();
      Get.snackbar('success'.tr, 'category_updated_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_update_category'.tr + ': $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return;
      }

      isLoading.value = true;
      await _firestore.collection('categories').doc(id).delete();
      await fetchCategories();
      Get.snackbar('success'.tr, 'category_deleted_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_delete_category'.tr + ': $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateArea(String id, Map<String, dynamic> data) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return false;
      }

      isLoading.value = true;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('areas').doc(id).update(data);
      await fetchAreas();
      Get.snackbar('success'.tr, 'area_updated_successfully'.tr);
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_update_area'.tr + ': $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteArea(String id) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('error'.tr, 'please_login_first'.tr);
        return;
      }

      isLoading.value = true;
      await _firestore.collection('areas').doc(id).delete();
      await fetchAreas();
      Get.snackbar('success'.tr, 'area_deleted_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_delete_area'.tr + ': $e');
    } finally {
      isLoading.value = false;
    }
  }
}
