import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/assets.dart';
import 'core/app_colors.dart';
import 'core/app_themes.dart';

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
              
              // Settings button
              OutlinedButton(
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
  int score = 0;
  bool isPlaying = true;

  void _onTap() {
    if (!isPlaying) return;
    
    setState(() {
      score++;
    });
    
    // TODO: Implement actual game logic
    // For now, just increment score
    
    // Simulate game over at score 20 for testing
    if (score >= 20) {
      _gameOver();
    }
  }

  void _gameOver() {
    setState(() {
      isPlaying = false;
    });
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(score: score),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grassGreenLight,
      body: SafeArea(
        child: Column(
          children: [
            // Score display
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textPrimary,
                  ),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement pause
                    },
                    icon: const Icon(Icons.pause),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
            
            // Game area
            Expanded(
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
                        const Text(
                          'Game engine coming soon...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final int score;
  
  const GameOverScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMedium,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Over icon
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  GameAssets.teddyBear,
                  fit: BoxFit.contain,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              
              // Score display
              Text(
                'Final Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Encouraging message
              Text(
                score >= 15 ? 'Great job! 🎉' : 
                score >= 10 ? 'Not bad! 👍' : 
                'Keep trying! 💪',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Play Again button
              ElevatedButton(
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Main Menu button
              OutlinedButton(
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
            ],
          ),
        ),
      ),
    );
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