import 'package:flutter/material.dart';
import 'tile.dart';

class WaterTile extends Tile {
  const WaterTile({
    required super.x,
    required super.y,
  }) : super(type: TileType.water);

  @override
  bool get isSafe => false;

  @override
  bool get isWalkable => false;

  @override
  bool get requiresVehicle => true;

  @override
  String get assetPath => 'assets/Package/Sprites/Game Objects/Background.png';

  @override
  Color get backgroundColor => const Color(0xFF2196F3);
}