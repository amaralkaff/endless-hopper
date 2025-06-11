import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/assets.dart';
import 'core/app_colors.dart';
import 'core/app_themes.dart';
import 'game/systems/scoring_system.dart';
import 'game/systems/progress_tracker.dart';
import 'game/widgets/score_display.dart';
import 'game/widgets/score_overlay.dart';
import 'game/entities/player.dart';
import 'game/entities/obstacle.dart';
import 'presentation/screens/progress_screen.dart';


void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (portrait only for mobile game)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Run the app
  runApp(const EndlessHopperApp());
}

class EndlessHopperApp extends StatelessWidget {
  const EndlessHopperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endless Hopper',
      debugShowCheckedModeBanner: false,
      theme: PixelArtThemes.lightTheme,
      darkTheme: PixelArtThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation and navigate to main menu after delay
    _animationController.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game logo/icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    GameAssets.teddyMark,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ENDLESS HOPPER',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '🧸 Hop your way to infinity!',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game title
              const Text(
                'ENDLESS HOPPER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '🧸 Ready to hop?',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 60),
              
              // Play button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  );
                },
                child: const Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProgressScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              // Game description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Tap to hop forward and avoid obstacles!\nHow far can you go?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ProgressTracker _progressTracker;
  late final ScoringSystem _scoringSystem;
  bool isPlaying = true;
  int _hopCount = 0;

  @override
  void initState() {
    super.initState();
    _progressTracker = ProgressTracker();
    _scoringSystem = ScoringSystem(progressTracker: _progressTracker);
    _scoringSystem.startNewSession();
  }

  @override
  void dispose() {
    _scoringSystem.dispose();
    _progressTracker.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!isPlaying) return;
    
    setState(() {
      _hopCount++;
    });
    
    // Simulate game mechanics with scoring system
    // TODO: Replace with actual game logic
    
    // Simulate distance progress
    _scoringSystem.updateDistance(MockPlayer(_hopCount));
    
    // Simulate various score events randomly
    if (_hopCount % 3 == 0) {
      _scoringSystem.recordHop(
        MockPlayer(_hopCount), 
        [], // No obstacles for now
        null, // No current tile for now
      );
    }
    
    // Simulate dangerous hop occasionally
    if (_hopCount % 7 == 0) {
      _scoringSystem.recordNearMiss(
        MockPlayer(_hopCount),
        MockObstacle(_hopCount * 48.0, _hopCount * 48.0),
      );
    }
    
