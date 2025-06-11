import 'dart:math';
import '../entities/tile.dart';
import '../entities/grass_tile.dart';
import '../entities/road_tile.dart';
import '../entities/water_tile.dart';
import '../entities/obstacle.dart';
import '../entities/car.dart';
import '../entities/log.dart';
import 'car_spawner.dart';
import 'log_spawner.dart';
import '../../core/constants.dart';

enum TerrainPattern {
  grassSafe,
  roadWithCars,
  riverWithLogs,
  mountainBarrier,
}

class TerrainRow {
  TerrainRow({
    required this.y,
    required this.pattern,
    required this.tiles,
    required this.obstacles,
    this.difficulty = 1.0,
  });

  final int y;
  final TerrainPattern pattern;
  final List<Tile> tiles;
  final List<Obstacle> obstacles;
  final double difficulty;

  // Validation and debug methods
  bool get hasCollisionSafeSpawning {
    for (int i = 0; i < obstacles.length; i++) {
      for (int j = i + 1; j < obstacles.length; j++) {
        if (obstacles[i].bounds.overlaps(obstacles[j].bounds)) {
          return false;
        }
      }
    }
    return true;
  }

  List<Car> get cars => obstacles.whereType<Car>().toList();
  List<Log> get logs => obstacles.whereType<Log>().toList();
  
  Map<String, dynamic> get spawnStats {
    final cars = this.cars;
    final logs = this.logs;
    
    if (cars.isEmpty && logs.isEmpty) {
      return {'totalObstacles': 0, 'type': 'empty'};
    }
    
    final result = <String, dynamic>{
      'totalObstacles': obstacles.length,
      'collisionSafe': hasCollisionSafeSpawning,
    };
    
    if (cars.isNotEmpty) {
      final carSpeeds = cars.map((car) => car.speed).toList();
      result['cars'] = {
        'count': cars.length,
        'speedRange': {
          'min': carSpeeds.reduce((a, b) => a < b ? a : b),
          'max': carSpeeds.reduce((a, b) => a > b ? a : b),
          'average': carSpeeds.fold(0.0, (sum, speed) => sum + speed) / carSpeeds.length,
        },
        'directions': cars.map((car) => car.direction).toSet().toList(),
      };
    }
    
    if (logs.isNotEmpty) {
      final logSpeeds = logs.map((log) => log.speed).toList();
      result['logs'] = {
        'count': logs.length,
        'speedRange': {
          'min': logSpeeds.reduce((a, b) => a < b ? a : b),
          'max': logSpeeds.reduce((a, b) => a > b ? a : b),
          'average': logSpeeds.fold(0.0, (sum, speed) => sum + speed) / logSpeeds.length,
        },
        'directions': logs.map((log) => log.direction).toSet().toList(),
        'totalWidth': logs.fold(0.0, (sum, log) => sum + log.width),
      };
    }
    
    return result;
  }
}

class DifficultySettings {
  DifficultySettings({
    required this.carSpeed,
    required this.logSpeed,
    required this.carDensity,
    required this.logDensity,
    required this.gapSize,
    required this.patternComplexity,
  });

  final double carSpeed;
  final double logSpeed;
  final double carDensity; // 0.0 to 1.0
  final double logDensity; // 0.0 to 1.0
  final double gapSize; // Average gap between obstacles
  final double patternComplexity; // 0.0 to 1.0

  static DifficultySettings forLevel(int level) {
    final normalizedLevel = level / 10.0; // Normalize every 10 levels
    
    return DifficultySettings(
      carSpeed: 80.0 + (normalizedLevel * 40.0), // 80-120 speed
      logSpeed: 40.0 + (normalizedLevel * 20.0), // 40-60 speed
      carDensity: 0.3 + (normalizedLevel * 0.4), // 30-70% density
      logDensity: 0.4 + (normalizedLevel * 0.3), // 40-70% density
      gapSize: 3.0 - (normalizedLevel * 1.0), // 3-2 tiles gap
      patternComplexity: normalizedLevel.clamp(0.0, 1.0),
    );
  }
}

class PatternTemplate {
  PatternTemplate({
    required this.pattern,
    required this.minLength,
    required this.maxLength,
    required this.weight,
    this.followingPatterns = const [],
  });

  final TerrainPattern pattern;
  final int minLength;
  final int maxLength;
  final double weight; // Probability weight
  final List<TerrainPattern> followingPatterns; // Allowed next patterns
}

class WorldGenerator {
  WorldGenerator({
    this.worldWidth = 11, // Odd number for center alignment
    this.seed,
  }) : _random = Random(seed),
       _carSpawner = CarSpawner(worldWidth: 11, seed: seed),
       _logSpawner = LogSpawner(worldWidth: 11, seed: seed) {
    _initializePatternTemplates();
  }

  final int worldWidth;
  final int? seed;
  final Random _random;
  final CarSpawner _carSpawner;
  final LogSpawner _logSpawner;
  
