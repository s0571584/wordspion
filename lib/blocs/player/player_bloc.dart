import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/player/player_event.dart';
import 'package:wortspion/blocs/player/player_state.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/core/constants/database_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final GameRepository gameRepository;

  PlayerBloc({required this.gameRepository}) : super(PlayerInitial()) {
    on<LoadPlayers>(_onLoadPlayers);
    on<AddPlayer>(_onAddPlayer);
    on<UpdatePlayerScore>(_onUpdatePlayerScore);
    on<RemovePlayer>(_onRemovePlayer);
    on<SortPlayers>(_onSortPlayers);
    on<RegisterPlayers>(_onRegisterPlayers);
    on<ResetPlayerState>(_onResetPlayerState);
  }

  Future<void> _onLoadPlayers(
    LoadPlayers event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoading());

    try {
      final players = await gameRepository.getPlayersByGameId(event.gameId);
      emit(PlayersLoaded(players));
    } catch (e) {
      emit(PlayerError('Fehler beim Laden der Spieler: $e'));
    }
  }

  Future<void> _onAddPlayer(
    AddPlayer event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoading());

    try {
      final player = await gameRepository.addPlayer(
        gameId: event.gameId,
        name: event.name,
      );

      final allPlayers = await gameRepository.getPlayersByGameId(event.gameId);

      emit(PlayerAdded(
        player: player,
        allPlayers: allPlayers,
      ));
    } catch (e) {
      emit(PlayerError('Fehler beim Hinzufügen des Spielers: $e'));
    }
  }

  Future<void> _onUpdatePlayerScore(
    UpdatePlayerScore event,
    Emitter<PlayerState> emit,
  ) async {
    final currentState = state;
    List<Player> players = [];

    if (currentState is PlayersLoaded) {
      players = List.from(currentState.players);
    } else if (currentState is PlayerAdded) {
      players = List.from(currentState.allPlayers);
    } else if (currentState is PlayerUpdated) {
      players = List.from(currentState.allPlayers);
    } else {
      emit(PlayerLoading());
    }

    try {
      // Aktuellen Spieler finden
      final playerIndex = players.indexWhere((p) => p.id == event.playerId);
      if (playerIndex == -1) {
        emit(const PlayerError('Spieler nicht gefunden'));
        return;
      }

      final player = players[playerIndex];

      // Punkte aktualisieren
      await gameRepository.updatePlayerScore(
        event.playerId,
        player.score + event.points,
      );

      // Spielerliste aktualisieren
      final updatedPlayer = player.copyWith(score: player.score + event.points);
      players[playerIndex] = updatedPlayer;

      emit(PlayerUpdated(
        player: updatedPlayer,
        allPlayers: players,
      ));
    } catch (e) {
      emit(PlayerError('Fehler beim Aktualisieren der Punkte: $e'));
    }
  }

  Future<void> _onRemovePlayer(
    RemovePlayer event,
    Emitter<PlayerState> emit,
  ) async {
    // Diese Funktionalität ist noch nicht implementiert,
    // da sie in der aktuellen Datenbank nicht unterstützt wird
    emit(const PlayerError('Entfernen von Spielern wird noch nicht unterstützt'));
  }

  Future<void> _onSortPlayers(
    SortPlayers event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final sortedPlayers = List<Player>.from(event.players);

      switch (event.sortCriteria) {
        case 'name':
          sortedPlayers.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'score':
          sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
          break;
        case 'created':
          sortedPlayers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        default:
          sortedPlayers.sort((a, b) => a.name.compareTo(b.name));
      }

      emit(PlayersSorted(
        players: sortedPlayers,
        sortCriteria: event.sortCriteria,
      ));
    } catch (e) {
      emit(PlayerError('Fehler beim Sortieren der Spieler: $e'));
    }
  }

  Future<void> _onRegisterPlayers(
    RegisterPlayers event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoading());

    try {
      final List<Player> registeredPlayers = [];

      // Get current game if one exists
      final currentGame = await gameRepository.getCurrentGame();

      late final game;
      
      // Check if current game has selected categories (was created via category selection)
      if (currentGame != null && currentGame.selectedCategoryIds != null && currentGame.selectedCategoryIds!.isNotEmpty) {
        // 🎯 FIX: Use existing game with categories instead of creating new one
        print("PlayerBloc: Using existing game with categories: ${currentGame.selectedCategoryIds}");
        game = currentGame;
      } else {
        // If previous game exists without categories, mark it as finished
        if (currentGame != null) {
          await gameRepository.updateGameState(currentGame.id, DatabaseConstants.gameStateFinished);
        }

        // Load settings from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final impostorCount = prefs.getInt('game_impostor_count') ?? 1;
        final saboteurCount = prefs.getInt('game_saboteur_count') ?? 0; // 🆕 NEW: Load saboteur count
        final roundCount = prefs.getInt('game_round_count') ?? 3;
        final timerDuration = prefs.getInt('game_timer_duration') ?? 60;
        final impostorsKnowEachOther = prefs.getBool('game_impostors_know_each_other') ?? false;

        print("PlayerBloc: Loaded settings from SharedPreferences:");
        print("- impostorCount = $impostorCount");
        print("- saboteurCount = $saboteurCount"); // 🆕 NEW: Debug print
        print("- roundCount = $roundCount");
        print("- timerDuration = $timerDuration");
        print("- impostorsKnowEachOther = $impostorsKnowEachOther");

        // Create a new game with settings from SharedPreferences (only if no game with categories exists)
        game = await gameRepository.createGame(
          playerCount: event.players.length,
          impostorCount: impostorCount,
          saboteurCount: saboteurCount, // 🆕 NEW: Pass saboteur count
          roundCount: roundCount,
          timerDuration: timerDuration,
          impostorsKnowEachOther: impostorsKnowEachOther,
        );

        print("PlayerBloc: Created NEW game with settings from SharedPreferences");
        print("- playerCount = ${event.players.length}");
        print("- impostorCount = $impostorCount");
        print("- saboteurCount = $saboteurCount"); // 🆕 NEW: Debug print
        print("- Database game.impostorCount = ${game.impostorCount}"); // Verify it's set correctly
        print("- Database game.saboteurCount = ${game.saboteurCount}"); // 🆕 NEW: Verify saboteur count
      }

      // Register each player with the game ID
      for (final player in event.players) {
        final registeredPlayer = await gameRepository.addPlayer(
          gameId: game.id,
          name: player.name,
        );
        registeredPlayers.add(registeredPlayer);
      }

      emit(PlayersRegistered(registeredPlayers));
    } catch (e) {
      emit(PlayerError('Error registering players: $e'));
    }
  }

  int calculateImpostorCount(int playerCount) {
    // Regeln für die Anzahl der Impostoren basierend auf der Spieleranzahl
    if (playerCount <= 4) return 1;
    if (playerCount <= 6) return 2;
    return 3; // Für größere Gruppen
  }

  void _onResetPlayerState(
    ResetPlayerState event,
    Emitter<PlayerState> emit,
  ) {
    emit(PlayerInitial());
  }
}
