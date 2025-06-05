# Phase 4: Realtime Architecture

This document covers the implementation of real-time synchronization using Supabase Realtime for multiplayer gameplay.

## Prerequisites

- [ ] Database setup completed (Phase 1)
- [ ] Authentication implemented (Phase 2)
- [ ] Backend functions deployed (Phase 3)
- [ ] Understanding of WebSocket connections

## 1. Realtime Overview

### Architecture Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│ Flutter App │────►│   Realtime   │────►│  PostgreSQL │────►│   Broadcast  │
│  (Player 1) │◄────│   Channel    │◄────│   Changes   │     │  to Channel  │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
                            ▲                                          │
                            │                                          │
                            └──────────────────────────────────────────┘
                                           Realtime Updates
```

### Key Concepts

1. **Channels**: Topic-based subscriptions (e.g., `room:${roomId}`)
2. **Events**: Database changes (INSERT, UPDATE, DELETE)
3. **Presence**: Track who's online in real-time
4. **Broadcast**: Send arbitrary messages between clients

## 2. Enable Realtime in Supabase

### 2.1 Enable Realtime for Tables

In Supabase Dashboard → Database → Replication:

```sql
-- Enable realtime for required tables
ALTER PUBLICATION supabase_realtime ADD TABLE game_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE room_players;
ALTER PUBLICATION supabase_realtime ADD TABLE rounds;
ALTER PUBLICATION supabase_realtime ADD TABLE player_roles;
ALTER PUBLICATION supabase_realtime ADD TABLE votes;
ALTER PUBLICATION supabase_realtime ADD TABLE game_events;
```

### 2.2 Configure Realtime Settings

```yaml
# Supabase Dashboard → Settings → Realtime
Max concurrent users: 500
Max events per second: 10
Max payload size: 1MB
```

## 3. Flutter Realtime Service

### 3.1 Base Realtime Service

```dart
// lib/data/services/realtime_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RealtimeService {
  Stream<RealtimeMessage> subscribeToRoom(String roomId);
  Stream<PresenceState> subscribeToPresence(String roomId);
  Future<void> broadcastMessage(String roomId, String event, Map<String, dynamic> payload);
  Future<void> updatePresence(String roomId, Map<String, dynamic> state);
  void dispose();
}

class SupabaseRealtimeService implements RealtimeService {
  final SupabaseClient _supabase;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<RealtimeMessage>> _messageControllers = {};
  final Map<String, StreamController<PresenceState>> _presenceControllers = {};
  
  SupabaseRealtimeService(this._supabase);
  
