import 'package:flutter/material.dart';
import 'tile.dart';

class RoadTile extends Tile {
  const RoadTile({
    required super.x,
    required super.y,
  }) : super(type: TileType.road);

  @override
  bool get isSafe => false;

  @override
  bool get isWalkable => true;

  @override
  bool get requiresVehicle => false;

  @override
  String get assetPath => 'assets/Package/Sprites/Game Objects/Background.png';

  @override
  Color get backgroundColor => const Color(0xFF424242);
}