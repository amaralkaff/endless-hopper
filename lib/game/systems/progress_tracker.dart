import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/player.dart';
import '../entities/obstacle.dart';
import '../entities/tile.dart';

enum ProgressMilestone {
  firstHop,
  reach10Rows,
  reach25Rows,
  reach50Rows,
  reach100Rows,
  reach250Rows,
  reach500Rows,
  firstWaterCrossing,
  surviveMinute,
  survive5Minutes,
  score100,
  score500,
  score1000,
  score5000,
  perfectStreak10,
  perfectStreak25,
  nearMiss50,
  waterCrossing10,
  sessionPlay10,
  sessionPlay50,
  totalHops1000,
  totalHops10000,
}

enum StatisticType {
  rowsCrossed,
  totalHops,
  waterCrossings,
  nearMisses,
  perfectTimings,
  gamesPlayed,
  timePlayedSeconds,
  highestScore,
  longestDistance,
  longestStreak,
  fastestCompletion,
  obstaclesAvoided,
  bonusPointsEarned,
  milestonesReached,
}

class ProgressMilestoneData {
  const ProgressMilestoneData({
    required this.milestone,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.trackingType,
    required this.icon,
    required this.rewardPoints,
    this.isSecret = false,
  });

  final ProgressMilestone milestone;
  final String title;
  final String description;
  final int targetValue;
  final StatisticType trackingType;
  final String icon;
  final int rewardPoints;
  final bool isSecret;
}

class AchievementProgress {
  const AchievementProgress({
    required this.milestone,
    required this.currentValue,
    required this.targetValue,
    required this.isCompleted,
    this.completedAt,
  });

  final ProgressMilestone milestone;
  final int currentValue;
  final int targetValue;
  final bool isCompleted;
  final DateTime? completedAt;

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  AchievementProgress copyWith({
    int? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return AchievementProgress(
      milestone: milestone,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestone': milestone.index,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      milestone: ProgressMilestone.values[json['milestone']],
      currentValue: json['currentValue'] ?? 0,
      targetValue: json['targetValue'] ?? 1,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
    );
  }
}

class SessionAnalytics {
  SessionAnalytics({
    DateTime? sessionStart,
    this.sessionEnd,
    this.rowsCrossed = 0,
    this.hopsPerformed = 0,
    this.waterCrossings = 0,
    this.nearMisses = 0,
    this.perfectTimings = 0,
    this.bonusPoints = 0,
    this.finalScore = 0,
    this.longestStreak = 0,
    this.obstaclesEncountered = 0,
    this.milestonesReached = 0,
    this.gameEndReason = '',
  }) : sessionStart = sessionStart ?? DateTime.now();

  final DateTime sessionStart;
  DateTime? sessionEnd;
  int rowsCrossed;
  int hopsPerformed;
  int waterCrossings;
  int nearMisses;
  int perfectTimings;
  int bonusPoints;
  int finalScore;
  int longestStreak;
  int obstaclesEncountered;
  int milestonesReached;
  String gameEndReason;

  Duration get sessionDuration {
    final end = sessionEnd ?? DateTime.now();
    return end.difference(sessionStart);
  }

  double get hopsPerMinute {
    final minutes = sessionDuration.inMinutes;
    return minutes > 0 ? hopsPerformed / minutes : 0;
  }

