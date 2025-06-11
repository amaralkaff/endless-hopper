import 'log.dart';

enum LogType {
  small,
  medium,
  large,
  cluster,
}

class LogSpecs {
  const LogSpecs({
    required this.type,
    required this.width,
    required this.height,
    required this.baseSpeed,
    required this.speedVariation,
    required this.assetPath,
    required this.spawnWeight,
    required this.carryCapacity, // How many players can safely ride
  });

  final LogType type;
  final double width;
  final double height;
  final double baseSpeed;
  final double speedVariation;
  final String assetPath;
  final double spawnWeight;
  final int carryCapacity;

  static const Map<LogType, LogSpecs> specs = {
    LogType.small: LogSpecs(
      type: LogType.small,
      width: 64.0,
      height: 32.0,
      baseSpeed: 40.0,
      speedVariation: 10.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_2.png',
      spawnWeight: 2.0,
      carryCapacity: 1,
    ),
    LogType.medium: LogSpecs(
      type: LogType.medium,
      width: 96.0,
      height: 32.0,
      baseSpeed: 35.0,
      speedVariation: 8.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_2.png',
      spawnWeight: 3.0, // Most common
      carryCapacity: 2,
    ),
    LogType.large: LogSpecs(
      type: LogType.large,
      width: 128.0,
      height: 36.0,
      baseSpeed: 30.0,
      speedVariation: 5.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_2.png',
      spawnWeight: 1.5,
      carryCapacity: 3,
    ),
    LogType.cluster: LogSpecs(
      type: LogType.cluster,
      width: 160.0,
      height: 40.0,
      baseSpeed: 25.0,
      speedVariation: 3.0,
      assetPath: 'assets/Package/Sprites/Game Objects/Obstacle_2.png',
      spawnWeight: 0.5, // Rare, provides safe crossing
      carryCapacity: 4,
    ),
  };

  static LogSpecs getSpecs(LogType type) => specs[type]!;
}

class SmallLog extends Log {
  const SmallLog({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 64.0,
    height: 32.0,
  );

  @override
  String get assetPath => LogSpecs.specs[LogType.small]!.assetPath;

  @override
  Log copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return SmallLog(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

class MediumLog extends Log {
  const MediumLog({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 96.0,
    height: 32.0,
  );

  @override
  String get assetPath => LogSpecs.specs[LogType.medium]!.assetPath;

  @override
  Log copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return MediumLog(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

class LargeLog extends Log {
  const LargeLog({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 128.0,
    height: 36.0,
  );

  @override
  String get assetPath => LogSpecs.specs[LogType.large]!.assetPath;

  @override
  Log copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return LargeLog(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

class LogCluster extends Log {
  const LogCluster({
    required super.x,
    required super.y,
    required super.speed,
    super.direction = 1,
  }) : super(
    width: 160.0,
    height: 40.0,
  );

  @override
  String get assetPath => LogSpecs.specs[LogType.cluster]!.assetPath;

  @override
  Log copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? direction,
  }) {
    return LogCluster(
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}