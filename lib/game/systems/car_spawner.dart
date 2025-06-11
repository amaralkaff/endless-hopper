import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../entities/car.dart';
import '../entities/car_types.dart';
import '../entities/obstacle.dart';
import '../../core/constants.dart';

class SpawnTiming {
  SpawnTiming({
    required this.minInterval,
    required this.maxInterval,
    required this.burstProbability,
    required this.burstSize,
  });

  final double minInterval; // Minimum seconds between spawns
  final double maxInterval; // Maximum seconds between spawns
  final double burstProbability; // Chance of spawning multiple cars
  final int burstSize; // Number of cars in a burst

  static SpawnTiming forDifficulty(double difficulty) {
    final normalizedDifficulty = difficulty.clamp(0.0, 1.0);
    
    return SpawnTiming(
      minInterval: 2.0 - (normalizedDifficulty * 1.5), // 2.0s -> 0.5s
      maxInterval: 4.0 - (normalizedDifficulty * 2.0), // 4.0s -> 2.0s
      burstProbability: normalizedDifficulty * 0.3, // 0% -> 30%
      burstSize: 2 + (normalizedDifficulty * 2).round(), // 2 -> 4 cars
    );
  }
}

class CarSpawner {
  CarSpawner({
    required this.worldWidth,
    this.seed,
  }) : _random = math.Random(seed);

  final int worldWidth;
  final int? seed;
  final math.Random _random;

  // Select random car type based on spawn weights
  CarType selectCarType() {
    const types = CarType.values;
    final weights = types.map((type) => CarSpecs.getSpecs(type).spawnWeight).toList();
    final totalWeight = weights.fold(0.0, (sum, weight) => sum + weight);
    
    double randomValue = _random.nextDouble() * totalWeight;
    for (int i = 0; i < types.length; i++) {
      randomValue -= weights[i];
      if (randomValue <= 0) {
        return types[i];
      }
    }
    
    return CarType.small; // Fallback
  }

  // Generate variable speed for car type
  double generateSpeed(CarType type, double difficultyMultiplier) {
    final specs = CarSpecs.getSpecs(type);
    final baseSpeed = specs.baseSpeed * difficultyMultiplier;
    final variation = specs.speedVariation;
    
    return baseSpeed + (_random.nextDouble() * 2 - 1) * variation;
  }

  // Create car instance of specific type
  Car createCar(CarType type, double x, double y, double speed, int direction) {
    switch (type) {
      case CarType.small:
        return SmallCar(x: x, y: y, speed: speed, direction: direction);
      case CarType.medium:
        return MediumCar(x: x, y: y, speed: speed, direction: direction);
      case CarType.large:
        return LargeCar(x: x, y: y, speed: speed, direction: direction);
      case CarType.truck:
        return Truck(x: x, y: y, speed: speed, direction: direction);
    }
  }

  // Check if position is safe for spawning (collision-safe)
  bool isSafeSpawnPosition(
    double x,
    double y,
    double width,
    double height,
    List<Obstacle> existingObstacles,
    {double safetyMargin = 32.0}
  ) {
    final spawnBounds = Rect.fromCenter(
      center: Offset(x, y),
      width: width + safetyMargin,
      height: height + safetyMargin,
    );

    for (final obstacle in existingObstacles) {
      if (spawnBounds.overlaps(obstacle.bounds)) {
        return false;
      }
    }

    return true;
  }

