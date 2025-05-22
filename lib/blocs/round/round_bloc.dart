import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/round/round_event.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/core/services/score_calculator.dart';
import 'package:wortspion/data/models/player_role.dart';
import 'package:wortspion/data/models/round.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/data/models/word.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/data/repositories/round_repository.dart';
import 'package:wortspion/data/repositories/word_repository.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:flutter/foundation.dart';

class RoundBloc extends Bloc<RoundEvent, RoundState> {
  final GameRepository gameRepository;
  final WordRepository wordRepository;
  final RoundRepository roundRepository;
  final ScoreCalculator scoreCalculator;

  RoundBloc({
    required this.gameRepository,
    required this.wordRepository,
    required this.roundRepository,
    required this.scoreCalculator,
  }) : super(RoundInitial()) {
    on<CreateRound>(_onCreateRound);
    on<LoadRound>(_onLoadRound);
    on<AssignRoles>(_onAssignRoles);
    on<GetPlayerRole>(_onGetPlayerRole);
    on<GuessMainWord>(_onGuessMainWord);
    on<CompleteRound>(_onCompleteRound);
    on<StartRound>(_onStartRound);
  }

  Future<void> _onStartRound(
    StartRound event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());

    // DEBUG PRINT ADDED HERE
    debugPrint("RoundBloc: _onStartRound: Received event with impostorCount = ${event.impostorCount}, playerCount = ${event.playerCount}");