  final List<TerrainRow> _generatedRows = [];
  final Map<TerrainPattern, PatternTemplate> _patterns = {};
  
  int _currentLevel = 1;
  int _rowsGenerated = 0;
  TerrainPattern? _lastPattern;
  int _currentPatternLength = 0;

  // Getters
  List<TerrainRow> get generatedRows => List.unmodifiable(_generatedRows);
  int get currentLevel => _currentLevel;
  int get rowsGenerated => _rowsGenerated;
  CarSpawner get carSpawner => _carSpawner;
  LogSpawner get logSpawner => _logSpawner;

  void _initializePatternTemplates() {
    _patterns[TerrainPattern.grassSafe] = PatternTemplate(
      pattern: TerrainPattern.grassSafe,
      minLength: 1,
      maxLength: 3,
      weight: 1.0,
      followingPatterns: [
        TerrainPattern.roadWithCars,
        TerrainPattern.riverWithLogs,
        TerrainPattern.mountainBarrier,
      ],
    );

    _patterns[TerrainPattern.roadWithCars] = PatternTemplate(
      pattern: TerrainPattern.roadWithCars,
      minLength: 2,
      maxLength: 5,
      weight: 1.5,
      followingPatterns: [
        TerrainPattern.grassSafe,
        TerrainPattern.riverWithLogs,
      ],
    );

    _patterns[TerrainPattern.riverWithLogs] = PatternTemplate(
      pattern: TerrainPattern.riverWithLogs,
      minLength: 3,
      maxLength: 6,
      weight: 1.2,
      followingPatterns: [
        TerrainPattern.grassSafe,
        TerrainPattern.roadWithCars,
      ],
    );

    _patterns[TerrainPattern.mountainBarrier] = PatternTemplate(
      pattern: TerrainPattern.mountainBarrier,
      minLength: 1,
      maxLength: 2,
      weight: 0.5,
      followingPatterns: [
        TerrainPattern.grassSafe,
      ],
    );
  }

  // Generate initial safe starting area
  List<TerrainRow> generateStartingArea() {
    final startingRows = <TerrainRow>[];
    
    // Generate 5 rows of safe grass
    for (int y = 0; y < 5; y++) {
      final row = _generateGrassRow(y);
      startingRows.add(row);
      _generatedRows.add(row);
    }
    
    _rowsGenerated = 5;
    return startingRows;
  }

  // Generate next chunk of rows
  List<TerrainRow> generateNextChunk(int chunkSize) {
    final chunk = <TerrainRow>[];
    
    for (int i = 0; i < chunkSize; i++) {
      final row = generateNextRow();
      chunk.add(row);
    }
    
    return chunk;
  }

  // Generate single row based on current pattern state
  TerrainRow generateNextRow() {
    // Update difficulty every 10 rows
    if (_rowsGenerated % 10 == 0) {
      _currentLevel = (_rowsGenerated ~/ 10) + 1;
    }

    final difficulty = DifficultySettings.forLevel(_currentLevel);
    TerrainPattern nextPattern;

    // Determine next pattern
    if (_lastPattern == null || _currentPatternLength <= 0) {
      nextPattern = _selectNextPattern();
      _currentPatternLength = _getPatternLength(nextPattern);
    } else {
      nextPattern = _lastPattern!;
    }

    // Generate row based on pattern
    TerrainRow row;
    switch (nextPattern) {
      case TerrainPattern.grassSafe:
        row = _generateGrassRow(_rowsGenerated, difficulty: difficulty);
        break;
      case TerrainPattern.roadWithCars:
        row = _generateRoadRow(_rowsGenerated, difficulty: difficulty);
        break;
      case TerrainPattern.riverWithLogs:
        row = _generateRiverRow(_rowsGenerated, difficulty: difficulty);
        break;
      case TerrainPattern.mountainBarrier:
        row = _generateMountainRow(_rowsGenerated, difficulty: difficulty);
        break;
    }

    // Update state
    _lastPattern = nextPattern;
    _currentPatternLength--;
    _rowsGenerated++;
    _generatedRows.add(row);

    return row;
  }

  TerrainPattern _selectNextPattern() {
    final candidates = <TerrainPattern>[];
    
    if (_lastPattern == null) {
      // First pattern after starting area
      candidates.addAll([
        TerrainPattern.roadWithCars,
        TerrainPattern.riverWithLogs,
      ]);
    } else {
      final template = _patterns[_lastPattern!]!;
      candidates.addAll(template.followingPatterns);
    }

    // Weight-based selection
    final weights = candidates.map((p) => _patterns[p]!.weight).toList();
    final totalWeight = weights.fold(0.0, (sum, weight) => sum + weight);
    
    double randomValue = _random.nextDouble() * totalWeight;
    for (int i = 0; i < candidates.length; i++) {
      randomValue -= weights[i];
      if (randomValue <= 0) {
        return candidates[i];
      }
    }
    
    return candidates.last;
  }