  @override
  Stream<RealtimeMessage> subscribeToRoom(String roomId) {
    final channelName = 'room:$roomId';
    
    // Create stream controller if not exists
    _messageControllers[roomId] ??= StreamController<RealtimeMessage>.broadcast();
    
    // Get or create channel
    if (!_channels.containsKey(roomId)) {
      final channel = _supabase.channel(channelName);
      
      // Subscribe to database changes
      channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          table: 'game_events',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            _handleDatabaseChange(roomId, 'game_events', payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          table: 'room_players',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            _handleDatabaseChange(roomId, 'room_players', payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          table: 'rounds',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            _handleDatabaseChange(roomId, 'rounds', payload);
          },
        )
        .onBroadcast(
          event: '*',
          callback: (payload) {
            _handleBroadcast(roomId, payload);
          },
        )
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Subscribed to room: $roomId');
          } else if (error != null) {
            print('Subscription error: $error');
            _messageControllers[roomId]?.addError(error);
          }
        });
      
      _channels[roomId] = channel;
    }
    
    return _messageControllers[roomId]!.stream;
  }
  
  @override
  Stream<PresenceState> subscribeToPresence(String roomId) {
    final channelName = 'room:$roomId:presence';
    
    _presenceControllers[roomId] ??= StreamController<PresenceState>.broadcast();
    
    if (!_channels.containsKey('$roomId:presence')) {
      final channel = _supabase.channel(channelName);
      
      channel
        .onPresenceSync((payload) {
          final state = PresenceState.fromPayload(payload);
          _presenceControllers[roomId]?.add(state);
        })
        .onPresenceJoin((payload) {
          final state = PresenceState.fromPayload(payload);
          _presenceControllers[roomId]?.add(state);
        })
        .onPresenceLeave((payload) {
          final state = PresenceState.fromPayload(payload);
          _presenceControllers[roomId]?.add(state);
        })
        .subscribe();
      
      _channels['$roomId:presence'] = channel;
    }
    
    return _presenceControllers[roomId]!.stream;
  }
  
  @override
  Future<void> broadcastMessage(
    String roomId,
    String event,
    Map<String, dynamic> payload,
  ) async {
    final channel = _channels[roomId];
    if (channel != null) {
      await channel.sendBroadcastMessage(
        event: event,
        payload: payload,
      );
    }
  }
  
  @override
  Future<void> updatePresence(String roomId, Map<String, dynamic> state) async {
    final channel = _channels['$roomId:presence'];
    if (channel != null) {
      await channel.track(state);
    }
  }
  
  void _handleDatabaseChange(
    String roomId,
    String table,
    PostgresChangePayload payload,
  ) {
    _messageControllers[roomId]?.add(
      RealtimeMessage(
        type: RealtimeMessageType.databaseChange,
        table: table,
        event: payload.eventType.name,
        data: payload.newRecord ?? payload.oldRecord ?? {},
      ),
    );
  }
  
  void _handleBroadcast(String roomId, Map<String, dynamic> payload) {
    _messageControllers[roomId]?.add(
      RealtimeMessage(
        type: RealtimeMessageType.broadcast,
        event: payload['event'] as String,
        data: payload['payload'] as Map<String, dynamic>,
      ),
    );
  }
  
  @override
  void dispose() {
    // Unsubscribe from all channels
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    
    // Close all stream controllers
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    for (final controller in _presenceControllers.values) {
      controller.close();
    }
    
    _channels.clear();
    _messageControllers.clear();
    _presenceControllers.clear();
  }
}

// Models
enum RealtimeMessageType { databaseChange, broadcast }

class RealtimeMessage {
  final RealtimeMessageType type;
  final String? table;
  final String event;
  final Map<String, dynamic> data;
  
  RealtimeMessage({
    required this.type,
    this.table,
    required this.event,
    required this.data,
  });
}

class PresenceState {
  final Map<String, List<Map<String, dynamic>>> presences;
  
  PresenceState(this.presences);
  
  factory PresenceState.fromPayload(Map<String, dynamic> payload) {
    return PresenceState(payload.cast<String, List<Map<String, dynamic>>>());
  }
  
