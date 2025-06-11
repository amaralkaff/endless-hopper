import 'package:flutter/material.dart';
import '../entities/tile.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
  });

  final Tile tile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tile.backgroundColor,
        image: DecorationImage(
          image: AssetImage(tile.assetPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}