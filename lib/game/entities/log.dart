import 'obstacle.dart';

class Log extends Obstacle {
  const Log({
    required super.x,
    required super.y,
    super.width = 96.0,
    super.height = 32.0,
    super.speed = 50.0,
    super.direction = 1,
  }) : super(type: ObstacleType.log);

  @override
  bool get isDeadly => false;

  @override
  bool get isRideable => true;

  @override
  String get assetPath => 'assets/Package/Sprites/Game Objects/Obstacle_2.png';

  @override
  Log copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return Log(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }

  Log moveBy(double deltaTime) {
    final newX = x + (speed * direction * deltaTime);
    return copyWith(x: newX);
  }
}