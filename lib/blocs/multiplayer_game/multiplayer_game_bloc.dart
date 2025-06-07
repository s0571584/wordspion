import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/multiplayer_game_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../../data/models/game_room.dart';
import '../../data/models/room_player.dart';
import '../../data/models/multiplayer_round.dart';
import '../../data/models/multiplayer_player_role.dart';
import '../../data/models/game_event.dart';
import '../../data/models/word.dart';
import '../../core/services/multiplayer_game_service.dart';
import 'multiplayer_game_event.dart';
import 'multiplayer_game_state.dart';

class MultiplayerGameBloc extends Bloc<MultiplayerGameEvent, MultiplayerGameState> {
  final MultiplayerGameRepository _gameRepository;
  final AuthRepository _authRepository;
  final MultiplayerGameService _gameService;

  StreamSubscription<List<RoomPlayer>>? _playersSubscription;
  StreamSubscription<GameRoom?>? _roomSubscription;
  StreamSubscription<List<GameEvent>>? _eventsSubscription;
  StreamSubscription<MultiplayerRound?>? _roundSubscription;
  Timer? _heartbeatTimer;

  String? _currentRoomId;
  String? _currentPlayerId;
  String? _currentUserId;

  MultiplayerGameBloc({
    required MultiplayerGameRepository gameRepository,
    required AuthRepository authRepository,
    required MultiplayerGameService gameService,
  })  : _gameRepository = gameRepository,
        _authRepository = authRepository,
        _gameService = gameService,
        super(MultiplayerGameInitial()) {
    on<CreateGameRoom>(_onCreateGameRoom);
    on<JoinGameRoom>(_onJoinGameRoom);
    on<LeaveGameRoom>(_onLeaveGameRoom);
    on<UpdatePlayerReadyStatus>(_onUpdatePlayerReadyStatus);
    on<StartGame>(_onStartGame);
    on<StartRound>(_onStartRound);
    on<MarkRoleAsViewed>(_onMarkRoleAsViewed);
    on<StartDiscussion>(_onStartDiscussion);
    on<StartVoting>(_onStartVoting);
    on<SubmitVote>(_onSubmitVote);
    on<SubmitWordGuess>(_onSubmitWordGuess);
    on<CompleteRound>(_onCompleteRound);
    on<CompleteGame>(_onCompleteGame);
    on<RoomUpdated>(_onRoomUpdated);
    on<PlayersUpdated>(_onPlayersUpdated);
    on<RoundUpdated>(_onRoundUpdated);
    on<GameEventReceived>(_onGameEventReceived);
    on<SendHeartbeat>(_onSendHeartbeat);
    on<LoadRoom>(_onLoadRoom);
    on<ResetGameState>(_onResetGameState);

    _initializeCurrentUser();
  }

  @override
  Future<void> close() {
    _cleanupSubscriptions();
    _heartbeatTimer?.cancel();
    return super.close();
  }

  Future<void> _initializeCurrentUser() async {
    final user = await _authRepository.getCurrentUser();
    _currentUserId = user?.id;
  }

  Future<void> _onCreateGameRoom(
    CreateGameRoom event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    print('DEBUG: CreateGameRoom event received');
    
    // Ensure current user is initialized
    await _initializeCurrentUser();
    print('DEBUG: Current user ID: $_currentUserId');
    
    if (_currentUserId == null) {
      print('DEBUG: User not authenticated');
      emit(const MultiplayerGameError(message: 'User not authenticated'));
      return;
    }

    emit(MultiplayerGameLoading());

    try {
      print('DEBUG: Creating room with settings: playerCount=${event.playerCount}, impostorCount=${event.impostorCount}');
      final room = await _gameRepository.createRoom(
        hostId: _currentUserId!,
        playerCount: event.playerCount,
        impostorCount: event.impostorCount,
        roundCount: event.roundCount,
        timerDuration: event.timerDuration,
        impostorsKnowEachOther: event.impostorsKnowEachOther,
        selectedCategories: event.selectedCategories,
      );

      print('DEBUG: Room created successfully: ${room.roomCode}');
      emit(GameRoomCreated(room));
    } catch (e) {
      print('DEBUG: Failed to create room: $e');
      emit(MultiplayerGameError(message: 'Failed to create room: ${e.toString()}'));
    }
  }

