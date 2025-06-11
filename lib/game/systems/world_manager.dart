import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/player.dart';
import '../entities/tile.dart';
import '../entities/obstacle.dart';
import 'world_generator.dart';
import 'camera_system.dart';
import '../../core/constants.dart';

class WorldChunk {
  WorldChunk({
    required this.startY,
    required this.endY,
    required this.rows,
    required this.tiles,
    required this.obstacles,
    this.isLoaded = false,
  });

  final int startY;
  final int endY;
  final List<TerrainRow> rows;
  final List<Tile> tiles;
  final List<Obstacle> obstacles;
  bool isLoaded;

  bool containsY(int y) => y >= startY && y <= endY;
  
  int get rowCount => rows.length;
  int get tileCount => tiles.length;
  int get obstacleCount => obstacles.length;

  // Memory footprint estimation in bytes
  int get estimatedMemoryUsage {
    const tileSize = 64; // Estimated bytes per tile
    const obstacleSize = 128; // Estimated bytes per obstacle
    const rowSize = 32; // Estimated bytes per row metadata
    
    return (tileCount * tileSize) + 
           (obstacleCount * obstacleSize) + 
           (rowCount * rowSize);
  }
}

class LoadingZone {
  LoadingZone({
    required this.centerY,
    this.loadAheadDistance = 10,
    this.loadBehindDistance = 5,
  });

  final int centerY;
  final int loadAheadDistance;
  final int loadBehindDistance;

  int get minY => centerY - loadBehindDistance;
  int get maxY => centerY + loadAheadDistance;

  bool shouldLoad(int chunkY) {
    return chunkY >= minY && chunkY <= maxY;
  }

  LoadingZone updateCenter(int newCenterY) {
    return LoadingZone(
      centerY: newCenterY,
      loadAheadDistance: loadAheadDistance,
      loadBehindDistance: loadBehindDistance,
    );
  }
}

class WorldManager {
  WorldManager({
    required this.generator,
    this.chunkSize = 10,
    this.maxLoadedChunks = 5,
    this.loadAheadDistance = 15,
    this.cleanupThreshold = 20,
  }) {
    _initialize();
  }

  final WorldGenerator generator;
  final int chunkSize;
  final int maxLoadedChunks;
  final int loadAheadDistance;
  final int cleanupThreshold;

  final Map<int, WorldChunk> _loadedChunks = {};
  final List<Tile> _activeTiles = [];
  final List<Obstacle> _activeObstacles = [];
  
  LoadingZone _loadingZone = LoadingZone(centerY: 0);
  int _totalMemoryUsage = 0;
  int _chunksGenerated = 0;
  int _tilesLoaded = 0;
  int _obstaclesLoaded = 0;

  // Performance metrics
  final Map<String, int> _performanceMetrics = {
    'chunksLoaded': 0,
    'chunksUnloaded': 0,
    'tilesLoaded': 0,
    'obstaclesLoaded': 0,
    'memoryCleanups': 0,
  };

  // Getters
  List<Tile> get activeTiles => List.unmodifiable(_activeTiles);
  List<Obstacle> get activeObstacles => List.unmodifiable(_activeObstacles);
  Map<int, WorldChunk> get loadedChunks => Map.unmodifiable(_loadedChunks);
  LoadingZone get loadingZone => _loadingZone;
  int get totalMemoryUsage => _totalMemoryUsage;
  Map<String, int> get performanceMetrics => Map.unmodifiable(_performanceMetrics);

  void _initialize() {
    // Generate starting area
    final startingRows = generator.generateStartingArea();
    _createChunkFromRows(0, startingRows);
    _updateActiveElements();
  }

  // Update world based on player position
  void update(Player player, {CameraSystem? camera}) {
    final playerGridY = player.gridY;
    
    // Update loading zone
    _loadingZone = _loadingZone.updateCenter(playerGridY);
    
    // Load chunks ahead of player
    _loadRequiredChunks();
    
    // Update active obstacles (movement)
    _updateObstacles();
    
    // Cleanup old chunks
    _cleanupDistantChunks();
    
    // Update active elements based on visibility
    if (camera != null) {
      _updateActiveElementsWithCamera(camera);
    } else {
      _updateActiveElements();
    }
  }

  void _loadRequiredChunks() {
    final maxY = _loadingZone.maxY;
    final highestLoadedY = _loadedChunks.keys.isNotEmpty 
        ? _loadedChunks.keys.reduce(max) 
        : -1;
    
    // Generate chunks if needed
    while (highestLoadedY < maxY) {
      final nextChunkStartY = highestLoadedY + 1;
      _generateAndLoadChunk(nextChunkStartY);
    }
  }

