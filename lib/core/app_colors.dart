import 'package:flutter/material.dart';

/// Color palette for Endless Hopper - Pixel Art Theme
/// Inspired by cute teddy bear pixel art and retro gaming aesthetics
class AppColors {
  // === PRIMARY BRAND COLORS ===
  // Purple-based primary palette to match pixel art style
  static const Color primaryPurple = Color(0xFF8B7CAB);      // Soft lavender purple
  static const Color primaryPurpleDark = Color(0xFF6B5B8C);  // Deeper purple
  static const Color primaryPurpleLight = Color(0xFFB4A7C7); // Light purple
  
  static const Color accentPink = Color(0xFFE8A1A1);         // Soft pink accent
  static const Color accentPinkDark = Color(0xFFD68181);     // Deeper pink
  static const Color accentPinkLight = Color(0xFFF0C4C4);    // Light pink
  
  static const Color accentYellow = Color(0xFFFFE66D);       // Soft yellow accent
  static const Color accentYellowDark = Color(0xFFFFD93D);   // Deeper yellow
  static const Color accentYellowLight = Color(0xFFFFF2A1);  // Light yellow
  
  // === PIXEL ART CHARACTER COLORS ===
  // Teddy Bear colors (warm browns and cream)
  static const Color teddyBrown = Color(0xFFB8860B);         // Golden brown
  static const Color teddyBrownDark = Color(0xFF8B6914);     // Dark brown
  static const Color teddyBrownLight = Color(0xFFD4AF37);    // Light golden
  static const Color teddyCream = Color(0xFFFDF5E6);         // Cream color
  static const Color teddyNose = Color(0xFF8B4513);          // Saddle brown for nose
  
  // === GAME ENVIRONMENT COLORS ===
  // Grass & Nature (soft greens)
  static const Color grassGreen = Color(0xFF90EE90);         // Light green
  static const Color grassGreenDark = Color(0xFF7BC97B);     // Medium green
  static const Color grassGreenLight = Color(0xFFC8F7C8);    // Very light green
  
  // Road & Urban (soft grays)
  static const Color roadGray = Color(0xFFD3D3D3);          // Light gray
  static const Color roadGrayDark = Color(0xFFA9A9A9);      // Dark gray
  static const Color roadGrayLight = Color(0xFFE8E8E8);     // Very light gray
  static const Color roadLines = Color(0xFFFFFFFF);          // White lines
  
  // Water (soft blues)
  static const Color waterBlue = Color(0xFF87CEEB);          // Sky blue
  static const Color waterBlueDark = Color(0xFF4682B4);      // Steel blue
  static const Color waterBlueLight = Color(0xFFB0E0E6);     // Powder blue
  
  // Mountains & Rocks (soft browns)
  static const Color mountainBrown = Color(0xFFCD853F);      // Peru brown
  static const Color mountainBrownDark = Color(0xFFA0522D);  // Sienna
  static const Color mountainBrownLight = Color(0xFFDEB887); // Burlywood
  
  // === OBSTACLE COLORS ===
  // Cars (bright but not harsh)
  static const Color carRed = Color(0xFFFF6B6B);            // Coral red
  static const Color carBlue = Color(0xFF4ECDC4);           // Turquoise
  static const Color carYellow = Color(0xFFFFE66D);         // Light yellow
  static const Color carPurple = Color(0xFFA8E6CF);         // Mint green
  static const Color carOrange = Color(0xFFFFB347);         // Peach orange
  
  // Natural obstacles
  static const Color logBrown = Color(0xFF8B4513);          // Saddle brown
  static const Color rockGray = Color(0xFF696969);          // Dim gray
  
  // === UI THEME COLORS ===
  // Backgrounds (soft pastels)
  static const Color backgroundLight = Color(0xFFF8F0FF);    // Very light purple
  static const Color backgroundMedium = Color(0xFFE6D7FF);   // Light purple
  static const Color backgroundDark = Color(0xFF2D1B3D);     // Dark purple
  
