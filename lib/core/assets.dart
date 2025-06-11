/// Asset paths for the Endless Hopper game
/// Contains all sprite, animation, and audio asset references
class GameAssets {
  // Base paths
  static const String _spritesPath = 'assets/Package/Sprites';
  static const String _animationsPath = 'assets/Package/Animations';
  static const String _soundsPath = 'assets/Sounds';

  /// 🎮 Game Objects
  static const String teddyBear = '$_spritesPath/Game Objects/Teddy_Bear.png';
  static const String background = '$_spritesPath/Game Objects/Background.png';
  static const String foreground = '$_spritesPath/Game Objects/Foreground.png';
  static const String obstacle1 = '$_spritesPath/Game Objects/Obstacle_1.png';
  static const String obstacle2 = '$_spritesPath/Game Objects/Obstacle_2.png';
  static const String obstacle3 = '$_spritesPath/Game Objects/Obstacle_3.png';

  /// 🎬 Animations
  static const String runAnimation = '$_animationsPath/Run.png';
  static const String jumpAnimation = '$_animationsPath/Jump.png';
  static const String deathAnimation = '$_animationsPath/Death.png';

  /// 🖱️ UI Elements  
  static const String playButton = '$_spritesPath/UI Elements/Play_Button.png';
  static const String pauseButton = '$_spritesPath/UI Elements/Pause_Button.png';
  static const String retryButton = '$_spritesPath/UI Elements/Retry_Button.png';
  static const String panel = '$_spritesPath/UI Elements/Panel.png';
  static const String sign = '$_spritesPath/UI Elements/Sign.png';
  static const String teddyMark = '$_spritesPath/UI Elements/Teddy_Mark.png';
  static const String curtainFixed = '$_spritesPath/UI Elements/Curtain_Fix.png';
  static const String curtainMobile = '$_spritesPath/UI Elements/Curtain_Mobile.png';

  /// 🔊 Audio Assets
  static const String backgroundMusic = '$_soundsPath/BGMusic.wav';
  static const String jumpSound = '$_soundsPath/Jump.wav';
  static const String clickSound = '$_soundsPath/Click.wav';
  static const String gameOverSound = '$_soundsPath/Game Over.wav';
  static const String recordSound = '$_soundsPath/Record.wav';

  /// 📂 Asset Lists for easy iteration
  static const List<String> obstacles = [obstacle1, obstacle2, obstacle3];
  static const List<String> animations = [runAnimation, jumpAnimation, deathAnimation];
  static const List<String> uiButtons = [playButton, pauseButton, retryButton];
  static const List<String> soundEffects = [jumpSound, clickSound, gameOverSound, recordSound];
} 