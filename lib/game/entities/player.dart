import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/assets.dart';

enum PlayerAnimationState {
  idle,
  running,
  jumping,
  death
}

class Player {
  // Position properties
  double _x;
  double _y;
  double _targetX;
  double _targetY;
  
  // Grid position for tile-based movement
  int gridX;
  int gridY;
  
  // Animation properties
  PlayerAnimationState _animationState;
  double _animationTime;
  bool _isAnimating;
  
  // Movement properties
  bool _isHopping;
  double _hopProgress;
  double _hopStartX;
  double _hopStartY;
  double _hopTargetX;
  double _hopTargetY;
  
  // Visual properties
  double rotation;
  double scale;
  
  // Collision properties
  late Rect _collisionBounds;
  
  // Size properties
  static const double _width = 32.0;
  static const double _height = 32.0;
  
  Player({
    double x = 0.0,
    double y = 0.0,
    int initialGridX = 0,
    int initialGridY = 0,
  }) : _x = x,
       _y = y,
       _targetX = x,
       _targetY = y,
       gridX = initialGridX,
       gridY = initialGridY,
       _animationState = PlayerAnimationState.idle,
       _animationTime = 0.0,
       _isAnimating = false,
       _isHopping = false,
       _hopProgress = 0.0,
       _hopStartX = x,
       _hopStartY = y,
       _hopTargetX = x,
       _hopTargetY = y,
       rotation = 0.0,
       scale = 1.0 {
    _updateCollisionBounds();
  }
  
  // Getters
  double get x => _x;
  double get y => _y;
  double get targetX => _targetX;
  double get targetY => _targetY;
  double get width => _width;
  double get height => _height;
  PlayerAnimationState get animationState => _animationState;
  double get animationTime => _animationTime;
  bool get isAnimating => _isAnimating;
  bool get isHopping => _isHopping;
  double get hopProgress => _hopProgress;
  Rect get collisionBounds => _collisionBounds;
  
  // Core movement method
  bool hop(Direction direction) {
    if (_isHopping) return false; // Can't hop while already hopping
    
    int newGridX = gridX;
    int newGridY = gridY;
    
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
    
      // Calculate world positions
    final double newTargetX = newGridX * GameConstants.tileSize;
    final double newTargetY = newGridY * GameConstants.tileSize;
    
    // Store hop start and target positions
    _hopStartX = _x;
    _hopStartY = _y;
    _hopTargetX = newTargetX;
    _hopTargetY = newTargetY;
    
    // Update grid position
    gridX = newGridX;
    gridY = newGridY;
    
    // Update target positions
    _targetX = newTargetX;
    _targetY = newTargetY;
    
    // Start hop animation
    _startHopAnimation();
    
    return true;
  }
  
  // Hop only forward (main game mechanic)
  bool hopForward() {
    return hop(Direction.up);
  }
  
  void _startHopAnimation() {
    _isHopping = true;
    _hopProgress = 0.0;
    _animationState = PlayerAnimationState.jumping;
    _isAnimating = true;
    _animationTime = 0.0;
  }
  
  void update(double deltaTime) {
    _animationTime += deltaTime;
    
    if (_isHopping) {
      _updateHopMovement(deltaTime);
    }
    
    _updateAnimation(deltaTime);
    _updateCollisionBounds();
  }
  
  void _updateHopMovement(double deltaTime) {
    _hopProgress += deltaTime / GameConstants.hopDuration;
    
    if (_hopProgress >= 1.0) {
      // Hop completed
      _hopProgress = 1.0;
      _isHopping = false;
      _x = _hopTargetX;
      _y = _hopTargetY;
      _animationState = PlayerAnimationState.idle;
    } else {
      // Interpolate position with hop arc
      final double t = _hopProgress;
      final double easedT = _easeInOutQuad(t);
      
      // Linear interpolation for X and Y
      _x = _hopStartX + ((_hopTargetX - _hopStartX) * easedT);
      _y = _hopStartY + ((_hopTargetY - _hopStartY) * easedT);
      
      // Add hop arc (parabolic jump)
      const double hopHeight = GameConstants.tileSize * 0.3;
      final double arcProgress = sin(t * pi);
      _y -= hopHeight * arcProgress;
    }
  }
  
  void _updateAnimation(double deltaTime) {
    switch (_animationState) {
      case PlayerAnimationState.jumping:
        if (!_isHopping) {
          _animationState = PlayerAnimationState.idle;
          _isAnimating = false;
        }
        break;
      case PlayerAnimationState.running:
        // Running animation logic if needed
        break;
      case PlayerAnimationState.death:
        // Death animation logic
        break;
      case PlayerAnimationState.idle:
        // Idle animation logic
        break;
    }
  }
  
  void _updateCollisionBounds() {
    _collisionBounds = Rect.fromCenter(
      center: Offset(_x, _y),
      width: _width * 0.8, // Slightly smaller for better gameplay
      height: _height * 0.8,
    );
  }
  
  // Easing function for smooth hop movement
  double _easeInOutQuad(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }
  
  // Collision detection
  bool checkCollision(Rect other) {
    return _collisionBounds.overlaps(other);
  }
  
  // Set position directly (for initialization or teleporting)
  void setPosition(double x, double y) {
    _x = x;
    _y = y;
    _targetX = x;
    _targetY = y;
    _hopStartX = x;
    _hopStartY = y;
    _hopTargetX = x;
    _hopTargetY = y;
    _updateCollisionBounds();
  }
  
  // Set grid position and update world position
  void setGridPosition(int gridX, int gridY) {
    this.gridX = gridX;
    this.gridY = gridY;
    final double worldX = gridX * GameConstants.tileSize;
    final double worldY = gridY * GameConstants.tileSize;
    setPosition(worldX, worldY);
  }
  
  // Animation state management
  void playDeathAnimation() {
    _animationState = PlayerAnimationState.death;
    _isAnimating = true;
    _animationTime = 0.0;
  }
  
  void resetAnimation() {
    _animationState = PlayerAnimationState.idle;
    _isAnimating = false;
    _animationTime = 0.0;
  }
  
  // Get current animation asset path
  String getCurrentAnimationAsset() {
    switch (_animationState) {
      case PlayerAnimationState.jumping:
        return GameAssets.animationJump;
      case PlayerAnimationState.running:
        return GameAssets.animationRun;
      case PlayerAnimationState.death:
        return GameAssets.animationDeath;
      case PlayerAnimationState.idle:
        return GameAssets.teddyBear;
    }
  }
  
  // Reset player to initial state
  void reset() {
    gridX = 0;
    gridY = 0;
    setPosition(0.0, 0.0);
    _isHopping = false;
    _hopProgress = 0.0;
    rotation = 0.0;
    scale = 1.0;
    resetAnimation();
  }
}