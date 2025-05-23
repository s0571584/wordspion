import 'package:uuid/uuid.dart';
import 'package:wortspion/core/constants/database_constants.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/data/sources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class GameRepositoryImpl implements GameRepository {
  final DatabaseHelper databaseHelper;
  final Uuid _uuid = const Uuid();

  GameRepositoryImpl({required this.databaseHelper});

  @override
  Future<Game> createGame({
    required int playerCount,
    required int impostorCount,
    required int roundCount,
    required int timerDuration,
    required bool impostorsKnowEachOther,
  }) async {
    final game = Game(
      id: _uuid.v4(),
      playerCount: playerCount,
      impostorCount: impostorCount,
      roundCount: roundCount,
      timerDuration: timerDuration,
      impostorsKnowEachOther: impostorsKnowEachOther,
      state: DatabaseConstants.gameStateSetup,
      currentRound: 0,
      createdAt: DateTime.now(),
    );

    final gameMap = game.toMap();
    print("GameRepositoryImpl.createGame: impostorCount in Game object = ${game.impostorCount}");
    print("GameRepositoryImpl.createGame: impostor_count in map for DB = ${gameMap['impostor_count']}");

    await databaseHelper.insert(
      DatabaseConstants.tableGames,
      gameMap,
    );

    return game;
  }

  @override
  Future<Game?> getCurrentGame() async {
    final games = await databaseHelper.query(
      DatabaseConstants.tableGames,
      where: 'state != ?',
      whereArgs: [DatabaseConstants.gameStateFinished],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (games.isEmpty) {
      return null;
    }

    return Game.fromMap(games.first);
  }

  @override
  Future<Game?> getGameById(String id) async {
    final games = await databaseHelper.query(
      DatabaseConstants.tableGames,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (games.isEmpty) {
      return null;
    }

    print("GameRepositoryImpl.getGameById: Raw map from DB for id $id = ${games.first}");

    return Game.fromMap(games.first);
  }

  @override
  Future<void> updateGameState(String id, String state) async {
    await databaseHelper.update(
      DatabaseConstants.tableGames,
      {'state': state},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateCurrentRound(String id, int currentRound) async {
    await databaseHelper.update(
      DatabaseConstants.tableGames,
      {'current_round': currentRound},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Player>> getPlayersByGameId(String gameId) async {
    final players = await databaseHelper.query(
      DatabaseConstants.tablePlayers,
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'created_at ASC',
    );

    return players.map((map) => Player.fromMap(map)).toList();
  }

  @override
  Future<Player?> getPlayerById(String id) async {
    final players = await databaseHelper.query(
      DatabaseConstants.tablePlayers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (players.isEmpty) {
      return null;
    }

    return Player.fromMap(players.first);
  }

  @override
  Future<Player> addPlayer({
    required String gameId,
    required String name,
  }) async {
    final player = Player(
      id: _uuid.v4(),
      gameId: gameId,
      name: name,
      score: 0,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await databaseHelper.insert(
      DatabaseConstants.tablePlayers,
      player.toMap(),
    );

    return player;
  }

  @override
  Future<void> updatePlayerScore(String id, int score) async {
    await databaseHelper.update(
      DatabaseConstants.tablePlayers,
      {'score': score},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteGame(String id) async {
    await databaseHelper.runTransaction((txn) async {
      // Alle mit dem Spiel verknüpften Daten löschen
      await txn.delete(
        DatabaseConstants.tablePlayers,
        where: 'game_id = ?',
        whereArgs: [id],
      );

      // Weitere verknüpfte Daten löschen (Rounds, etc.)
      // ...

      // Spiel löschen
      await txn.delete(
        DatabaseConstants.tableGames,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> updatePlayerScores(List<RoundScoreResult> scoreResults) async {
    await databaseHelper.runTransaction((txn) async {
      for (final result in scoreResults) {
        await txn.update(
          DatabaseConstants.tablePlayers,
          {'score': result.totalScore},
          where: 'id = ?',
          whereArgs: [result.playerId],
        );
      }
    });
  }

  @override
  Future<void> saveRoundResults(String gameId, int roundNumber, List<RoundScoreResult> results) async {
    final roundId = 'round_${gameId}_$roundNumber';
    final batch = await databaseHelper.database.then((db) => db.batch());

    for (final result in results) {
      batch.insert(
        DatabaseConstants.tableRoundResults,
        {
          'id': '${roundId}_${result.playerId}',
          'round_id': roundId,
          'player_id': result.playerId,
          'player_name': result.playerName,
          'score_change': result.scoreChange,
          'total_score': result.totalScore,
          'is_spy': result.isSpy ? 1 : 0,
          'reason': result.reason,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<RoundScoreResult>> getRoundResults(String gameId, int roundNumber) async {
    final roundId = 'round_${gameId}_$roundNumber';
    final results = await databaseHelper.query(
      DatabaseConstants.tableRoundResults,
      where: 'round_id = ?',
      whereArgs: [roundId],
      orderBy: 'created_at ASC',
    );

    return results.map((result) => RoundScoreResult.fromMap(result)).toList();
  }

  @override
  Future<Map<String, int>> getFinalScores(String gameId) async {
    final players = await getPlayersByGameId(gameId);
    final Map<String, int> finalScores = {};

    for (final player in players) {
      finalScores[player.id] = player.score;
    }

    return finalScores;
  }
  
  @override
  Future<Game> createGameWithCategories({
    required int playerCount,
    required int impostorCount,
    required int roundCount,
    required int timerDuration,
    required bool impostorsKnowEachOther,
    required List<String> selectedCategoryIds,
  }) async {
    // For now, we create a regular game and use the categories for word selection
    // In the future, categories could be stored in a separate table or as a JSON field
    final game = Game(
      id: _uuid.v4(),
      playerCount: playerCount,
      impostorCount: impostorCount,
      roundCount: roundCount,
      timerDuration: timerDuration,
      impostorsKnowEachOther: impostorsKnowEachOther,
      state: DatabaseConstants.gameStateSetup,
      currentRound: 0,
      createdAt: DateTime.now(),
    );

    final gameMap = game.toMap();
    print("GameRepositoryImpl.createGameWithCategories: impostorCount in Game object = ${game.impostorCount}");
    print("GameRepositoryImpl.createGameWithCategories: Selected categories = $selectedCategoryIds");

    await databaseHelper.insert(
      DatabaseConstants.tableGames,
      gameMap,
    );

    // TODO: In the future, store game-category relationships in a separate table
    // For now, the categories are used during word selection but not persisted
    
    return game;
  }
}
