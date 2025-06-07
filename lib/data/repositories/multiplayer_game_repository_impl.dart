import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';
import '../models/game_room.dart';
import '../models/room_player.dart';
import '../models/multiplayer_round.dart';
import '../models/game_event.dart';
import '../models/user_profile.dart';
import '../models/multiplayer_player_role.dart';
import '../models/vote.dart';
import '../models/word_guess.dart';
import '../models/word.dart';
import 'multiplayer_game_repository.dart';

class MultiplayerGameRepositoryImpl implements MultiplayerGameRepository {
  final supabase.SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  MultiplayerGameRepositoryImpl(this._client);

  @override
  Future<GameRoom> createRoom({
    required String hostId,
    required int playerCount,
    required int impostorCount,
    required int roundCount,
    required int timerDuration,
    bool impostorsKnowEachOther = false,
    List<String> selectedCategories = const ['entertainment', 'sports', 'animals', 'food'],
  }) async {
    print('DEBUG: Creating room with hostId: $hostId');
    
    // Validate that the host profile exists
    print('DEBUG: Checking if host profile exists...');
    final hostProfile = await _client
        .from('user_profiles')
        .select('id, username')
        .eq('id', hostId)
        .maybeSingle();
    
    print('DEBUG: Host profile result: $hostProfile');
    
    if (hostProfile == null) {
      print('DEBUG: Host profile not found');
      throw Exception('User profile not found. Please complete your profile setup before creating a room.');
    }
    
    print('DEBUG: Generating room code...');
    final roomCode = await _generateRoomCode();
    print('DEBUG: Generated room code: $roomCode');
    
    final now = DateTime.now();
    
    final roomData = {
      'room_code': roomCode,
      'host_id': hostId,
      'player_count': playerCount,
      'impostor_count': impostorCount,
      'round_count': roundCount,
      'timer_duration': timerDuration,
      'impostors_know_each_other': impostorsKnowEachOther,
      'selected_categories': selectedCategories,
      'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
    };

    print('DEBUG: Room data to insert: $roomData');

    try {
      final response = await _client
          .from('game_rooms')
          .insert(roomData)
          .select()
          .single();

      print('DEBUG: Room created successfully: $response');
      return GameRoom.fromJson(response);
    } catch (e) {
      print('DEBUG: Error creating room: $e');
      rethrow;
    }
  }

  @override
  Future<GameRoom?> joinRoom(String roomCode, String userId, String playerName) async {
    // First, get the room
    final room = await getRoomByCode(roomCode);
    if (room == null || !room.isActive || room.isExpired) {
      throw Exception('Room not found or expired');
    }

    // Check if room is full
    final players = await getRoomPlayers(room.id);
    if (players.length >= room.playerCount) {
      throw Exception('Room is full');
    }

    // Check if user is already in the room
    final existingPlayer = players.where((p) => p.userId == userId).firstOrNull;
    if (existingPlayer != null) {
      return room; // User already in room
    }

    // Add player to room
    final playerData = {
      'room_id': room.id,
      'user_id': userId,
      'player_name': playerName,
      'player_order': players.length + 1,
    };

    await _client.from('room_players').insert(playerData);

    // Create join event
    await createGameEvent(
      roomId: room.id,
      eventType: GameEventTypes.playerJoined,
      eventData: {'player_name': playerName},
      createdBy: userId,
    );

    return room;
  }