  double get survivalRate {
    return obstaclesEncountered > 0 
        ? (obstaclesEncountered - nearMisses) / obstaclesEncountered 
        : 1.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionStart': sessionStart.millisecondsSinceEpoch,
      'sessionEnd': sessionEnd?.millisecondsSinceEpoch,
      'rowsCrossed': rowsCrossed,
      'hopsPerformed': hopsPerformed,
      'waterCrossings': waterCrossings,
      'nearMisses': nearMisses,
      'perfectTimings': perfectTimings,
      'bonusPoints': bonusPoints,
      'finalScore': finalScore,
      'longestStreak': longestStreak,
      'obstaclesEncountered': obstaclesEncountered,
      'milestonesReached': milestonesReached,
      'gameEndReason': gameEndReason,
    };
  }

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      sessionStart: DateTime.fromMillisecondsSinceEpoch(json['sessionStart']),
      sessionEnd: json['sessionEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sessionEnd'])
          : null,
      rowsCrossed: json['rowsCrossed'] ?? 0,
      hopsPerformed: json['hopsPerformed'] ?? 0,
      waterCrossings: json['waterCrossings'] ?? 0,
      nearMisses: json['nearMisses'] ?? 0,
      perfectTimings: json['perfectTimings'] ?? 0,
      bonusPoints: json['bonusPoints'] ?? 0,
      finalScore: json['finalScore'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      obstaclesEncountered: json['obstaclesEncountered'] ?? 0,
      milestonesReached: json['milestonesReached'] ?? 0,
      gameEndReason: json['gameEndReason'] ?? '',
    );
  }
}

class ProgressTracker extends ChangeNotifier {
  ProgressTracker() {
    _initializeMilestones();
    _loadProgress();
  }

  // Current session tracking
  SessionAnalytics? _currentSession;
  final List<SessionAnalytics> _sessionHistory = [];

  // Achievement tracking
  final Map<ProgressMilestone, AchievementProgress> _achievements = {};
  final List<ProgressMilestone> _recentlyCompleted = [];

  // Statistics tracking
  final Map<StatisticType, int> _statistics = {};

