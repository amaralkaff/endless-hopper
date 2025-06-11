import 'package:flutter/material.dart';
import 'tile.dart';

class GrassTile extends Tile {
  const GrassTile({
    required super.x,
    required super.y,
  }) : super(type: TileType.grass);

  @override
  bool get isSafe => true;

  @override
  bool get isWalkable => true;

  @override
  bool get requiresVehicle => false;

  @override
  String get assetPath => 'assets/Package/Sprites/Game Objects/Foreground.png';

  @override
  Color get backgroundColor => const Color(0xFF4CAF50);
}