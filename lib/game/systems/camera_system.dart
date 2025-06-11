import 'package:flutter/material.dart';
import '../entities/player.dart';

enum CameraMode {
  follow,
  fixed,
  smooth,
}

class CameraBoundaries {
  const CameraBoundaries({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  bool isWithinBounds(double x, double y) {
    return x >= minX && x <= maxX && y >= minY && y <= maxY;
  }

  Offset clampPosition(Offset position) {
    return Offset(
      position.dx.clamp(minX, maxX),
      position.dy.clamp(minY, maxY),
    );
  }
}

class CameraSystem {
  CameraSystem({
    this.mode = CameraMode.smooth,
    this.smoothingFactor = 0.05,
    this.followOffset = const Offset(0, 100),
    this.deadZone = const Size(100, 80),
    CameraBoundaries? boundaries,
  }) : _boundaries = boundaries ?? const CameraBoundaries(
    minX: -1000,
    maxX: 1000,
    minY: -2000,
    maxY: 500,
  );

  final CameraMode mode;
  final double smoothingFactor;
  final Offset followOffset;
  final Size deadZone;
  final CameraBoundaries _boundaries;

  Offset _position = Offset.zero;
  Offset _targetPosition = Offset.zero;
  Size _viewportSize = const Size(400, 800);

  bool _isInitialized = false;

  // Getters
  Offset get position => _position;
  Offset get targetPosition => _targetPosition;
  Size get viewportSize => _viewportSize;
  CameraBoundaries get boundaries => _boundaries;

  void initialize(Size viewportSize, Player player) {
    _viewportSize = viewportSize;
    _position = _calculateTargetPosition(player);
    _targetPosition = _position;
    _isInitialized = true;
  }

  void updateViewportSize(Size newSize) {
    _viewportSize = newSize;
  }

  void update(double deltaTime, Player player) {
    if (!_isInitialized) return;

    _targetPosition = _calculateTargetPosition(player);
    
    switch (mode) {
      case CameraMode.follow:
        _position = _targetPosition;
        break;
      case CameraMode.smooth:
        _updateSmoothFollow(deltaTime);
        break;
      case CameraMode.fixed:
        // Camera doesn't move
        break;
    }

    // Apply boundaries
    _position = _boundaries.clampPosition(_position);
  }

  Offset _calculateTargetPosition(Player player) {
    final playerWorldPos = Offset(player.x, player.y);
    final desiredCameraPos = playerWorldPos + followOffset;

    // Apply dead zone logic for smoother following
    if (mode == CameraMode.smooth) {
      final currentPlayerScreenPos = worldToScreen(playerWorldPos);
      final screenCenter = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
      final deadZoneRect = Rect.fromCenter(
        center: screenCenter,
        width: deadZone.width,
        height: deadZone.height,
      );

      if (deadZoneRect.contains(currentPlayerScreenPos)) {
        // Player is within dead zone, don't move camera
        return _targetPosition;
      }
    }

    return desiredCameraPos;
  }

  void _updateSmoothFollow(double deltaTime) {
    final difference = _targetPosition - _position;
    final smoothingAmount = smoothingFactor * deltaTime * 60; // 60 FPS normalization
    _position = _position + (difference * smoothingAmount.clamp(0.0, 1.0));
  }

  // Convert world coordinates to screen coordinates
  Offset worldToScreen(Offset worldPosition) {
    return Offset(
      worldPosition.dx - _position.dx + (_viewportSize.width / 2),
      worldPosition.dy - _position.dy + (_viewportSize.height / 2),
    );
  }

  // Convert screen coordinates to world coordinates
  Offset screenToWorld(Offset screenPosition) {
    return Offset(
      screenPosition.dx + _position.dx - (_viewportSize.width / 2),
      screenPosition.dy + _position.dy - (_viewportSize.height / 2),
    );
  }

  // Check if a world position is visible on screen
  bool isVisible(Offset worldPosition, {Size? objectSize}) {
    final screenPos = worldToScreen(worldPosition);
    final size = objectSize ?? const Size(32, 32);
    
    return screenPos.dx + size.width >= 0 &&
           screenPos.dx <= _viewportSize.width &&
           screenPos.dy + size.height >= 0 &&
           screenPos.dy <= _viewportSize.height;
  }

  // Get the visible world area
  Rect getVisibleWorldArea() {
    final topLeft = screenToWorld(Offset.zero);
    final bottomRight = screenToWorld(Offset(_viewportSize.width, _viewportSize.height));
    
    return Rect.fromPoints(topLeft, bottomRight);
  }

  // Force camera to specific position
  void setPosition(Offset position) {
    _position = _boundaries.clampPosition(position);
    _targetPosition = _position;
  }

  // Move camera by offset
  void moveBy(Offset offset) {
    setPosition(_position + offset);
  }

  // Center camera on world position
  void centerOn(Offset worldPosition) {
    setPosition(worldPosition);
  }

  // Ensure player is always in view
  void ensurePlayerInView(Player player) {
    final playerScreenPos = worldToScreen(Offset(player.x, player.y));
    const margin = 50.0; // Minimum distance from screen edge
    
    bool needsAdjustment = false;
    Offset adjustment = Offset.zero;

    // Check horizontal bounds
    if (playerScreenPos.dx < margin) {
      adjustment = adjustment.translate(playerScreenPos.dx - margin, 0);
      needsAdjustment = true;
    } else if (playerScreenPos.dx > _viewportSize.width - margin) {
      adjustment = adjustment.translate(
        playerScreenPos.dx - (_viewportSize.width - margin), 0);
      needsAdjustment = true;
    }

    // Check vertical bounds
    if (playerScreenPos.dy < margin) {
      adjustment = adjustment.translate(0, playerScreenPos.dy - margin);
      needsAdjustment = true;
    } else if (playerScreenPos.dy > _viewportSize.height - margin) {
      adjustment = adjustment.translate(0, 
        playerScreenPos.dy - (_viewportSize.height - margin));
      needsAdjustment = true;
    }

    if (needsAdjustment) {
      moveBy(-adjustment);
    }
  }

  // Create a camera transform matrix
  Matrix4 getTransformMatrix() {
    return Matrix4.identity()
      ..translate(-_position.dx + (_viewportSize.width / 2),
                  -_position.dy + (_viewportSize.height / 2));
  }

  // Shake effect for game events
  void shake({double intensity = 10.0, Duration duration = const Duration(milliseconds: 300)}) {
    // Note: This would need animation controller integration
    // For now, just apply immediate offset
    const shakeOffset = Offset(0, 0); // Placeholder for shake effect
    moveBy(shakeOffset);
  }

  // Reset camera to default state
  void reset(Player player) {
    _position = _calculateTargetPosition(player);
    _targetPosition = _position;
  }

  // Update camera boundaries (useful for different levels/areas)
  CameraSystem copyWith({
    CameraMode? mode,
    double? smoothingFactor,
    Offset? followOffset,
    Size? deadZone,
    CameraBoundaries? boundaries,
  }) {
    return CameraSystem(
      mode: mode ?? this.mode,
      smoothingFactor: smoothingFactor ?? this.smoothingFactor,
      followOffset: followOffset ?? this.followOffset,
      deadZone: deadZone ?? this.deadZone,
      boundaries: boundaries ?? _boundaries,
    );
  }
}