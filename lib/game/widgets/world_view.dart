import 'package:flutter/material.dart';
import '../entities/player.dart';
import '../systems/world_manager.dart';
import '../systems/world_generator.dart';
import '../systems/camera_system.dart';
import '../widgets/tile_widget.dart';
import '../widgets/obstacle_widget.dart';
import '../widgets/player_widget.dart';
import '../widgets/camera_widget.dart';

class WorldView extends StatefulWidget {
  const WorldView({
    super.key,
    required this.worldManager,
    required this.cameraSystem,
    required this.player,
    this.showDebugInfo = false,
    this.showPerformanceMetrics = false,
  });

  final WorldManager worldManager;
  final CameraSystem cameraSystem;
  final Player player;
  final bool showDebugInfo;
  final bool showPerformanceMetrics;

  @override
  State<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView> with TickerProviderStateMixin {
  late AnimationController _updateController;

  @override
  void initState() {
    super.initState();
    
    _updateController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _updateController.addListener(_updateWorld);
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  void _updateWorld() {
    widget.worldManager.update(widget.player, camera: widget.cameraSystem);
    widget.player.update(1.0 / 60.0); // Update player
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main game world with camera
          CameraWidget(
            cameraSystem: widget.cameraSystem,
            player: widget.player,
            showDebugInfo: widget.showDebugInfo,
            child: _buildWorld(),
          ),
          
          // Performance overlay
          if (widget.showPerformanceMetrics)
            _buildPerformanceOverlay(),
          
          // Debug controls
          if (widget.showDebugInfo)
            _buildDebugControls(),
        ],
      ),
    );
  }

  Widget _buildWorld() {
    return Stack(
      children: [
        // Background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.lightGreen.shade100,
        ),
        
        // Tiles
        ...widget.worldManager.activeTiles.map((tile) => 
          WorldPositioned(
            worldX: tile.x * 64.0,
            worldY: tile.y * 64.0,
            cameraSystem: widget.cameraSystem,
            child: TileWidget(tile: tile, size: 64.0),
          ),
        ),
        
        // Obstacles
        ...widget.worldManager.activeObstacles.map((obstacle) =>
          WorldPositioned(
            worldX: obstacle.x,
            worldY: obstacle.y,
            cameraSystem: widget.cameraSystem,
            width: obstacle.width,
            height: obstacle.height,
            child: ObstacleWidget(obstacle: obstacle),
          ),
        ),
        
        // Player
        WorldPositioned(
          worldX: widget.player.x,
          worldY: widget.player.y,
          cameraSystem: widget.cameraSystem,
          child: PlayerWidget(player: widget.player),
        ),
      ],
    );
  }

  Widget _buildPerformanceOverlay() {
    final metrics = widget.worldManager.performanceMetrics;
    
    return Positioned(
      top: 80,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chunks: ${widget.worldManager.loadedChunks.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Tiles: ${widget.worldManager.activeTiles.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Obstacles: ${widget.worldManager.activeObstacles.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Memory: ${(widget.worldManager.totalMemoryUsage / 1024).toStringAsFixed(1)} KB',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Loaded: ${metrics['chunksLoaded']}',
              style: const TextStyle(color: Colors.green, fontSize: 10),
            ),
            Text(
              'Unloaded: ${metrics['chunksUnloaded']}',
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
            Text(
              'Cleanups: ${metrics['memoryCleanups']}',
              style: const TextStyle(color: Colors.orange, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _testInfiniteScrolling,
            child: const Text('Test Infinite Scrolling'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _optimizeMemory,
            child: const Text('Optimize Memory'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _printDebugInfo,
            child: const Text('Print Debug Info'),
          ),
        ],
      ),
    );
  }

  void _testInfiniteScrolling() {
    widget.worldManager.testInfiniteScrolling(1000);
    setState(() {}); // Refresh UI
  }

  void _optimizeMemory() {
    widget.worldManager.optimizeMemory();
    setState(() {}); // Refresh UI
  }

  void _printDebugInfo() {
    debugPrint(widget.worldManager.getDebugInfo());
  }
}

// Helper extension for positioned world objects in camera view
class WorldPositioned extends StatelessWidget {
  const WorldPositioned({
    super.key,
    required this.worldX,
    required this.worldY,
    required this.cameraSystem,
    required this.child,
    this.width,
    this.height,
  });

  final double worldX;
  final double worldY;
  final CameraSystem cameraSystem;
  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // Check if object is visible before rendering (performance optimization)
    if (!cameraSystem.isVisible(
      Offset(worldX, worldY),
      objectSize: Size(width ?? 32, height ?? 32),
    )) {
      return const SizedBox.shrink();
    }

    final screenPos = cameraSystem.worldToScreen(Offset(worldX, worldY));
    
    return Positioned(
      left: screenPos.dx,
      top: screenPos.dy,
      child: child,
    );
  }
}

// Infinite scrolling test widget
class InfiniteScrollingTestWidget extends StatefulWidget {
  const InfiniteScrollingTestWidget({super.key});

  @override
  State<InfiniteScrollingTestWidget> createState() => _InfiniteScrollingTestWidgetState();
}

class _InfiniteScrollingTestWidgetState extends State<InfiniteScrollingTestWidget> {
  late WorldManager worldManager;
  late CameraSystem cameraSystem;
  late Player player;
  bool isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize systems
    final generator = WorldGenerator(seed: 12345);
    worldManager = WorldManager(generator: generator);
    cameraSystem = CameraSystem();
    player = Player();
    
    // Initialize camera with player
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      cameraSystem.initialize(size, player);
    });
  }

  void _toggleAutoScroll() {
    setState(() {
      isAutoScrolling = !isAutoScrolling;
    });
    
    if (isAutoScrolling) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() async {
    while (isAutoScrolling && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          player.hopForward();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scrolling Test'),
        actions: [
          IconButton(
            icon: Icon(isAutoScrolling ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoScroll,
          ),
        ],
      ),
      body: WorldView(
        worldManager: worldManager,
        cameraSystem: cameraSystem,
        player: player,
        showDebugInfo: true,
        showPerformanceMetrics: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            player.hopForward();
          });
        },
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
}