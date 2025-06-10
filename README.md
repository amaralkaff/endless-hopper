# Endless Hopper

A Flutter mobile game inspired by Crossy Road and Frogger featuring tap-to-hop mechanics and procedural world generation.

## Overview

Endless Hopper is a mobile arcade game where players navigate forward across procedurally generated terrain by tapping to hop. The objective is to travel as far as possible while avoiding obstacles and environmental hazards.

### Core Features
- Single-tap forward movement mechanics
- Procedurally generated infinite terrain
- Multiple terrain types with unique obstacles
- Distance-based scoring system
- Portrait orientation optimized for mobile
- Game over and restart functionality

### Planned Features
- Character unlock system with collectible coins
- Multiple environment themes (space, jungle, desert)
- Leaderboards and achievements integration
- Rewarded video advertisements
- Character customization options

## Technology Stack

- **Framework**: Flutter (Latest Stable)
- **Language**: Dart
- **Architecture**: Clean Architecture with BLoC pattern
- **Platforms**: Android and iOS

## Requirements

### Development Environment
- Flutter SDK (Latest Stable)
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Xcode (for iOS development on macOS)
- Git

### Target Devices
- **Android**: API level 21+ (Android 5.0)
- **iOS**: iOS 12.0+
- **RAM**: 2GB minimum
- **Storage**: 100MB

## Setup

```bash
# Clone the repository
git clone https://github.com/amaralkaff/endless-hopper.git
cd endless-hopper

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

## Project Structure

```
lib/
├── core/                      # Core utilities and constants
├── data/                      # Data layer (repositories, models)
├── domain/                    # Business logic (entities, use cases)
├── presentation/              # UI layer (screens, widgets, BLoC)
├── game/                      # Game-specific logic
│   ├── entities/              # Game objects (player, obstacles)
│   ├── systems/               # Game systems (collision, scoring)
│   └── components/            # Reusable game components
└── main.dart

assets/
├── images/                    # Sprites and textures
├── audio/                     # Sound effects and music
└── fonts/                     # Custom fonts

test/                          # Unit and widget tests
integration_test/              # Integration tests
```

## Game Design

### Core Gameplay
1. Player starts on safe grass tiles
2. Tap screen to hop forward one tile
3. Navigate through different terrain types
4. Avoid obstacles and environmental hazards
5. Score increases with distance traveled
6. Game ends on collision or falling off screen

### Terrain Types
- **Grass**: Safe starting and rest areas
- **Road**: Moving cars that must be avoided
- **Water**: Requires logs to cross safely
- **Mountain**: Static obstacles to navigate around

### Core Mechanics
- Forward-only movement via tap input
- Rectangle-based collision detection
- Smooth hop animations
- Audio feedback for actions and collisions

## Development Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Build for release
flutter build apk              # Android
flutter build ios             # iOS (macOS only)

# Clean project
flutter clean && flutter pub get
```

## Testing Strategy

- **Unit Tests**: Game logic and utility functions
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: Complete gameplay scenarios
- **Performance Tests**: Frame rate and memory optimization

## Platform Integration

### Android
- Material Design UI components
- Google Play Games Services
- AdMob integration
- Haptic feedback support

### iOS
- Cupertino design patterns
- Game Center integration
- App Store guidelines compliance
- iOS-specific haptic feedback

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/feature-name`)
3. Commit your changes (`git commit -m 'Add feature description'`)
4. Push to the branch (`git push origin feature/feature-name`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Crossy Road and Frogger
- Flutter community documentation and resources