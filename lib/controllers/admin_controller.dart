import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isAdmin = false.obs;
  final RxList<Map<String, dynamic>> places = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
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
    final snapshot = await _firestore.collection('places').orderBy('createdAt', descending: true).get();
    places.value = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    isLoading.value = false;
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    final snap = await _firestore.collection('categories').orderBy('name').get();
    categories.value = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
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
      Get.snackbar('Success', 'Place added successfully');
      return true;
    } catch (e) {
      print('Error adding place: $e'); // Debug log
      Get.snackbar('Error', 'Failed to add place: $e');
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
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      isLoading.value = true;
      await _firestore.collection('categories').add({
        'name': name.trim(), 
        'status': 'active', // Default status
        'createdAt': FieldValue.serverTimestamp()
      });
      await fetchCategories();
      Get.snackbar('Success', 'Category added successfully');
      return true;
    } catch (e) {
      print('Error adding category: $e'); // Debug log
      Get.snackbar('Error', 'Failed to add category: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addPlaceWithCoords(Map<String, dynamic> data, double? lat, double? lng) async {
    print('addPlaceWithCoords called with lat: $lat, lng: $lng');
    print('data: $data');
    
    // Create a new map to avoid any reference issues
    final Map<String, dynamic> placeData = {
      'title': data['title'] as String,
      'imageUrl': data['imageUrl'] as String,
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
        Get.snackbar('Error', 'Please login first');
        return false;
      }

      isLoading.value = true;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('places').doc(id).update(data);
      await fetchPlaces();
      Get.snackbar('Success', 'Place updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update place: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePlace(String id) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please login first');
        return;
      }

      isLoading.value = true;
      await _firestore.collection('places').doc(id).delete();
      await fetchPlaces();
      Get.snackbar('Success', 'Place deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete place: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please login first');
        return;
      }

      isLoading.value = true;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('categories').doc(id).update(data);
      await fetchCategories();
      Get.snackbar('Success', 'Category updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please login first');
        return;
      }

      isLoading.value = true;
      await _firestore.collection('categories').doc(id).delete();
      await fetchCategories();
      Get.snackbar('Success', 'Category deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
