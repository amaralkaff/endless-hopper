import 'obstacle.dart';

class Car extends Obstacle {
  const Car({
    required super.x,
    required super.y,
    super.width = 64.0,
    super.height = 32.0,
    super.speed = 100.0,
    super.direction = 1,
  }) : super(type: ObstacleType.car);

  @override
  bool get isDeadly => true;

  @override
  bool get isRideable => false;

  @override
  String get assetPath => 'assets/Package/Sprites/Game Objects/Obstacle_1.png';

  @override
  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return Car(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }

  Car moveBy(double deltaTime) {
    final newX = x + (speed * direction * deltaTime);
    return copyWith(x: newX);
  }
}