  Future<void> _onJoinGameRoom(
    JoinGameRoom event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentUserId == null) {
      emit(const MultiplayerGameError(message: 'User not authenticated'));
      return;
    }

    emit(MultiplayerGameLoading());

    try {
      final room = await _gameRepository.joinRoom(
        event.roomCode,
        _currentUserId!,
        event.playerName,
      );

      if (room == null) {
        emit(const MultiplayerGameError(message: 'Room not found or expired'));
        return;
      }

      _currentRoomId = room.id;
      await _setupRoomSubscriptions(room.id);
      _startHeartbeat();

      // Get initial players list
      final players = await _gameRepository.getRoomPlayers(room.id);
      final currentPlayer = players.firstWhere((p) => p.userId == _currentUserId);
      _currentPlayerId = currentPlayer.id;

      emit(GameRoomJoined(
        room: room,
        players: players,
        currentPlayer: currentPlayer,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to join room: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveGameRoom(
    LeaveGameRoom event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentPlayerId != null) {
      try {
        await _gameRepository.leaveRoom(_currentPlayerId!);
      } catch (e) {
        // Log error but continue with cleanup
      }
    }

    _cleanupSubscriptions();
    _heartbeatTimer?.cancel();
    _currentRoomId = null;
    _currentPlayerId = null;

    emit(MultiplayerGameInitial());
  }

  Future<void> _onUpdatePlayerReadyStatus(
    UpdatePlayerReadyStatus event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentPlayerId == null) return;

    try {
      await _gameRepository.updatePlayerReadyStatus(_currentPlayerId!, event.isReady);
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to update ready status: ${e.toString()}'));
    }
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      await _gameRepository.startGame(_currentRoomId!);

      await _gameRepository.createGameEvent(
        roomId: _currentRoomId!,
        eventType: GameEventTypes.gameStarted,
        createdBy: _currentUserId,
      );
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to start game: ${e.toString()}'));
    }
  }

  Future<void> _onStartRound(
    StartRound event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentRoomId == null || _currentUserId == null) return;