  // Milestone definitions
  static const Map<ProgressMilestone, ProgressMilestoneData> _milestoneData = {
    ProgressMilestone.firstHop: ProgressMilestoneData(
      milestone: ProgressMilestone.firstHop,
      title: 'First Steps',
      description: 'Take your first hop forward',
      targetValue: 1,
      trackingType: StatisticType.totalHops,
      icon: '👣',
      rewardPoints: 10,
    ),
    ProgressMilestone.reach10Rows: ProgressMilestoneData(
      milestone: ProgressMilestone.reach10Rows,
      title: 'Getting Started',
      description: 'Cross 10 rows in a single game',
      targetValue: 10,
      trackingType: StatisticType.rowsCrossed,
      icon: '🎯',
      rewardPoints: 50,
    ),
    ProgressMilestone.reach25Rows: ProgressMilestoneData(
      milestone: ProgressMilestone.reach25Rows,
      title: 'On a Roll',
      description: 'Cross 25 rows in a single game',
      targetValue: 25,
      trackingType: StatisticType.rowsCrossed,
      icon: '🚀',
      rewardPoints: 100,
    ),
    ProgressMilestone.reach50Rows: ProgressMilestoneData(
      milestone: ProgressMilestone.reach50Rows,
      title: 'Halfway Hero',
      description: 'Cross 50 rows in a single game',
      targetValue: 50,
      trackingType: StatisticType.rowsCrossed,
      icon: '⭐',
      rewardPoints: 250,
    ),
    ProgressMilestone.reach100Rows: ProgressMilestoneData(
      milestone: ProgressMilestone.reach100Rows,
      title: 'Century Club',
      description: 'Cross 100 rows in a single game',
      targetValue: 100,
      trackingType: StatisticType.rowsCrossed,
      icon: '💯',
      rewardPoints: 500,
    ),
    ProgressMilestone.reach250Rows: ProgressMilestoneData(
      milestone: ProgressMilestone.reach250Rows,
      title: 'Distance Master',
      description: 'Cross 250 rows in a single game',
      targetValue: 250,
      trackingType: StatisticType.rowsCrossed,
      icon: '🏆',
      rewardPoints: 1000,
    ),
    ProgressMilestone.reach500Rows: ProgressMilestoneData(
      milestone: ProgressMilestone.reach500Rows,
      title: 'Legendary Hopper',
      description: 'Cross 500 rows in a single game',
      targetValue: 500,
      trackingType: StatisticType.rowsCrossed,
      icon: '👑',
      rewardPoints: 2500,
      isSecret: true,
    ),
    ProgressMilestone.firstWaterCrossing: ProgressMilestoneData(
      milestone: ProgressMilestone.firstWaterCrossing,
      title: 'Water Walker',
      description: 'Successfully cross water for the first time',
      targetValue: 1,
      trackingType: StatisticType.waterCrossings,
      icon: '🌊',
      rewardPoints: 25,
    ),
    ProgressMilestone.surviveMinute: ProgressMilestoneData(
      milestone: ProgressMilestone.surviveMinute,
      title: 'Survivor',
      description: 'Survive for 1 minute in a single game',
      targetValue: 60,
      trackingType: StatisticType.timePlayedSeconds,
      icon: '⏱️',
      rewardPoints: 75,
    ),
    ProgressMilestone.survive5Minutes: ProgressMilestoneData(
      milestone: ProgressMilestone.survive5Minutes,
      title: 'Endurance Expert',
      description: 'Survive for 5 minutes in a single game',
      targetValue: 300,
      trackingType: StatisticType.timePlayedSeconds,
      icon: '🔥',
      rewardPoints: 500,
    ),
    ProgressMilestone.score100: ProgressMilestoneData(
      milestone: ProgressMilestone.score100,
      title: 'Point Collector',
      description: 'Score 100 points in a single game',
      targetValue: 100,
      trackingType: StatisticType.highestScore,
      icon: '📈',
      rewardPoints: 25,
    ),
    ProgressMilestone.score500: ProgressMilestoneData(
      milestone: ProgressMilestone.score500,
      title: 'Score Chaser',
      description: 'Score 500 points in a single game',
      targetValue: 500,
      trackingType: StatisticType.highestScore,
      icon: '💎',
      rewardPoints: 100,
    ),
    ProgressMilestone.score1000: ProgressMilestoneData(
      milestone: ProgressMilestone.score1000,
      title: 'High Roller',
      description: 'Score 1000 points in a single game',
      targetValue: 1000,
      trackingType: StatisticType.highestScore,
      icon: '💰',
      rewardPoints: 250,
    ),
    ProgressMilestone.score5000: ProgressMilestoneData(
      milestone: ProgressMilestone.score5000,
      title: 'Score Legend',
      description: 'Score 5000 points in a single game',
      targetValue: 5000,
      trackingType: StatisticType.highestScore,
      icon: '🎖️',
      rewardPoints: 1000,
      isSecret: true,
    ),
    ProgressMilestone.perfectStreak10: ProgressMilestoneData(
      milestone: ProgressMilestone.perfectStreak10,
      title: 'Streak Starter',
      description: 'Achieve a 10-hop streak',
      targetValue: 10,
      trackingType: StatisticType.longestStreak,
      icon: '🔥',
      rewardPoints: 100,
    ),
    ProgressMilestone.perfectStreak25: ProgressMilestoneData(
      milestone: ProgressMilestone.perfectStreak25,
      title: 'Streak Master',
      description: 'Achieve a 25-hop streak',
      targetValue: 25,
      trackingType: StatisticType.longestStreak,
      icon: '⚡',
      rewardPoints: 300,
    ),
    ProgressMilestone.nearMiss50: ProgressMilestoneData(
      milestone: ProgressMilestone.nearMiss50,
      title: 'Close Call Champion',
      description: 'Survive 50 near misses',
      targetValue: 50,
      trackingType: StatisticType.nearMisses,
      icon: '😅',
      rewardPoints: 200,
    ),
    ProgressMilestone.waterCrossing10: ProgressMilestoneData(
      milestone: ProgressMilestone.waterCrossing10,
      title: 'Aquatic Athlete',
      description: 'Complete 10 water crossings',
      targetValue: 10,
      trackingType: StatisticType.waterCrossings,
      icon: '🏊',
      rewardPoints: 150,
    ),
    ProgressMilestone.sessionPlay10: ProgressMilestoneData(
      milestone: ProgressMilestone.sessionPlay10,
      title: 'Regular Player',
      description: 'Play 10 game sessions',
      targetValue: 10,
      trackingType: StatisticType.gamesPlayed,
      icon: '🎮',
      rewardPoints: 100,
    ),
    ProgressMilestone.sessionPlay50: ProgressMilestoneData(
      milestone: ProgressMilestone.sessionPlay50,
      title: 'Dedicated Hopper',
      description: 'Play 50 game sessions',
      targetValue: 50,
      trackingType: StatisticType.gamesPlayed,
      icon: '🎯',
      rewardPoints: 500,
    ),
    ProgressMilestone.totalHops1000: ProgressMilestoneData(
      milestone: ProgressMilestone.totalHops1000,
      title: 'Hop Counter',
      description: 'Perform 1000 total hops',
      targetValue: 1000,
      trackingType: StatisticType.totalHops,
      icon: '🦘',
      rewardPoints: 200,
    ),
    ProgressMilestone.totalHops10000: ProgressMilestoneData(
      milestone: ProgressMilestone.totalHops10000,
      title: 'Hopping Legend',
      description: 'Perform 10,000 total hops',
      targetValue: 10000,
      trackingType: StatisticType.totalHops,
      icon: '🏅',
      rewardPoints: 1500,
      isSecret: true,
    ),
  };