  int _getPatternLength(TerrainPattern pattern) {
    final template = _patterns[pattern]!;
    return template.minLength + 
           _random.nextInt(template.maxLength - template.minLength + 1);
  }

  TerrainRow _generateGrassRow(int y, {DifficultySettings? difficulty}) {
    final tiles = <Tile>[];
    final obstacles = <Obstacle>[];

    // Generate grass tiles across width
    for (int x = -(worldWidth ~/ 2); x <= (worldWidth ~/ 2); x++) {
      tiles.add(GrassTile(x: x, y: y));
    }

    return TerrainRow(
      y: y,
      pattern: TerrainPattern.grassSafe,
      tiles: tiles,
      obstacles: obstacles,
      difficulty: difficulty?.patternComplexity ?? 1.0,
    );
  }

  TerrainRow _generateRoadRow(int y, {required DifficultySettings difficulty}) {
    final tiles = <Tile>[];
    final obstacles = <Obstacle>[];

    // Generate road tiles
    for (int x = -(worldWidth ~/ 2); x <= (worldWidth ~/ 2); x++) {
      tiles.add(RoadTile(x: x, y: y));
    }

    // Generate cars with enhanced spawning system
    final cars = _carSpawner.generateCarsForRow(
      y: y,
      difficulty: difficulty.patternComplexity,
      densityMultiplier: difficulty.carDensity,
      existingObstacles: obstacles,
    );
    obstacles.addAll(cars);

    return TerrainRow(
      y: y,
      pattern: TerrainPattern.roadWithCars,
      tiles: tiles,
      obstacles: obstacles,
      difficulty: difficulty.patternComplexity,
    );
  }

  TerrainRow _generateRiverRow(int y, {required DifficultySettings difficulty}) {
    final tiles = <Tile>[];
    final obstacles = <Obstacle>[];

    // Generate water tiles
    for (int x = -(worldWidth ~/ 2); x <= (worldWidth ~/ 2); x++) {
      tiles.add(WaterTile(x: x, y: y));
    }

    // Generate logs with enhanced spawning system
    final logs = _logSpawner.generateLogsForRow(
      y: y,
      difficulty: difficulty.patternComplexity,
      existingObstacles: obstacles,
    );
    obstacles.addAll(logs);

    return TerrainRow(
      y: y,
      pattern: TerrainPattern.riverWithLogs,
      tiles: tiles,
      obstacles: obstacles,
      difficulty: difficulty.patternComplexity,
    );
  }

  TerrainRow _generateMountainRow(int y, {required DifficultySettings difficulty}) {
    final tiles = <Tile>[];
    final obstacles = <Obstacle>[];

    // Generate mixed terrain with gaps
    for (int x = -(worldWidth ~/ 2); x <= (worldWidth ~/ 2); x++) {
      // Create strategic gaps for player movement
      if (_random.nextDouble() < 0.3) { // 30% chance for passable tile
        tiles.add(GrassTile(x: x, y: y));
      } else {
        tiles.add(RoadTile(x: x, y: y)); // Barrier tile
        // Add static obstacle
        obstacles.add(Car(
          x: x * GameConstants.tileSize,
          y: y * GameConstants.tileSize,
          speed: 0.0, // Static obstacle
        ));
      }
    }

    // Ensure at least one passable route
    _ensurePassableRoute(tiles, y);

    return TerrainRow(
      y: y,
      pattern: TerrainPattern.mountainBarrier,
      tiles: tiles,
      obstacles: obstacles,
      difficulty: difficulty.patternComplexity,
    );
  }



  void _ensurePassableRoute(List<Tile> tiles, int y) {
    // Find grass tiles (passable)
    final grassIndices = <int>[];
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] is GrassTile) {
        grassIndices.add(i);
      }
    }
    
    // If no grass tiles, create one in center
    if (grassIndices.isEmpty) {
      final centerIndex = tiles.length ~/ 2;
      tiles[centerIndex] = GrassTile(x: centerIndex - (worldWidth ~/ 2), y: y);
    }
  }

  // Utility methods
  List<TerrainRow> getRowsInRange(int startY, int endY) {
    return _generatedRows.where((row) => 
      row.y >= startY && row.y <= endY).toList();
  }

  void clearOldRows(int keepRowsCount) {
    if (_generatedRows.length > keepRowsCount) {
      final removeCount = _generatedRows.length - keepRowsCount;
      _generatedRows.removeRange(0, removeCount);
    }
  }

  TerrainRow? getRowAt(int y) {
    try {
      return _generatedRows.firstWhere((row) => row.y == y);
    } catch (e) {
      return null;
    }
  }

  // Reset generator state
  void reset() {
    _generatedRows.clear();
    _currentLevel = 1;
    _rowsGenerated = 0;
    _lastPattern = null;
    _currentPatternLength = 0;
  }
}