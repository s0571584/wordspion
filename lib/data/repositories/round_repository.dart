import 'package:uuid/uuid.dart';
import 'package:wortspion/core/constants/database_constants.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/player_role.dart';
import 'package:wortspion/data/models/round.dart';
import 'package:wortspion/data/models/round_result.dart';
import 'package:wortspion/data/models/vote.dart';
import 'package:wortspion/data/models/word_guess.dart';
import 'package:wortspion/data/sources/local/database_helper.dart';

abstract class RoundRepository {
  // Round operations
  Future<Round> createRound({
    required String gameId,
    required int roundNumber,
    required String mainWordId,
    required String categoryId,
  });

  Future<Round?> getCurrentRound(String gameId);
  Future<Round?> getRoundById(String roundId);
  Future<List<Round>> getRoundsByGameId(String gameId);
  Future<void> completeRound(String roundId);

  // Player role operations
  Future<List<PlayerRole>> assignRoles({
    required String roundId,
    required List<Player> players,
    required int impostorCount,
    int saboteurCount = 0, // 🆕 NEW: Add saboteur count parameter
  });

  Future<List<PlayerRole>> getPlayerRolesByRoundId(String roundId);
  Future<PlayerRole?> getPlayerRole(String roundId, String playerId);

  // Voting operations
  Future<Vote> createVote({
    required String roundId,
    required String voterId,
    required String targetId,
  });

  Future<List<Vote>> getVotesByRoundId(String roundId);
  Future<Map<String, int>> countVotes(String roundId);
  Future<bool> hasPlayerVoted(String roundId, String playerId);

  // Word guess operations
  Future<WordGuess> createWordGuess({
    required String roundId,
    required String playerId,
    required String guessedWord,
    required bool isCorrect,
  });

  Future<List<WordGuess>> getWordGuessesByRoundId(String roundId);

  // Round result operations
  Future<RoundResult> createRoundResult({
    required String roundId,
    required bool impostorsWon,
    required bool wordGuessed,
  });

  Future<RoundResult?> getRoundResult(String roundId);
}

class RoundRepositoryImpl implements RoundRepository {
  final DatabaseHelper databaseHelper;
  final Uuid _uuid = const Uuid();

  RoundRepositoryImpl({required this.databaseHelper});

  @override
  Future<Round> createRound({
    required String gameId,
    required int roundNumber,
    required String mainWordId,
    required String categoryId,
  }) async {
    final roundId = _uuid.v4();
    final now = DateTime.now();
    
    // Explicitly construct the map to ensure all fields are included
    final roundMap = {
      'id': roundId,
      'game_id': gameId,
      'round_number': roundNumber,
      'main_word_id': mainWordId,
      'decoy_word_id': mainWordId, // Use main word as decoy for backward compatibility
      'category_id': categoryId,
      'is_completed': 0,
      'created_at': now.millisecondsSinceEpoch,
    };
    
    print('Creating round with map: $roundMap'); // Debug logging

    await databaseHelper.insert(
      DatabaseConstants.tableRounds,
      roundMap,
    );

    // Create Round object for return
    final round = Round(
      id: roundId,
      gameId: gameId,
      roundNumber: roundNumber,
      mainWordId: mainWordId,
      decoyWordId: mainWordId,
      categoryId: categoryId,
      isCompleted: false,
      createdAt: now,
    );

    return round;
  }

  @override
  Future<Round?> getCurrentRound(String gameId) async {
    final rounds = await databaseHelper.query(
      DatabaseConstants.tableRounds,
      where: 'game_id = ? AND is_completed = ?',
      whereArgs: [gameId, 0],
      orderBy: 'round_number DESC',
      limit: 1,
    );

    if (rounds.isEmpty) {
      return null;
    }

    return Round.fromMap(rounds.first);
  }

  @override
  Future<Round?> getRoundById(String roundId) async {
    final rounds = await databaseHelper.query(
      DatabaseConstants.tableRounds,
      where: 'id = ?',
      whereArgs: [roundId],
    );

    if (rounds.isEmpty) {
      return null;
    }

    return Round.fromMap(rounds.first);
  }

  @override
  Future<List<Round>> getRoundsByGameId(String gameId) async {
    final rounds = await databaseHelper.query(
      DatabaseConstants.tableRounds,
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'round_number ASC',
    );

    return rounds.map((map) => Round.fromMap(map)).toList();
  }

  @override
  Future<void> completeRound(String roundId) async {
    await databaseHelper.update(
      DatabaseConstants.tableRounds,
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [roundId],
    );
  }

