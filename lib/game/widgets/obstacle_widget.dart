import 'package:flutter/material.dart';
import '../entities/obstacle.dart';

class ObstacleWidget extends StatelessWidget {
  const ObstacleWidget({
    super.key,
    required this.obstacle,
  });

  final Obstacle obstacle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: obstacle.x,
      top: obstacle.y,
      child: Container(
        width: obstacle.width,
        height: obstacle.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(obstacle.assetPath),
            fit: BoxFit.contain,
          ),
        ),
        child: obstacle.isMoving 
          ? _buildMovementIndicator() 
          : null,
      ),
    );
  }

  Widget _buildMovementIndicator() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: obstacle.isDeadly 
            ? Colors.red.withOpacity(0.3)
            : Colors.blue.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}