import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';

class GameUtils {
  static final Random _random = Random();
  
  // Random number generation
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
  
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }
  
  static bool randomBool() {
    return _random.nextBool();
  }
  
  // Choose random element from list
  static T randomElement<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('List cannot be empty');
    return list[_random.nextInt(list.length)];
  }
  
  // Collision detection
  static bool rectanglesCollide(Rect rect1, Rect rect2) {
    return rect1.overlaps(rect2);
  }
  
  static bool pointInRectangle(Offset point, Rect rectangle) {
    return rectangle.contains(point);
  }
  
  // Distance calculations
  static double distance(Offset point1, Offset point2) {
    final dx = point1.dx - point2.dx;
    final dy = point1.dy - point2.dy;
    return sqrt(dx * dx + dy * dy);
  }
  
  static double distanceSquared(Offset point1, Offset point2) {
    final dx = point1.dx - point2.dx;
    final dy = point1.dy - point2.dy;
    return dx * dx + dy * dy;
  }
  
  // Animation & Interpolation
  static double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }
  
  static Offset lerpOffset(Offset start, Offset end, double t) {
    return Offset(
      lerp(start.dx, end.dx, t),
      lerp(start.dy, end.dy, t),
    );
  }
  
  static Color lerpColor(Color start, Color end, double t) {
    return Color.lerp(start, end, t) ?? start;
  }
  
  // Easing functions
  static double easeInOut(double t) {
    return t * t * (3.0 - 2.0 * t);
  }
  
  static double easeOutBounce(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    } else {
      t -= 2.625 / 2.75;
      return 7.5625 * t * t + 0.984375;
    }
  }
  
  // Coordinate transformations
  static Offset worldToScreen(Offset worldPos, Offset cameraPos, Size screenSize) {
    return Offset(
      worldPos.dx - cameraPos.dx + screenSize.width / 2,
      worldPos.dy - cameraPos.dy + screenSize.height / 2,
    );
  }
  
  static Offset screenToWorld(Offset screenPos, Offset cameraPos, Size screenSize) {
    return Offset(
      screenPos.dx + cameraPos.dx - screenSize.width / 2,
      screenPos.dy + cameraPos.dy - screenSize.height / 2,
    );
  }
  
  // Grid/Tile utilities
  static Offset tileIndexToWorldPosition(int row, int col) {
    return Offset(
      col * GameConstants.tileSize,
      row * GameConstants.tileSize,
    );
  }
  
  static Point<int> worldPositionToTileIndex(Offset worldPos) {
    return Point<int>(
      (worldPos.dy / GameConstants.tileSize).floor(),
      (worldPos.dx / GameConstants.tileSize).floor(),
    );
  }
  
  static bool isValidTileIndex(int row, int col, int maxRows, int maxCols) {
    return row >= 0 && row < maxRows && col >= 0 && col < maxCols;
  }
  
  // Game mechanics utilities
  static double calculateDifficulty(int rowsCrossed) {
    final difficultyMultiplier = (rowsCrossed / GameConstants.rowsPerDifficultyIncrease).floor();
    return GameConstants.baseDifficulty + (difficultyMultiplier * GameConstants.difficultyIncrement);
  }
  
  static int calculateScore(int rowsCrossed, int timePlayed, int bonusActions) {
    final baseScore = rowsCrossed * GameConstants.pointsPerRow;
    final timeBonus = timePlayed * GameConstants.timeBonus;
    final bonusScore = bonusActions * GameConstants.bonusPointsForSpecialActions;
    return baseScore + timeBonus + bonusScore;
  }
  
  // Number formatting
  static String formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
  
  static String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Validation utilities
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
  
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }
  
  // Platform utilities
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
  
  // Performance utilities
  static void logPerformance(String operation, Function() function) {
    if (!isDebugMode) {
      function();
      return;
    }
    
    final stopwatch = Stopwatch()..start();
    function();
    stopwatch.stop();
    debugPrint('Performance: $operation took ${stopwatch.elapsedMilliseconds}ms');
  }
  
  // Clamp values
  static double clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }
  
  static int clampInt(int value, int min, int max) {
    return value < min ? min : (value > max ? max : value);
  }
  
  // Screen safe area calculations
  static EdgeInsets calculateSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }
  
  // Vibration patterns
  static List<int> get hopVibrationPattern => [0, 50];
  static List<int> get collisionVibrationPattern => [0, 100, 50, 100];
  static List<int> get successVibrationPattern => [0, 50, 50, 50];
} 