import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_room.dart';
import '../models/room_player.dart';
import '../models/multiplayer_round.dart';
import '../models/game_event.dart';
import '../models/user_profile.dart';
import '../models/multiplayer_player_role.dart';
import '../models/vote.dart';
import '../models/word_guess.dart';
import '../models/word.dart';

abstract class MultiplayerGameRepository {
  Future<GameRoom> createRoom({
    required String hostId,
    required int playerCount,
    required int impostorCount,
    required int roundCount,
    required int timerDuration,
    bool impostorsKnowEachOther = false,
    List<String> selectedCategories = const ['entertainment', 'sports', 'animals', 'food'],
  });

  Future<GameRoom?> joinRoom(String roomCode, String userId, String playerName);
  Future<GameRoom?> getRoomByCode(String roomCode);
  Future<GameRoom?> getRoomById(String roomId);
  Future<GameRoom?> getRoom(String roomId);
  Future<List<RoomPlayer>> getRoomPlayers(String roomId);
  Future<void> updatePlayerReadyStatus(String playerId, bool isReady);
  Future<void> updatePlayerHeartbeat(String playerId);
  Future<void> leaveRoom(String playerId);
  
  Future<GameRoom> startGame(String roomId);
  Future<MultiplayerRound> createRound({
    required String roomId,
    required int roundNumber,
    String? mainWordId,
    String? decoyWordId,
    String? categoryId,
  });
  
  Future<void> assignPlayerRoles(String roundId, List<MultiplayerPlayerRole> roles);
  Future<void> createPlayerRole(MultiplayerPlayerRole role);
  Future<MultiplayerPlayerRole?> getPlayerRole(String roundId, String playerId);
  Future<List<MultiplayerPlayerRole>> getRoundPlayerRoles(String roundId);
  Future<void> markRoleAsViewed(String roleId);
  
  Future<void> updateRoundState(String roundId, RoundState state);
  Future<void> updateRoundPhase(String roundId, String phase);
  Future<void> submitVote(String roundId, String voterId, String targetId);
  Future<void> submitWordGuess(String roundId, String playerId, String guessedWord, bool isCorrect);
  Future<List<Vote>> getRoundVotes(String roundId);
  Future<List<WordGuess>> getRoundWordGuesses(String roundId);
  Future<Word?> getWordById(String wordId);
  Future<void> completeRound(String roundId, bool impostorsWon, Map<String, int> scores);
  Future<List<MultiplayerRound>> getGameRounds(String roomId);
  Future<void> completeGame(String roomId, Map<String, int> finalScores);
  
  Future<void> createGameEvent({
    required String roomId,
    required String eventType,
    Map<String, dynamic> eventData = const {},
    String? createdBy,
  });
  
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomId);
  Stream<GameRoom?> watchRoom(String roomId);
  Stream<List<GameEvent>> watchGameEvents(String roomId);
  Stream<MultiplayerRound?> watchCurrentRound(String roomId);
}