  List<String> get onlineUserIds {
    final users = <String>[];
    for (final presenceList in presences.values) {
      for (final presence in presenceList) {
        final userId = presence['user_id'] as String?;
        if (userId != null && !users.contains(userId)) {
          users.add(userId);
        }
      }
    }
    return users;
  }
}
```

### 3.2 Game-Specific Realtime Handler

```dart
// lib/data/services/game_realtime_handler.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class GameRealtimeHandler {
  final RealtimeService _realtimeService;
  final String roomId;
  StreamSubscription<RealtimeMessage>? _messageSubscription;
  StreamSubscription<PresenceState>? _presenceSubscription;
  
  // Callbacks for different events
  final Function(PlayerJoinedEvent) onPlayerJoined;
  final Function(PlayerLeftEvent) onPlayerLeft;
  final Function(GameStartedEvent) onGameStarted;
  final Function(RolesAssignedEvent) onRolesAssigned;
  final Function(VoteSubmittedEvent) onVoteSubmitted;
  final Function(RoundEndedEvent) onRoundEnded;
  final Function(List<String>) onPresenceUpdate;
  
  GameRealtimeHandler({
    required this.realtimeService,
    required this.roomId,
    required this.onPlayerJoined,
    required this.onPlayerLeft,
    required this.onGameStarted,
    required this.onRolesAssigned,
    required this.onVoteSubmitted,
    required this.onRoundEnded,
    required this.onPresenceUpdate,
  }) {
    _initialize();
  }
  
  void _initialize() {
    // Subscribe to room messages
    _messageSubscription = _realtimeService
        .subscribeToRoom(roomId)
        .listen(_handleMessage);
    
    // Subscribe to presence
    _presenceSubscription = _realtimeService
        .subscribeToPresence(roomId)
        .listen(_handlePresence);
    
    // Announce presence
    _realtimeService.updatePresence(roomId, {
      'user_id': getCurrentUserId(),
      'joined_at': DateTime.now().toIso8601String(),
    });
  }
  
  void _handleMessage(RealtimeMessage message) {
    if (message.type == RealtimeMessageType.databaseChange) {
      _handleDatabaseChange(message);
    } else if (message.type == RealtimeMessageType.broadcast) {
      _handleBroadcast(message);
    }
  }
  
  void _handleDatabaseChange(RealtimeMessage message) {
    switch (message.table) {
      case 'game_events':
        _handleGameEvent(message.data);
        break;
      case 'room_players':
        _handlePlayerChange(message.event, message.data);
        break;
      case 'rounds':
        _handleRoundChange(message.event, message.data);
        break;
    }
  }
  
  void _handleGameEvent(Map<String, dynamic> eventData) {
    final eventType = eventData['event_type'] as String;
    final data = eventData['event_data'] as Map<String, dynamic>;
    
    switch (eventType) {
      case 'player_joined':
        onPlayerJoined(PlayerJoinedEvent(
          playerId: data['player_id'],
          playerName: data['player_name'],
          playerOrder: data['player_order'],
        ));
        break;
      case 'game_started':
        onGameStarted(GameStartedEvent(
          roundNumber: data['round_number'],
        ));
        break;
      case 'roles_assigned':
        onRolesAssigned(RolesAssignedEvent(
          roundId: data['round_id'],
          impostorsKnowEachOther: data['impostors_know_each_other'],
        ));
        break;
      case 'vote_submitted':
        onVoteSubmitted(VoteSubmittedEvent(
          votesCount: data['votes_count'],
          playersCount: data['players_count'],
          allVoted: data['all_voted'],
        ));
        break;
      case 'round_ended':
        onRoundEnded(RoundEndedEvent(
          roundNumber: data['round_number'],
          impostorsWon: data['impostors_won'],
          wordGuessed: data['word_guessed'],
          scores: Map<String, int>.from(data['scores']),
          isGameFinished: data['is_game_finished'],
        ));
        break;
    }
  }
  
  void _handlePlayerChange(String event, Map<String, dynamic> data) {
    if (event == 'UPDATE') {
      final isConnected = data['is_connected'] as bool;
      if (!isConnected) {
        onPlayerLeft(PlayerLeftEvent(
          playerId: data['id'],
          playerName: data['player_name'],
        ));
      }
    }
  }
  
  void _handleRoundChange(String event, Map<String, dynamic> data) {
    // Handle round state changes if needed
  }
  
  void _handleBroadcast(RealtimeMessage message) {
    // Handle custom broadcast messages
    switch (message.event) {
      case 'chat_message':
        // Handle chat if implemented
        break;
      case 'emoji_reaction':
        // Handle reactions if implemented
        break;
    }
  }
  
  void _handlePresence(PresenceState state) {
    onPresenceUpdate(state.onlineUserIds);
  }
  
  void dispose() {
    _messageSubscription?.cancel();
    _presenceSubscription?.cancel();
  }
}

// Event models
class PlayerJoinedEvent {
  final String playerId;
  final String playerName;
  final int playerOrder;
  
  PlayerJoinedEvent({
    required this.playerId,
    required this.playerName,
    required this.playerOrder,
  });
}

class PlayerLeftEvent {
  final String playerId;
  final String playerName;
  
  PlayerLeftEvent({
    required this.playerId,
    required this.playerName,
  });
}