  static const Color surfaceLight = Color(0xFFFFFFFF);       // Pure white
  static const Color surfaceMedium = Color(0xFFF5F0FF);      // Off-white purple tint
  static const Color surfaceDark = Color(0xFF3D2C4F);        // Dark purple surface
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D1B3D);        // Dark purple text
  static const Color textSecondary = Color(0xFF6B5B8C);      // Medium purple text
  static const Color textTertiary = Color(0xFF9B8BAD);       // Light purple text
  static const Color textLight = Color(0xFFFFFFFF);          // White text
  static const Color textAccent = Color(0xFFE8A1A1);         // Pink accent text
  
  // === STATUS & FEEDBACK COLORS ===
  static const Color success = Color(0xFF7BC97B);            // Soft green
  static const Color warning = Color(0xFFFFB347);            // Soft orange
  static const Color error = Color(0xFFFF6B6B);              // Soft red
  static const Color info = Color(0xFF87CEEB);               // Soft blue
  
  // Game-specific status
  static const Color scoreGold = Color(0xFFFFD700);          // Gold
  static const Color scoreSilver = Color(0xFFC0C0C0);        // Silver
  static const Color scoreBronze = Color(0xFFCD853F);        // Bronze
  
  // Health indicators
  static const Color healthFull = Color(0xFF7BC97B);         // Green
  static const Color healthMedium = Color(0xFFFFB347);       // Orange
  static const Color healthLow = Color(0xFFFF6B6B);          // Red
  
  // === VISUAL EFFECTS COLORS ===
  // Sparkles and particles
  static const Color sparkleWhite = Color(0xFFFFFFFF);       // Pure white
  static const Color sparkleGold = Color(0xFFFFD700);        // Gold sparkle
  static const Color sparklePink = Color(0xFFFFB3DA);        // Pink sparkle
  static const Color sparklePurple = Color(0xFFD8BFD8);      // Purple sparkle
  
  // Water effects
  static const Color splashBlue = Color(0xFF87CEEB);         // Water splash
  static const Color splashWhite = Color(0xFFFFFFFF);        // Foam
  
  // === SHADOWS & OVERLAYS ===
  static const Color shadowSoft = Color(0x1A2D1B3D);        // Soft purple shadow
  static const Color shadowMedium = Color(0x332D1B3D);       // Medium purple shadow
  static const Color shadowHard = Color(0x662D1B3D);         // Hard purple shadow
  
  static const Color overlayLight = Color(0x1AFFFFFF);       // Light white overlay
  static const Color overlayMedium = Color(0x33FFFFFF);      // Medium white overlay
  static const Color overlayDark = Color(0x662D1B3D);        // Dark purple overlay
  
  // === GRADIENT PALETTES ===
  // Sky gradients
  static const List<Color> skyDayGradient = [
    Color(0xFFB4A7C7), // Light purple
    Color(0xFFE6D7FF), // Very light purple
  ];
  
  static const List<Color> skyEveningGradient = [
    Color(0xFFE8A1A1), // Pink
    Color(0xFFB4A7C7), // Purple
    Color(0xFF8B7CAB), // Deeper purple
  ];
  
  static const List<Color> skyNightGradient = [
    Color(0xFF2D1B3D), // Dark purple
    Color(0xFF3D2C4F), // Medium dark purple
  ];
  
  // UI gradients
  static const List<Color> buttonGradient = [
    Color(0xFFB4A7C7), // Light purple
    Color(0xFF8B7CAB), // Primary purple
  ];
  
  static const List<Color> panelGradient = [
    Color(0xFFF8F0FF), // Very light purple
    Color(0xFFE6D7FF), // Light purple
  ];
  
  // === BUTTON COLORS ===
  static const Color buttonPrimary = primaryPurple;
  static const Color buttonPrimaryPressed = primaryPurpleDark;
  static const Color buttonSecondary = accentPink;
  static const Color buttonSecondaryPressed = accentPinkDark;
  static const Color buttonSuccess = success;
  static const Color buttonWarning = warning;
  static const Color buttonError = error;
  
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonDisabledText = Color(0xFFB0B0B0);
  
  // === GAME STATE COLORS ===
  static const Color pausedOverlay = Color(0x802D1B3D);      // Purple pause overlay
  static const Color gameOverOverlay = Color(0xB32D1B3D);    // Darker purple game over
  static const Color victoryOverlay = Color(0x80FFD700);     // Gold victory overlay
  
  // === PIXEL ART SPECIFIC COLORS ===
  // Outline colors for pixel art style
  static const Color pixelOutlineDark = Color(0xFF2D1B3D);   // Dark outline
  static const Color pixelOutlineLight = Color(0xFF6B5B8C);  // Light outline
  
  // Highlight colors for pixel art
  static const Color pixelHighlight = Color(0xFFFFFFFF);     // White highlight
  static const Color pixelMidtone = Color(0xFFE6D7FF);       // Light purple midtone
  static const Color pixelShadow = Color(0xFF8B7CAB);        // Purple shadow
  
  // === DYNAMIC COLOR FUNCTIONS ===
  
  /// Get grass color based on environment health
  static Color getGrassColor(double health) {
    return Color.lerp(grassGreenLight, grassGreenDark, health) ?? grassGreen;
  }
  
  /// Get water color based on depth/movement
  static Color getWaterColor(double intensity) {
    return Color.lerp(waterBlueLight, waterBlueDark, intensity) ?? waterBlue;
  }
  
  /// Get health color based on percentage
  static Color getHealthColor(double healthPercentage) {
    if (healthPercentage > 0.6) {
      return healthFull;
    } else if (healthPercentage > 0.3) {
      return healthMedium;
    } else {
      return healthLow;
    }
  }
  
  /// Get difficulty color based on level
  static Color getDifficultyColor(double difficulty) {
    if (difficulty < 2.0) {
      return success;
    } else if (difficulty < 4.0) {
      return warning;
    } else {
      return error;
    }
  }
  
  /// Get time-of-day color
  static List<Color> getSkyGradient(double timeOfDay) {
    if (timeOfDay < 0.3) {
      return skyNightGradient;
    } else if (timeOfDay < 0.7) {
      return skyDayGradient;
    } else {
      return skyEveningGradient;
    }
  }
  
  // === MATERIAL COLOR SWATCH ===
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF8B7CAB,
    <int, Color>{
      50: Color(0xFFF8F0FF),   // Very light purple
      100: Color(0xFFE6D7FF),  // Light purple
      200: Color(0xFFD4BFFF),  // Medium light purple
      300: Color(0xFFC2A7FF),  // Medium purple
      400: Color(0xFFB4A7C7),  // Light primary
      500: Color(0xFF8B7CAB),  // Primary purple
      600: Color(0xFF7B6C9B),  // Medium dark purple
      700: Color(0xFF6B5B8C),  // Dark purple
      800: Color(0xFF5B4B7C),  // Darker purple
      900: Color(0xFF2D1B3D),  // Very dark purple
    },
  );
}

/// Color schemes for different game themes
class PixelArtColorSchemes {
  /// Light theme color scheme
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryPurple,
    onPrimary: AppColors.textLight,
    secondary: AppColors.accentPink,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.teddyBrown,
    onTertiary: AppColors.textLight,
    error: AppColors.error,
    onError: AppColors.textLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.pixelOutlineLight,
    shadow: AppColors.shadowSoft,
  );
  
  /// Dark theme color scheme
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryPurpleLight,
    onPrimary: AppColors.textPrimary,
    secondary: AppColors.accentPinkLight,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.teddyBrownLight,
    onTertiary: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textLight,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textLight,
    onSurfaceVariant: AppColors.textTertiary,
    outline: AppColors.pixelOutlineDark,
    shadow: AppColors.shadowHard,
  );
  
  /// High contrast theme for accessibility
  static const ColorScheme highContrastScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF333333),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF666666),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFFF0000),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    onSurfaceVariant: Color(0xFF333333),
    outline: Color(0xFF000000),
    shadow: Color(0xFF000000),
  );
} 