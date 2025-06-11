import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../entities/log.dart';
import '../entities/log_types.dart';
import '../entities/obstacle.dart';
import '../../core/constants.dart';

enum CrossingDifficulty {
  easy,    // Multiple large logs, slow speeds
  medium,  // Mixed log sizes, moderate speeds
  hard,    // Fewer logs, faster speeds, precise timing required
  expert,  // Minimal logs, high speeds, advanced timing
}

class LogPattern {
  LogPattern({
    required this.logPositions,
    required this.direction,
    required this.gapSizes,
    required this.crossingSafety,
  });

  final List<double> logPositions; // Relative X positions
  final int direction;
  final List<double> gapSizes;
  final double crossingSafety; // 0.0-1.0, higher = easier to cross

  static LogPattern safe(int worldWidth, int direction) => LogPattern(
    logPositions: List.generate(5, (i) => i * (worldWidth / 5) - (worldWidth / 2)),
    direction: direction,
    gapSizes: List.filled(4, 1.0),
    crossingSafety: 0.9,
  );

  static LogPattern challenging(int worldWidth, int direction) => LogPattern(
    logPositions: [
      -worldWidth / 3,
      worldWidth / 6,
      worldWidth / 2.5,
    ],
    direction: direction,
    gapSizes: [2.0, 1.5, 2.5],
    crossingSafety: 0.6,
  );

  static LogPattern expert(int worldWidth, int direction) => LogPattern(
    logPositions: [
      -worldWidth / 4,
      worldWidth / 3,
    ],
    direction: direction,
    gapSizes: [3.0, 4.0],
    crossingSafety: 0.3,
  );
}

class LogSpawner {
  LogSpawner({
    required this.worldWidth,
    this.seed,
  }) : _random = math.Random(seed);

  final int worldWidth;
  final int? seed;
  final math.Random _random;

  // Strategic log placement patterns
  static const List<List<double>> crossingPatterns = [
    // Pattern 1: Evenly spaced (easy)
    [-0.6, -0.2, 0.2, 0.6],
    // Pattern 2: Clustered (medium)
    [-0.5, -0.3, 0.4, 0.6],
    // Pattern 3: Sparse (hard)
    [-0.4, 0.3],
    // Pattern 4: Single large crossing point (expert)
    [0.0],
  ];

  CrossingDifficulty getDifficultyForLevel(double difficulty) {
    if (difficulty < 0.3) return CrossingDifficulty.easy;
    if (difficulty < 0.6) return CrossingDifficulty.medium;
    if (difficulty < 0.8) return CrossingDifficulty.hard;
    return CrossingDifficulty.expert;
  }

  LogType selectLogType(CrossingDifficulty difficulty) {
    Map<LogType, double> weights;

    switch (difficulty) {
      case CrossingDifficulty.easy:
        weights = {
          LogType.small: 1.0,
          LogType.medium: 3.0,
          LogType.large: 2.0,
          LogType.cluster: 1.5,
        };
        break;
      case CrossingDifficulty.medium:
        weights = {
          LogType.small: 2.0,
          LogType.medium: 3.0,
          LogType.large: 1.5,
          LogType.cluster: 0.5,
        };
        break;
      case CrossingDifficulty.hard:
        weights = {
          LogType.small: 3.0,
          LogType.medium: 2.0,
          LogType.large: 1.0,
          LogType.cluster: 0.2,
        };
        break;
      case CrossingDifficulty.expert:
        weights = {
          LogType.small: 4.0,
          LogType.medium: 1.0,
          LogType.large: 0.5,
          LogType.cluster: 0.1,
        };
        break;
    }

    final totalWeight = weights.values.fold(0.0, (sum, weight) => sum + weight);
    double randomValue = _random.nextDouble() * totalWeight;

    for (final entry in weights.entries) {
      randomValue -= entry.value;
      if (randomValue <= 0) {
        return entry.key;
      }
    }

    return LogType.medium; // Fallback
  }

  double generateSpeed(LogType type, double difficultyMultiplier) {
    final specs = LogSpecs.getSpecs(type);
    final baseSpeed = specs.baseSpeed * difficultyMultiplier;
    final variation = specs.speedVariation;
    
    return baseSpeed + (_random.nextDouble() * 2 - 1) * variation;
  }

  Log createLog(LogType type, double x, double y, double speed, int direction) {
    switch (type) {
      case LogType.small:
        return SmallLog(x: x, y: y, speed: speed, direction: direction);
      case LogType.medium:
        return MediumLog(x: x, y: y, speed: speed, direction: direction);
      case LogType.large:
        return LargeLog(x: x, y: y, speed: speed, direction: direction);
      case LogType.cluster:
        return LogCluster(x: x, y: y, speed: speed, direction: direction);
    }
  }

  // Check if logs provide adequate crossing opportunities
  bool validateCrossingSafety(List<Log> logs, int worldWidth) {
    if (logs.isEmpty) return false;

    const tileSize = GameConstants.tileSize;
    const playerWidth = 32.0;
    const safetyMargin = 16.0;

    // Check if player can cross from any starting position
    for (double startX = -(worldWidth ~/ 2) * tileSize; 
         startX <= (worldWidth ~/ 2) * tileSize; 
         startX += tileSize) {
      
      bool canCross = false;
      for (final log in logs) {
        final logLeft = log.x - log.width / 2;
        final logRight = log.x + log.width / 2;
        
        // Check if log can accommodate player with safety margin
        if (logRight - logLeft >= playerWidth + safetyMargin) {
          // Check if log is reachable from start position
          final distance = (log.x - startX).abs();
          if (distance <= tileSize * 2) { // Within 2 tiles reach
            canCross = true;
            break;
          }
        }
      }
      
      if (canCross) return true;
    }

    return false;
  }

