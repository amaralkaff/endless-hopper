import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../systems/scoring_system.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.scoringSystem,
    this.showHighScore = true,
    this.compact = false,
  });

  final ScoringSystem scoringSystem;
  final bool showHighScore;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scoringSystem,
      builder: (context, child) {
        return Container(
          padding: compact ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: compact ? _buildCompactDisplay() : _buildFullDisplay(),
        );
      },
    );
  }

  Widget _buildCompactDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: AppColors.accentYellow,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${scoringSystem.currentScore}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildFullDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current Score
        Row(
          children: [
            Icon(
              Icons.star,
              color: AppColors.accentYellow,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Score: ${scoringSystem.currentScore}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            if (scoringSystem.isNewHighScore) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.emoji_events,
                color: AppColors.accentYellow,
                size: 20,
              ),
              const Text(
                'NEW!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentYellow,
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Distance Progress
        Row(
          children: [
            Icon(
              Icons.straighten,
              color: AppColors.accentPink,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Distance: ${scoringSystem.currentDistance}m',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
            if (scoringSystem.isNewBestDistance) ...[
              const SizedBox(width: 8),
              const Text(
                'BEST!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPink,
                ),
              ),
            ],
          ],
        ),
        
        // Streak Display
        if (scoringSystem.currentStreak > 1) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.whatshot,
                color: AppColors.accentPink,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Streak: ${scoringSystem.currentStreak}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.accentPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        
        // High Score Display
        if (showHighScore && scoringSystem.highScore > 0) ...[
          const SizedBox(height: 8),
          const Divider(color: AppColors.primaryPurple, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppColors.accentYellow,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Best: ${scoringSystem.highScore}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ScorePopup extends StatefulWidget {
  const ScorePopup({
    super.key,
    required this.scoreEvent,
    required this.position,
    this.duration = const Duration(seconds: 2),
  });

  final ScoreEvent scoreEvent;
  final Offset position;
  final Duration duration;

  @override
  State<ScorePopup> createState() => _ScorePopupState();
}

class _ScorePopupState extends State<ScorePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -50),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 50,
      top: widget.position.dy - 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _slideAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getScoreColor().withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getScoreIcon(),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${widget.scoreEvent.finalPoints}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor() {
    switch (widget.scoreEvent.action) {
      case ScoreAction.dangerousHop:
      case ScoreAction.nearMiss:
        return AppColors.error;
      case ScoreAction.perfectTiming:
      case ScoreAction.waterCrossing:
        return AppColors.accentYellow;
      case ScoreAction.streakBonus:
        return AppColors.accentPink;
      case ScoreAction.distanceBonus:
        return AppColors.accentPink;
      default:
        return AppColors.primaryPurple;
    }
  }

  IconData _getScoreIcon() {
    switch (widget.scoreEvent.action) {
      case ScoreAction.dangerousHop:
        return Icons.warning;
      case ScoreAction.nearMiss:
        return Icons.close;
      case ScoreAction.perfectTiming:
        return Icons.timer;
      case ScoreAction.waterCrossing:
        return Icons.waves;
      case ScoreAction.streakBonus:
        return Icons.whatshot;
      case ScoreAction.distanceBonus:
        return Icons.emoji_events;
      case ScoreAction.logRide:
        return Icons.surfing;
      case ScoreAction.speedBonus:
        return Icons.speed;
      default:
        return Icons.add;
    }
  }
}

class StatisticsDisplay extends StatelessWidget {
  const StatisticsDisplay({
    super.key,
    required this.scoringSystem,
    this.showAllTime = false,
  });

  final ScoringSystem scoringSystem;
  final bool showAllTime;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scoringSystem,
      builder: (context, child) {
        final stats = showAllTime 
          ? scoringSystem.allTimeStats 
          : scoringSystem.currentStats;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showAllTime ? 'All-Time Stats' : 'Session Stats',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildStatRow(
                'Total Hops',
                '${stats.totalHops}',
                Icons.skip_next,
                AppColors.primaryPurple,
              ),
              
              _buildStatRow(
                'Water Crossings',
                '${stats.waterCrossings}',
                Icons.waves,
                AppColors.waterBlue,
              ),
              
              _buildStatRow(
                'Near Misses',
                '${stats.nearMisses}',
                Icons.close,
                AppColors.error,
              ),
              
              _buildStatRow(
                'Perfect Timings',
                '${stats.perfectTimings}',
                Icons.timer,
                AppColors.accentYellow,
              ),
              
              _buildStatRow(
                'Longest Streak',
                '${showAllTime ? stats.longestStreak : scoringSystem.longestStreak}',
                Icons.whatshot,
                AppColors.accentPink,
              ),
              
              if (stats.sessionStartTime != null) ...[
                _buildStatRow(
                  'Session Time',
                  _formatDuration(stats.currentSessionTime),
                  Icons.timer_outlined,
                  AppColors.textSecondary,
                ),
              ],
              
              if (showAllTime && stats.fastestTime != Duration.zero) ...[
                _buildStatRow(
                  'Fastest Time',
                  _formatDuration(stats.fastestTime),
                  Icons.speed,
                  AppColors.accentPink,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class LeaderboardDisplay extends StatelessWidget {
  const LeaderboardDisplay({
    super.key,
    required this.scoringSystem,
    this.maxEntries = 5,
  });

  final ScoringSystem scoringSystem;
  final int maxEntries;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scoringSystem,
      builder: (context, child) {
        final topScores = scoringSystem.topScores.take(maxEntries).toList();
        
        if (topScores.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                'No scores yet!\nPlay a game to set your first record.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.leaderboard,
                    color: AppColors.accentYellow,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Top Scores',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              ...topScores.asMap().entries.map((entry) {
                final index = entry.key;
                final score = entry.value;
                final isCurrentScore = score == scoringSystem.currentScore && scoringSystem.currentScore > 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrentScore 
                        ? AppColors.primaryPurple.withValues(alpha: 0.2)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrentScore 
                        ? Border.all(color: AppColors.primaryPurple, width: 1)
                        : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getRankColor(index),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${score} points',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isCurrentScore ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentScore ? AppColors.textLight : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (isCurrentScore) ...[
                          const Icon(
                            Icons.arrow_left,
                            color: AppColors.primaryPurple,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return AppColors.accentYellow; // Gold
      case 1:
        return AppColors.textSecondary; // Silver
      case 2:
        return AppColors.warning; // Bronze
      default:
        return AppColors.primaryPurple;
    }
  }
}