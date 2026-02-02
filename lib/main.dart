import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourguideapp/pages/navigationscreen.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/notification_controller.dart';
import 'services/notification_service.dart';
import 'config/app_colors.dart';
import 'pages/splashscreen.dart';
import 'pages/loginscreen.dart';
import 'pages/registerscreen.dart';
import 'pages/homescreen.dart';
import 'pages/settingsscreen.dart';
import 'pages/adminscreen.dart';
import 'pages/placedetailscreen.dart';
import 'pages/mapselectscreen.dart';
import 'pages/notificationdetailscreen.dart';
import 'models/notification_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthController());
  Get.put(ThemeController(), permanent: true);
  // Pre-register controllers for Settings and admin features
  Get.put(ProfileController(), permanent: true);
  Get.put(AdminController(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Tour Guide - Cambodia',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode.value,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          fontFamily: 'NexaRegular',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryDeep,
            primary: AppColors.primaryDeep,
            secondary: AppColors.primaryMedium,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.backgroundLight,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) => const TextStyle(
                color: Colors.white,
                fontFamily: 'NexaRegular',
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDeep,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryDeep,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          fontFamily: 'NexaRegular',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryDeep,
            primary: AppColors.primaryMedium,
            secondary: AppColors.primaryLight,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppColors.backgroundDark,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A237E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) => const TextStyle(
                color: Colors.white,
                fontFamily: 'NexaRegular',
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFF1E1E1E),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryMedium,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
          ),
        ),
        // Page routing
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const Splashscreen()),
          GetPage(name: '/login', page: () => const Loginscreen()),
          GetPage(name: '/register', page: () => Registerscreen()),
          GetPage(name: '/home', page: () => const Homescreen()),
          GetPage(name: '/settings', page: () => const SettingsScreen()),
          GetPage(name: '/admin', page: () => const Adminscreen()),
          GetPage(name: '/placedetails', page: () => const Placedetailscreen()),
          GetPage(name: '/mapselect', page: () => const Mapselectscreen()),
          GetPage(name: '/navigation', page: () => const NavigationScreen()),
          GetPage(
            name: '/notificationdetail',
            page: () {
              final notification = Get.arguments as NotificationModel;
              return NotificationDetailScreen(notification: notification);
            },
          ),
        ],
      ),
    );
  }
}
