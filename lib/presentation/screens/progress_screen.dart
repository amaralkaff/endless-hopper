import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../game/systems/progress_tracker.dart';
import '../../game/widgets/progress_display.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final ProgressTracker _progressTracker;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _progressTracker = ProgressTracker();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _progressTracker.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Progress & Achievements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryPurple,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryPurple,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Sessions', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAchievementsTab(),
          _buildSessionsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListenableBuilder(
      listenable: _progressTracker,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress overview
              ProgressOverview(
                progressTracker: _progressTracker,
                showRecentAchievements: true,
              ),
              
              const SizedBox(height: 20),
              
              // Quick stats
              _buildQuickStats(),
              
              const SizedBox(height: 20),
              
              // Progress breakdown
              _buildProgressBreakdown(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    final stats = _progressTracker.statistics;
    
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
                Icons.analytics,
                color: AppColors.accentPink,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Game Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatCard(
                'Games Played',
                '${stats[StatisticType.gamesPlayed] ?? 0}',
                Icons.games,
                AppColors.primaryPurple,
              ),
              _buildStatCard(
                'Total Hops',
                '${stats[StatisticType.totalHops] ?? 0}',
                Icons.skip_next,
                AppColors.accentPink,
              ),
              _buildStatCard(
                'Water Crossings',
                '${stats[StatisticType.waterCrossings] ?? 0}',
                Icons.waves,
                AppColors.waterBlue,
              ),
              _buildStatCard(
                'Near Misses',
                '${stats[StatisticType.nearMisses] ?? 0}',
                Icons.close,
                AppColors.error,
              ),
              _buildStatCard(
                'Perfect Timings',
                '${stats[StatisticType.perfectTimings] ?? 0}',
                Icons.timer,
                AppColors.accentYellow,
              ),
              _buildStatCard(
                'Best Score',
                '${stats[StatisticType.highestScore] ?? 0}',
                Icons.star,
                AppColors.accentYellow
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBreakdown() {
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
                Icons.trending_up,
                color: AppColors.accentYellow,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Progress Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildProgressItem('Distance Achievements', _countDistanceAchievements()),
          _buildProgressItem('Score Achievements', _countScoreAchievements()),
          _buildProgressItem('Skill Achievements', _countSkillAchievements()),
          _buildProgressItem('Volume Achievements', _countVolumeAchievements()),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String category, Map<String, int> data) {
    final completed = data['completed']!;
    final total = data['total']!;
    final progress = total > 0 ? completed / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '$completed/$total',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPink),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListenableBuilder(
      listenable: _progressTracker,
      builder: (context, child) {
        final completedAchievements = _progressTracker.achievements.values
            .where((a) => a.isCompleted)
            .toList();
        final incompleteAchievements = _progressTracker.getIncompleteAchievements();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter tabs
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'All (${_progressTracker.achievements.length})',
                      true,
                      () => _showAllAchievements(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton(
                      'Completed (${completedAchievements.length})',
                      false,
                      () => _showCompletedAchievements(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton(
                      'In Progress (${incompleteAchievements.length})',
                      false,
                      () => _showInProgressAchievements(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Achievement list
              ..._progressTracker.achievements.values.map((achievement) {
                return AchievementCard(
                  achievement: achievement,
                  showProgress: true,
                  compact: false,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primaryPurple 
            : AppColors.primaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryPurple,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primaryPurple,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSessionsTab() {
    return ListenableBuilder(
      listenable: _progressTracker,
      builder: (context, child) {
        final sessions = _progressTracker.sessionHistory;
        final currentSession = _progressTracker.currentSession;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current session
              if (currentSession != null) ...[
                const Text(
                  'Current Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SessionSummaryCard(
                  session: currentSession,
                  isCurrentSession: true,
                ),
                const SizedBox(height: 20),
              ],
              
              // Session history
              Row(
                children: [
                  const Text(
                    'Recent Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${sessions.length} total',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              if (sessions.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No previous sessions',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Play your first game to see session history!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...sessions.reversed.take(20).map((session) {
                  return SessionSummaryCard(
                    session: session,
                    isCurrentSession: false,
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  // Achievement counting helpers
  Map<String, int> _countDistanceAchievements() {
    final distanceAchievements = [
      ProgressMilestone.reach10Rows,
      ProgressMilestone.reach25Rows,
      ProgressMilestone.reach50Rows,
      ProgressMilestone.reach100Rows,
      ProgressMilestone.reach250Rows,
      ProgressMilestone.reach500Rows,
    ];
    
    return _countAchievements(distanceAchievements);
  }

  Map<String, int> _countScoreAchievements() {
    final scoreAchievements = [
      ProgressMilestone.score100,
      ProgressMilestone.score500,
      ProgressMilestone.score1000,
      ProgressMilestone.score5000,
    ];
    
    return _countAchievements(scoreAchievements);
  }

  Map<String, int> _countSkillAchievements() {
    final skillAchievements = [
      ProgressMilestone.firstWaterCrossing,
      ProgressMilestone.perfectStreak10,
      ProgressMilestone.perfectStreak25,
      ProgressMilestone.nearMiss50,
      ProgressMilestone.waterCrossing10,
      ProgressMilestone.surviveMinute,
      ProgressMilestone.survive5Minutes,
    ];
    
    return _countAchievements(skillAchievements);
  }

  Map<String, int> _countVolumeAchievements() {
    final volumeAchievements = [
      ProgressMilestone.firstHop,
      ProgressMilestone.sessionPlay10,
      ProgressMilestone.sessionPlay50,
      ProgressMilestone.totalHops1000,
      ProgressMilestone.totalHops10000,
    ];
    
    return _countAchievements(volumeAchievements);
  }

  Map<String, int> _countAchievements(List<ProgressMilestone> milestones) {
    int completed = 0;
    
    for (final milestone in milestones) {
      final achievement = _progressTracker.achievements[milestone];
      if (achievement?.isCompleted == true) {
        completed++;
      }
    }
    
    return {
      'completed': completed,
      'total': milestones.length,
    };
  }

  // Filter methods (for future implementation)
  void _showAllAchievements() {
    // Implementation for showing all achievements
  }

  void _showCompletedAchievements() {
    // Implementation for showing only completed achievements
  }

  void _showInProgressAchievements() {
    // Implementation for showing only in-progress achievements
  }
}