  // Getters
  SessionAnalytics? get currentSession => _currentSession;
  List<SessionAnalytics> get sessionHistory => List.unmodifiable(_sessionHistory);
  Map<ProgressMilestone, AchievementProgress> get achievements => Map.unmodifiable(_achievements);
  List<ProgressMilestone> get recentlyCompleted => List.unmodifiable(_recentlyCompleted);
  Map<StatisticType, int> get statistics => Map.unmodifiable(_statistics);

  static ProgressMilestoneData? getMilestoneData(ProgressMilestone milestone) {
    return _milestoneData[milestone];
  }

  static List<ProgressMilestoneData> get allMilestones => _milestoneData.values.toList();

  // Session management
  void startNewSession() {
    _currentSession = SessionAnalytics();
    _incrementStatistic(StatisticType.gamesPlayed, 1);
    notifyListeners();
  }

  void endCurrentSession({String endReason = 'Game Over'}) {
    if (_currentSession == null) return;

    _currentSession!.sessionEnd = DateTime.now();
    _currentSession!.gameEndReason = endReason;

    // Update lifetime statistics
    _incrementStatistic(StatisticType.timePlayedSeconds, 
        _currentSession!.sessionDuration.inSeconds);

    // Store session in history
    _sessionHistory.add(_currentSession!);
    if (_sessionHistory.length > 100) {
      _sessionHistory.removeAt(0); // Keep only last 100 sessions
    }

    // Check for session-based achievements
    _checkSessionAchievements();

    _currentSession = null;
    _saveProgress();
    notifyListeners();
  }

  // Progress tracking methods
  void trackRowCrossed(int newRow) {
    if (_currentSession == null) return;

    _currentSession!.rowsCrossed = newRow;

    // Update statistics if this is a new personal best
    if (newRow > _getStatistic(StatisticType.longestDistance)) {
      _setStatistic(StatisticType.longestDistance, newRow);
    }

    // Check row-based achievements
    _checkProgressForType(StatisticType.rowsCrossed, newRow);
    notifyListeners();
  }

  void trackHop(Player player, List<Obstacle> nearbyObstacles, Tile? currentTile) {
    if (_currentSession == null) return;

    _currentSession!.hopsPerformed++;
    _incrementStatistic(StatisticType.totalHops, 1);

    // Track obstacles encountered
    _currentSession!.obstaclesEncountered += nearbyObstacles.length;

    // Check hop-based achievements
    _checkProgressForType(StatisticType.totalHops, _getStatistic(StatisticType.totalHops));
    notifyListeners();
  }

