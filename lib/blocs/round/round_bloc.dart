import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/round/round_event.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/core/services/score_calculator.dart';
import 'package:wortspion/data/models/player_role.dart';
import 'package:wortspion/data/models/round.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/data/models/word.dart';
import 'package:wortspion/data/models/category.dart' as Category;
import 'package:wortspion/data/models/spy_word_set.dart';
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

  
      // Get all registered players for the game
      final players = await gameRepository.getPlayersByGameId(game.id);
      if (players.isEmpty) {
        emit(const RoundError(message: 'Keine Spieler gefunden'));
        return;
      }

      late Round round;
      late Word mainWord;
      late SpyWordSet spyWordSet;

      // Find existing round for this game and round number
      final existingRounds = await roundRepository.getRoundsByGameId(game.id);
      final existingRound = existingRounds.where((r) => r.roundNumber == event.roundNumber).toList();

      if (existingRound.isNotEmpty) {
        // Use the existing round
        round = existingRound.first;
        mainWord = await wordRepository.getWordById(round.mainWordId);
        spyWordSet = await wordRepository.getSpyWordSet(round.mainWordId);
      } else {
        // Get selected categories from the game, fallback to default if none selected
        List<String> categoryIds;
        if (game.selectedCategoryIds != null && game.selectedCategoryIds!.isNotEmpty) {
          // Use user-selected categories
          categoryIds = game.selectedCategoryIds!;
        } else {
          // TEMPORARY FIX: For old games without selected categories, force Tiere category
          final allCategories = await wordRepository.getAllCategories();
          Category.Category? tiereCategory;

          for (final category in allCategories) {
            if (category.name.toLowerCase() == 'tiere') {
              tiereCategory = category;
              break;
            }
          }

          if (tiereCategory != null) {
            categoryIds = [tiereCategory.id];
          } else {
            // Final fallback to default categories
            final categories = await wordRepository.getDefaultCategories();
            if (categories.isEmpty) {
              emit(const RoundError(message: 'Keine Kategorien gefunden'));
              return;
            }
            categoryIds = categories.map((c) => c.id).toList();
          }
        }

        // Create a new round with random words
        mainWord = await wordRepository.selectMainWord(categoryIds, 0);

        // DEBUG: Verify the selected word is from the right category

        // Get and print the actual category name for verification
        try {
          final selectedWordCategory = await wordRepository.getCategoryById(mainWord.categoryId);
          if (selectedWordCategory.name.toLowerCase() != 'tiere') {
          } else {
          }
        } catch (e) {
        }

        try {
          spyWordSet = await wordRepository.getSpyWordSet(mainWord.id);

          // Validate the spy word set
          if (spyWordSet.spyWords.isEmpty) {
          } else {
          }
        } catch (e) {
          emit(RoundError(message: 'Fehler beim Laden der Spy-Wörter: $e'));
          return;
        }

        try {
          // Create the round
          round = await roundRepository.createRound(
            gameId: game.id,
            roundNumber: event.roundNumber,
            mainWordId: mainWord.id,
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

          try {
            spyWordSet = await wordRepository.getSpyWordSet(round.mainWordId);
          } catch (e) {
            emit(RoundError(message: 'Fehler beim Laden der Spy-Wörter: $e'));
            return;
          }
        }
      }

      // Check if roles have already been assigned for this round
      final existingRoles = await roundRepository.getPlayerRolesByRoundId(round.id);

      // DEBUG PRINT ADDED HERE
      debugPrint("RoundBloc: _onStartRound: impostorCount being passed to roundRepository.assignRoles = ${event.impostorCount}");

      final roles = existingRoles.isNotEmpty
          ? existingRoles
          : await roundRepository.assignRoles(
              roundId: round.id,
              players: players,
              impostorCount: event.impostorCount,
              saboteurCount: event.saboteurCount, // 🆕 NEW: Pass saboteur count
            );

      // Get the category name
      final category = await wordRepository.getCategoryById(round.categoryId);

      // Create maps for player roles and words
      final Map<String, PlayerRoleType> playerRoles = {};
      final Map<String, String> playerWords = {};
      final Map<String, SpyWordInfo> spyWordAssignments = {};

      // Get all spy players for smart word assignment
      final spyPlayers = roles.where((role) => role.roleType == PlayerRoleType.impostor).toList();

      // Validate spy word availability
      if (spyPlayers.isNotEmpty && spyWordSet.spyWords.isEmpty) {
        emit(const RoundError(message: 'Keine Spy-Wörter verfügbar für die zugewiesenen Spione'));
        return;
      }

      if (spyPlayers.length > spyWordSet.spyWords.length) {
      }

      // Assign different spy words to different spies
      for (int i = 0; i < spyPlayers.length; i++) {
        final spyPlayerId = spyPlayers[i].playerId;

        if (i < spyWordSet.spyWords.length) {
          // Assign unique spy word
          final spyWordInfo = spyWordSet.spyWords[i];
          playerWords[spyPlayerId] = spyWordInfo.text;
          spyWordAssignments[spyPlayerId] = spyWordInfo;
        } else {
          // If more spies than words, cycle through with priority-based selection
          final wordIndex = i % spyWordSet.spyWords.length;
          final spyWordInfo = spyWordSet.spyWords[wordIndex];
          playerWords[spyPlayerId] = spyWordInfo.text;
          spyWordAssignments[spyPlayerId] = spyWordInfo;
        }
      }

      // Assign roles and words to all players
      for (final role in roles) {
        playerRoles[role.playerId] = role.roleType;

        // Assign words based on role (skip spies as they were assigned above)
        if (role.roleType == PlayerRoleType.saboteur) {
          // Saboteurs know the main word (they want to be caught!)
          playerWords[role.playerId] = mainWord.text;
        } else if (role.roleType == PlayerRoleType.civilian) {
          // Civilians get the main word
          playerWords[role.playerId] = mainWord.text;
        }
        // Spies already assigned above with unique words
      }

      emit(RoundStarted(
        roundId: round.id,
        roundNumber: event.roundNumber,
        players: players,
        categoryName: category.name,
        playerRoles: playerRoles,
        playerWords: playerWords,
        spyWordSet: spyWordSet, // Include for debugging/admin view
        spyWordAssignments: spyWordAssignments, // Track which spy got which word
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

      // Spy word set holen
      final spyWordSet = await wordRepository.getSpyWordSet(mainWord.id);

      // Runde erstellen
      final round = await roundRepository.createRound(
        gameId: event.gameId,
        roundNumber: event.roundNumber,
        mainWordId: mainWord.id,
        categoryId: mainWord.categoryId,
      );

      emit(RoundCreated(
        round: round,
        mainWord: mainWord,
        spyWordSet: spyWordSet,
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
      final spyWordSet = await wordRepository.getSpyWordSet(round.mainWordId);
      final category = await wordRepository.getCategoryById(round.categoryId);

      emit(RoundLoaded(
        round: round,
        mainWord: mainWord,
        spyWordSet: spyWordSet,
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
        saboteurCount: event.saboteurCount, // 🆕 NEW: Pass saboteur count
      );

      // Aktuelle Runde holen
      final round = await roundRepository.getCurrentRound(
        event.players.first.gameId,
      );

      if (round == null) {
        emit(const RoundError(message: 'Keine aktive Runde gefunden'));
        return;
      }

      // Hauptwort und Spy word set laden
      final mainWord = await wordRepository.getWordById(round.mainWordId);
      final spyWordSet = await wordRepository.getSpyWordSet(round.mainWordId);

      // Spione identifizieren, wenn sie einander kennen sollen
      List<String> impostorIds = [];
      if (game.impostorsKnowEachOther) {
        impostorIds = roles.where((role) => role.isImpostor).map((role) => role.playerId).toList();
      }

      emit(RolesAssigned(
        round: round,
        roles: roles,
        mainWord: mainWord,
        spyWordSet: spyWordSet,
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
      // NOTE: This method may need updating for the new spy word system
      // For now, use the main word for all players
      final word = await wordRepository.getWordById(round.mainWordId);

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
      final List<String> saboteurIds = []; // 🆕 NEW: Now properly populated

      for (final role in rolesFromRepo) {
        final player = playerMap[role.playerId];

        // 🆕 NEW: Enhanced role name detection
        String roleName;
        if (role.roleType == PlayerRoleType.saboteur) {
          roleName = 'Saboteur';
        } else if (role.roleType == PlayerRoleType.impostor) {
          roleName = 'Spion';
        } else {
          roleName = 'Bürger';
        }

        playerRolesInfo.add(PlayerRoleInfo(
          playerId: role.playerId,
          playerName: player?.name ?? 'Unbekannter Spieler',
          roleName: roleName,
          isImpostor: role.isImpostor, // Keep for backward compatibility
        ));

        // 🆕 NEW: Properly categorize players by role
        if (role.roleType == PlayerRoleType.impostor) {
          spyIds.add(role.playerId);
        } else if (role.roleType == PlayerRoleType.saboteur) {
          saboteurIds.add(role.playerId);
        }
      }

      // Calculate scores based on voting results
      List<RoundScoreResult> scoreResults;
      bool actualImpostorsWon;

      if (event.skipToResults) {
        // Use SkipToResults logic (spies automatically win)
        scoreResults = scoreCalculator.calculateSkipResults(
          players: allGamePlayers,
          spies: spyIds,
          saboteurs: saboteurIds, // 🆕 NEW: Now properly populated with actual saboteur IDs
        );
        actualImpostorsWon = true; // Spies always win when skipping
      } else {
        // Normal scoring logic
        scoreResults = scoreCalculator.calculateRoundScores(
          players: allGamePlayers,
          spies: spyIds,
          saboteurs: saboteurIds, // 🆕 NEW: Now properly populated with actual saboteur IDs
          accusedSpies: event.accusedPlayerIds ?? [],
          wordGuessed: event.wordGuessed,
          wordGuesserId: event.wordGuesserId,
        );

        // 🚨 FIX: Calculate the actual winner based on score results instead of trusting the event
        // Team wins if they correctly identified all spies (evidenced by team members getting +2 points)
        final teamMembersWithPoints = scoreResults.where((result) => !result.isSpy && result.scoreChange > 0).length;

        final totalTeamMembers = scoreResults.where((result) => !result.isSpy).length;

        // If all team members got points, it means they correctly identified all spies
        actualImpostorsWon = !(teamMembersWithPoints == totalTeamMembers && teamMembersWithPoints > 0);

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

      // Calculate the actual round number we just completed
      // The issue is that round.roundNumber in DB might be off by 1
      // Let's calculate it based on how many rounds have been completed
      final completedRounds = await roundRepository.getRoundsByGameId(round.gameId);
      final actualRoundNumber = completedRounds.length; // This round we just completed
      
      
      emit(RoundComplete(
        roundId: event.roundId,
        playerRoles: playerRolesInfo,
        secretWord: mainWord.text,
        impostorsWon: actualImpostorsWon, // 🚨 FIX: Use calculated value instead of event value
        wordGuessed: event.wordGuessed,
        scoreResults: scoreResults,
        roundNumber: actualRoundNumber, // 🚨 FIX: Use calculated round number
        totalRounds: game.roundCount,
      ));
    } catch (e) {
      emit(RoundError(message: 'Fehler beim Abschließen der Runde: $e'));
    }
  }
}