// ... other event classes
```

## 4. BLoC Integration

### 4.1 Multiplayer Game BLoC

```dart
// lib/blocs/multiplayer_game/multiplayer_game_bloc.dart
class MultiplayerGameBloc extends Bloc<MultiplayerGameEvent, MultiplayerGameState> {
  final GameRepository _gameRepository;
  final RealtimeService _realtimeService;
  GameRealtimeHandler? _realtimeHandler;
  
  MultiplayerGameBloc({
    required GameRepository gameRepository,
    required RealtimeService realtimeService,
  })  : _gameRepository = gameRepository,
        _realtimeService = realtimeService,
        super(MultiplayerGameInitial()) {
    on<JoinRoom>(_onJoinRoom);
    on<PlayerJoinedRoom>(_onPlayerJoinedRoom);
    on<PlayerLeftRoom>(_onPlayerLeftRoom);
    on<GameStartedByHost>(_onGameStartedByHost);
    on<RolesWereAssigned>(_onRolesWereAssigned);
    on<UpdateVotingProgress>(_onUpdateVotingProgress);
    on<RoundHasEnded>(_onRoundHasEnded);
  }
  
  Future<void> _onJoinRoom(JoinRoom event, Emitter emit) async {
    try {
      emit(MultiplayerGameLoading());
      
      // Join room via API
      final result = await _gameRepository.joinRoom(
        event.roomCode,
        event.playerName,
      );
      
      // Set up realtime handler
      _realtimeHandler = GameRealtimeHandler(
        realtimeService: _realtimeService,
        roomId: result.roomId,
        onPlayerJoined: (event) => add(PlayerJoinedRoom(event)),
        onPlayerLeft: (event) => add(PlayerLeftRoom(event)),
        onGameStarted: (event) => add(GameStartedByHost(event)),
        onRolesAssigned: (event) => add(RolesWereAssigned(event)),
        onVoteSubmitted: (event) => add(UpdateVotingProgress(event)),
        onRoundEnded: (event) => add(RoundHasEnded(event)),
        onPresenceUpdate: (userIds) {
          // Handle presence updates
        },
      );
      
      // Get initial room state
      final room = await _gameRepository.getRoom(result.roomId);
      final players = await _gameRepository.getRoomPlayers(result.roomId);
      
      emit(MultiplayerGameInLobby(
        room: room,
        players: players,
        currentPlayerId: result.playerId,
      ));
    } catch (e) {
      emit(MultiplayerGameError(e.toString()));
    }
  }
  
  void _onPlayerJoinedRoom(PlayerJoinedRoom event, Emitter emit) {
    if (state is MultiplayerGameInLobby) {
      final currentState = state as MultiplayerGameInLobby;
      final updatedPlayers = List<RoomPlayer>.from(currentState.players);
      
      // Add new player
      updatedPlayers.add(RoomPlayer(
        id: event.details.playerId,
        playerName: event.details.playerName,
        playerOrder: event.details.playerOrder,
        isReady: false,
        isConnected: true,
        score: 0,
      ));
      
      emit(currentState.copyWith(players: updatedPlayers));
    }
  }
  
  @override
  Future<void> close() {
    _realtimeHandler?.dispose();
    return super.close();
  }
}
```

### 4.2 Round BLoC with Realtime

```dart
// lib/blocs/round/round_bloc.dart
class RoundBloc extends Bloc<RoundEvent, RoundState> {
  final RoundRepository _repository;
  final RealtimeService _realtimeService;
  String? _currentRoundId;
  
  RoundBloc({
    required RoundRepository repository,
    required RealtimeService realtimeService,
  })  : _repository = repository,
        _realtimeService = realtimeService,
        super(RoundInitial()) {
    on<LoadRound>(_onLoadRound);
    on<ViewRole>(_onViewRole);
    on<StartDiscussion>(_onStartDiscussion);
    on<StartVoting>(_onStartVoting);
    on<SubmitVote>(_onSubmitVote);
    on<SubmitWordGuess>(_onSubmitWordGuess);
  }
  