  void trackWaterCrossing() {
    if (_currentSession == null) return;

    _currentSession!.waterCrossings++;
    _incrementStatistic(StatisticType.waterCrossings, 1);

    _checkProgressForType(StatisticType.waterCrossings, _getStatistic(StatisticType.waterCrossings));
    notifyListeners();
  }

  void trackNearMiss() {
    if (_currentSession == null) return;

    _currentSession!.nearMisses++;
    _incrementStatistic(StatisticType.nearMisses, 1);

    _checkProgressForType(StatisticType.nearMisses, _getStatistic(StatisticType.nearMisses));
    notifyListeners();
  }

  void trackPerfectTiming() {
    if (_currentSession == null) return;

    _currentSession!.perfectTimings++;
    _incrementStatistic(StatisticType.perfectTimings, 1);
    notifyListeners();
  }

  void trackStreak(int streakLength) {
    if (_currentSession == null) return;

    _currentSession!.longestStreak = streakLength;
    
    if (streakLength > _getStatistic(StatisticType.longestStreak)) {
      _setStatistic(StatisticType.longestStreak, streakLength);
      _checkProgressForType(StatisticType.longestStreak, streakLength);
    }
    notifyListeners();
  }

  void trackScore(int score, int bonusPoints) {
    if (_currentSession == null) return;

    _currentSession!.finalScore = score;
    _currentSession!.bonusPoints += bonusPoints;

    if (score > _getStatistic(StatisticType.highestScore)) {
      _setStatistic(StatisticType.highestScore, score);
      _checkProgressForType(StatisticType.highestScore, score);
    }
    notifyListeners();
  }

  void trackMilestoneReached() {
    if (_currentSession == null) return;
    
    _currentSession!.milestonesReached++;
    _incrementStatistic(StatisticType.milestonesReached, 1);
    notifyListeners();
  }

  // Achievement system
  void _initializeMilestones() {
    for (final milestone in ProgressMilestone.values) {
      final data = _milestoneData[milestone]!;
      _achievements[milestone] = AchievementProgress(
        milestone: milestone,
        currentValue: 0,
        targetValue: data.targetValue,
        isCompleted: false,
      );
    }
  }

  void _checkProgressForType(StatisticType type, int currentValue) {
    for (final achievement in _achievements.values) {
      final data = _milestoneData[achievement.milestone]!;
      
      if (data.trackingType == type && !achievement.isCompleted) {
        if (currentValue >= data.targetValue) {
          _completeAchievement(achievement.milestone);
        } else {
          // Update progress without completing
          _achievements[achievement.milestone] = achievement.copyWith(
            currentValue: currentValue,
          );
        }
      }
    }
  }

  void _checkSessionAchievements() {
    if (_currentSession == null) return;

    final sessionDuration = _currentSession!.sessionDuration.inSeconds;
    
    // Check time-based achievements
    _checkProgressForType(StatisticType.timePlayedSeconds, sessionDuration);
    _checkProgressForType(StatisticType.gamesPlayed, _getStatistic(StatisticType.gamesPlayed));
  }

  void _completeAchievement(ProgressMilestone milestone) {
    final achievement = _achievements[milestone]!;
    if (achievement.isCompleted) return;

    _achievements[milestone] = achievement.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    _recentlyCompleted.add(milestone);
    if (_recentlyCompleted.length > 10) {
      _recentlyCompleted.removeAt(0); // Keep only recent completions
    }

    trackMilestoneReached();
    debugPrint('Achievement completed: ${_milestoneData[milestone]!.title}');
  }

  // Statistics helpers
  int _getStatistic(StatisticType type) {
    return _statistics[type] ?? 0;
  }

  void _setStatistic(StatisticType type, int value) {
    _statistics[type] = value;
  }

  void _incrementStatistic(StatisticType type, int increment) {
    _statistics[type] = (_statistics[type] ?? 0) + increment;
  }

