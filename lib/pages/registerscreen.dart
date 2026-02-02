import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/url_validator.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../config/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';

class Registerscreen extends StatelessWidget {
  Registerscreen({super.key});
  final AuthController _auth = Get.find();
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString imageUrl = ''.obs;
  final RxBool obscurePassword = true.obs;

  // Audio player instance (cheap for short effects)
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                GlassContainer(
                  padding: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ស្វាគមន៍មកកាន់ការធ្វើដំណើរ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ចាប់ផ្តើមការស្វែងរកភាពល្អនៃពិភពលោក។",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => name.value = v,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Snoopy',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
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
                        const SizedBox(height: 20),
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (v) => email.value = v,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'snoopier@example.com',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
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
                        const SizedBox(height: 20),
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => TextField(
                            onChanged: (v) => password.value = v,
                            obscureText: obscurePassword.value,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Create a strong password',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () => obscurePassword.value =
                                    !obscurePassword.value,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
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
                        const SizedBox(height: 32),
                        Obx(
                          () => _auth.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (name.value.trim().isEmpty ||
                                          email.value.trim().isEmpty ||
                                          password.value.trim().isEmpty) {
                                        // Play error sound for validation failure
                                        await player.play(
                                          AssetSource('fail.mp3'),
                                        );

                                        Get.snackbar(
                                          'Error',
                                          'Please fill all required fields',
                                          backgroundColor: Colors.red.shade100,
                                          colorText: Colors.red.shade900,
                                        );
                                        return;
                                      }
                                      if (imageUrl.value.isNotEmpty &&
                                          !isValidImageUrl(imageUrl.value)) {
                                        // Play error sound for invalid URL
                                        await player.play(
                                          AssetSource('fail.mp3'),
                                        );

                                        Get.snackbar(
                                          'Error',
                                          'Invalid image URL',
                                          backgroundColor: Colors.red.shade100,
                                          colorText: Colors.red.shade900,
                                        );
                                        return;
                                      }

                                      _auth.isLoading.value = true;

                                      try {
                                        await _auth.register(
                                          name.value.trim(),
                                          email.value.trim(),
                                          password.value.trim(),
                                          profileImageUrl: imageUrl.value
                                              .trim(),
                                        );

                                        // Success → play sound
                                        await player.play(
                                          AssetSource('success.mp3'),
                                        );

                                        // Optional: success message or auto-redirect
                                        Get.snackbar(
                                          'Success',
                                          'Account created! Welcome aboard.',
                                          backgroundColor:
                                              Colors.green.shade100,
                                          colorText: Colors.green.shade900,
                                        );
                                      } catch (e) {
                                        // Failure → play fail sound
                                        await player.play(
                                          AssetSource('fail.mp3'),
                                        );

                                        Get.snackbar(
                                          'Registration Failed',
                                          e.toString().replaceAll(
                                            'Exception: ',
                                            '',
                                          ),
                                          backgroundColor: Colors.red.shade100,
                                          colorText: Colors.red.shade900,
                                        );
                                      } finally {
                                        _auth.isLoading.value = false;
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
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
      ),
    );
  }
}
