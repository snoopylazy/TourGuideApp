import 'package:flutter/material.dart';

/// Centralized color configuration for the app
/// Change colors here and they will apply to all pages
class AppColors {
  // Primary gradient colors - Change these to customize your app theme
  static const Color primaryLight = Color(0xFF42A5F5); // Blue 400
  static const Color primaryMedium = Color(0xFF1E88E5); // Blue 600
  static const Color primaryDark = Color(0xFF1565C0); // Blue 800
  static const Color primaryDeep = Color(0xFF0D47A1); // Blue 900

  // Light mode colors
  static List<Color> get lightGradient => [
        primaryLight,
        primaryMedium,
        primaryDark,
      ];

  // Dark mode colors (darker shades)
  static List<Color> get darkGradient => [
        const Color(0xFF1A237E), // Indigo 900
        const Color(0xFF283593), // Indigo 800
        const Color(0xFF3949AB), // Indigo 700
      ];

  // Text colors
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF212121);
  static Color textLightSecondary = Colors.white.withOpacity(0.8);
  static Color textDarkSecondary = const Color(0xFF212121).withOpacity(0.7);

  // Glass container opacity
  static const double glassOpacity = 0.2;
  static const double glassOpacitySecondary = 0.1;

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Accent colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentAmber = Color(0xFFFFC107);
}