  // Generate strategic log placement for water crossing
  List<Log> generateLogsForRow({
    required int y,
    required double difficulty,
    List<Obstacle> existingObstacles = const [],
  }) {
    final logs = <Log>[];
    final worldY = y * GameConstants.tileSize;
    final crossingDifficulty = getDifficultyForLevel(difficulty);
    
    // Determine movement direction (alternating pattern for variety)
    final direction = (y % 2 == 0) ? 1 : -1;
    
    // Select crossing pattern based on difficulty
    List<double> positions;
    switch (crossingDifficulty) {
      case CrossingDifficulty.easy:
        positions = crossingPatterns[0];
        break;
      case CrossingDifficulty.medium:
        positions = crossingPatterns[_random.nextInt(2)];
        break;
      case CrossingDifficulty.hard:
        positions = crossingPatterns[2];
        break;
      case CrossingDifficulty.expert:
        positions = crossingPatterns[3];
        break;
    }

    // Generate logs at strategic positions
    for (final relativePos in positions) {
      final logType = selectLogType(crossingDifficulty);
      final specs = LogSpecs.getSpecs(logType);
      final speed = generateSpeed(logType, 1.0 + difficulty * 0.5);
      
      final logX = relativePos * worldWidth * GameConstants.tileSize;
      
      // Check collision safety with existing obstacles
      if (_isSafeLogPosition(logX, worldY, specs.width, specs.height, existingObstacles)) {
        final log = createLog(logType, logX, worldY, speed, direction);
        logs.add(log);
      }
    }

    // Ensure at least one crossing point exists
    if (!validateCrossingSafety(logs, worldWidth)) {
      _addEmergencyLog(logs, worldY, direction, difficulty);
    }

    // Balance difficulty by adjusting log count
    _balanceLogDifficulty(logs, crossingDifficulty, worldY, direction, difficulty);

    return logs;
  }

  bool _isSafeLogPosition(
    double x,
    double y,
    double width,
    double height,
    List<Obstacle> existingObstacles,
  ) {
    final logBounds = Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    );

    for (final obstacle in existingObstacles) {
      if (logBounds.overlaps(obstacle.bounds)) {
        return false;
      }
    }

    return true;
  }

  void _addEmergencyLog(List<Log> logs, double worldY, int direction, double difficulty) {
    // Add a guaranteed crossing log in the center
    final emergencyLog = createLog(
      LogType.medium,
      0.0, // Center position
      worldY,
      generateSpeed(LogType.medium, 1.0 + difficulty * 0.3),
      direction,
    );
    logs.add(emergencyLog);
  }

  void _balanceLogDifficulty(
    List<Log> logs,
    CrossingDifficulty difficulty,
    double worldY,
    int direction,
    double difficultyLevel,
  ) {
    final targetLogCount = _getTargetLogCount(difficulty);
    
    if (logs.length < targetLogCount) {
      // Add more logs for easier crossing
      final additionalLogs = targetLogCount - logs.length;
      for (int i = 0; i < additionalLogs; i++) {
        final logType = selectLogType(difficulty);
        final position = _random.nextDouble() * worldWidth * GameConstants.tileSize - 
                        (worldWidth * GameConstants.tileSize / 2);
        
        final log = createLog(
          logType,
          position,
          worldY,
          generateSpeed(logType, 1.0 + difficultyLevel * 0.5),
          direction,
        );
        logs.add(log);
      }
    }
  }

  int _getTargetLogCount(CrossingDifficulty difficulty) {
    switch (difficulty) {
      case CrossingDifficulty.easy:
        return 4;
      case CrossingDifficulty.medium:
        return 3;
      case CrossingDifficulty.hard:
        return 2;
      case CrossingDifficulty.expert:
        return 1;
    }
  }

  // Generate multiple log rows with varied patterns
  List<List<Log>> generateLogPattern({
    required int startY,
    required int rowCount,
    required double difficulty,
    List<Obstacle> existingObstacles = const [],
  }) {
    final pattern = <List<Log>>[];
    
    for (int i = 0; i < rowCount; i++) {
      final y = startY + i;
      final rowDifficulty = difficulty + (i * 0.05); // Gradual increase
      
      final logs = generateLogsForRow(
        y: y,
        difficulty: rowDifficulty,
        existingObstacles: existingObstacles,
      );
      
      pattern.add(logs);
    }
    
    return pattern;
  }

  // Get spawning statistics for debugging
  Map<String, dynamic> getSpawnStats(List<Log> logs) {
    final typeCount = <LogType, int>{};
    double totalSpeed = 0;
    double minSpeed = double.infinity;
    double maxSpeed = 0;
    int totalCapacity = 0;

    for (final log in logs) {
      // Determine log type by width
      LogType type = LogType.small;
      if (log.width >= 160) {
        type = LogType.cluster;
      } else if (log.width >= 128) {
        type = LogType.large;
      } else if (log.width >= 96) {
        type = LogType.medium;
      }

      typeCount[type] = (typeCount[type] ?? 0) + 1;
      totalSpeed += log.speed;
      minSpeed = math.min(minSpeed, log.speed);
      maxSpeed = math.max(maxSpeed, log.speed);
      totalCapacity += LogSpecs.getSpecs(type).carryCapacity;
    }

    return {
      'totalLogs': logs.length,
      'typeDistribution': typeCount,
      'averageSpeed': logs.isNotEmpty ? totalSpeed / logs.length : 0,
      'speedRange': {'min': minSpeed, 'max': maxSpeed},
      'totalCapacity': totalCapacity,
      'crossingSafety': validateCrossingSafety(logs, worldWidth),
    };
  }
}