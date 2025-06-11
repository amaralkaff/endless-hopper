import 'package:flutter/material.dart';
import '../entities/player.dart';
import '../../core/constants.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final double cameraOffsetX;
  final double cameraOffsetY;
  
  const PlayerWidget({
    super.key,
    required this.player,
    this.cameraOffsetX = 0.0,
    this.cameraOffsetY = 0.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: player.x - cameraOffsetX - (GameConstants.playerSize / 2),
      top: player.y - cameraOffsetY - (GameConstants.playerSize / 2),
      child: Transform.rotate(
        angle: player.rotation,
        child: Transform.scale(
          scale: player.scale,
          child: SizedBox(
            width: GameConstants.playerSize,
            height: GameConstants.playerSize,
            child: _buildPlayerSprite(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlayerSprite() {
    return AnimatedBuilder(
      animation: const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Image.asset(
          player.getCurrentAnimationAsset(),
          width: GameConstants.playerSize,
          height: GameConstants.playerSize,
          fit: BoxFit.contain,
          // Add animation effects based on player state
          color: player.animationState == PlayerAnimationState.death 
              ? Colors.red.withValues(alpha: 0.7)
              : null,
          colorBlendMode: player.animationState == PlayerAnimationState.death 
              ? BlendMode.srcIn
              : null,
        );
      },
    );
  }
}

// Alternative custom painter version for more control
class PlayerCustomPainter extends CustomPainter {
  final Player player;
  final ImageProvider? spriteImage;
  
  PlayerCustomPainter({
    required this.player,
    this.spriteImage,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    // if (false) { // Set to true for debugging
    //   final debugPaint = Paint()
    //     ..color = Colors.red.withValues(alpha: 0.3)
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2.0;
      
    //   canvas.drawRect(
    //     Rect.fromCenter(
    //       center: Offset(size.width / 2, size.height / 2),
    //       width: player.collisionBounds.width,
    //       height: player.collisionBounds.height,
    //     ),
    //     debugPaint,
    //   );
    // }
    
    // Draw player sprite or fallback shape
    if (spriteImage != null) {
      // TODO: Draw sprite image when ImageProvider is resolved
      // For now, draw a simple shape
      _drawFallbackShape(canvas, size, paint);
    } else {
      _drawFallbackShape(canvas, size, paint);
    }
  }
  
  void _drawFallbackShape(Canvas canvas, Size size, Paint paint) {
    // Draw a simple teddy bear-like shape as fallback
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // Body
    paint.color = const Color(0xFF8B4513); // Brown color
    canvas.drawCircle(center, radius, paint);
    
    // Head
    paint.color = const Color(0xFFA0522D); // Saddle brown
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.7),
      radius * 0.7,
      paint,
    );
    
    // Ears
    paint.color = const Color(0xFF654321); // Dark brown
    canvas.drawCircle(
      Offset(center.dx - radius * 0.5, center.dy - radius * 1.2),
      radius * 0.3,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.5, center.dy - radius * 1.2),
      radius * 0.3,
      paint,
    );
    
    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.8),
      radius * 0.1,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.25, center.dy - radius * 0.8),
      radius * 0.1,
      paint,
    );
    
    // Nose
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      radius * 0.08,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(PlayerCustomPainter oldDelegate) {
    return player != oldDelegate.player;
  }
}