    // Simulate game over at score 500 for testing
    if (_scoringSystem.currentScore >= 500) {
      _gameOver();
    }
  }

  void _gameOver() async {
    setState(() {
      isPlaying = false;
    });
    
    await _scoringSystem.endSession();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameOverScreen(scoringSystem: _scoringSystem),
        ),
      );
    }
  }

  void _pauseGame() {
    setState(() {
      isPlaying = false;
    });
    // TODO: Implement pause logic
  }

  void _resumeGame() {
    setState(() {
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grassGreenLight,
      body: ScoreOverlay(
        scoringSystem: _scoringSystem,
        showScorePopups: true,
        child: Stack(
          children: [
            // Game area
            Positioned.fill(
              child: GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Teddy Bear Character
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            GameAssets.teddyBear,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'TAP TO HOP!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Score: ${_scoringSystem.currentScore} | Distance: ${_scoringSystem.currentDistance}m',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Hops: $_hopCount | Streak: ${_scoringSystem.currentStreak}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Game HUD overlay
            GameHUD(
              scoringSystem: _scoringSystem,
              onBack: () => Navigator.of(context).pop(),
              onPause: isPlaying ? _pauseGame : _resumeGame,
              showBackButton: true,
              showPauseButton: true,
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final ScoringSystem scoringSystem;
  
  const GameOverScreen({super.key, required this.scoringSystem});

  @override
  Widget build(BuildContext context) {
    final score = scoringSystem.currentScore;
    final distance = scoringSystem.currentDistance;
    final isNewRecord = scoringSystem.isNewHighScore;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundMedium,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Game Over icon
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  GameAssets.teddyBear,
                  fit: BoxFit.contain,
                  color: isNewRecord 
                    ? AppColors.accentYellow.withValues(alpha: 0.8)
                    : AppColors.error.withValues(alpha: 0.7),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                isNewRecord ? 'NEW RECORD!' : 'GAME OVER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isNewRecord ? AppColors.accentYellow : AppColors.error,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Score display with details
              ScoreDisplay(
                scoringSystem: scoringSystem,
                showHighScore: true,
                compact: false,
              ),
              
              const SizedBox(height: 20),
              
              // Score comparison
              if (scoringSystem.highScore > 0) ...[
                ScoreComparisonWidget(
                  currentScore: score,
                  previousBest: scoringSystem.highScore,
                  isNewRecord: isNewRecord,
                ),
                const SizedBox(height: 20),
              ],
              
              // Statistics display
              StatisticsDisplay(
                scoringSystem: scoringSystem,
                showAllTime: false,
              ),
              
              const SizedBox(height: 20),
              
              // Leaderboard
              LeaderboardDisplay(
                scoringSystem: scoringSystem,
                maxEntries: 5,
              ),
              
              const SizedBox(height: 32),
              
              // Encouraging message
              Text(
                _getEncouragingMessage(score, distance),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const GameScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainMenuScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'MAIN MENU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getEncouragingMessage(int score, int distance) {
    if (score >= 400) return 'Incredible performance! You\'re a hopping legend! 🏆';
    if (score >= 300) return 'Outstanding! You\'ve mastered the art of hopping! 🎯';
    if (score >= 200) return 'Excellent work! You\'re becoming a pro hopper! 🌟';
    if (score >= 100) return 'Great job! Keep up the fantastic hopping! 🎉';
    if (score >= 50) return 'Nice work! You\'re getting the hang of it! 👍';
    return 'Keep trying! Every hop gets you closer to greatness! 💪';
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;
  double gameSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio Settings Section
              const Text(
                'Audio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sound Effects Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Game sound effects'),
                  value: soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      soundEnabled = value;
                    });
                  },
                  activeColor: AppColors.accentPink,
                ),
              ),
              
              // Background Music Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Background Music'),
                  subtitle: const Text('Game background music'),
                  value: musicEnabled,
                  onChanged: (value) {
                    setState(() {
                      musicEnabled = value;
                    });
                  },
                  activeColor: AppColors.accentPink,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Gameplay Settings Section
              const Text(
                'Gameplay',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 16),
              
              // Vibration Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Haptic feedback'),
                  value: vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      vibrationEnabled = value;
                    });
                  },
                  activeColor: AppColors.accentPink,
                ),
              ),
              
              // Game Speed Slider
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Game Speed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Slow'),
                          Expanded(
                            child: Slider(
                              value: gameSpeed,
                              min: 0.5,
                              max: 2.0,
                              divisions: 6,
                              label: '${gameSpeed.toStringAsFixed(1)}x',
                              onChanged: (value) {
                                setState(() {
                                  gameSpeed = value;
                                });
                              },
                              activeColor: AppColors.primaryPurple,
                            ),
                          ),
                          const Text('Fast'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Reset to Defaults button
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      soundEnabled = true;
                      musicEnabled = true;
                      vibrationEnabled = true;
                      gameSpeed = 1.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings reset to defaults'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning),
                  ),
                  child: const Text(
                    'Reset to Defaults',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Mock classes for testing the scoring system
class MockPlayer extends Player {
  MockPlayer(int gridY) : super(
    x: 0.0,
    y: gridY * 48.0, // Assuming 48px tile size
    initialGridX: 0,
    initialGridY: gridY,
  );
}

class MockObstacle extends Obstacle {
  const MockObstacle(double x, double y) : super(
    x: x,
    y: y,
    width: 48.0,
    height: 32.0,
    type: ObstacleType.car,
    speed: 50.0,
    direction: 1,
  );
  
  @override
  String get assetPath => 'assets/Package/Sprites/Game Objects/Obstacle_1.png';
  
  @override
  bool get isDeadly => true;
  
  @override
  bool get isRideable => false;
  
  @override
  Obstacle copyWith({double? x, double? y}) {
    return MockObstacle(
      x ?? this.x,
      y ?? this.y,
    );
  }
}