import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/player.dart';
import '../entities/obstacle.dart';
import '../entities/tile.dart';
import '../entities/water_tile.dart';
import 'progress_tracker.dart';

enum ScoreAction {
  hop,              // Basic forward hop
  dangerousHop,     // Hop near moving car
  perfectTiming,    // Hop onto log at perfect moment
  logRide,          // Successfully ride log across water
  waterCrossing,    // Complete water section crossing
  nearMiss,         // Barely avoid collision with car
  streakBonus,      // Multiple hops without stopping
  speedBonus,       // Complete section quickly
  distanceBonus,    // Reach new distance milestone
}

class ScoreEvent {
  ScoreEvent({
    required this.action,
    required this.points,
    required this.timestamp,
    this.multiplier = 1.0,
    this.description = '',
    this.position,
  });

  final ScoreAction action;
  final int points;
  final DateTime timestamp;
  final double multiplier;
  final String description;
  final Offset? position;

  int get finalPoints => (points * multiplier).round();
}

class ScoreMultipliers {
  static const Map<ScoreAction, int> basePoints = {
    ScoreAction.hop: 10,
    ScoreAction.dangerousHop: 25,
    ScoreAction.perfectTiming: 50,
    ScoreAction.logRide: 20,
    ScoreAction.waterCrossing: 100,
    ScoreAction.nearMiss: 30,
    ScoreAction.streakBonus: 15,
    ScoreAction.speedBonus: 40,
    ScoreAction.distanceBonus: 200,
  };

  static const Map<int, double> distanceMultipliers = {
    0: 1.0,     // Rows 0-9
    10: 1.2,    // Rows 10-19
    25: 1.5,    // Rows 25-49
    50: 2.0,    // Rows 50-99
    100: 2.5,   // Rows 100-199
    200: 3.0,   // Rows 200+
  };

  static double getDistanceMultiplier(int distance) {
    final keys = distanceMultipliers.keys.toList()..sort();
    for (int i = keys.length - 1; i >= 0; i--) {
      if (distance >= keys[i]) {
        return distanceMultipliers[keys[i]]!;
      }
    }
    return 1.0;
  }
}

class GameStats {
  GameStats({
    this.totalDistance = 0,
    this.totalHops = 0,
    this.waterCrossings = 0,
    this.nearMisses = 0,
    this.perfectTimings = 0,
    this.longestStreak = 0,
    this.fastestTime = Duration.zero,
    this.sessionStartTime,
  });

  final int totalDistance;
  final int totalHops;
  final int waterCrossings;
  final int nearMisses;
  final int perfectTimings;
  final int longestStreak;
  final Duration fastestTime;
  final DateTime? sessionStartTime;

