import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ObstacleType {
  car,
  log,
  staticBarrier,
}

abstract class Obstacle extends Equatable {
  const Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    this.speed = 0.0,
    this.direction = 1,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final ObstacleType type;
  final double speed;
  final int direction; // 1 for right, -1 for left

  bool get isMoving => speed > 0;
  bool get isDeadly;
  bool get isRideable;
  String get assetPath;
  
  Rect get bounds => Rect.fromLTWH(x, y, width, height);
  
  Obstacle copyWith({double? x, double? y});

  @override
  List<Object?> get props => [x, y, width, height, type, speed, direction];
}