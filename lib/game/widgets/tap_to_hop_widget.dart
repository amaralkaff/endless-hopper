import 'package:flutter/material.dart';
import '../systems/movement_system.dart';
import '../entities/player.dart';

class TapToHopWidget extends StatefulWidget {
  const TapToHopWidget({
    super.key,
    required this.player,
    required this.child,
    this.boundaries,
    this.onTap,
    this.onHopComplete,
    this.onBoundaryHit,
    this.enabled = true,
  });

  final Player player;
  final Widget child;
  final MovementBoundaries? boundaries;
  final VoidCallback? onTap;
  final VoidCallback? onHopComplete;
  final VoidCallback? onBoundaryHit;
  final bool enabled;

  @override
  State<TapToHopWidget> createState() => _TapToHopWidgetState();
}

class _TapToHopWidgetState extends State<TapToHopWidget>
    with TickerProviderStateMixin {
  late TapToHopController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = TapToHopController(
      player: widget.player,
      boundaries: widget.boundaries,
      onTap: widget.onTap,
      onHopComplete: widget.onHopComplete,
      onBoundaryHit: widget.onBoundaryHit,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;

    // Visual feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Handle the tap through controller
    _controller.handleTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}