  // Analytics methods
  double getAverageSessionDuration() {
    if (_sessionHistory.isEmpty) return 0.0;
    
    final totalSeconds = _sessionHistory
        .map((s) => s.sessionDuration.inSeconds)
        .fold(0, (sum, duration) => sum + duration);
    
    return totalSeconds / _sessionHistory.length;
  }

  double getAverageScore() {
    if (_sessionHistory.isEmpty) return 0.0;
    
    final totalScore = _sessionHistory
        .map((s) => s.finalScore)
        .fold(0, (sum, score) => sum + score);
    
    return totalScore / _sessionHistory.length;
  }

  double getProgressPercentage() {
    final completedCount = _achievements.values
        .where((achievement) => achievement.isCompleted)
        .length;
    
    return completedCount / _achievements.length;
  }

  List<AchievementProgress> getRecentAchievements({int limit = 5}) {
    return _recentlyCompleted
        .take(limit)
        .map((milestone) => _achievements[milestone]!)
        .toList();
  }

  List<AchievementProgress> getIncompleteAchievements() {
    return _achievements.values
        .where((achievement) => !achievement.isCompleted)
        .toList()
        ..sort((a, b) => b.progress.compareTo(a.progress));
  }

  SessionAnalytics? getBestSession() {
    if (_sessionHistory.isEmpty) return null;
    
    return _sessionHistory.reduce((best, current) => 
        current.finalScore > best.finalScore ? current : best);
  }

  // Persistence
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load statistics
      for (final type in StatisticType.values) {
        final value = prefs.getInt('stat_${type.index}') ?? 0;
        _statistics[type] = value;
      }
      
      // Load achievements
      final achievementsJson = prefs.getString('achievements');
      if (achievementsJson != null) {
        final Map<String, dynamic> data = jsonDecode(achievementsJson);
        for (final entry in data.entries) {
          final milestone = ProgressMilestone.values[int.parse(entry.key)];
          _achievements[milestone] = AchievementProgress.fromJson(entry.value);
        }
      }
      
      // Load session history
      final historyJson = prefs.getString('session_history');
      if (historyJson != null) {
        final List<dynamic> data = jsonDecode(historyJson);
        _sessionHistory.clear();
        _sessionHistory.addAll(
          data.map((json) => SessionAnalytics.fromJson(json)).toList(),
        );
      }
      
      // Load recently completed
      final recentJson = prefs.getString('recent_completed');
      if (recentJson != null) {
        final List<dynamic> data = jsonDecode(recentJson);
        _recentlyCompleted.clear();
        _recentlyCompleted.addAll(
          data.map((index) => ProgressMilestone.values[index]).toList(),
        );
      }
      
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save statistics
      for (final entry in _statistics.entries) {
        await prefs.setInt('stat_${entry.key.index}', entry.value);
      }
      
      // Save achievements
      final achievementsData = <String, dynamic>{};
      for (final entry in _achievements.entries) {
        achievementsData[entry.key.index.toString()] = entry.value.toJson();
      }
      await prefs.setString('achievements', jsonEncode(achievementsData));
      
      // Save session history (last 50 sessions)
      final limitedHistory = _sessionHistory.length > 50 
          ? _sessionHistory.sublist(_sessionHistory.length - 50)
          : _sessionHistory;
      final historyData = limitedHistory.map((s) => s.toJson()).toList();
      await prefs.setString('session_history', jsonEncode(historyData));
      
      // Save recently completed
      final recentData = _recentlyCompleted.map((m) => m.index).toList();
      await prefs.setString('recent_completed', jsonEncode(recentData));
      
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('achievements');
    await prefs.remove('session_history');
    await prefs.remove('recent_completed');
    
    for (final type in StatisticType.values) {
      await prefs.remove('stat_${type.index}');
    }
    
    _statistics.clear();
    _sessionHistory.clear();
    _recentlyCompleted.clear();
    _initializeMilestones();
    
    notifyListeners();
  }

  @override
  void dispose() {
    _saveProgress();
    super.dispose();
  }
}