import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants.dart';

// Game Events
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  final String gameMode;
  
  const GameStarted({this.gameMode = GameConstants.classicMode});
  
  @override
  List<Object?> get props => [gameMode];
}

class GamePaused extends GameEvent {}

class GameResumed extends GameEvent {}

class GameRestarted extends GameEvent {}

class GameEnded extends GameEvent {
  final int finalScore;
  final int rowsCrossed;
  
  const GameEnded({
    required this.finalScore,
    required this.rowsCrossed,
  });
  
  @override
  List<Object?> get props => [finalScore, rowsCrossed];
}

class PlayerMoved extends GameEvent {
  final Direction direction;
  
  const PlayerMoved(this.direction);
  
  @override
  List<Object?> get props => [direction];
}

class PlayerCollided extends GameEvent {
  final ObstacleType obstacleType;
  
  const PlayerCollided(this.obstacleType);
  
  @override
  List<Object?> get props => [obstacleType];
}

class ScoreUpdated extends GameEvent {
  final int newScore;
  final int rowsCrossed;
  
  const ScoreUpdated({
    required this.newScore,
    required this.rowsCrossed,
  });
  
  @override
  List<Object?> get props => [newScore, rowsCrossed];
}

class DifficultyIncreased extends GameEvent {
  final double newDifficulty;
  
  const DifficultyIncreased(this.newDifficulty);
  
  @override
  List<Object?> get props => [newDifficulty];
}

// Game States
abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GamePlaying extends GameState {
  final int score;
  final int rowsCrossed;
  final double difficulty;
  final String gameMode;
  final Duration elapsedTime;
  final bool isMoving;
  
  const GamePlaying({
    required this.score,
    required this.rowsCrossed,
    required this.difficulty,
    required this.gameMode,
    required this.elapsedTime,
    this.isMoving = false,
  });
  
  @override
  List<Object?> get props => [
    score,
    rowsCrossed,
    difficulty,
    gameMode,
    elapsedTime,
    isMoving,
  ];
  
  GamePlaying copyWith({
    int? score,
    int? rowsCrossed,
    double? difficulty,
    String? gameMode,
    Duration? elapsedTime,
    bool? isMoving,
  }) {
    return GamePlaying(
      score: score ?? this.score,
      rowsCrossed: rowsCrossed ?? this.rowsCrossed,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isMoving: isMoving ?? this.isMoving,
    );
  }
}

class GamePausedState extends GameState {
  final GamePlaying pausedState;
  
  const GamePausedState(this.pausedState);
  
  @override
  List<Object?> get props => [pausedState];
}

class GameOver extends GameState {
  final int finalScore;
  final int rowsCrossed;
  final Duration totalTime;
  final bool isNewHighScore;
  final String gameMode;
  
  const GameOver({
    required this.finalScore,
    required this.rowsCrossed,
    required this.totalTime,
    required this.isNewHighScore,
    required this.gameMode,
  });
  
  @override
  List<Object?> get props => [
    finalScore,
    rowsCrossed,
    totalTime,
    isNewHighScore,
    gameMode,
  ];
}

class GameError extends GameState {
  final String message;
  
  const GameError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Game BLoC
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<GamePaused>(_onGamePaused);
    on<GameResumed>(_onGameResumed);
    on<GameRestarted>(_onGameRestarted);
    on<GameEnded>(_onGameEnded);
    on<PlayerMoved>(_onPlayerMoved);
    on<PlayerCollided>(_onPlayerCollided);
    on<ScoreUpdated>(_onScoreUpdated);
    on<DifficultyIncreased>(_onDifficultyIncreased);
  }

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    emit(GameLoading());
    
    // Initialize game state
    emit(GamePlaying(
      score: 0,
      rowsCrossed: 0,
      difficulty: GameConstants.baseDifficulty,
      gameMode: event.gameMode,
      elapsedTime: Duration.zero,
    ));
  }

  void _onGamePaused(GamePaused event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      emit(GamePausedState(state as GamePlaying));
    }
  }

  void _onGameResumed(GameResumed event, Emitter<GameState> emit) {
    if (state is GamePausedState) {
      final pausedState = (state as GamePausedState).pausedState;
      emit(pausedState);
    }
  }

  void _onGameRestarted(GameRestarted event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final currentState = state as GamePlaying;
      emit(GamePlaying(
        score: 0,
        rowsCrossed: 0,
        difficulty: GameConstants.baseDifficulty,
        gameMode: currentState.gameMode,
        elapsedTime: Duration.zero,
      ));
    } else if (state is GameOver) {
      final gameOverState = state as GameOver;
      emit(GamePlaying(
        score: 0,
        rowsCrossed: 0,
        difficulty: GameConstants.baseDifficulty,
        gameMode: gameOverState.gameMode,
        elapsedTime: Duration.zero,
      ));
    }
  }

  void _onGameEnded(GameEnded event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final currentState = state as GamePlaying;
      
      // TODO: Check if it's a new high score
      const isNewHighScore = false; // Implement high score checking logic
      
      emit(GameOver(
        finalScore: event.finalScore,
        rowsCrossed: event.rowsCrossed,
        totalTime: currentState.elapsedTime,
        isNewHighScore: isNewHighScore,
        gameMode: currentState.gameMode,
      ));
    }
  }

  void _onPlayerMoved(PlayerMoved event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final currentState = state as GamePlaying;
      
      // Set moving state temporarily
      emit(currentState.copyWith(isMoving: true));
      
      // Reset moving state after animation would complete
      Future.delayed(
        Duration(milliseconds: (GameConstants.hopDuration * 1000).round()),
        () {
          if (state is GamePlaying) {
            final playingState = state as GamePlaying;
            if (playingState.isMoving) {
              emit(playingState.copyWith(isMoving: false));
            }
          }
        },
      );
    }
  }

  void _onPlayerCollided(PlayerCollided event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final currentState = state as GamePlaying;
      
      // End the game on collision
      add(GameEnded(
        finalScore: currentState.score,
        rowsCrossed: currentState.rowsCrossed,
      ));
    }
  }

  void _onScoreUpdated(ScoreUpdated event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final currentState = state as GamePlaying;
      
      emit(currentState.copyWith(
        score: event.newScore,
        rowsCrossed: event.rowsCrossed,
      ));
      
      // Check if difficulty should increase
      final newDifficulty = _calculateDifficulty(event.rowsCrossed);
      if (newDifficulty > currentState.difficulty) {
        add(DifficultyIncreased(newDifficulty));
      }
    }
  }

  void _onDifficultyIncreased(DifficultyIncreased event, Emitter<GameState> emit) {
    if (state is GamePlaying) {
      final currentState = state as GamePlaying;
      
      emit(currentState.copyWith(difficulty: event.newDifficulty));
    }
  }

  double _calculateDifficulty(int rowsCrossed) {
    final difficultyMultiplier = 
        (rowsCrossed / GameConstants.rowsPerDifficultyIncrease).floor();
    return GameConstants.baseDifficulty + 
           (difficultyMultiplier * GameConstants.difficultyIncrement);
  }
} 