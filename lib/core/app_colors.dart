import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);
  
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentBlueDark = Color(0xFF1976D2);
  static const Color accentBlueLight = Color(0xFF64B5F6);
  
  // Game Environment Colors
  static const Color grassGreen = Color(0xFF8BC34A);
  static const Color grassGreenDark = Color(0xFF689F38);
  static const Color grassGreenLight = Color(0xFFAED581);
  
  static const Color roadGray = Color(0xFF424242);
  static const Color roadGrayDark = Color(0xFF212121);
  static const Color roadGrayLight = Color(0xFF616161);
  
  static const Color waterBlue = Color(0xFF03A9F4);
  static const Color waterBlueDark = Color(0xFF0277BD);
  static const Color waterBlueLight = Color(0xFF4FC3F7);
  
  static const Color mountainBrown = Color(0xFF795548);
  static const Color mountainBrownDark = Color(0xFF5D4037);
  static const Color mountainBrownLight = Color(0xFF8D6E63);
  
  // Character Colors
  static const Color frogGreen = Color(0xFF4CAF50);
  static const Color teddyBrown = Color(0xFF8D6E63);
  static const Color robotSilver = Color(0xFF9E9E9E);
  static const Color ninjaBlack = Color(0xFF263238);
  
  // Obstacle Colors
  static const Color carRed = Color(0xFFF44336);
  static const Color carBlue = Color(0xFF2196F3);
  static const Color carYellow = Color(0xFFFFEB3B);
  static const Color truckOrange = Color(0xFFFF9800);
  
  static const Color logBrown = Color(0xFF8D6E63);
  static const Color rockGray = Color(0xFF757575);
  
  // UI Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Game-specific Status Colors
  static const Color scoreGold = Color(0xFFFFD700);
  static const Color scoreSilver = Color(0xFFC0C0C0);
  static const Color scoreBronze = Color(0xFFCD7F32);
  
  static const Color healthGreen = Color(0xFF4CAF50);
  static const Color healthYellow = Color(0xFFFFEB3B);
  static const Color healthRed = Color(0xFFF44336);
  
  // Particle & Effect Colors
  static const Color sparkleWhite = Color(0xFFFFFFFF);
  static const Color sparkleYellow = Color(0xFFFFEB3B);
  static const Color splashBlue = Color(0xFF03A9F4);
  static const Color dustBrown = Color(0xFF8D6E63);
  
  // Shadow & Overlay Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x66000000);
  
  static const Color overlayLight = Color(0x1AFFFFFF);
  static const Color overlayMedium = Color(0x33FFFFFF);
  static const Color overlayDark = Color(0x66FFFFFF);
  
  // Gradient Colors
  static const List<Color> skyGradient = [
    Color(0xFF87CEEB), // Sky blue
    Color(0xFFE0F6FF), // Light blue
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFE66D), // Yellow
    Color(0xFF4ECDC4), // Teal
  ];
  
  static const List<Color> nightGradient = [
    Color(0xFF0F3460), // Dark blue
    Color(0xFF16213E), // Navy
  ];
  
  // Button Colors
  static const Color buttonPrimary = primaryGreen;
  static const Color buttonPrimaryPressed = primaryGreenDark;
  static const Color buttonSecondary = accentBlue;
  static const Color buttonSecondaryPressed = accentBlueDark;
  
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonDisabledText = Color(0xFF9E9E9E);
  
  // Input Colors
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBorderFocused = primaryGreen;
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color inputText = textPrimary;
  
  // Game State Colors
  static const Color pausedOverlay = Color(0x80000000);
  static const Color gameOverOverlay = Color(0xB3000000);
  static const Color loadingOverlay = Color(0x99000000);
  
  // Animation Colors
  static const Color fadeIn = Color(0x00000000);
  static const Color fadeOut = Color(0xFF000000);
  
  // Accessibility Colors (High Contrast)
  static const Color highContrastPrimary = Color(0xFF000000);
  static const Color highContrastSecondary = Color(0xFFFFFFFF);
  static const Color highContrastAccent = Color(0xFFFFFF00);
  
  // Color Getters for Dynamic Theming
  static Color getGrassColor(double intensity) {
    return Color.lerp(grassGreenLight, grassGreenDark, intensity) ?? grassGreen;
  }
  
  static Color getWaterColor(double depth) {
    return Color.lerp(waterBlueLight, waterBlueDark, depth) ?? waterBlue;
  }
  
  static Color getHealthColor(double healthPercentage) {
    if (healthPercentage > 0.6) {
      return healthGreen;
    } else if (healthPercentage > 0.3) {
      return healthYellow;
    } else {
      return healthRed;
    }
  }
  
  static Color getDifficultyColor(double difficulty) {
    if (difficulty < 2.0) {
      return success;
    } else if (difficulty < 4.0) {
      return warning;
    } else {
      return error;
    }
  }
  
  // Material Color Swatches
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF4CAF50,
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );
}

// Color schemes for different themes
class ColorSchemes {
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryGreen,
    onPrimary: Colors.white,
    secondary: AppColors.accentBlue,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimary,
  );
  
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryGreenLight,
    onPrimary: Colors.black,
    secondary: AppColors.accentBlueLight,
    onSecondary: Colors.black,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
  );
} 