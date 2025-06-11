import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TileType {
  grass,
  road,
  water,
}

abstract class Tile extends Equatable {
  const Tile({
    required this.x,
    required this.y,
    required this.type,
  });

  final int x;
  final int y;
  final TileType type;

  bool get isSafe;
  bool get isWalkable;
  bool get requiresVehicle;
  String get assetPath;
  Color get backgroundColor;

  @override
  List<Object?> get props => [x, y, type];
}