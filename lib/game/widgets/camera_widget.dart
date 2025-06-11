import 'package:flutter/material.dart';
import '../systems/camera_system.dart';
import '../entities/player.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({
    super.key,
    required this.cameraSystem,
    required this.player,
    required this.child,
    this.showDebugInfo = false,
  });

  final CameraSystem cameraSystem;
  final Player player;
  final Widget child;
  final bool showDebugInfo;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>
    with TickerProviderStateMixin {
  late AnimationController _updateController;

  @override
  void initState() {
    super.initState();
    
    _updateController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _updateController.addListener(_updateCamera);
    
    // Initialize camera on next frame when layout is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      widget.cameraSystem.initialize(size, widget.player);
    });
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  void _updateCamera() {
    const deltaTime = 1.0 / 60.0; // Assume 60 FPS
    widget.cameraSystem.update(deltaTime, widget.player);
    widget.cameraSystem.ensurePlayerInView(widget.player);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update viewport size if it changed
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        widget.cameraSystem.updateViewportSize(size);

        return ClipRect(
          child: Stack(
            children: [
              // Main game world with camera transform
              Transform(
                transform: widget.cameraSystem.getTransformMatrix(),
                child: widget.child,
              ),
              
              // Debug overlay
              if (widget.showDebugInfo)
                _buildDebugOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugOverlay() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Camera Debug',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pos: ${widget.cameraSystem.position.dx.toStringAsFixed(1)}, ${widget.cameraSystem.position.dy.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Target: ${widget.cameraSystem.targetPosition.dx.toStringAsFixed(1)}, ${widget.cameraSystem.targetPosition.dy.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Player: ${widget.player.x.toStringAsFixed(1)}, ${widget.player.y.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Viewport: ${widget.cameraSystem.viewportSize.width.toStringAsFixed(0)}x${widget.cameraSystem.viewportSize.height.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for positioned world objects
class WorldPositioned extends StatelessWidget {
  const WorldPositioned({
    super.key,
    required this.worldX,
    required this.worldY,
    required this.child,
    required this.cameraSystem,
    this.width,
    this.height,
  });

  final double worldX;
  final double worldY;
  final Widget child;
  final CameraSystem cameraSystem;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final screenPos = cameraSystem.worldToScreen(Offset(worldX, worldY));
    
    // Only render if visible (performance optimization)
    if (!cameraSystem.isVisible(
      Offset(worldX, worldY),
      objectSize: Size(width ?? 32, height ?? 32),
    )) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: screenPos.dx,
      top: screenPos.dy,
      child: child,
    );
  }
}

// Camera controller for external manipulation
class CameraController {
  CameraController(this._cameraSystem);

  final CameraSystem _cameraSystem;

  void centerOnPlayer(Player player) {
    _cameraSystem.centerOn(Offset(player.x, player.y));
  }

  void shake({double intensity = 10.0}) {
    _cameraSystem.shake(intensity: intensity);
  }

  void setMode(CameraMode mode) {
    // Would need to recreate camera system with new mode
    // This is a simplified interface
  }

  bool isWorldPositionVisible(Offset worldPosition) {
    return _cameraSystem.isVisible(worldPosition);
  }

  Rect getVisibleArea() {
    return _cameraSystem.getVisibleWorldArea();
  }
}