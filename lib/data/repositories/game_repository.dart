import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/core/constants/database_constants.dart';

abstract class GameRepository {
  Future<Game> createGame({
    required int playerCount,
    required int impostorCount,
    int saboteurCount = 0, // 🆕 NEW: Add saboteur count parameter
    required int roundCount,
    required int timerDuration,
    required bool impostorsKnowEachOther,
  });

  Future<Game?> getCurrentGame();

  Future<Game?> getGameById(String id);

  Future<void> updateGameState(String id, String state);

  Future<void> updateCurrentRound(String id, int currentRound);

  Future<List<Player>> getPlayersByGameId(String gameId);

  Future<Player?> getPlayerById(String id);

  Future<Player> addPlayer({
    required String gameId,
    required String name,
  });

  Future<void> updatePlayerScore(String id, int score);

  Future<void> deleteGame(String id);
  
  Future<Game> createGameWithCategories({
    required int playerCount,
    required int impostorCount,
    int saboteurCount = 0, // 🆕 NEW: Add saboteur count parameter
    required int roundCount,
    required int timerDuration,
    required bool impostorsKnowEachOther,
    required List<String> selectedCategoryIds,
  });
  
  Future<void> updatePlayerScores(List<RoundScoreResult> scoreResults);
  
  Future<void> saveRoundResults(String gameId, int roundNumber, List<RoundScoreResult> results);
  
  Future<List<RoundScoreResult>> getRoundResults(String gameId, int roundNumber);
  
  Future<Map<String, int>> getFinalScores(String gameId);
}