    try {
      // Get current room and players
      final room = await _gameRepository.getRoom(_currentRoomId!);
      final players = await _gameRepository.getRoomPlayers(_currentRoomId!);

      if (room == null || players.isEmpty) {
        emit(const MultiplayerGameError(message: 'Room or players not found'));
        return;
      }

      // Create a new round
      final round = await _gameRepository.createRound(
        roomId: _currentRoomId!,
        roundNumber: event.roundNumber,
      );

      // Assign roles using the game service
      final roleAssignments = await _gameService.assignPlayerRoles(
        roundId: round.id,
        players: players,
        impostorCount: room.impostorCount,
        selectedCategories: room.selectedCategories,
        impostorsKnowEachOther: room.impostorsKnowEachOther,
      );

      // Save role assignments to database
      for (final role in roleAssignments) {
        await _gameRepository.createPlayerRole(role);
      }

      // Get the current player's role and word
      final myRole = roleAssignments.firstWhere((role) => players.any((player) => player.id == role.playerId && player.userId == _currentUserId));

      final myWord = await _gameRepository.getWordById(myRole.assignedWordId);
      final currentPlayer = players.firstWhere((p) => p.userId == _currentUserId);

      // Create game event for round start
      await _gameRepository.createGameEvent(
        roomId: _currentRoomId!,
        eventType: GameEventTypes.roundStarted,
        createdBy: _currentUserId,
        eventData: {'round_number': event.roundNumber},
      );

      // Emit role assignment phase
      emit(RoleAssignmentPhase(
        room: room,
        currentRound: round,
        playerRole: myRole,
        players: players,
        currentPlayer: currentPlayer,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to start round: ${e.toString()}'));
    }
  }

  Future<void> _onMarkRoleAsViewed(
    MarkRoleAsViewed event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (state is! RoleAssignmentPhase) return;

    final currentState = state as RoleAssignmentPhase;

    try {
      // Mark role as viewed in database
      await _gameRepository.markRoleAsViewed(currentState.playerRole!.id);

      // Get the assigned word
      final myWord = await _gameRepository.getWordById(currentState.playerRole!.assignedWordId);

      if (myWord == null) {
        emit(const MultiplayerGameError(message: 'Assigned word not found'));
        return;
      }

      // Transition to role reveal phase
      emit(RoleRevealPhase(
        room: currentState.room,
        currentRound: currentState.currentRound,
        playerRole: currentState.playerRole!,
        assignedWord: myWord.text,
        players: currentState.players,
        currentPlayer: currentState.currentPlayer,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to mark role as viewed: ${e.toString()}'));
    }
  }

  Future<void> _onStartDiscussion(
    StartDiscussion event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (state is! RoleRevealPhase) return;

    final currentState = state as RoleRevealPhase;

    try {
      // Update round phase in database
      await _gameRepository.updateRoundPhase(currentState.currentRound.id, 'discussion');

      // Create game event for discussion start
      await _gameRepository.createGameEvent(
        roomId: _currentRoomId!,
        eventType: GameEventTypes.discussionStarted,
        createdBy: _currentUserId,
        eventData: {'round_id': currentState.currentRound.id},
      );

      // Calculate remaining time based on room settings
      final remainingTime = Duration(seconds: currentState.room.timerDuration);

      // Transition to discussion phase
      emit(DiscussionPhase(
        room: currentState.room,
        currentRound: currentState.currentRound,
        playerRole: currentState.playerRole,
        assignedWord: currentState.assignedWord,
        players: currentState.players,
        currentPlayer: currentState.currentPlayer,
        remainingTime: remainingTime,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to start discussion: ${e.toString()}'));
    }
  }

  Future<void> _onStartVoting(
    StartVoting event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (state is! DiscussionPhase) return;

    final currentState = state as DiscussionPhase;

    try {
      // Update round phase in database
      await _gameRepository.updateRoundPhase(currentState.currentRound.id, 'voting');

      // Create game event for voting start
      await _gameRepository.createGameEvent(
        roomId: _currentRoomId!,
        eventType: GameEventTypes.votingStarted,
        createdBy: _currentUserId,
        eventData: {'round_id': currentState.currentRound.id},
      );

      // Transition to voting phase
      emit(VotingPhase(
        room: currentState.room,
        currentRound: currentState.currentRound,
        playerRole: currentState.playerRole,
        players: currentState.players,
        currentPlayer: currentState.currentPlayer,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to start voting: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitVote(
    SubmitVote event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (state is! VotingPhase || _currentPlayerId == null) return;

    final currentState = state as VotingPhase;

    try {
      // Submit vote to database
      await _gameRepository.submitVote(
        currentState.currentRound.id,
        _currentPlayerId!,
        event.targetPlayerId,
      );

      // Get updated vote count
      final votes = await _gameRepository.getRoundVotes(currentState.currentRound.id);
      final voteCount = <String, int>{};
      for (final vote in votes) {
        voteCount[vote.targetId] = (voteCount[vote.targetId] ?? 0) + 1;
      }

      // Update state with vote information
      emit(currentState.copyWith(
        votedPlayerId: event.targetPlayerId,
        voteCount: voteCount,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to submit vote: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitWordGuess(
    SubmitWordGuess event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentPlayerId == null) return;

    try {
      // Submit word guess to database
      await _gameRepository.submitWordGuess(
        (state as dynamic).currentRound.id,
        _currentPlayerId!,
        event.guessedWord,
        false, // TODO: Check if guess is correct
      );
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to submit word guess: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteRound(
    CompleteRound event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (state is! VotingPhase || _currentRoomId == null) return;

    final currentState = state as VotingPhase;

    try {
      // Get all votes and word guesses for the round
      final votes = await _gameRepository.getRoundVotes(currentState.currentRound.id);
      final wordGuesses = await _gameRepository.getRoundWordGuesses(currentState.currentRound.id);
      final roles = await _gameRepository.getRoundPlayerRoles(currentState.currentRound.id);

      // Convert to the format expected by the game service
      final voteMap = <String, String>{};
      for (final vote in votes) {
        voteMap[vote.voterId] = vote.targetId;
      }

      final wordGuessMap = <String, String>{};
      for (final guess in wordGuesses) {
        wordGuessMap[guess.playerId] = guess.guessedWord;
      }

      // Get the correct word for this round
      final mainWordRole = roles.firstWhere((role) => !role.isImpostor);
      final mainWord = await _gameRepository.getWordById(mainWordRole.assignedWordId);

      if (mainWord == null) {
        emit(const MultiplayerGameError(message: 'Main word not found'));
        return;
      }

      // Calculate round results using the game service
      final roundResults = _gameService.calculateRoundResults(
        players: currentState.players,
        roles: roles,
        votes: voteMap,
        wordGuesses: wordGuessMap,
        correctWord: mainWord.text,
      );

      // Update round as completed
      await _gameRepository.completeRound(
        currentState.currentRound.id,
        roundResults['impostors_won'],
        roundResults['scores'],
      );

      // Create game event for round completion
      await _gameRepository.createGameEvent(
        roomId: _currentRoomId!,
        eventType: GameEventTypes.roundCompleted,
        createdBy: _currentUserId,
        eventData: roundResults,
      );

      // Emit round completed state
      emit(RoundCompleted(
        room: currentState.room,
        completedRound: currentState.currentRound,
        players: currentState.players,
        currentPlayer: currentState.currentPlayer,
        impostorsWon: roundResults['impostors_won'],
        finalVotes: Map<String, int>.from(roundResults['vote_count']),
        eliminatedPlayers: List<String>.from(roundResults['eliminated_players']),
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to complete round: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteGame(
    CompleteGame event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      // Get all completed rounds for this game
      final rounds = await _gameRepository.getGameRounds(_currentRoomId!);
      final room = await _gameRepository.getRoom(_currentRoomId!);
      final players = await _gameRepository.getRoomPlayers(_currentRoomId!);

      if (room == null) {
        emit(const MultiplayerGameError(message: 'Room not found'));
        return;
      }

      // Calculate final scores using the game service
      final allRoundScores = <Map<String, int>>[];
      for (final round in rounds) {
        if (round.scores != null && round.scores!.isNotEmpty) {
          allRoundScores.add(Map<String, int>.from(round.scores!));
        }
      }

      final finalScores = _gameService.calculateFinalScores(allRoundScores);

      // Determine winners (highest scores)
      final maxScore = finalScores.values.isEmpty ? 0 : finalScores.values.reduce((a, b) => a > b ? a : b);
      final winners = finalScores.entries.where((entry) => entry.value == maxScore).map((entry) => entry.key).toList();

      // Update game as completed
      await _gameRepository.completeGame(_currentRoomId!, finalScores);

      // Create game event for game completion
      await _gameRepository.createGameEvent(
        roomId: _currentRoomId!,
        eventType: GameEventTypes.gameCompleted,
        createdBy: _currentUserId,
        eventData: {
          'final_scores': finalScores,
          'winners': winners,
        },
      );

      final currentPlayer = players.firstWhere((p) => p.userId == _currentUserId);

      // Emit game completed state
      emit(GameCompleted(
        room: room,
        finalPlayers: players,
        currentPlayer: currentPlayer,
        impostorsWon: false, // This would need more complex logic to determine
        finalScores: finalScores,
        allRounds: rounds,
      ));
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to complete game: ${e.toString()}'));
    }
  }

  Future<void> _onRoomUpdated(
    RoomUpdated event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (event.roomData != null && state is InGameLobby) {
      final currentState = state as InGameLobby;
      final updatedRoom = GameRoom.fromJson(event.roomData);

      emit(currentState.copyWith(room: updatedRoom));
    }
  }

  Future<void> _onPlayersUpdated(
    PlayersUpdated event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (state is InGameLobby) {
      final currentState = state as InGameLobby;
      final updatedPlayers = event.playersData.map((data) => RoomPlayer.fromJson(data)).toList();

      final currentPlayer = updatedPlayers.firstWhere(
        (p) => p.userId == _currentUserId,
        orElse: () => currentState.currentPlayer,
      );

      emit(currentState.copyWith(
        players: updatedPlayers,
        currentPlayer: currentPlayer,
      ));
    }
  }

  Future<void> _onRoundUpdated(
    RoundUpdated event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    // Handle round updates
  }

  Future<void> _onGameEventReceived(
    GameEventReceived event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    // Handle real-time game events
  }

  Future<void> _onSendHeartbeat(
    SendHeartbeat event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentPlayerId != null) {
      try {
        await _gameRepository.updatePlayerHeartbeat(_currentPlayerId!);
      } catch (e) {
        // Heartbeat failed - connection issues
      }
    }
  }

  Future<void> _onLoadRoom(
    LoadRoom event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    if (_currentUserId == null) {
      emit(const MultiplayerGameError(message: 'User not authenticated'));
      return;
    }

    emit(MultiplayerGameLoading());

    try {
      // Load room and check if user is already a player
      final room = await _gameRepository.getRoom(event.roomId);
      if (room == null) {
        emit(const MultiplayerGameError(message: 'Room not found'));
        return;
      }

      // Get players in the room
      final players = await _gameRepository.getRoomPlayers(event.roomId);
      final currentPlayerOptional = players.where((p) => p.userId == _currentUserId).toList();

      if (currentPlayerOptional.isEmpty) {
        emit(const MultiplayerGameError(message: 'You are not a member of this room'));
        return;
      }

      final currentPlayer = currentPlayerOptional.first;
      _currentRoomId = room.id;
      _currentPlayerId = currentPlayer.id;

      // Set up real-time subscriptions
      await _setupRoomSubscriptions(room.id);
      _startHeartbeat();

      // Check game status and emit appropriate state
      if (room.gameState == GameRoomState.waiting) {
        emit(InGameLobby(
          room: room,
          players: players,
          currentPlayer: currentPlayer,
        ));
      } else if (room.gameState == GameRoomState.playing) {
        // Check if there's an active round
        final rounds = await _gameRepository.getGameRounds(room.id);
        if (rounds.isNotEmpty) {
          final currentRound = rounds.last;
          final roles = await _gameRepository.getRoundPlayerRoles(currentRound.id);
          final myRole = roles.firstWhere((role) => players.any((player) => player.id == role.playerId && player.userId == _currentUserId));

          // Determine current phase based on round data
          if (currentRound.roundState == RoundState.discussion) {
            final myWord = await _gameRepository.getWordById(myRole.assignedWordId);
            emit(DiscussionPhase(
              room: room,
              currentRound: currentRound,
              playerRole: myRole,
              assignedWord: myWord?.text ?? '',
              players: players,
              currentPlayer: currentPlayer,
            ));
          } else if (currentRound.roundState == RoundState.voting) {
            emit(VotingPhase(
              room: room,
              currentRound: currentRound,
              playerRole: myRole,
              players: players,
              currentPlayer: currentPlayer,
            ));
          } else {
            // Default to role assignment if phase is unclear
            emit(RoleAssignmentPhase(
              room: room,
              currentRound: currentRound,
              playerRole: myRole,
              players: players,
              currentPlayer: currentPlayer,
            ));
          }
        } else {
          emit(GameStarted(
            room: room,
            players: players,
            currentPlayer: currentPlayer,
          ));
        }
      } else {
        emit(InGameLobby(
          room: room,
          players: players,
          currentPlayer: currentPlayer,
        ));
      }
    } catch (e) {
      emit(MultiplayerGameError(message: 'Failed to load room: ${e.toString()}'));
    }
  }

  Future<void> _onResetGameState(
    ResetGameState event,
    Emitter<MultiplayerGameState> emit,
  ) async {
    _cleanupSubscriptions();
    _heartbeatTimer?.cancel();
    _currentRoomId = null;
    _currentPlayerId = null;
    emit(MultiplayerGameInitial());
  }

  Future<void> _setupRoomSubscriptions(String roomId) async {
    _cleanupSubscriptions();

    _playersSubscription = _gameRepository.watchRoomPlayers(roomId).listen(
          (players) => add(PlayersUpdated(players.map((p) => p.toJson()).toList())),
        );

    _roomSubscription = _gameRepository.watchRoom(roomId).listen(
          (room) => add(RoomUpdated(room?.toJson())),
        );

    _eventsSubscription = _gameRepository.watchGameEvents(roomId).listen(
      (events) {
        for (final event in events) {
          add(GameEventReceived(
            eventType: event.eventType,
            eventData: event.eventData,
          ));
        }
      },
    );
  }

  void _cleanupSubscriptions() {
    _playersSubscription?.cancel();
    _roomSubscription?.cancel();
    _eventsSubscription?.cancel();
    _roundSubscription?.cancel();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(SendHeartbeat()),
    );
  }
}