  @override
  Future<GameRoom?> getRoomByCode(String roomCode) async {
    try {
      final response = await _client
          .from('game_rooms')
          .select()
          .eq('room_code', roomCode)
          .eq('is_active', true)
          .single();

      return GameRoom.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<GameRoom?> getRoomById(String roomId) async {
    try {
      final response = await _client
          .from('game_rooms')
          .select()
          .eq('id', roomId)
          .single();

      return GameRoom.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<RoomPlayer>> getRoomPlayers(String roomId) async {
    print('DEBUG: Getting room players for room: $roomId');
    try {
      final response = await _client
          .from('room_players')
          .select()
          .eq('room_id', roomId)
          .order('player_order');

      print('DEBUG: Room players response: $response');
      final players = response.map((json) => RoomPlayer.fromJson(json)).toList();
      print('DEBUG: Parsed ${players.length} players');
      return players;
    } catch (e) {
      print('DEBUG: Error getting room players: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePlayerReadyStatus(String playerId, bool isReady) async {
    await _client
        .from('room_players')
        .update({'is_ready': isReady})
        .eq('id', playerId);
  }

  @override
  Future<void> updatePlayerHeartbeat(String playerId) async {
    await _client
        .from('room_players')
        .update({'last_heartbeat': DateTime.now().toIso8601String()})
        .eq('id', playerId);
  }

  @override
  Future<void> leaveRoom(String playerId) async {
    await _client
        .from('room_players')
        .update({
          'is_connected': false,
          'left_at': DateTime.now().toIso8601String(),
        })
        .eq('id', playerId);
  }

  @override
  Future<GameRoom> startGame(String roomId) async {
    final response = await _client
        .from('game_rooms')
        .update({
          'game_state': 'playing',
          'started_at': DateTime.now().toIso8601String(),
        })
        .eq('id', roomId)
        .select()
        .single();

    return GameRoom.fromJson(response);
  }

  @override
  Future<MultiplayerRound> createRound({
    required String roomId,
    required int roundNumber,
    String? mainWordId,
    String? decoyWordId,
    String? categoryId,
  }) async {
    final roundData = <String, dynamic>{
      'room_id': roomId,
      'round_number': roundNumber,
    };
    
    if (mainWordId != null) roundData['main_word_id'] = mainWordId;
    if (decoyWordId != null) roundData['decoy_word_id'] = decoyWordId;
    if (categoryId != null) roundData['category_id'] = categoryId;

    final response = await _client
        .from('rounds')
        .insert(roundData)
        .select()
        .single();

    return MultiplayerRound.fromJson(response);
  }

  @override
  Future<void> assignPlayerRoles(String roundId, List<MultiplayerPlayerRole> roles) async {
    final roleData = roles.map((role) => {
      'round_id': roundId,
      'player_id': role.playerId,
      'is_impostor': role.isImpostor,
      'assigned_word_id': role.assignedWordId,
    }).toList();

    await _client.from('player_roles').insert(roleData);
  }

  @override
  Future<MultiplayerPlayerRole?> getPlayerRole(String roundId, String playerId) async {
    try {
      final response = await _client
          .from('player_roles')
          .select()
          .eq('round_id', roundId)
          .eq('player_id', playerId)
          .single();

      return MultiplayerPlayerRole.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markRoleAsViewed(String roleId) async {
    await _client
        .from('player_roles')
        .update({'role_viewed_at': DateTime.now().toIso8601String()})
        .eq('id', roleId);
  }

  @override
  Future<void> updateRoundState(String roundId, RoundState state) async {
    final updates = <String, dynamic>{'round_state': _roundStateToString(state)};
    
    switch (state) {
      case RoundState.discussion:
        updates['discussion_started_at'] = DateTime.now().toIso8601String();
        break;
      case RoundState.voting:
        updates['voting_started_at'] = DateTime.now().toIso8601String();
        break;
      case RoundState.completed:
        updates['completed_at'] = DateTime.now().toIso8601String();
        break;
      default:
        break;
    }

    await _client.from('rounds').update(updates).eq('id', roundId);
  }

  @override
  Future<void> submitVote(String roundId, String voterId, String targetId) async {
    await _client.from('votes').insert({
      'round_id': roundId,
      'voter_id': voterId,
      'target_id': targetId,
    });
  }

  @override
  Future<void> submitWordGuess(String roundId, String playerId, String guessedWord, bool isCorrect) async {
    await _client.from('word_guesses').insert({
      'round_id': roundId,
      'player_id': playerId,
      'guessed_word': guessedWord,
      'is_correct': isCorrect,
    });
  }

  @override
  Future<void> createGameEvent({
    required String roomId,
    required String eventType,
    Map<String, dynamic> eventData = const {},
    String? createdBy,
  }) async {
    await _client.from('game_events').insert({
      'room_id': roomId,
      'event_type': eventType,
      'event_data': eventData,
      'created_by': createdBy,
    });
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomId) {
    return _client
        .from('room_players')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('player_order')
        .map((data) => data.map((json) => RoomPlayer.fromJson(json)).toList());
  }

  @override
  Stream<GameRoom?> watchRoom(String roomId) {
    return _client
        .from('game_rooms')
        .stream(primaryKey: ['id'])
        .eq('id', roomId)
        .map((data) => data.isNotEmpty ? GameRoom.fromJson(data.first) : null);
  }

  @override
  Stream<List<GameEvent>> watchGameEvents(String roomId) {
    return _client
        .from('game_events')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => data.map((json) => GameEvent.fromJson(json)).toList());
  }

  @override
  Stream<MultiplayerRound?> watchCurrentRound(String roomId) {
    return _client
        .from('rounds')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('round_number', ascending: false)
        .limit(1)
        .map((data) => data.isNotEmpty ? MultiplayerRound.fromJson(data.first) : null);
  }

  @override
  Future<GameRoom?> getRoom(String roomId) async {
    return getRoomById(roomId);
  }

  @override
  Future<void> createPlayerRole(MultiplayerPlayerRole role) async {
    await _client.from('player_roles').insert(role.toJson());
  }

  @override
  Future<List<MultiplayerPlayerRole>> getRoundPlayerRoles(String roundId) async {
    final response = await _client
        .from('player_roles')
        .select()
        .eq('round_id', roundId);
    
    return response.map((json) => MultiplayerPlayerRole.fromJson(json)).toList();
  }

  @override
  Future<void> updateRoundPhase(String roundId, String phase) async {
    await _client
        .from('rounds')
        .update({'phase': phase})
        .eq('id', roundId);
  }

  @override
  Future<List<Vote>> getRoundVotes(String roundId) async {
    final response = await _client
        .from('votes')
        .select()
        .eq('round_id', roundId);
    
    return response.map((json) => Vote.fromJson(json)).toList();
  }

  @override
  Future<List<WordGuess>> getRoundWordGuesses(String roundId) async {
    final response = await _client
        .from('word_guesses')
        .select()
        .eq('round_id', roundId);
    
    return response.map((json) => WordGuess.fromJson(json)).toList();
  }

  @override
  Future<Word?> getWordById(String wordId) async {
    final response = await _client
        .from('words')
        .select()
        .eq('id', wordId)
        .maybeSingle();
    
    return response != null ? Word.fromJson(response) : null;
  }

  @override
  Future<void> completeRound(String roundId, bool impostorsWon, Map<String, int> scores) async {
    await _client
        .from('rounds')
        .update({
          'round_state': 'completed',
          'impostors_won': impostorsWon,
          'scores': scores,
        })
        .eq('id', roundId);
  }

  @override
  Future<List<MultiplayerRound>> getGameRounds(String roomId) async {
    final response = await _client
        .from('rounds')
        .select()
        .eq('room_id', roomId)
        .order('round_number');
    
    return response.map((json) => MultiplayerRound.fromJson(json)).toList();
  }

  @override
  Future<void> completeGame(String roomId, Map<String, int> finalScores) async {
    await _client
        .from('game_rooms')
        .update({
          'room_state': 'completed',
          'final_scores': finalScores,
        })
        .eq('id', roomId);
  }

  Future<String> _generateRoomCode() async {
    // Generate a 6-character room code
    final response = await _client.rpc('generate_room_code');
    return response as String;
  }

  String _roundStateToString(RoundState state) {
    switch (state) {
      case RoundState.roleAssignment:
        return 'role_assignment';
      case RoundState.roleReveal:
        return 'role_reveal';
      case RoundState.discussion:
        return 'discussion';
      case RoundState.voting:
        return 'voting';
      case RoundState.resolution:
        return 'resolution';
      case RoundState.completed:
        return 'completed';
    }
  }
}