    try {
      // Get the current game (or by ID if provided)
      final game = await gameRepository.getGameById(event.gameId);
      if (game == null) {
        emit(const RoundError(message: 'Spiel nicht gefunden'));
        return;
      }

      print("RoundBloc: Game from DB has impostorCount = ${game.impostorCount}");

      // Get all registered players for the game
      final players = await gameRepository.getPlayersByGameId(game.id);
      if (players.isEmpty) {
        emit(const RoundError(message: 'Keine Spieler gefunden'));
        return;
      }

      late Round round;
      late Word mainWord;
      late Word decoyWord;

      // Find existing round for this game and round number
      final existingRounds = await roundRepository.getRoundsByGameId(game.id);
      final existingRound = existingRounds.where((r) => r.roundNumber == event.roundNumber).toList();

      if (existingRound.isNotEmpty) {
        // Use the existing round
        round = existingRound.first;
        mainWord = await wordRepository.getWordById(round.mainWordId);
        decoyWord = await wordRepository.getWordById(round.decoyWordId);
      } else {
        // Get default categories for word selection
        final categories = await wordRepository.getDefaultCategories();
        if (categories.isEmpty) {
          emit(const RoundError(message: 'Keine Kategorien gefunden'));
          return;
        }

        final categoryIds = categories.map((c) => c.id).toList();

        // Create a new round with random words
        mainWord = await wordRepository.selectMainWord(categoryIds, 0);
        decoyWord = await wordRepository.selectDecoyWord(mainWord.id, categoryIds);

        try {
          // Create the round
          round = await roundRepository.createRound(
            gameId: game.id,
            roundNumber: event.roundNumber,
            mainWordId: mainWord.id,
            decoyWordId: decoyWord.id,
            categoryId: mainWord.categoryId,
          );
        } catch (e) {
          // If there was a conflict, try to retrieve the existing round again
          // This is a failsafe for concurrent access or race conditions
          final retryExistingRounds = await roundRepository.getRoundsByGameId(game.id);
          final retryExistingRound = retryExistingRounds.where((r) => r.roundNumber == event.roundNumber).toList();

          if (retryExistingRound.isEmpty) {
            throw Exception('Fehler beim Erstellen oder Abrufen der Runde: $e');
          }

          round = retryExistingRound.first;
          mainWord = await wordRepository.getWordById(round.mainWordId);
          decoyWord = await wordRepository.getWordById(round.decoyWordId);
        }
      }

      // Check if roles have already been assigned for this round
      final existingRoles = await roundRepository.getPlayerRolesByRoundId(round.id);

      // DEBUG PRINT ADDED HERE
      debugPrint("RoundBloc: _onStartRound: impostorCount being passed to roundRepository.assignRoles = ${event.impostorCount}");
      print("RoundBloc: CRITICAL - Using explicitly provided impostorCount=${event.impostorCount} from event, not from game object");

      final roles = existingRoles.isNotEmpty
          ? existingRoles
          : await roundRepository.assignRoles(
              roundId: round.id,
              players: players,
              impostorCount: event.impostorCount,
            );

      // Get the category name
      final category = await wordRepository.getCategoryById(round.categoryId);

      // Create maps for player roles and words
      final Map<String, PlayerRoleType> playerRoles = {};
      final Map<String, String> playerWords = {};

      for (final role in roles) {
        // Set role type
        playerRoles[role.playerId] = role.isImpostor ? PlayerRoleType.impostor : PlayerRoleType.civilian;

        // Set word based on role
        playerWords[role.playerId] = role.isImpostor ? decoyWord.text : mainWord.text;
      }

      emit(RoundStarted(
        roundId: round.id,
        roundNumber: event.roundNumber,
        players: players,
        categoryName: category.name,
        playerRoles: playerRoles,
        playerWords: playerWords,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Starten der Runde: $e'));
    }
  }

  Future<void> _onCreateRound(
    CreateRound event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());

    try {
      // Hauptwort wählen
      final mainWord = await wordRepository.selectMainWord(
        event.categoryIds,
        event.difficulty,
      );

      // Täuschungswort wählen
      final decoyWord = await wordRepository.selectDecoyWord(
        mainWord.id,
        event.categoryIds,
      );

      // Runde erstellen
      final round = await roundRepository.createRound(
        gameId: event.gameId,
        roundNumber: event.roundNumber,
        mainWordId: mainWord.id,
        decoyWordId: decoyWord.id,
        categoryId: mainWord.categoryId,
      );

      emit(RoundCreated(
        round: round,
        mainWord: mainWord,
        decoyWord: decoyWord,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Erstellen der Runde: $e'));
    }
  }

  Future<void> _onLoadRound(
    LoadRound event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());

    try {
      final Round? round;

      if (event.roundId != null) {
        // Spezifische Runde laden
        round = await roundRepository.getRoundById(event.roundId!);
      } else {
        // Aktuelle Runde laden
        round = await roundRepository.getCurrentRound(event.gameId);
      }

      if (round == null) {
        emit(const RoundError(message: 'Keine aktive Runde gefunden'));
        return;
      }

      final mainWord = await wordRepository.getWordById(round.mainWordId);
      final decoyWord = await wordRepository.getWordById(round.decoyWordId);
      final category = await wordRepository.getCategoryById(round.categoryId);

      emit(RoundLoaded(
        round: round,
        mainWord: mainWord,
        decoyWord: decoyWord,
        categoryName: category.name,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Laden der Runde: $e'));
    }
  }

  Future<void> _onAssignRoles(
    AssignRoles event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());

    try {
      // Holen des Spiels, um zu überprüfen, ob Spione einander kennen sollen
      final game = await gameRepository.getGameById(event.players.first.gameId);
      if (game == null) {
        emit(const RoundError(message: 'Spiel nicht gefunden'));
        return;
      }

      // Zufällige Zuweisung von Rollen
      final roles = await roundRepository.assignRoles(
        roundId: event.roundId,
        players: event.players,
        impostorCount: event.impostorCount,
      );

      // Aktuelle Runde holen
      final round = await roundRepository.getCurrentRound(
        event.players.first.gameId,
      );

      if (round == null) {
        emit(const RoundError(message: 'Keine aktive Runde gefunden'));
        return;
      }

      // Hauptwort und Täuschungswort laden
      final mainWord = await wordRepository.getWordById(round.mainWordId);
      final decoyWord = await wordRepository.getWordById(round.decoyWordId);

      // Spione identifizieren, wenn sie einander kennen sollen
      List<String> impostorIds = [];
      if (game.impostorsKnowEachOther) {
        impostorIds = roles.where((role) => role.isImpostor).map((role) => role.playerId).toList();
      }

      emit(RolesAssigned(
        round: round,
        roles: roles,
        mainWord: mainWord,
        decoyWord: decoyWord,
        impostorIds: impostorIds,
        impostorsKnowEachOther: game.impostorsKnowEachOther,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Zuweisen der Rollen: $e'));
    }
  }

  Future<void> _onGetPlayerRole(
    GetPlayerRole event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());

    try {
      final role = await roundRepository.getPlayerRole(
        event.roundId,
        event.playerId,
      );

      if (role == null) {
        emit(const RoundError(message: 'Keine Rolle gefunden'));
        return;
      }

      final round = await roundRepository.getCurrentRound(
        (await gameRepository.getPlayersByGameId(event.playerId)).first.gameId,
      );

      if (round == null) {
        emit(const RoundError(message: 'Keine aktive Runde gefunden'));
        return;
      }

      // Wort basierend auf Rolle ausgeben
      final wordId = role.isImpostor ? round.decoyWordId : round.mainWordId;
      final word = await wordRepository.getWordById(wordId);

      emit(PlayerRoleLoaded(
        role: role,
        word: word,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Laden der Spielerrolle: $e'));
    }
  }

  Future<void> _onGuessMainWord(
    GuessMainWord event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());

    try {
      // Überprüfen, ob die Vermutung korrekt ist
      final isCorrect = event.guessedWord.toLowerCase().trim() == event.mainWord.toLowerCase().trim();

      // Vermutung speichern
      final wordGuess = await roundRepository.createWordGuess(
        roundId: event.roundId,
        playerId: event.playerId,
        guessedWord: event.guessedWord,
        isCorrect: isCorrect,
      );

      final round = await roundRepository.getCurrentRound(
        (await gameRepository.getPlayersByGameId(event.playerId)).first.gameId,
      );

      if (round == null) {
        emit(const RoundError(message: 'Keine aktive Runde gefunden'));
        return;
      }

      emit(WordGuessed(
        wordGuess: wordGuess,
        round: round,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Aufzeichnen der Vermutung: $e'));
    }
  }

  Future<void> _onCompleteRound(
    CompleteRound event,
    Emitter<RoundState> emit,
  ) async {
    emit(RoundLoading());
    try {
      final round = await roundRepository.getRoundById(event.roundId);
      if (round == null) {
        emit(const RoundError(message: 'Runde nicht gefunden'));
        return;
      }

      // Get game data and current round number
      final game = await gameRepository.getGameById(round.gameId);
      if (game == null) {
        emit(const RoundError(message: 'Spiel nicht gefunden'));
        return;
      }

      final allGamePlayers = await gameRepository.getPlayersByGameId(round.gameId);
      final Map<String, Player> playerMap = {for (var p in allGamePlayers) p.id: p};

      final rolesFromRepo = await roundRepository.getPlayerRolesByRoundId(event.roundId);
      final mainWord = await wordRepository.getWordById(round.mainWordId);

      final List<PlayerRoleInfo> playerRolesInfo = [];
      final List<String> spyIds = [];

      for (final role in rolesFromRepo) {
        final player = playerMap[role.playerId];
        playerRolesInfo.add(PlayerRoleInfo(
          playerId: role.playerId,
          playerName: player?.name ?? 'Unbekannter Spieler',
          roleName: role.isImpostor ? 'Spion' : 'Bürger',
          isImpostor: role.isImpostor,
        ));
        
        if (role.isImpostor) {
          spyIds.add(role.playerId);
        }
      }

      // Calculate scores based on voting results
      List<RoundScoreResult> scoreResults;
      
      if (event.skipToResults) {
        // Use SkipToResults logic (spies automatically win)
        scoreResults = scoreCalculator.calculateSkipResults(
          players: allGamePlayers,
          spies: spyIds,
        );
      } else {
        // Normal scoring logic
        scoreResults = scoreCalculator.calculateRoundScores(
          players: allGamePlayers,
          spies: spyIds,
          accusedSpies: event.accusedPlayerIds ?? [],
          wordGuessed: event.wordGuessed,
          wordGuesserId: event.wordGuesserId,
        );
      }
      
      // Update player scores in the database
      await gameRepository.updatePlayerScores(scoreResults);
      
      // Save the round results
      await gameRepository.saveRoundResults(
        round.gameId,
        round.roundNumber,
        scoreResults,
      );

      // Mark the round as completed
      await roundRepository.completeRound(event.roundId);

      emit(RoundComplete(
        roundId: event.roundId,
        playerRoles: playerRolesInfo,
        secretWord: mainWord.text,
        impostorsWon: event.impostorsWon,
        wordGuessed: event.wordGuessed,
        scoreResults: scoreResults,
        roundNumber: round.roundNumber,
        totalRounds: game.roundCount,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Abschließen der Runde: $e'));
    }
  }
}
