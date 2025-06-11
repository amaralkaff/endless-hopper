import 'package:flutter/material.dart';
import '../entities/player.dart';
import '../entities/obstacle.dart';
import '../entities/tile.dart';
import '../entities/water_tile.dart';
import 'movement_system.dart';
import '../../core/constants.dart';

enum CollisionType {
  none,
  deadly,
  rideable,
  boundary,
  water,
  safe,
}

class CollisionResult {
  const CollisionResult({
    required this.type,
    this.obstacle,
    this.tile,
    this.position,
    this.message,
  });

  final CollisionType type;
  final Obstacle? obstacle;
  final Tile? tile;
  final Offset? position;
  final String? message;

  bool get hasCollision => type != CollisionType.none;
  bool get isDeadly => type == CollisionType.deadly;
  bool get isRideable => type == CollisionType.rideable;
  bool get isBoundary => type == CollisionType.boundary;
  bool get isWater => type == CollisionType.water;
  bool get isSafe => type == CollisionType.safe;
}

class CollisionSystem {
  static bool checkRectCollision(Rect rect1, Rect rect2) {
    return rect1.overlaps(rect2);
  }

  static Rect getPlayerBounds(Player player) {
    return Rect.fromCenter(
      center: Offset(player.x, player.y),
      width: player.width,
      height: player.height,
    );
  }

  static Rect getTileBounds(Tile tile) {
    const tileSize = GameConstants.tileSize;
    return Rect.fromLTWH(
      tile.x * tileSize,
      tile.y * tileSize,
      tileSize,
      tileSize,
    );
  }

  // Enhanced player-obstacle collision with detailed results
  static CollisionResult checkPlayerObstacleCollision(
    Player player,
    List<Obstacle> obstacles,
  ) {
    final playerBounds = getPlayerBounds(player);

    for (final obstacle in obstacles) {
      if (checkRectCollision(playerBounds, obstacle.bounds)) {
        if (obstacle.isDeadly) {
          return CollisionResult(
            type: CollisionType.deadly,
            obstacle: obstacle,
            position: Offset(obstacle.x, obstacle.y),
            message: 'Player hit deadly obstacle',
          );
        } else if (obstacle.isRideable) {
          return CollisionResult(
            type: CollisionType.rideable,
            obstacle: obstacle,
            position: Offset(obstacle.x, obstacle.y),
            message: 'Player riding obstacle',
          );
        }
      }
    }

    return const CollisionResult(type: CollisionType.none);
  }

  // Water interaction detection
  static CollisionResult checkPlayerWaterInteraction(
    Player player,
    List<Tile> tiles,
    List<Obstacle> obstacles,
  ) {
    final playerBounds = getPlayerBounds(player);
    
    // Check if player is on water tile
    for (final tile in tiles) {
      if (tile is WaterTile && isPlayerOnTile(player, tile)) {
        // Check if player is on a rideable obstacle (log) in water
        for (final obstacle in obstacles) {
          if (obstacle.isRideable && 
              checkRectCollision(playerBounds, obstacle.bounds)) {
            return CollisionResult(
              type: CollisionType.safe,
              tile: tile,
              obstacle: obstacle,
              message: 'Player safely on log',
            );
          }
        }
        
        // Player is in water without log - deadly
        return CollisionResult(
          type: CollisionType.water,
          tile: tile,
          position: Offset(tile.x.toDouble(), tile.y.toDouble()),
          message: 'Player drowned in water',
        );
      }
    }

    return const CollisionResult(type: CollisionType.none);
  }

  // Boundary collision detection
  static CollisionResult checkPlayerBoundaryCollision(
    Player player,
    MovementBoundaries boundaries,
  ) {
    if (!boundaries.isWithinBounds(player.gridX, player.gridY)) {
      return CollisionResult(
        type: CollisionType.boundary,
        position: Offset(player.x, player.y),
        message: 'Player hit boundary',
      );
    }

    return const CollisionResult(type: CollisionType.none);
  }

  // Comprehensive collision check
  static List<CollisionResult> checkAllCollisions(
    Player player,
    List<Obstacle> obstacles,
    List<Tile> tiles,
    MovementBoundaries boundaries,
  ) {
    final results = <CollisionResult>[];

    // Check boundary collisions
    final boundaryResult = checkPlayerBoundaryCollision(player, boundaries);
    if (boundaryResult.hasCollision) {
      results.add(boundaryResult);
    }

    // Check obstacle collisions
    final obstacleResult = checkPlayerObstacleCollision(player, obstacles);
    if (obstacleResult.hasCollision) {
      results.add(obstacleResult);
    }

    // Check water interactions
    final waterResult = checkPlayerWaterInteraction(player, tiles, obstacles);
    if (waterResult.hasCollision) {
      results.add(waterResult);
    }

    return results;
  }

  static bool checkPlayerTileCollision(Player player, Tile tile) {
    final playerBounds = getPlayerBounds(player);
    final tileBounds = getTileBounds(tile);
    return checkRectCollision(playerBounds, tileBounds);
  }

  static bool isPlayerOnTile(Player player, Tile tile) {
    const tileSize = GameConstants.tileSize;
    final tileX = tile.x * tileSize;
    final tileY = tile.y * tileSize;
    
    return player.x >= tileX && 
           player.x < tileX + tileSize &&
           player.y >= tileY && 
           player.y < tileY + tileSize;
  }

  // Utility methods for game logic
  static bool isPlayerSafe(
    Player player,
    List<Obstacle> obstacles,
    List<Tile> tiles,
    MovementBoundaries boundaries,
  ) {
    final collisions = checkAllCollisions(player, obstacles, tiles, boundaries);
    return collisions.every((collision) => 
      collision.type == CollisionType.safe || 
      collision.type == CollisionType.none);
  }

  static bool willPlayerDie(
    Player player,
    List<Obstacle> obstacles,
    List<Tile> tiles,
    MovementBoundaries boundaries,
  ) {
    final collisions = checkAllCollisions(player, obstacles, tiles, boundaries);
    return collisions.any((collision) => 
      collision.isDeadly || 
      collision.isWater || 
      collision.isBoundary);
  }

  // Check if a position is safe to move to
  static bool isPositionSafe(
    int gridX,
    int gridY,
    List<Obstacle> obstacles,
    List<Tile> tiles,
    MovementBoundaries boundaries,
  ) {
    // Check boundaries
    if (!boundaries.isWithinBounds(gridX, gridY)) {
      return false;
    }

    // Create temporary position for checking
    final worldX = gridX * GameConstants.tileSize;
    final worldY = gridY * GameConstants.tileSize;
    final checkBounds = Rect.fromCenter(
      center: Offset(worldX, worldY),
      width: 32.0, // Player width
      height: 32.0, // Player height
    );

    // Check for deadly obstacles
    for (final obstacle in obstacles) {
      if (obstacle.isDeadly && checkRectCollision(checkBounds, obstacle.bounds)) {
        return false;
      }
    }

    // Check water tiles (need to be on log)
    for (final tile in tiles) {
      if (tile is WaterTile && tile.x == gridX && tile.y == gridY) {
        // Check if there's a rideable obstacle at this position
        bool hasLog = false;
        for (final obstacle in obstacles) {
          if (obstacle.isRideable && 
              checkRectCollision(checkBounds, obstacle.bounds)) {
            hasLog = true;
            break;
          }
        }
        if (!hasLog) return false;
      }
    }

    return true;
  }
}