  void _generateAndLoadChunk(int startY) {
    final rows = generator.generateNextChunk(chunkSize);
    final chunk = _createChunkFromRows(startY, rows);
    
    _loadedChunks[startY] = chunk;
    _chunksGenerated++;
    _performanceMetrics['chunksLoaded'] = _performanceMetrics['chunksLoaded']! + 1;
    
    // Update memory usage
    _totalMemoryUsage += chunk.estimatedMemoryUsage;
    
    debugPrint('Loaded chunk $startY-${startY + chunkSize - 1} '
          '(${chunk.tileCount} tiles, ${chunk.obstacleCount} obstacles)');
  }

  WorldChunk _createChunkFromRows(int startY, List<TerrainRow> rows) {
    final tiles = <Tile>[];
    final obstacles = <Obstacle>[];
    
    for (final row in rows) {
      tiles.addAll(row.tiles);
      obstacles.addAll(row.obstacles);
    }
    
    return WorldChunk(
      startY: startY,
      endY: startY + rows.length - 1,
      rows: rows,
      tiles: tiles,
      obstacles: obstacles,
      isLoaded: true,
    );
  }

  void _updateObstacles() {
    const deltaTime = 1.0 / 60.0; // Assume 60 FPS
    
    for (int i = 0; i < _activeObstacles.length; i++) {
      final obstacle = _activeObstacles[i];
      if (obstacle.isMoving) {
        // Update obstacle position
        final updatedObstacle = obstacle.copyWith(
          x: obstacle.x + (obstacle.speed * obstacle.direction * deltaTime),
        );
        _activeObstacles[i] = updatedObstacle;
        
        // Update in chunks as well
        _updateObstacleInChunks(obstacle, updatedObstacle);
      }
    }
  }

  void _updateObstacleInChunks(Obstacle oldObstacle, Obstacle newObstacle) {
    for (final chunk in _loadedChunks.values) {
      final index = chunk.obstacles.indexOf(oldObstacle);
      if (index != -1) {
        chunk.obstacles[index] = newObstacle;
        break;
      }
    }
  }

  void _cleanupDistantChunks() {
    if (_loadedChunks.length <= maxLoadedChunks) return;
    
    final chunksToRemove = <int>[];
    final minY = _loadingZone.minY - cleanupThreshold;
    
    for (final entry in _loadedChunks.entries) {
      final chunkStartY = entry.key;
      final chunk = entry.value;
      
      // Remove chunks that are too far behind
      if (chunk.endY < minY) {
        chunksToRemove.add(chunkStartY);
        _totalMemoryUsage -= chunk.estimatedMemoryUsage;
      }
    }
    
    // Remove chunks
    for (final chunkY in chunksToRemove) {
      final removedChunk = _loadedChunks.remove(chunkY);
      if (removedChunk != null) {
        _performanceMetrics['chunksUnloaded'] = _performanceMetrics['chunksUnloaded']! + 1;
        _performanceMetrics['memoryCleanups'] = _performanceMetrics['memoryCleanups']! + 1;
        
        debugPrint('Unloaded chunk $chunkY-${removedChunk.endY} '
              '(freed ${removedChunk.estimatedMemoryUsage} bytes)');
      }
    }
  }

  void _updateActiveElements() {
    _activeTiles.clear();
    _activeObstacles.clear();
    
    final visibleRange = _loadingZone;
    
    for (final chunk in _loadedChunks.values) {
      if (_isChunkInRange(chunk, visibleRange.minY, visibleRange.maxY)) {
        _activeTiles.addAll(chunk.tiles);
        _activeObstacles.addAll(chunk.obstacles);
      }
    }
    
    _tilesLoaded = _activeTiles.length;
    _obstaclesLoaded = _activeObstacles.length;
    _performanceMetrics['tilesLoaded'] = _tilesLoaded;
    _performanceMetrics['obstaclesLoaded'] = _obstaclesLoaded;
  }

  void _updateActiveElementsWithCamera(CameraSystem camera) {
    _activeTiles.clear();
    _activeObstacles.clear();
    
    final visibleArea = camera.getVisibleWorldArea();
    final minTileY = (visibleArea.top / GameConstants.tileSize).floor() - 1;
    final maxTileY = (visibleArea.bottom / GameConstants.tileSize).ceil() + 1;
    
    for (final chunk in _loadedChunks.values) {
      if (_isChunkInRange(chunk, minTileY, maxTileY)) {
        // Only add visible tiles and obstacles
        for (final tile in chunk.tiles) {
          final tileWorldY = tile.y * GameConstants.tileSize;
          if (tileWorldY >= visibleArea.top - 64 && 
              tileWorldY <= visibleArea.bottom + 64) {
            _activeTiles.add(tile);
          }
        }
        
        for (final obstacle in chunk.obstacles) {
          if (camera.isVisible(
            Offset(obstacle.x, obstacle.y),
            objectSize: Size(obstacle.width, obstacle.height),
          )) {
            _activeObstacles.add(obstacle);
          }
        }
      }
    }
    
    _tilesLoaded = _activeTiles.length;
    _obstaclesLoaded = _activeObstacles.length;
    _performanceMetrics['tilesLoaded'] = _tilesLoaded;
    _performanceMetrics['obstaclesLoaded'] = _obstaclesLoaded;
  }

