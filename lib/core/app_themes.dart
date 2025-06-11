import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Pixel Art Game Theme Configuration
/// Provides themes that complement the cute teddy bear pixel art style
class PixelArtThemes {
  
  // === LIGHT THEME ===
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: PixelArtColorSchemes.lightScheme,
      primarySwatch: AppColors.primarySwatch,
      
      // Pixel Art Typography
      fontFamily: 'Roboto', // Can be changed to pixel font later
      
      // App Bar Theme - Purple gradient style
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.textLight,
        elevation: 0, // Flat design for pixel art
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
        toolbarHeight: 56,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      
      // Primary Buttons - Rounded pixel art style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textLight,
          elevation: 4,
          shadowColor: AppColors.shadowSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded for friendly feel
          ),
          minimumSize: const Size(140, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      
      // Secondary Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
      
      // Outlined Buttons - Pink accent
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPink,
          side: const BorderSide(color: AppColors.accentPink, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(120, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      
      // Cards - Soft rounded style
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 6,
        shadowColor: AppColors.shadowSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(12),
        surfaceTintColor: AppColors.primaryPurpleLight,
      ),
      
      // Input Fields - Rounded friendly style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.pixelOutlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.pixelOutlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      
      // Typography - Friendly pixel art style
      textTheme: const TextTheme(
        // Display styles - Game titles
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 2.0,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.8,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
          height: 1.3,
        ),
        
        // Headlines - Section titles
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
        ),
        
        // Titles - Button text, labels
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.6,
        ),
        
        // Body text - Descriptions, content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          height: 1.3,
        ),
        
        // Labels - Small UI text
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.6,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          letterSpacing: 0.4,
        ),
      ),
      
      // Icons - Pixel art friendly
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 28, // Slightly larger for better visibility
      ),
      
      // Floating Action Button - Rounded with gradient feel
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPink,
        foregroundColor: AppColors.textLight,
        elevation: 8,
        shape: CircleBorder(),
        iconSize: 28,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Dialogs - Rounded friendly style
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceLight,
        elevation: 12,
        shadowColor: AppColors.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
      
      // Switch Theme - Pink accent
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentPink;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentPinkLight;
          }
          return AppColors.backgroundMedium;
        }),
      ),
      
      // Slider Theme - Purple accent
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primaryPurple,
        inactiveTrackColor: AppColors.backgroundMedium,
        thumbColor: AppColors.primaryPurple,
        overlayColor: AppColors.overlayLight,
        valueIndicatorColor: AppColors.primaryPurple,
        valueIndicatorTextStyle: TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // SnackBar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryPurple,
        contentTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Chip Theme - Rounded pills
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundMedium,
        selectedColor: AppColors.primaryPurpleLight,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
    );
  }
  
  // === DARK THEME ===
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: PixelArtColorSchemes.darkScheme,
      primarySwatch: AppColors.primarySwatch,
      
      // Dark theme styling with pixel art aesthetics
      fontFamily: 'Roboto',
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurpleLight,
          foregroundColor: AppColors.textPrimary,
          elevation: 6,
          shadowColor: AppColors.shadowHard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(140, 56),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 8,
        shadowColor: AppColors.shadowHard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(12),
      ),
      
      // Continue with dark theme specific styling...
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 2.0,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textLight,
          height: 1.5,
        ),
        // ... other text styles
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.textLight,
        size: 28,
      ),
    );
  }
  
  // === HIGH CONTRAST THEME ===
  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: PixelArtColorSchemes.highContrastScheme,
      
      // High contrast styling for accessibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 18, // Larger for better readability
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(160, 60), // Larger touch targets
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Game-specific theme extensions
class GameThemeExtension extends ThemeExtension<GameThemeExtension> {
  final Color playerColor;
  final Color grassColor;
  final Color roadColor;
  final Color waterColor;
  final Color obstacleColor;
  final Color scoreColor;
  final Color hudBackgroundColor;
  final Color pauseOverlayColor;
  
  const GameThemeExtension({
    required this.playerColor,
    required this.grassColor,
    required this.roadColor,
    required this.waterColor,
    required this.obstacleColor,
    required this.scoreColor,
    required this.hudBackgroundColor,
    required this.pauseOverlayColor,
  });
  
  @override
  GameThemeExtension copyWith({
    Color? playerColor,
    Color? grassColor,
    Color? roadColor,
    Color? waterColor,
    Color? obstacleColor,
    Color? scoreColor,
    Color? hudBackgroundColor,
    Color? pauseOverlayColor,
  }) {
    return GameThemeExtension(
      playerColor: playerColor ?? this.playerColor,
      grassColor: grassColor ?? this.grassColor,
      roadColor: roadColor ?? this.roadColor,
      waterColor: waterColor ?? this.waterColor,
      obstacleColor: obstacleColor ?? this.obstacleColor,
      scoreColor: scoreColor ?? this.scoreColor,
      hudBackgroundColor: hudBackgroundColor ?? this.hudBackgroundColor,
      pauseOverlayColor: pauseOverlayColor ?? this.pauseOverlayColor,
    );
  }
  
  @override
  GameThemeExtension lerp(ThemeExtension<GameThemeExtension>? other, double t) {
    if (other is! GameThemeExtension) {
      return this;
    }
    return GameThemeExtension(
      playerColor: Color.lerp(playerColor, other.playerColor, t)!,
      grassColor: Color.lerp(grassColor, other.grassColor, t)!,
      roadColor: Color.lerp(roadColor, other.roadColor, t)!,
      waterColor: Color.lerp(waterColor, other.waterColor, t)!,
      obstacleColor: Color.lerp(obstacleColor, other.obstacleColor, t)!,
      scoreColor: Color.lerp(scoreColor, other.scoreColor, t)!,
      hudBackgroundColor: Color.lerp(hudBackgroundColor, other.hudBackgroundColor, t)!,
      pauseOverlayColor: Color.lerp(pauseOverlayColor, other.pauseOverlayColor, t)!,
    );
  }
  
  static const light = GameThemeExtension(
    playerColor: AppColors.teddyBrown,
    grassColor: AppColors.grassGreen,
    roadColor: AppColors.roadGray,
    waterColor: AppColors.waterBlue,
    obstacleColor: AppColors.carRed,
    scoreColor: AppColors.scoreGold,
    hudBackgroundColor: AppColors.overlayMedium,
    pauseOverlayColor: AppColors.pausedOverlay,
  );
  
  static const dark = GameThemeExtension(
    playerColor: AppColors.teddyBrownLight,
    grassColor: AppColors.grassGreenDark,
    roadColor: AppColors.roadGrayDark,
    waterColor: AppColors.waterBlueDark,
    obstacleColor: AppColors.carRed,
    scoreColor: AppColors.scoreGold,
    hudBackgroundColor: AppColors.overlayDark,
    pauseOverlayColor: AppColors.pausedOverlay,
  );
} 