  Future<void> _onViewRole(ViewRole event, Emitter emit) async {
    try {
      // Get player's role
      final role = await _repository.getPlayerRole(
        event.roundId,
        event.playerId,
      );
      
      // Mark as viewed
      await _repository.markRoleViewed(event.playerId);
      
      // Check if all players have viewed roles
      final allViewed = await _repository.checkAllRolesViewed(event.roundId);
      
      if (allViewed) {
        // Broadcast to start discussion
        await _realtimeService.broadcastMessage(
          event.roomId,
          'start_discussion',
          {'round_id': event.roundId},
        );
      }
      
      emit(RoundRoleRevealed(
        role: role,
        allPlayersViewed: allViewed,
      ));
    } catch (e) {
      emit(RoundError(e.toString()));
    }
  }
}
```

## 5. UI Components with Realtime

### 5.1 Game Lobby with Live Updates

```dart
// lib/presentation/screens/multiplayer/game_lobby_screen.dart
class GameLobbyScreen extends StatelessWidget {
  final String roomId;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
      builder: (context, state) {
        if (state is! MultiplayerGameInLobby) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Raum: ${state.room.roomCode}'),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareRoomCode(state.room.roomCode),
              ),
            ],
          ),
          body: Column(
            children: [
              // Room settings display
              _RoomSettingsCard(room: state.room),
              
              // Players list with live updates
              Expanded(
                child: ListView.builder(
                  itemCount: state.players.length,
                  itemBuilder: (context, index) {
                    final player = state.players[index];
                    return _PlayerTile(
                      player: player,
                      isCurrentPlayer: player.id == state.currentPlayerId,
                      isHost: player.userId == state.room.hostId,
                    );
                  },
                ),
              ),
              
              // Ready button
              if (!state.isCurrentPlayerReady)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<MultiplayerGameBloc>().add(
                        ToggleReady(playerId: state.currentPlayerId),
                      );
                    },
                    child: Text('Bereit'),
                  ),
                ),
              
              // Start button for host
              if (state.isHost && state.allPlayersReady)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<MultiplayerGameBloc>().add(
                        StartGame(roomId: roomId),
                      );
                    },
                    child: Text('Spiel starten'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final RoomPlayer player;
  final bool isCurrentPlayer;
  final bool isHost;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: player.isConnected ? Colors.green : Colors.grey,
        child: Text(player.playerOrder.toString()),
      ),
      title: Text(
        player.playerName,
        style: TextStyle(
          fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        player.isConnected ? 'Verbunden' : 'Getrennt',
        style: TextStyle(
          color: player.isConnected ? Colors.green : Colors.red,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHost) Icon(Icons.star, color: Colors.amber),
          if (player.isReady)
            Icon(Icons.check_circle, color: Colors.green)
          else
            Icon(Icons.radio_button_unchecked, color: Colors.grey),
        ],
      ),
    );
  }
}
```

### 5.2 Voting Screen with Progress

```dart
// lib/presentation/screens/multiplayer/voting_screen.dart
class VotingScreen extends StatefulWidget {
  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? selectedPlayerId;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoundBloc, RoundState>(
      listener: (context, state) {
        if (state is RoundVotingComplete) {
          Navigator.pushReplacementNamed(context, '/resolution');
        }
      },
      builder: (context, state) {
        if (state is! RoundVoting) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Abstimmung'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: _VotingProgress(
                votedCount: state.votedCount,
                totalCount: state.totalPlayers,
                timeRemaining: state.timeRemaining,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.players.length,
                  itemBuilder: (context, index) {
                    final player = state.players[index];
                    if (player.id == state.currentPlayerId) {
                      return SizedBox(); // Don't show self
                    }
                    
                    return RadioListTile<String>(
                      value: player.id,
                      groupValue: selectedPlayerId,
                      onChanged: state.hasVoted ? null : (value) {
                        setState(() => selectedPlayerId = value);
                      },
                      title: Text(player.playerName),
                      subtitle: Text('Spieler ${player.playerOrder}'),
                    );
                  },
                ),
              ),
              