  bool _isChunkInRange(WorldChunk chunk, int minY, int maxY) {
    return !(chunk.endY < minY || chunk.startY > maxY);
  }

  // Get tiles in specific area (for collision detection)
  List<Tile> getTilesInArea(Rect area) {
    final minGridX = (area.left / GameConstants.tileSize).floor();
    final maxGridX = (area.right / GameConstants.tileSize).ceil();
    final minGridY = (area.top / GameConstants.tileSize).floor();
    final maxGridY = (area.bottom / GameConstants.tileSize).ceil();
    
    return _activeTiles.where((tile) =>
      tile.x >= minGridX && tile.x <= maxGridX &&
      tile.y >= minGridY && tile.y <= maxGridY
    ).toList();
  }

  // Get obstacles in specific area (for collision detection)
  List<Obstacle> getObstaclesInArea(Rect area) {
    return _activeObstacles.where((obstacle) =>
      area.overlaps(obstacle.bounds)
    ).toList();
  }

  // Force load specific chunk
  void forceLoadChunk(int startY) {
    if (!_loadedChunks.containsKey(startY)) {
      _generateAndLoadChunk(startY);
      _updateActiveElements();
    }
  }

  // Memory optimization
  void optimizeMemory() {
    // Force cleanup of distant chunks
    final chunksToRemove = <int>[];
    final threshold = _loadingZone.minY - (cleanupThreshold * 2);
    
    for (final entry in _loadedChunks.entries) {
      if (entry.value.endY < threshold) {
        chunksToRemove.add(entry.key);
        _totalMemoryUsage -= entry.value.estimatedMemoryUsage;
      }
    }
    
    for (final chunkY in chunksToRemove) {
      _loadedChunks.remove(chunkY);
      _performanceMetrics['memoryCleanups'] = _performanceMetrics['memoryCleanups']! + 1;
    }
    
    debugPrint('Memory optimization: freed ${chunksToRemove.length} chunks');
  }

  // Debug and testing methods
  String getDebugInfo() {
    return '''
World Manager Debug Info:
- Loaded Chunks: ${_loadedChunks.length}
- Active Tiles: ${_activeTiles.length}
- Active Obstacles: ${_activeObstacles.length}
- Memory Usage: ${(_totalMemoryUsage / 1024).toStringAsFixed(1)} KB
- Loading Zone: ${_loadingZone.minY} to ${_loadingZone.maxY}
- Chunks Generated: $_chunksGenerated
- Performance: $performanceMetrics
''';
  }

  void testInfiniteScrolling(int iterations) {
    debugPrint('Testing infinite scrolling for $iterations iterations...');
    
    final startTime = DateTime.now();
    final startMemory = _totalMemoryUsage;
    
    // Simulate player moving forward rapidly
    for (int i = 0; i < iterations; i++) {
      final testPlayer = Player(y: i * GameConstants.tileSize);
      testPlayer.setGridPosition(0, i);
      update(testPlayer);
      
      // Log every 100 iterations
      if (i % 100 == 0) {
        debugPrint('Iteration $i: ${_loadedChunks.length} chunks, '
              '${(_totalMemoryUsage / 1024).toStringAsFixed(1)} KB');
      }
    }
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    final memoryGrowth = _totalMemoryUsage - startMemory;
    
    debugPrint('''
Infinite Scrolling Test Results:
- Duration: ${duration.inMilliseconds}ms
- Memory Growth: ${(memoryGrowth / 1024).toStringAsFixed(1)} KB
- Final Chunks: ${_loadedChunks.length}
- Performance: $performanceMetrics
''');
  }

  // Reset world manager
  void reset() {
    _loadedChunks.clear();
    _activeTiles.clear();
    _activeObstacles.clear();
    _loadingZone = LoadingZone(centerY: 0);
    _totalMemoryUsage = 0;
    _chunksGenerated = 0;
    _tilesLoaded = 0;
    _obstaclesLoaded = 0;
    _performanceMetrics.clear();
    
    generator.reset();
    _initialize();
  }
}