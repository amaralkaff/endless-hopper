import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../systems/progress_tracker.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.achievement,
    this.showProgress = true,
    this.compact = false,
  });

  final AchievementProgress achievement;
  final bool showProgress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final data = ProgressTracker.getMilestoneData(achievement.milestone)!;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: compact ? 4 : 8,
        horizontal: compact ? 8 : 16,
      ),
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: achievement.isCompleted 
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isCompleted 
            ? AppColors.success 
            : AppColors.primaryPurple.withValues(alpha: 0.3),
          width: achievement.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: compact ? 40 : 50,
            height: compact ? 40 : 50,
            decoration: BoxDecoration(
              color: achievement.isCompleted 
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.primaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                data.icon,
                style: TextStyle(fontSize: compact ? 20 : 24),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          fontSize: compact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: achievement.isCompleted 
                            ? AppColors.success 
                            : AppColors.textLight,
                        ),
                      ),
                    ),
                    if (achievement.isCompleted) ...[
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: compact ? 16 : 20,
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                if (showProgress && !achievement.isCompleted) ...[
                  const SizedBox(height: 8),
                  _buildProgressBar(),
                ],
                
                if (achievement.isCompleted && achievement.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Completed ${_formatDate(achievement.completedAt!)}',
                    style: TextStyle(
                      fontSize: compact ? 10 : 12,
                      color: AppColors.success,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Reward points
          if (!compact) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${data.rewardPoints}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentYellow,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${achievement.currentValue}/${achievement.targetValue}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(achievement.progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.accentPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: achievement.progress,
            backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPink),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({
    super.key,
    required this.progressTracker,
    this.showRecentAchievements = true,
  });

  final ProgressTracker progressTracker;
  final bool showRecentAchievements;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressTracker,
      builder: (context, child) {
        final completedCount = progressTracker.achievements.values
            .where((a) => a.isCompleted)
            .length;
        final totalCount = progressTracker.achievements.length;
        final progressPercentage = progressTracker.getProgressPercentage();
        
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
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppColors.accentYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Progress Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completedCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentPink,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Overall progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentYellow),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Statistics summary
              _buildStatsSummary(progressTracker),
              
              if (showRecentAchievements) ...[
                const SizedBox(height: 16),
                _buildRecentAchievements(progressTracker),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary(ProgressTracker tracker) {
    final stats = tracker.statistics;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Games Played',
                '${stats[StatisticType.gamesPlayed] ?? 0}',
                Icons.games,
                AppColors.primaryPurple,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Total Hops',
                '${stats[StatisticType.totalHops] ?? 0}',
                Icons.skip_next,
                AppColors.accentPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Best Score',
                '${stats[StatisticType.highestScore] ?? 0}',
                Icons.star,
                AppColors.accentYellow,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Best Distance',
                '${stats[StatisticType.longestDistance] ?? 0}m',
                Icons.straighten,
                AppColors.accentPink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(ProgressTracker tracker) {
    final recent = tracker.getRecentAchievements(limit: 3);
    
    if (recent.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Achievements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        ...recent.map((achievement) => AchievementCard(
          achievement: achievement,
          compact: true,
          showProgress: false,
        )).toList(),
      ],
    );
  }
}

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.session,
    this.isCurrentSession = false,
  });

  final SessionAnalytics session;
  final bool isCurrentSession;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentSession 
          ? AppColors.primaryPurple.withValues(alpha: 0.1)
          : AppColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentSession 
            ? AppColors.primaryPurple 
            : AppColors.primaryPurple.withValues(alpha: 0.3),
          width: isCurrentSession ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session header
          Row(
            children: [
              Icon(
                isCurrentSession ? Icons.play_circle : Icons.history,
                color: isCurrentSession ? AppColors.primaryPurple : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCurrentSession ? 'Current Session' : 'Past Session',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentSession ? AppColors.primaryPurple : AppColors.textLight,
                ),
              ),
              const Spacer(),
              Text(
                _formatSessionTime(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Key metrics
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Score',
                  '${session.finalScore}',
                  Icons.star,
                  AppColors.accentYellow,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Rows',
                  '${session.rowsCrossed}',
                  Icons.straighten,
                  AppColors.accentPink,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Duration',
                  _formatDuration(session.sessionDuration),
                  Icons.timer,
                  AppColors.accentPink,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Additional stats
          Row(
            children: [
              Expanded(
                child: _buildSmallMetric('Hops', '${session.hopsPerformed}'),
              ),
              Expanded(
                child: _buildSmallMetric('Water Crossings', '${session.waterCrossings}'),
              ),
              Expanded(
                child: _buildSmallMetric('Near Misses', '${session.nearMisses}'),
              ),
              Expanded(
                child: _buildSmallMetric('Perfect Timings', '${session.perfectTimings}'),
              ),
            ],
          ),
          
          if (session.gameEndReason.isNotEmpty && !isCurrentSession) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Ended: ${session.gameEndReason}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatSessionTime() {
    final start = session.sessionStart;
    final now = DateTime.now();
    final difference = now.difference(start);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class AchievementPopup extends StatefulWidget {
  const AchievementPopup({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  final AchievementProgress achievement;
  final VoidCallback? onDismiss;

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ProgressTracker.getMilestoneData(widget.achievement.milestone)!;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentYellow,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Achievement icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            data.icon,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Achievement unlocked text
                      const Text(
                        'ACHIEVEMENT UNLOCKED!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Achievement title
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Achievement description
                      Text(
                        data.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Reward points
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${data.rewardPoints} Points',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
    );
  }
}