              if (!state.hasVoted && selectedPlayerId != null)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<RoundBloc>().add(
                        SubmitVote(
                          roundId: state.roundId,
                          targetPlayerId: selectedPlayerId!,
                        ),
                      );
                    },
                    child: Text('Abstimmen'),
                  ),
                ),
              
              if (state.hasVoted)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Warte auf andere Spieler...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VotingProgress extends StatelessWidget {
  final int votedCount;
  final int totalCount;
  final Duration timeRemaining;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Abstimmung: $votedCount / $totalCount'),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: votedCount / totalCount,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          _CountdownTimer(duration: timeRemaining),
        ],
      ),
    );
  }
}
```

## 6. Connection Management

### 6.1 Connection Monitor Service

```dart
// lib/data/services/connection_monitor.dart
class ConnectionMonitor {
  final SupabaseClient _supabase;
  final String roomId;
  final String playerId;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  StreamController<ConnectionStatus> _statusController = StreamController.broadcast();
  ConnectionStatus _currentStatus = ConnectionStatus.connected;
  
  Stream<ConnectionStatus> get status => _statusController.stream;
  
  ConnectionMonitor({
    required SupabaseClient supabase,
    required this.roomId,
    required this.playerId,
  }) : _supabase = supabase {
    _startHeartbeat();
    _monitorConnection();
  }
  
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      try {
        await _supabase.functions.invoke(
          'player-heartbeat',
          body: {'room_id': roomId},
        );
        _updateStatus(ConnectionStatus.connected);
      } catch (e) {
        _updateStatus(ConnectionStatus.disconnected);
        _attemptReconnect();
      }
    });
  }
  
  void _monitorConnection() {
    // Monitor WebSocket connection
    _supabase.realtime.onConnChange.listen((state) {
      if (state == ConnState.connected) {
        _updateStatus(ConnectionStatus.connected);
      } else if (state == ConnState.disconnected) {
        _updateStatus(ConnectionStatus.disconnected);
        _attemptReconnect();
      }
    });
  }
  
  void _attemptReconnect() {
    if (_reconnectTimer != null) return;
    
    _updateStatus(ConnectionStatus.reconnecting);
    
    int attempts = 0;
    _reconnectTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      attempts++;
      
      try {
        // Try to reconnect
        await _supabase.realtime.connect();
        
        // Update player status
        await _supabase
            .from('room_players')
            .update({'is_connected': true})
            .eq('id', playerId);
        
        _updateStatus(ConnectionStatus.connected);
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
      } catch (e) {
        if (attempts > 12) { // 1 minute
          _updateStatus(ConnectionStatus.failed);
          _reconnectTimer?.cancel();
          _reconnectTimer = null;
        }
      }
    });
  }
  
  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }
  
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _statusController.close();
  }
}

enum ConnectionStatus {
  connected,
  disconnected,
  reconnecting,
  failed,
}
```

### 6.2 Connection Status Widget

```dart
// lib/presentation/widgets/connection_status.dart
class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionMonitor monitor;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: monitor.status,
      initialData: ConnectionStatus.connected,
      builder: (context, snapshot) {
        final status = snapshot.data!;
        
        if (status == ConnectionStatus.connected) {
          return SizedBox();
        }
        
        return MaterialBanner(
          content: Text(_getMessage(status)),
          backgroundColor: _getColor(status),
          actions: [
            if (status == ConnectionStatus.failed)
              TextButton(
                onPressed: () => _reconnect(context),
                child: Text('Erneut versuchen'),
              ),
          ],
        );
      },
    );
  }
  
  String _getMessage(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return 'Verbindung verloren';
      case ConnectionStatus.reconnecting:
        return 'Verbindung wird wiederhergestellt...';
      case ConnectionStatus.failed:
        return 'Verbindung fehlgeschlagen';
      default:
        return '';
    }
  }
  
  Color _getColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return Colors.orange;
      case ConnectionStatus.reconnecting:
        return Colors.blue;
      case ConnectionStatus.failed:
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
```

## 7. Optimizations

### 7.1 Debounce Updates

```dart
// lib/core/utils/debouncer.dart
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({required this.delay});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

// Usage in BLoC
class GameBloc extends Bloc<GameEvent, GameState> {
  final _votingDebouncer = Debouncer(delay: Duration(milliseconds: 500));
  
