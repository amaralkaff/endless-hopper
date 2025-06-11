// Game Constants
class GameConstants {
  // Game Dimensions
  static const double tileSize = 64.0;
  static const double playerSize = 48.0;
  static const double obstacleSize = 56.0;
  
  // Movement & Animation
  static const double hopDuration = 0.3;
  static const double cameraFollowSpeed = 0.5;
  static const double animationSpeed = 1.0;
  
  // World Generation
  static const int initialRowsToGenerate = 20;
  static const int rowsAheadToKeep = 30;
  static const int rowsBehindToKeep = 10;
  static const double worldWidth = 800.0;
  
  // Difficulty Progression
  static const double baseDifficulty = 1.0;
  static const double difficultyIncrement = 0.1;
  static const int rowsPerDifficultyIncrease = 10;
  
  // Obstacle Settings
  static const double minCarSpeed = 50.0;
  static const double maxCarSpeed = 150.0;
  static const double minLogSpeed = 20.0;
  static const double maxLogSpeed = 80.0;
  
  // Spawn Rates (per second)
  static const double carSpawnRate = 0.5;
  static const double logSpawnRate = 0.3;
  
  // Scoring
  static const int pointsPerRow = 10;
  static const int bonusPointsForSpecialActions = 50;
  static const int timeBonus = 1;
  
  // UI Constants
  static const double uiElementPadding = 16.0;
  static const double buttonHeight = 56.0;
  static const double menuSpacing = 24.0;
  
  // Audio Settings
  static const double defaultMusicVolume = 0.7;
  static const double defaultSfxVolume = 0.8;
  
  // Performance
  static const int targetFPS = 60;
  static const int maxParticles = 100;
  
  // Game Modes
  static const String classicMode = 'classic';
  static const String challengeMode = 'challenge';
  static const String timeAttackMode = 'time_attack';
  
  // Storage Keys
  static const String highScoreKey = 'high_score';
  static const String musicVolumeKey = 'music_volume';
  static const String sfxVolumeKey = 'sfx_volume';
  static const String selectedCharacterKey = 'selected_character';
  static const String gameSettingsKey = 'game_settings';
}

// Enum for different tile types
enum TileType {
  grass,
  road,
  water,
  mountain,
  goal
}

// Enum for movement directions
enum Direction {
  up,
  down,
  left,
  right
}

// Enum for game states
enum GameState {
  menu,
  playing,
  paused,
  gameOver,
  loading
}

// Enum for character types
enum CharacterType {
  frog,
  teddyBear,
  robot,
  ninja
}

// Enum for obstacle types
enum ObstacleType {
  car,
  truck,
  log,
  rock,
  enemy
} 