# Dynamic Color Configuration Guide

## How to Change App Colors

All app colors are centralized in `lib/config/app_colors.dart`. Simply modify the colors in that file and they will apply to all pages automatically.

### Primary Colors

Edit these constants in `app_colors.dart`:

```dart
static const Color primaryLight = Color(0xFF42A5F5);  // Change this
static const Color primaryMedium = Color(0xFF1E88E5); // Change this
static const Color primaryDark = Color(0xFF1565C0);    // Change this
static const Color primaryDeep = Color(0xFF0D47A1);   // Change this
```

### Gradient Colors

The gradients are automatically generated from the primary colors:

- **Light Mode**: Uses `lightGradient` (primaryLight → primaryMedium → primaryDark)
- **Dark Mode**: Uses `darkGradient` (darker indigo shades)

### Text Colors

- `textLight`: White text for light backgrounds
- `textDark`: Dark text for light backgrounds
- `textLightSecondary`: Semi-transparent white
- `textDarkSecondary`: Semi-transparent dark

### Accent Colors

- `accentGreen`: Success messages
- `accentRed`: Error messages
- `accentOrange`: Warning messages
- `accentAmber`: Highlight color

## Dark Mode / Light Mode

The app now supports both dark and light modes:

1. **Toggle Theme**: Tap the theme icon in the Settings page app bar
2. **Theme Persistence**: Your preference is saved and will persist across app restarts
3. **Automatic Adaptation**: All pages automatically adapt to the selected theme

## Usage in Code

Instead of hardcoding colors, use:

```dart
import '../config/app_colors.dart';

// Use gradient background
GradientBackground(child: YourWidget())

// Use colors directly
Container(color: AppColors.primaryDeep)
Text('Hello', style: TextStyle(color: AppColors.textLight))
```

## Splash Screen

The splash screen now shows properly on app start with a minimum display duration for better UX.

