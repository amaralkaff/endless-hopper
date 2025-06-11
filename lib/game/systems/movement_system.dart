import 'package:flutter/material.dart';
import '../entities/player.dart';
import '../../core/constants.dart';

class MovementBoundaries {
  const MovementBoundaries({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final int minX;
  final int maxX;
  final int minY;
  final int maxY;

  bool isWithinBounds(int gridX, int gridY) {
    return gridX >= minX && 
           gridX <= maxX && 
           gridY >= minY && 
           gridY <= maxY;
  }
}

class TapToHopController {
  TapToHopController({
    required this.player,
    this.boundaries,
    this.onTap,
    this.onHopComplete,
    this.onBoundaryHit,
  });

  final Player player;
  final MovementBoundaries? boundaries;
  final VoidCallback? onTap;
  final VoidCallback? onHopComplete;
  final VoidCallback? onBoundaryHit;

  bool _wasHopping = false;

  void handleTap() {
    onTap?.call();
    
    if (player.isHopping) return;

    final int newGridY = player.gridY - 1; // Forward movement (up)
    
    // Check boundaries
    if (boundaries != null) {
      if (!boundaries!.isWithinBounds(player.gridX, newGridY)) {
        onBoundaryHit?.call();
        return;
      }
    }
    
    // Execute hop forward
    player.hopForward();
  }

  void update(double deltaTime) {
    // Check if hop just completed
    if (_wasHopping && !player.isHopping) {
      onHopComplete?.call();
    }
    _wasHopping = player.isHopping;
  }
}

class MovementSystem {
  MovementSystem({
    required this.player,
    MovementBoundaries? boundaries,
  }) : _boundaries = boundaries ?? const MovementBoundaries(
    minX: -5,
    maxX: 5,
    minY: -1000,
    maxY: 100,
  );

  final Player player;
  final MovementBoundaries _boundaries;

  bool canMove(Direction direction) {
    if (player.isHopping) return false;

    int newGridX = player.gridX;
    int newGridY = player.gridY;

    switch (direction) {
      case Direction.up:
        newGridY -= 1;
        break;
      case Direction.down:
        newGridY += 1;
        break;
      case Direction.left:
        newGridX -= 1;
        break;
      case Direction.right:
        newGridX += 1;
        break;
    }

    return _boundaries.isWithinBounds(newGridX, newGridY);
  }

  bool movePlayer(Direction direction) {
    if (!canMove(direction)) return false;
    
    return player.hop(direction);
  }

  bool moveForward() {
    // Ensure forward-only movement constraint
    return movePlayer(Direction.up);
  }

  void updateBoundaries(MovementBoundaries newBoundaries) {
    // This could be used to dynamically update boundaries based on game state
  }

  bool isAtBoundary(Direction direction) {
    int checkGridX = player.gridX;
    int checkGridY = player.gridY;

    switch (direction) {
      case Direction.up:
        checkGridY -= 1;
        break;
      case Direction.down:
        checkGridY += 1;
        break;
      case Direction.left:
        checkGridX -= 1;
        break;
      case Direction.right:
        checkGridX += 1;
        break;
    }

    return !_boundaries.isWithinBounds(checkGridX, checkGridY);
  }

  MovementBoundaries get boundaries => _boundaries;
}