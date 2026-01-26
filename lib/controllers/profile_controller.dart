import 'package:get/get.dart';
import '../models/app_user.dart';
import '../services/user_profile_service.dart';
import '../controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final UserProfileService _service = UserProfileService();

  final Rxn<AppUser> user = Rxn<AppUser>();
  final RxBool isLoading = false.obs;

  String? _lastLoadedUid; // ← simple guard to prevent reloading same user

  @override
  void onInit() {
    super.onInit();

    // React automatically to login/logout
    ever(Get.find<AuthController>().firebaseUser, (firebaseUser) async {
      if (firebaseUser != null) {
        await _loadProfileIfNeeded(firebaseUser.uid);
      } else {
        user.value = null;
        _lastLoadedUid = null;
      }
    });
  }

  /// Main loading method with deduplication
  Future<void> _loadProfileIfNeeded(String uid) async {
    // Prevent reloading the same user multiple times
    if (uid == _lastLoadedUid && user.value != null) {
      return;
    }

    isLoading.value = true;
    try {
      final loadedUser = await _service.getUserProfile(uid);
      if (loadedUser != null) {
        user.value = loadedUser;
        _lastLoadedUid = uid;
      } else {
        user.value = null;
        _lastLoadedUid = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
      user.value = null;
      _lastLoadedUid = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProfile(String uid) async {
    // Public method still available if needed somewhere else
    await _loadProfileIfNeeded(uid);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _service.updateUserProfile(uid, data);
      await _loadProfileIfNeeded(uid); // reload fresh data
      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
