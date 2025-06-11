import 'car.dart';

enum CarType {
  small,
  medium,
  large,
  truck,
}

class CarSpecs {
  const CarSpecs({
    required this.type,
    required this.width,
    required this.height,
    required this.baseSpeed,
    required this.speedVariation,
    required this.assetPath,
    required this.spawnWeight,
  });

  final CarType type;
  final double width;
  final double height;
  final double baseSpeed;
  final double speedVariation; // ±variation range
  final String assetPath;
  final double spawnWeight; // Probability weight for spawning

  static const Map<CarType, CarSpecs> specs = {
    CarType.small: CarSpecs(
      type: CarType.small,
      width: 48.0,
      height: 24.0,
      baseSpeed: 120.0,
      speedVariation: 20.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_1.png',
      spawnWeight: 3.0, // Most common
    ),
    CarType.medium: CarSpecs(
      type: CarType.medium,
      width: 64.0,
      height: 32.0,
      baseSpeed: 100.0,
      speedVariation: 15.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_2.png',
      spawnWeight: 2.0, // Common
    ),
    CarType.large: CarSpecs(
      type: CarType.large,
      width: 80.0,
      height: 36.0,
      baseSpeed: 80.0,
      speedVariation: 10.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_3.png',
      spawnWeight: 1.5, // Less common
    ),
    CarType.truck: CarSpecs(
      type: CarType.truck,
      width: 96.0,
      height: 40.0,
      baseSpeed: 60.0,
      speedVariation: 5.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_1.png', // Reuse asset
      spawnWeight: 0.5, // Rare
    ),
  };

  static CarSpecs getSpecs(CarType type) => specs[type]!;
}

class SmallCar extends Car {
  const SmallCar({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 48.0,
    height: 24.0,
  );

  @override
  String get assetPath => CarSpecs.specs[CarType.small]!.assetPath;

  @override
  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return SmallCar(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

class MediumCar extends Car {
  const MediumCar({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 64.0,
    height: 32.0,
  );

  @override
  String get assetPath => CarSpecs.specs[CarType.medium]!.assetPath;

  @override
  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return MediumCar(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

class LargeCar extends Car {
  const LargeCar({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 80.0,
    height: 36.0,
  );

  @override
  String get assetPath => CarSpecs.specs[CarType.large]!.assetPath;

  @override
  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return LargeCar(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

class Truck extends Car {
  const Truck({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 96.0,
    height: 40.0,
  );

  @override
  String get assetPath => CarSpecs.specs[CarType.truck]!.assetPath;

  @override
  Car copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return Truck(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}