  // Generate cars for a single row with advanced spawning logic
  List<Car> generateCarsForRow({
    required int y,
    required double difficulty,
    required double densityMultiplier,
    List<Obstacle> existingObstacles = const [],
  }) {
    final cars = <Car>[];
    final worldY = y * GameConstants.tileSize;
    final direction = _random.nextBool() ? 1 : -1;
    final timing = SpawnTiming.forDifficulty(difficulty);

    // Calculate spawn positions based on timing intervals
    final startX = direction == 1 
        ? -(worldWidth ~/ 2) * GameConstants.tileSize 
        : (worldWidth ~/ 2) * GameConstants.tileSize;

    double currentX = startX.toDouble();
    int spawnAttempts = 0;
    const maxAttempts = 20; // Prevent infinite loops

    while (spawnAttempts < maxAttempts && 
           ((direction == 1 && currentX <= (worldWidth ~/ 2) * GameConstants.tileSize) ||
            (direction == -1 && currentX >= -(worldWidth ~/ 2) * GameConstants.tileSize))) {
      
      spawnAttempts++;

      // Random spawn decision based on density
      if (_random.nextDouble() > densityMultiplier) {
        currentX += direction * GameConstants.tileSize * 2;
        continue;
      }

      // Select car type and generate specs
      final carType = selectCarType();
      final specs = CarSpecs.getSpecs(carType);
      final speed = generateSpeed(carType, difficulty);

      // Check for burst spawning
      int carsToSpawn = 1;
      if (_random.nextDouble() < timing.burstProbability) {
        carsToSpawn = _random.nextInt(timing.burstSize) + 1;
      }

      // Spawn cars in burst
      for (int i = 0; i < carsToSpawn; i++) {
        final carX = currentX + (i * specs.width * 1.2 * direction);
        
        // Check bounds
        if ((direction == 1 && carX > (worldWidth ~/ 2) * GameConstants.tileSize) ||
            (direction == -1 && carX < -(worldWidth ~/ 2) * GameConstants.tileSize)) {
          break;
        }

        // Check collision safety
        if (isSafeSpawnPosition(
          carX,
          worldY,
          specs.width,
          specs.height,
          [...existingObstacles, ...cars],
        )) {
          final car = createCar(carType, carX, worldY, speed, direction);
          cars.add(car);
        }
      }

      // Move to next spawn position with random gap
      final gapSize = timing.minInterval + 
                     _random.nextDouble() * (timing.maxInterval - timing.minInterval);
      currentX += direction * GameConstants.tileSize * gapSize;
    }

    return cars;
  }

  // Generate random spawn pattern for multiple rows
  List<List<Car>> generateCarPattern({
    required int startY,
    required int rowCount,
    required double difficulty,
    List<Obstacle> existingObstacles = const [],
  }) {
    final pattern = <List<Car>>[];
    
    for (int i = 0; i < rowCount; i++) {
      final y = startY + i;
      final rowDifficulty = difficulty + (i * 0.1); // Slight increase per row
      final densityMultiplier = 0.3 + (difficulty * 0.4); // 30-70% density
      
      final cars = generateCarsForRow(
        y: y,
        difficulty: rowDifficulty,
        densityMultiplier: densityMultiplier,
        existingObstacles: existingObstacles,
      );
      
      pattern.add(cars);
    }
    
    return pattern;
  }

  // Validate spawn safety across multiple obstacles
  bool validateSpawnSafety(List<Obstacle> obstacles) {
    for (int i = 0; i < obstacles.length; i++) {
      for (int j = i + 1; j < obstacles.length; j++) {
        if (obstacles[i].bounds.overlaps(obstacles[j].bounds)) {
          return false; // Found overlapping obstacles
        }
      }
    }
    return true;
  }

  // Get spawn statistics for debugging
  Map<String, dynamic> getSpawnStats(List<Car> cars) {
    final typeCount = <CarType, int>{};
    double totalSpeed = 0;
    double minSpeed = double.infinity;
    double maxSpeed = 0;

    for (final car in cars) {
      // Determine car type by width (simple heuristic)
      CarType type = CarType.small;
      if (car.width >= CarSpecs.specs[CarType.truck]!.width) {
        type = CarType.truck;
      } else if (car.width >= CarSpecs.specs[CarType.large]!.width) {
        type = CarType.large;
      } else if (car.width >= CarSpecs.specs[CarType.medium]!.width) {
        type = CarType.medium;
      }

      typeCount[type] = (typeCount[type] ?? 0) + 1;
      totalSpeed += car.speed;
      minSpeed = math.min(minSpeed, car.speed);
      maxSpeed = math.max(maxSpeed, car.speed);
    }

    return {
      'totalCars': cars.length,
      'typeDistribution': typeCount,
      'averageSpeed': cars.isNotEmpty ? totalSpeed / cars.length : 0,
      'speedRange': {'min': minSpeed, 'max': maxSpeed},
    };
  }
}