  void _onVoteUpdate(VoteUpdate event, Emitter emit) {
    _votingDebouncer.run(() {
      // Update UI only after debounce period
      emit(state.copyWith(votingProgress: event.progress));
    });
  }
}
```

### 7.2 Batch Updates

```dart
// lib/data/services/batch_update_service.dart
class BatchUpdateService {
  final Queue<GameEvent> _eventQueue = Queue();
  Timer? _batchTimer;
  final Function(List<GameEvent>) onBatch;
  
  BatchUpdateService({required this.onBatch});
  
  void addEvent(GameEvent event) {
    _eventQueue.add(event);
    
    if (_batchTimer == null) {
      _batchTimer = Timer(Duration(milliseconds: 100), _processBatch);
    }
  }
  
  void _processBatch() {
    if (_eventQueue.isEmpty) return;
    
    final events = _eventQueue.toList();
    _eventQueue.clear();
    
    onBatch(events);
    
    _batchTimer = null;
  }
}
```

## 8. Testing Realtime

### 8.1 Mock Realtime Service

```dart
// test/mocks/mock_realtime_service.dart
class MockRealtimeService extends Mock implements RealtimeService {
  final _messageController = StreamController<RealtimeMessage>.broadcast();
  final _presenceController = StreamController<PresenceState>.broadcast();
  
  @override
  Stream<RealtimeMessage> subscribeToRoom(String roomId) {
    return _messageController.stream;
  }
  
  @override
  Stream<PresenceState> subscribeToPresence(String roomId) {
    return _presenceController.stream;
  }
  
  // Helper methods for testing
  void simulatePlayerJoined(String playerId, String playerName) {
    _messageController.add(
      RealtimeMessage(
        type: RealtimeMessageType.databaseChange,
        table: 'game_events',
        event: 'INSERT',
        data: {
          'event_type': 'player_joined',
          'event_data': {
            'player_id': playerId,
            'player_name': playerName,
            'player_order': 2,
          },
        },
      ),
    );
  }
}
```

### 8.2 Integration Tests

```dart
// test/integration/realtime_game_test.dart
void main() {
  group('Realtime Game Flow', () {
    late SupabaseClient supabase;
    late RealtimeService realtimeService;
    
    setUp(() async {
      supabase = await createTestSupabaseClient();
      realtimeService = SupabaseRealtimeService(supabase);
    });
    
    test('Players receive join notifications', () async {
      // Create room
      final room = await createTestRoom(supabase);
      
      // Player 1 subscribes
      final player1Stream = realtimeService.subscribeToRoom(room.id);
      
      // Player 2 joins
      await joinTestRoom(supabase, room.roomCode, 'Player 2');
      
      // Verify player 1 receives notification
      await expectLater(
        player1Stream,
        emits(predicate<RealtimeMessage>((msg) =>
          msg.data['event_type'] == 'player_joined' &&
          msg.data['event_data']['player_name'] == 'Player 2'
        )),
      );
    });
  });
}
```

## Verification Checklist

- [ ] Realtime enabled for all required tables
- [ ] Realtime service implemented
- [ ] Game realtime handler working
- [ ] BLoCs integrated with realtime
- [ ] UI updates in real-time
- [ ] Connection monitoring functional
- [ ] Reconnection logic tested
- [ ] Presence tracking working
- [ ] Performance optimizations applied
- [ ] Mock services for testing
- [ ] Integration tests passing

## Common Issues & Solutions

### Issue: Missing realtime updates
**Solution**: Ensure table has realtime enabled and RLS policies allow SELECT

### Issue: Duplicate events
**Solution**: Implement deduplication using event IDs or timestamps

### Issue: Connection drops frequently
**Solution**: Increase heartbeat frequency and implement robust reconnection

### Issue: UI flickers with updates
**Solution**: Use debouncing and batch updates

## Next Steps

1. Test realtime with multiple devices
2. Monitor WebSocket performance
3. Implement offline queue for actions
4. Proceed to [Frontend Migration](./05-frontend-migration.md)
