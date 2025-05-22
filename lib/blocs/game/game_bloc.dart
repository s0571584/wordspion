import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/core/constants/database_constants.dart';
import 'package:wortspion/core/services/score_calculator.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;
  final ScoreCalculator scoreCalculator;

  // Store the last user settings
  int _lastImpostorCount = 1;
  int _lastRoundCount = 3;
  int _lastTimerDuration = 180;
  bool _lastImpostorsKnowEachOther = false;

  // Constants for SharedPreferences keys
  static const String _keyImpostorCount = 'game_impostor_count';
  static const String _keyRoundCount = 'game_round_count';
  static const String _keyTimerDuration = 'game_timer_duration';
  static const String _keyImpostorsKnowEachOther = 'game_impostors_know_each_other';
  
  // Print a check at startup
  static void _checkKeys() {
    print('=== Key Consistency Check ===');
    print('- In GameBloc: _keyImpostorCount = $_keyImpostorCount');
  }

  GameBloc({
    required this.gameRepository,
    required this.scoreCalculator,
  }) : super(GameInitial()) {
    on<CreateGame>(_onCreateGame);
    on<LoadGame>(_onLoadGame);
    on<StartGame>(_onStartGame);
    on<StartRound>(_onStartRound);
    on<CompleteRound>(_onCompleteRound);
    on<CompleteGame>(_onCompleteGame);
    on<DeleteGame>(_onDeleteGame);
    on<CreateGameFromGroup>(_onCreateGameFromGroup);

    // Print key check
    _checkKeys();
    
    // Load saved settings when bloc is created
    _loadSavedSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the values with explicit defaults
      final loadedImpostorCount = prefs.getInt(_keyImpostorCount);
      final loadedRoundCount = prefs.getInt(_keyRoundCount);
      final loadedTimerDuration = prefs.getInt(_keyTimerDuration);
      final loadedImpostorsKnowEachOther = prefs.getBool(_keyImpostorsKnowEachOther);
      
      // Assign values with defaults
      _lastImpostorCount = loadedImpostorCount ?? 1;
      _lastRoundCount = loadedRoundCount ?? 3;
      _lastTimerDuration = loadedTimerDuration ?? 180;
      _lastImpostorsKnowEachOther = loadedImpostorsKnowEachOther ?? false;
      
      print('=== GameBloc: _loadSavedSettings ===');
      print('Direct values from SharedPreferences:');
      print('- impostorCount (direct) = $loadedImpostorCount');
      print('- roundCount (direct) = $loadedRoundCount');
      print('- timerDuration (direct) = $loadedTimerDuration');
      print('- impostorsKnowEachOther (direct) = $loadedImpostorsKnowEachOther');
      print('');
      print('Final values with defaults applied:');
      print('- _lastImpostorCount = $_lastImpostorCount');
      print('- _lastRoundCount = $_lastRoundCount');
      print('- _lastTimerDuration = $_lastTimerDuration');
      print('- _lastImpostorsKnowEachOther = $_lastImpostorsKnowEachOther');
      
    } catch (e) {
      // If loading fails, we'll use the default values
      print('Failed to load game settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyImpostorCount, _lastImpostorCount);
      await prefs.setInt(_keyRoundCount, _lastRoundCount);
      await prefs.setInt(_keyTimerDuration, _lastTimerDuration);
      await prefs.setBool(_keyImpostorsKnowEachOther, _lastImpostorsKnowEachOther);
    } catch (e) {
      print('Failed to save game settings: $e');
    }
  }

  Future<void> _onCreateGame(
    CreateGame event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      print('_onCreateGame: Creating game with playerCount=${event.playerCount}, impostorCount=${event.impostorCount}');
      
      // Store user settings for future use
      _lastImpostorCount = event.impostorCount;
      _lastRoundCount = event.roundCount;
      _lastTimerDuration = event.timerDuration;
      _lastImpostorsKnowEachOther = event.impostorsKnowEachOther;

      // Save settings to SharedPreferences
      await _saveSettings();

      final game = await gameRepository.createGame(
        playerCount: event.playerCount,
        impostorCount: event.impostorCount,
        roundCount: event.roundCount,
        timerDuration: event.timerDuration,
        impostorsKnowEachOther: event.impostorsKnowEachOther,
      );

      emit(GameCreated(game));
    } catch (e) {
      emit(GameError('Fehler beim Erstellen des Spiels: $e'));
    }
  }

  Future<void> _onLoadGame(
    LoadGame event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      final Game? game;

      if (event.id != null) {
        game = await gameRepository.getGameById(event.id!);
      } else {
        game = await gameRepository.getCurrentGame();
      }

      if (game == null) {
        emit(GameInitial());
        return;
      }

      if (game.state == DatabaseConstants.gameStateFinished) {
        final players = await gameRepository.getPlayersByGameId(game.id);
        players.sort((a, b) => b.score.compareTo(a.score));

        final winnerNames = players.take(3).map((p) => p.name).toList();

        emit(GameCompleted(game: game, winnerNames: winnerNames));
      } else {
        emit(GameInProgress(game));
      }
    } catch (e) {
      emit(GameError('Fehler beim Laden des Spiels: $e'));
    }
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      await gameRepository.updateGameState(
        event.gameId,
        DatabaseConstants.gameStatePlaying,
      );

      await gameRepository.updateCurrentRound(
        event.gameId,
        1,
      );

      final game = await gameRepository.getGameById(event.gameId);

      if (game != null) {
        emit(GameInProgress(game));
      } else {
        emit(const GameError('Spiel nicht gefunden'));
      }
    } catch (e) {
      emit(GameError('Fehler beim Starten des Spiels: $e'));
    }
  }

  Future<void> _onStartRound(
    StartRound event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      await gameRepository.updateCurrentRound(
        event.gameId,
        event.roundNumber,
      );

      final game = await gameRepository.getGameById(event.gameId);

      if (game != null) {
        emit(GameInProgress(game));
      } else {
        emit(const GameError('Spiel nicht gefunden'));
      }
    } catch (e) {
      emit(GameError('Fehler beim Starten der Runde: $e'));
    }
  }

  Future<void> _onCompleteRound(
    CompleteRound event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      final game = await gameRepository.getGameById(event.gameId);

      if (game == null) {
        emit(const GameError('Spiel nicht gefunden'));
        return;
      }

      // Get all players with their scores
      final players = await gameRepository.getPlayersByGameId(game.id);
      
      if (event.roundNumber >= game.roundCount) {
        // Final round - determine winner and show results
        await gameRepository.updateGameState(
          event.gameId,
          DatabaseConstants.gameStateFinished,
        );

        // Sort players by score to determine winner
        players.sort((a, b) => b.score.compareTo(a.score));
        
        // Get winner details
        final Player winner = players.first;
        final Map<String, int> finalScores = await gameRepository.getFinalScores(game.id);
        
        final winnerNames = players.take(3).map((p) => p.name).toList();

        emit(GameCompleted(
          game: game.copyWith(state: DatabaseConstants.gameStateFinished),
          winnerNames: winnerNames,
        ));
      } else {
        // Intermediate round - prepare next round
        final nextRound = event.roundNumber + 1;

        await gameRepository.updateCurrentRound(
          event.gameId,
          nextRound,
        );

        final updatedGame = await gameRepository.getGameById(event.gameId);

        if (updatedGame != null) {
          emit(GameRoundCompleted(
            game: updatedGame,
            roundNumber: event.roundNumber,
          ));
        } else {
          emit(const GameError('Aktualisiertes Spiel nicht gefunden'));
        }
      }
    } catch (e) {
      emit(GameError('Fehler beim Abschließen der Runde: $e'));
    }
  }

  Future<void> _onCompleteGame(
    CompleteGame event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      await gameRepository.updateGameState(
        event.gameId,
        DatabaseConstants.gameStateFinished,
      );

      final game = await gameRepository.getGameById(event.gameId);

      if (game == null) {
        emit(const GameError('Spiel nicht gefunden'));
        return;
      }

      final players = await gameRepository.getPlayersByGameId(game.id);
      players.sort((a, b) => b.score.compareTo(a.score));

      final winnerNames = players.take(3).map((p) => p.name).toList();

      emit(GameCompleted(
        game: game.copyWith(state: DatabaseConstants.gameStateFinished),
        winnerNames: winnerNames,
      ));
    } catch (e) {
      emit(GameError('Fehler beim Abschließen des Spiels: $e'));
    }
  }

  Future<void> _onDeleteGame(
    DeleteGame event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    try {
      await gameRepository.deleteGame(event.gameId);
      emit(GameInitial());
    } catch (e) {
      emit(GameError('Fehler beim Löschen des Spiels: $e'));
    }
  }

  Future<void> _onCreateGameFromGroup(
    CreateGameFromGroup event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    try {
      final int playerCount = event.playerNames.length;

      // Make sure we have the latest saved settings
      await _loadSavedSettings();

      // Debug print to see what settings are being loaded at this point
      print('=== GameBloc: _onCreateGameFromGroup ===');
      print('Initial impostorCount from saved settings = $_lastImpostorCount, playerCount = $playerCount');

      // Get user-selected impostor count without overriding
      int impostorCount = _lastImpostorCount;
      
      // Only enforce basic validation - impostorCount can't exceed playerCount-2
      if (impostorCount > playerCount - 2) {
        print('GameBloc: Warning: Impostor count ($impostorCount) is too high for player count ($playerCount).');
        print('For a valid game, we need at least 2 non-impostors. Adjusting to ${playerCount - 2}.');
        impostorCount = playerCount - 2;
      }
      
      // Special case to ensure user's intent is honored
      if (playerCount == 5 && _lastImpostorCount == 3) {
        print('GameBloc: Special case detected - user wants 3 impostors with 5 players.');
        print('This is valid (3 impostors + 2 civilians) so we will honor this request.');
        impostorCount = 3;
      }
      
      print('GameBloc: Final impostor count to use = $impostorCount');
      
      // Create the game with user settings or defaults
      final game = await gameRepository.createGame(
        playerCount: playerCount,
        impostorCount: impostorCount,
        roundCount: _lastRoundCount,
        timerDuration: _lastTimerDuration,
        impostorsKnowEachOther: _lastImpostorsKnowEachOther,
      );

      // Add all players from the group
      for (final playerName in event.playerNames) {
        await gameRepository.addPlayer(gameId: game.id, name: playerName);
      }

      // Update game state to ready for play
      await gameRepository.updateGameState(
        game.id,
        DatabaseConstants.gameStateSetup,
      );

      // Update current round to 1 to prepare for game start
      await gameRepository.updateCurrentRound(
        game.id,
        1,
      );

      // Get the updated game object
      final updatedGame = await gameRepository.getGameById(game.id);
      if (updatedGame == null) {
        emit(const GameError('Spiel konnte nicht korrekt erstellt werden'));
        return;
      }

      print('GameBloc: Game created and updated successfully. Final impostor count = ${updatedGame.impostorCount}');
      emit(GameCreated(updatedGame));
    } catch (e) {
      emit(GameError('Fehler beim Erstellen des Spiels aus Gruppe: ${e.toString()}'));
    }
  }
}