  @override
  Future<List<PlayerRole>> assignRoles({
    required String roundId,
    required List<Player> players,
    required int impostorCount,
    int saboteurCount = 0, // 🆕 NEW: Add saboteur count parameter
  }) async {
    print("RoundRepositoryImpl.assignRoles: Assigning $impostorCount impostors and $saboteurCount saboteurs among ${players.length} players");
    
    // 🆕 NEW: Validate role counts
    final totalSpecialRoles = impostorCount + saboteurCount;
    final minCivilians = 1; // At least 1 civilian required
    final maxSpecialRoles = players.length - minCivilians;
    
    if (totalSpecialRoles > maxSpecialRoles) {
      print("RoundRepositoryImpl.assignRoles: ERROR - Too many special roles requested. Total: $totalSpecialRoles, Max allowed: $maxSpecialRoles");
      throw ArgumentError('Cannot assign $totalSpecialRoles special roles with only ${players.length} players. Need at least $minCivilians civilian(s).');
    }
    
    // Assign roles in priority order: Saboteurs first, then Impostors, then Civilians
    final shuffledPlayers = List<Player>.from(players)..shuffle();
    
    // 1. Assign saboteurs first
    final saboteurs = shuffledPlayers.take(saboteurCount).toList();
    print("RoundRepositoryImpl.assignRoles: Selected ${saboteurs.length} saboteurs: ${saboteurs.map((p) => p.name).join(', ')}");
    
    // 2. Assign impostors from remaining players
    final remainingAfterSaboteurs = shuffledPlayers.skip(saboteurCount).toList();
    final impostors = remainingAfterSaboteurs.take(impostorCount).toList();
    print("RoundRepositoryImpl.assignRoles: Selected ${impostors.length} impostors: ${impostors.map((p) => p.name).join(', ')}");
    
    // 3. Remaining players are civilians
    final civilians = shuffledPlayers.skip(saboteurCount + impostorCount).toList();
    print("RoundRepositoryImpl.assignRoles: Remaining ${civilians.length} civilians: ${civilians.map((p) => p.name).join(', ')}");

    final playerRoles = <PlayerRole>[];

    await databaseHelper.runTransaction((txn) async {
      for (final player in players) {
        // Determine role type and backward-compatible isImpostor flag
        late PlayerRoleType roleType;
        late bool isImpostor;
        
        if (saboteurs.contains(player)) {
          roleType = PlayerRoleType.saboteur;
          isImpostor = false; // Saboteur is not an impostor for backward compatibility
        } else if (impostors.contains(player)) {
          roleType = PlayerRoleType.impostor;
          isImpostor = true;
        } else {
          roleType = PlayerRoleType.civilian;
          isImpostor = false;
        }
        
        final role = PlayerRole(
          id: _uuid.v4(),
          roundId: roundId,
          playerId: player.id,
          isImpostor: isImpostor,
          roleType: roleType, // 🆕 NEW: Set role type
          createdAt: DateTime.now(),
        );

        await txn.insert(
          DatabaseConstants.tablePlayerRoles,
          role.toMap(),
        );

        playerRoles.add(role);
      }
    });

    return playerRoles;
  }

  @override
  Future<List<PlayerRole>> getPlayerRolesByRoundId(String roundId) async {
    final roles = await databaseHelper.query(
      DatabaseConstants.tablePlayerRoles,
      where: 'round_id = ?',
      whereArgs: [roundId],
    );

    return roles.map((map) => PlayerRole.fromMap(map)).toList();
  }

  @override
  Future<PlayerRole?> getPlayerRole(String roundId, String playerId) async {
    final roles = await databaseHelper.query(
      DatabaseConstants.tablePlayerRoles,
      where: 'round_id = ? AND player_id = ?',
      whereArgs: [roundId, playerId],
    );

    if (roles.isEmpty) {
      return null;
    }

    return PlayerRole.fromMap(roles.first);
  }

  @override
  Future<Vote> createVote({
    required String roundId,
    required String voterId,
    required String targetId,
  }) async {
    final vote = Vote(
      id: _uuid.v4(),
      roundId: roundId,
      voterId: voterId,
      targetId: targetId,
      createdAt: DateTime.now(),
    );

    await databaseHelper.insert(
      DatabaseConstants.tableVotes,
      vote.toMap(),
    );

    return vote;
  }

  @override
  Future<List<Vote>> getVotesByRoundId(String roundId) async {
    final votes = await databaseHelper.query(
      DatabaseConstants.tableVotes,
      where: 'round_id = ?',
      whereArgs: [roundId],
    );

    return votes.map((map) => Vote.fromMap(map)).toList();
  }

  @override
  Future<Map<String, int>> countVotes(String roundId) async {
    final votes = await getVotesByRoundId(roundId);
    final voteCounts = <String, int>{};

    for (final vote in votes) {
      voteCounts[vote.targetId] = (voteCounts[vote.targetId] ?? 0) + 1;
    }

    return voteCounts;
  }

  @override
  Future<bool> hasPlayerVoted(String roundId, String playerId) async {
    final votes = await databaseHelper.query(
      DatabaseConstants.tableVotes,
      where: 'round_id = ? AND voter_id = ?',
      whereArgs: [roundId, playerId],
    );

    return votes.isNotEmpty;
  }

  @override
  Future<WordGuess> createWordGuess({
    required String roundId,
    required String playerId,
    required String guessedWord,
    required bool isCorrect,
  }) async {
    final wordGuess = WordGuess(
      id: _uuid.v4(),
      roundId: roundId,
      playerId: playerId,
      guessedWord: guessedWord,
      isCorrect: isCorrect,
      createdAt: DateTime.now(),
    );

    await databaseHelper.insert(
      DatabaseConstants.tableWordGuesses,
      wordGuess.toMap(),
    );

    return wordGuess;
  }

  @override
  Future<List<WordGuess>> getWordGuessesByRoundId(String roundId) async {
    final guesses = await databaseHelper.query(
      DatabaseConstants.tableWordGuesses,
      where: 'round_id = ?',
      whereArgs: [roundId],
    );

    return guesses.map((map) => WordGuess.fromMap(map)).toList();
  }

  @override
  Future<RoundResult> createRoundResult({
    required String roundId,
    required bool impostorsWon,
    required bool wordGuessed,
  }) async {
    final result = RoundResult(
      id: _uuid.v4(),
      roundId: roundId,
      impostorsWon: impostorsWon,
      wordGuessed: wordGuessed,
      createdAt: DateTime.now(),
    );

    await databaseHelper.insert(
      DatabaseConstants.tableRoundResults,
      result.toMap(),
    );

    return result;
  }

  @override
  Future<RoundResult?> getRoundResult(String roundId) async {
    final results = await databaseHelper.query(
      DatabaseConstants.tableRoundResults,
      where: 'round_id = ?',
      whereArgs: [roundId],
    );

    if (results.isEmpty) {
      return null;
    }

    return RoundResult.fromMap(results.first);
  }
}
