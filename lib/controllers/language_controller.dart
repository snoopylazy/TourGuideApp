import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  final Rx<Locale> currentLocale = const Locale(
    'km',
    'KH',
  ).obs; // Default: Khmer

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString('language_code');
      final savedCountryCode = prefs.getString('country_code');

      if (savedLanguageCode != null && savedCountryCode != null) {
        currentLocale.value = Locale(savedLanguageCode, savedCountryCode);
        Get.updateLocale(currentLocale.value);
      } else {
        // Default to Khmer
        currentLocale.value = const Locale('km', 'KH');
        Get.updateLocale(currentLocale.value);
      }
    } catch (e) {
      // If loading fails, use Khmer as default
      currentLocale.value = const Locale('km', 'KH');
      Get.updateLocale(currentLocale.value);
    }
  }

  Future<void> setLanguage(Locale locale) async {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');
    } catch (e) {
      // If saving fails, continue anyway
    }
  }

  void toggleLanguage() {
    if (currentLocale.value.languageCode == 'km') {
      setLanguage(const Locale('en', 'US'));
    } else {
      setLanguage(const Locale('km', 'KH'));
    }
  }

  bool get isKhmer => currentLocale.value.languageCode == 'km';
  bool get isEnglish => currentLocale.value.languageCode == 'en';
}
