import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../systems/scoring_system.dart';
import 'score_display.dart';

class ScoreOverlay extends StatefulWidget {
  const ScoreOverlay({
    super.key,
    required this.scoringSystem,
    required this.child,
    this.showScorePopups = true,
  });

  final ScoringSystem scoringSystem;
  final Widget child;
  final bool showScorePopups;

  @override
  State<ScoreOverlay> createState() => _ScoreOverlayState();
}

class _ScoreOverlayState extends State<ScoreOverlay> {
  final List<ScorePopupData> _activePopups = [];
  late final List<ScoreEvent> _lastKnownEvents;

  @override
  void initState() {
    super.initState();
    _lastKnownEvents = List.from(widget.scoringSystem.sessionEvents);
    widget.scoringSystem.addListener(_onScoreSystemUpdate);
  }

  @override
  void dispose() {
    widget.scoringSystem.removeListener(_onScoreSystemUpdate);
    super.dispose();
  }

  void _onScoreSystemUpdate() {
    if (!widget.showScorePopups) return;
    
    final currentEvents = widget.scoringSystem.sessionEvents;
    
    // Find new events since last update
    if (currentEvents.length > _lastKnownEvents.length) {
      final newEvents = currentEvents.skip(_lastKnownEvents.length).toList();
      
      for (final event in newEvents) {
        if (event.position != null) {
          _addScorePopup(event);
        }
      }
    }
    
    // Update our cache
    _lastKnownEvents.clear();
    _lastKnownEvents.addAll(currentEvents);
  }

  void _addScorePopup(ScoreEvent event) {
    final popupData = ScorePopupData(
      event: event,
      position: event.position!,
      id: DateTime.now().millisecondsSinceEpoch,
    );
    
    setState(() {
      _activePopups.add(popupData);
    });
    
    // Auto-remove popup after duration
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _activePopups.removeWhere((popup) => popup.id == popupData.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Score popups overlay
        if (widget.showScorePopups) ...[
          for (final popup in _activePopups)
            ScorePopup(
              key: ValueKey(popup.id),
              scoreEvent: popup.event,
              position: popup.position,
            ),
        ],
      ],
    );
  }
}

class ScorePopupData {
  const ScorePopupData({
    required this.event,
    required this.position,
    required this.id,
  });

  final ScoreEvent event;
  final Offset position;
  final int id;
}

class GameHUD extends StatelessWidget {
  const GameHUD({
    super.key,
    required this.scoringSystem,
    this.onPause,
    this.onBack,
    this.showBackButton = true,
    this.showPauseButton = true,
    this.showStats = false,
  });

  final ScoringSystem scoringSystem;
  final VoidCallback? onPause;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showPauseButton;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top HUD row
            Row(
              children: [
                // Back button
                if (showBackButton && onBack != null) ...[
                  _buildHUDButton(
                    icon: Icons.arrow_back,
                    onPressed: onBack!,
                    backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Score display
                Expanded(
                  child: ScoreDisplay(
                    scoringSystem: scoringSystem,
                    compact: true,
                    showHighScore: false,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Pause button
                if (showPauseButton && onPause != null) ...[
                  _buildHUDButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
            
            // Stats display (expandable)
            if (showStats) ...[
              const SizedBox(height: 16),
              StatisticsDisplay(
                scoringSystem: scoringSystem,
                showAllTime: false,
              ),
            ],
            
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryPurple.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: AppColors.textLight,
          size: 24,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
      ),
    );
  }
}

class ScoreComparisonWidget extends StatelessWidget {
  const ScoreComparisonWidget({
    super.key,
    required this.currentScore,
    required this.previousBest,
    required this.isNewRecord,
  });

  final int currentScore;
  final int previousBest;
  final bool isNewRecord;

  @override
  Widget build(BuildContext context) {
    final difference = currentScore - previousBest;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNewRecord 
          ? AppColors.accentYellow.withValues(alpha: 0.2)
          : AppColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNewRecord 
            ? AppColors.accentYellow
            : AppColors.primaryPurple.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isNewRecord ? Icons.emoji_events : Icons.trending_up,
                color: isNewRecord ? AppColors.accentYellow : AppColors.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isNewRecord ? 'NEW RECORD!' : 'Score Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isNewRecord ? AppColors.accentYellow : AppColors.textLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Current score
          _buildScoreRow(
            'Current Score',
            currentScore,
            AppColors.accentPink,
            Icons.star,
          ),
          
          const SizedBox(height: 8),
          
          // Previous best
          _buildScoreRow(
            'Previous Best',
            previousBest,
            AppColors.textSecondary,
            Icons.history,
          ),
          
          if (difference != 0) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.primaryPurple, height: 1),
            const SizedBox(height: 8),
            
            // Difference
            Row(
              children: [
                Icon(
                  difference > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: difference > 0 ? AppColors.success : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Difference: ${difference > 0 ? '+' : ''}$difference',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: difference > 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, int score, Color color, IconData icon) {
    return Row(
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
          '$score',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class ScoreProgressIndicator extends StatelessWidget {
  const ScoreProgressIndicator({
    super.key,
    required this.currentScore,
    required this.nextMilestone,
    this.showDetails = false,
  });

  final int currentScore;
  final int nextMilestone;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final progress = currentScore / nextMilestone;
    final remaining = nextMilestone - currentScore;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: AppColors.accentYellow,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Next Goal: $nextMilestone',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.accentPink,
              ),
              minHeight: 6,
            ),
          ),
          
          if (showDetails) ...[
            const SizedBox(height: 6),
            Text(
              remaining > 0 ? '$remaining to go' : 'Goal reached!',
              style: TextStyle(
                fontSize: 10,
                color: remaining > 0 ? AppColors.textSecondary : AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}