  GameStats copyWith({
    int? totalDistance,
    int? totalHops,
    int? waterCrossings,
    int? nearMisses,
    int? perfectTimings,
    int? longestStreak,
    Duration? fastestTime,
    DateTime? sessionStartTime,
  }) {
    return GameStats(
      totalDistance: totalDistance ?? this.totalDistance,
      totalHops: totalHops ?? this.totalHops,
      waterCrossings: waterCrossings ?? this.waterCrossings,
      nearMisses: nearMisses ?? this.nearMisses,
      perfectTimings: perfectTimings ?? this.perfectTimings,
      longestStreak: longestStreak ?? this.longestStreak,
      fastestTime: fastestTime ?? this.fastestTime,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }

  Duration get currentSessionTime {
    if (sessionStartTime == null) return Duration.zero;
    return DateTime.now().difference(sessionStartTime!);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDistance': totalDistance,
      'totalHops': totalHops,
      'waterCrossings': waterCrossings,
      'nearMisses': nearMisses,
      'perfectTimings': perfectTimings,
      'longestStreak': longestStreak,
      'fastestTime': fastestTime.inMilliseconds,
      'sessionStartTime': sessionStartTime?.millisecondsSinceEpoch,
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalDistance: json['totalDistance'] ?? 0,
      totalHops: json['totalHops'] ?? 0,
      waterCrossings: json['waterCrossings'] ?? 0,
      nearMisses: json['nearMisses'] ?? 0,
      perfectTimings: json['perfectTimings'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      fastestTime: Duration(milliseconds: json['fastestTime'] ?? 0),
      sessionStartTime: json['sessionStartTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['sessionStartTime'])
          : null,
    );
  }
}

class ScoringSystem extends ChangeNotifier {
  ScoringSystem({ProgressTracker? progressTracker}) 
    : _progressTracker = progressTracker {
    _loadHighScores();
    _resetSession();
  }

  final ProgressTracker? _progressTracker;

  // Current session data
  int _currentScore = 0;
  int _currentDistance = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  GameStats _currentStats = GameStats();
  final List<ScoreEvent> _sessionEvents = [];

  // Persistent data
  int _highScore = 0;
  int _bestDistance = 0;
  GameStats _allTimeStats = GameStats();
  final List<int> _topScores = [];

  // Tracking variables
  DateTime? _lastHopTime;
  bool _onLog = false;
  DateTime? _logRideStartTime;

  // Getters
  int get currentScore => _currentScore;
  int get currentDistance => _currentDistance;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get highScore => _highScore;
  int get bestDistance => _bestDistance;
  GameStats get currentStats => _currentStats;
  GameStats get allTimeStats => _allTimeStats;
  List<int> get topScores => List.unmodifiable(_topScores);
  List<ScoreEvent> get sessionEvents => List.unmodifiable(_sessionEvents);

  bool get isNewHighScore => _currentScore > _highScore;
  bool get isNewBestDistance => _currentDistance > _bestDistance;

  void _resetSession() {
    _currentScore = 0;
    _currentDistance = 0;
    _currentStreak = 0;
    _longestStreak = 0;
    _currentStats = GameStats(sessionStartTime: DateTime.now());
    _sessionEvents.clear();
    _lastHopTime = null;
    _onLog = false;
    _logRideStartTime = null;
    notifyListeners();
  }

  // Distance-based scoring
  void updateDistance(Player player) {
    final newDistance = math.max(0, player.gridY);
    
    if (newDistance > _currentDistance) {
      final distanceGained = newDistance - _currentDistance;
      _currentDistance = newDistance;
      
      // Track progress
      _progressTracker?.trackRowCrossed(_currentDistance);
      
      // Distance-based points
      final basePoints = distanceGained * 10;
      final multiplier = ScoreMultipliers.getDistanceMultiplier(_currentDistance);
      final points = (basePoints * multiplier).round();
      
      _addScore(points, ScoreAction.hop, 
          description: 'Distance: $distanceGained tiles');
      
      // Distance milestones
      if (_currentDistance > 0 && _currentDistance % 10 == 0) {
        _addScore(ScoreMultipliers.basePoints[ScoreAction.distanceBonus]!, 
            ScoreAction.distanceBonus,
            multiplier: multiplier,
            description: 'Milestone: $_currentDistance tiles!');
      }
      
      _currentStats = _currentStats.copyWith(
        totalDistance: math.max(_currentStats.totalDistance, _currentDistance),
      );
      
      notifyListeners();
    }
  }

  // Bonus points for special actions
  void recordHop(Player player, List<Obstacle> nearbyObstacles, Tile? currentTile) {
    _currentStats = _currentStats.copyWith(
      totalHops: _currentStats.totalHops + 1,
    );

    // Track progress
    _progressTracker?.trackHop(player, nearbyObstacles, currentTile);

    // Update streak
    final now = DateTime.now();
    if (_lastHopTime != null && now.difference(_lastHopTime!) < const Duration(seconds: 2)) {
      _currentStreak++;
      _longestStreak = math.max(_longestStreak, _currentStreak);
      
      // Track streak progress
      _progressTracker?.trackStreak(_currentStreak);
      
      // Streak bonus
      if (_currentStreak >= 5 && _currentStreak % 5 == 0) {
        _addScore(ScoreMultipliers.basePoints[ScoreAction.streakBonus]! * (_currentStreak ~/ 5), 
            ScoreAction.streakBonus,
            description: 'Streak: $_currentStreak hops!');
      }
    } else {
      _currentStreak = 1;
    }
    
    _lastHopTime = now;

    // Check for dangerous hop (near moving cars)
    final playerPos = Offset(player.x, player.y);
    for (final obstacle in nearbyObstacles) {
      if (obstacle.isDeadly && obstacle.isMoving) {
        final distance = (Offset(obstacle.x, obstacle.y) - playerPos).distance;
        if (distance < 80) { // Within 80 pixels of danger
          _addScore(ScoreMultipliers.basePoints[ScoreAction.dangerousHop]!, 
              ScoreAction.dangerousHop,
              description: 'Dangerous hop!',
              position: playerPos);
          break;
        }
      }
    }

    // Check water tile interactions
    if (currentTile is WaterTile) {
      _checkWaterInteractions(player, nearbyObstacles);
    }

    notifyListeners();
  }

  void _checkWaterInteractions(Player player, List<Obstacle> obstacles) {
    final playerPos = Offset(player.x, player.y);
    bool foundLog = false;

    for (final obstacle in obstacles) {
      if (obstacle.isRideable) {
        final obstaclePos = Offset(obstacle.x, obstacle.y);
        final distance = (obstaclePos - playerPos).distance;
        
        if (distance < 40) { // On log
          foundLog = true;
          
          if (!_onLog) {
            // Just got on log
            _onLog = true;
            _logRideStartTime = DateTime.now();
            
            // Check for perfect timing (log moving at good speed)
            if (obstacle.speed > 20 && obstacle.speed < 60) {
              _addScore(ScoreMultipliers.basePoints[ScoreAction.perfectTiming]!, 
                  ScoreAction.perfectTiming,
                  description: 'Perfect timing!',
                  position: playerPos);
              
              _currentStats = _currentStats.copyWith(
                perfectTimings: _currentStats.perfectTimings + 1,
              );
              
              // Track progress
              _progressTracker?.trackPerfectTiming();
            }
          } else {
            // Continuing to ride log
            final rideDuration = DateTime.now().difference(_logRideStartTime!);
            if (rideDuration.inSeconds >= 2) {
              _addScore(ScoreMultipliers.basePoints[ScoreAction.logRide]!, 
                  ScoreAction.logRide,
                  description: 'Log surfing!');
            }
          }
          break;
        }
      }
    }

    if (!foundLog && _onLog) {
      // Just completed water crossing
      _onLog = false;
      _addScore(ScoreMultipliers.basePoints[ScoreAction.waterCrossing]!, 
          ScoreAction.waterCrossing,
          description: 'Water crossed!',
          position: playerPos);
      
      _currentStats = _currentStats.copyWith(
        waterCrossings: _currentStats.waterCrossings + 1,
      );
      
      // Track progress
      _progressTracker?.trackWaterCrossing();
    }
  }

  void recordNearMiss(Player player, Obstacle obstacle) {
    _addScore(ScoreMultipliers.basePoints[ScoreAction.nearMiss]!, 
        ScoreAction.nearMiss,
        description: 'Close call!',
        position: Offset(player.x, player.y));
    
    _currentStats = _currentStats.copyWith(
      nearMisses: _currentStats.nearMisses + 1,
    );
    
    // Track progress
    _progressTracker?.trackNearMiss();
    
    notifyListeners();
  }

  void recordSpeedBonus(Duration timeToComplete, int distance) {
    final targetTime = Duration(seconds: distance * 2); // 2 seconds per tile target
    if (timeToComplete < targetTime) {
      final bonus = math.max(1, (targetTime.inSeconds - timeToComplete.inSeconds) ~/ 2);
      _addScore(ScoreMultipliers.basePoints[ScoreAction.speedBonus]! * bonus, 
          ScoreAction.speedBonus,
          description: 'Speed bonus!');
      notifyListeners();
    }
  }

  void _addScore(int points, ScoreAction action, {
    double multiplier = 1.0,
    String description = '',
    Offset? position,
  }) {
    final distanceMultiplier = ScoreMultipliers.getDistanceMultiplier(_currentDistance);
    final finalMultiplier = multiplier * distanceMultiplier;
    
    final event = ScoreEvent(
      action: action,
      points: points,
      timestamp: DateTime.now(),
      multiplier: finalMultiplier,
      description: description,
      position: position,
    );
    
    _sessionEvents.add(event);
    _currentScore += event.finalPoints;
    
    // Keep only recent events for performance
    if (_sessionEvents.length > 100) {
      _sessionEvents.removeAt(0);
    }
  }

  Future<void> endSession() async {
    final sessionTime = _currentStats.currentSessionTime;
    
    // Update all-time stats
    _allTimeStats = _allTimeStats.copyWith(
      totalDistance: _allTimeStats.totalDistance + _currentStats.totalDistance,
      totalHops: _allTimeStats.totalHops + _currentStats.totalHops,
      waterCrossings: _allTimeStats.waterCrossings + _currentStats.waterCrossings,
      nearMisses: _allTimeStats.nearMisses + _currentStats.nearMisses,
      perfectTimings: _allTimeStats.perfectTimings + _currentStats.perfectTimings,
      longestStreak: math.max(_allTimeStats.longestStreak, _longestStreak),
      fastestTime: _allTimeStats.fastestTime == Duration.zero || 
          (sessionTime < _allTimeStats.fastestTime && _currentDistance > 10)
          ? sessionTime : _allTimeStats.fastestTime,
    );

    // Update high scores
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
    }
    
    if (_currentDistance > _bestDistance) {
      _bestDistance = _currentDistance;
    }

    // Update top scores list
    _topScores.add(_currentScore);
    _topScores.sort((a, b) => b.compareTo(a)); // Sort descending
    if (_topScores.length > 10) {
      _topScores.removeRange(10, _topScores.length); // Keep top 10
    }

    // Track progress for scores
    _progressTracker?.trackScore(_currentScore, 
        _sessionEvents.fold(0, (sum, event) => sum + event.finalPoints));
    
    // End progress tracking session
    _progressTracker?.endCurrentSession(endReason: 'Game completed');
    
    await _saveHighScores();
    notifyListeners();
  }

  void startNewSession() {
    _resetSession();
    _progressTracker?.startNewSession();
  }

  // High score persistence
  Future<void> _loadHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _highScore = prefs.getInt('high_score') ?? 0;
      _bestDistance = prefs.getInt('best_distance') ?? 0;
      
      final topScoresJson = prefs.getStringList('top_scores') ?? [];
      _topScores.clear();
      _topScores.addAll(topScoresJson.map((score) => int.parse(score)));
      
      final allTimeStatsJson = prefs.getString('all_time_stats');
      if (allTimeStatsJson != null) {
        final Map<String, dynamic> statsMap = {};
        // Simple JSON parsing for stats
        allTimeStatsJson.split(',').forEach((pair) {
          final keyValue = pair.split(':');
          if (keyValue.length == 2) {
            statsMap[keyValue[0].trim()] = int.tryParse(keyValue[1].trim()) ?? 0;
          }
        });
        _allTimeStats = GameStats.fromJson(statsMap);
      }
    } catch (e) {
      debugPrint('Error loading high scores: $e');
    }
  }

  Future<void> _saveHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('high_score', _highScore);
      await prefs.setInt('best_distance', _bestDistance);
      await prefs.setStringList('top_scores', 
          _topScores.map((score) => score.toString()).toList());
      
      // Simple JSON serialization for stats
      final statsJson = _allTimeStats.toJson().entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      await prefs.setString('all_time_stats', statsJson);
      
    } catch (e) {
      debugPrint('Error saving high scores: $e');
    }
  }

  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('high_score');
    await prefs.remove('best_distance');
    await prefs.remove('top_scores');
    await prefs.remove('all_time_stats');
    
    _highScore = 0;
    _bestDistance = 0;
    _topScores.clear();
    _allTimeStats = GameStats();
    _resetSession();
  }

  // Debug and analytics
  Map<String, dynamic> getSessionSummary() {
    return {
      'currentScore': _currentScore,
      'currentDistance': _currentDistance,
      'longestStreak': _longestStreak,
      'sessionTime': _currentStats.currentSessionTime.inSeconds,
      'eventsCount': _sessionEvents.length,
      'stats': _currentStats.toJson(),
    };
  }

  Map<ScoreAction, int> getActionBreakdown() {
    final breakdown = <ScoreAction, int>{};
    for (final event in _sessionEvents) {
      breakdown[event.action] = (breakdown[event.action] ?? 0) + event.finalPoints;
    }
    return breakdown;
  }
}