# Phase 6: Multiplayer Game Flow

This document details the complete multiplayer game flow implementation, from room creation to game completion.

## Prerequisites

- [ ] All previous phases completed (1-5)
- [ ] Understanding of game mechanics
- [ ] Realtime architecture in place
- [ ] Frontend components ready

## 1. Game Flow Overview

### 1.1 Complete Flow Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Sign In   │────►│ Game Mode   │────►│Create/Join  │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Lobby    │────►│ Role Reveal │────►│ Discussion  │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Results   │◄────│ Resolution  │◄────│   Voting    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                       
       ▼                                       
┌─────────────┐                               
│  Game End   │                               
└─────────────┘                               
```

### 1.2 State Transitions

```dart
// lib/core/game/game_state_machine.dart
enum GamePhase {
  lobby,
  starting,
  roleAssignment,
  roleReveal,
  discussion,
  voting,
  resolution,
  roundEnd,
  gameEnd,
}

class GameStateMachine {
  GamePhase _currentPhase = GamePhase.lobby;
  
  final Map<GamePhase, List<GamePhase>> _validTransitions = {
    GamePhase.lobby: [GamePhase.starting],
    GamePhase.starting: [GamePhase.roleAssignment],
    GamePhase.roleAssignment: [GamePhase.roleReveal],
    GamePhase.roleReveal: [GamePhase.discussion],
    GamePhase.discussion: [GamePhase.voting],
    GamePhase.voting: [GamePhase.resolution],
    GamePhase.resolution: [GamePhase.roundEnd],
    GamePhase.roundEnd: [GamePhase.roleAssignment, GamePhase.gameEnd],
    GamePhase.gameEnd: [],
  };
  
  bool canTransitionTo(GamePhase newPhase) {
    return _validTransitions[_currentPhase]?.contains(newPhase) ?? false;
  }
  
  void transitionTo(GamePhase newPhase) {
    if (!canTransitionTo(newPhase)) {
      throw StateError('Invalid transition from $_currentPhase to $newPhase');
    }
    _currentPhase = newPhase;
  }
}
```

## 2. Room Creation and Joining

### 2.1 Room Creation Flow

```dart
// lib/presentation/flows/create_room_flow.dart
class CreateRoomFlow {
  final MultiplayerGameBloc _gameBloc;
  final NavigationService _navigation;
  
  Future<void> execute(GameSettings settings, String hostName) async {
    try {
      // Step 1: Create room
      _gameBloc.add(CreateRoom(settings: settings, hostName: hostName));
      
      // Step 2: Wait for room creation
      await _gameBloc.stream.firstWhere((state) => state is MultiplayerGameInLobby);
      
      // Step 3: Navigate to lobby
      final state = _gameBloc.state as MultiplayerGameInLobby;
      _navigation.navigateToLobby(
        roomId: state.room.id,
        roomCode: state.room.roomCode,
      );
      
      // Step 4: Show share dialog
      _showShareDialog(state.room.roomCode);
      
    } catch (e) {
      _handleError(e);
    }
  }
  
  void _showShareDialog(String roomCode) {
    showDialog(
      context: _navigation.context,
      builder: (context) => AlertDialog(
        title: Text('Raum erstellt!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Teile diesen Code mit deinen Freunden:'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roomCode,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            SizedBox(height: 16),
            QrImageView(
              data: 'wortspion://join/$roomCode',
              size: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Share.share(
              'Spiele WortSpion mit mir! Raumcode: $roomCode\n'
              'oder nutze diesen Link: https://wortspion.app/join/$roomCode',
            ),
            child: Text('Teilen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### 2.2 Join Room Flow

```dart
// lib/presentation/flows/join_room_flow.dart
class JoinRoomFlow {
  final MultiplayerGameBloc _gameBloc;
  final ValidationService _validation;
  
  Future<bool> execute(String roomCode, String playerName) async {
    // Step 1: Validate input
    if (!_validation.isValidRoomCode(roomCode)) {
      throw ValidationException('Ungültiger Raumcode');
    }
    
    if (!_validation.isValidPlayerName(playerName)) {
      throw ValidationException('Ungültiger Spielername');
    }
    
    // Step 2: Check if room exists (optimistic)
    _gameBloc.add(JoinRoom(
      roomCode: roomCode.toUpperCase(),
      playerName: playerName,
    ));
    
    // Step 3: Wait for result
    final state = await _gameBloc.stream.firstWhere(
      (state) => state is MultiplayerGameInLobby || state is MultiplayerGameError,
    );
    
    if (state is MultiplayerGameError) {
      throw GameException(state.message);
    }
    
    return true;
  }
}
```

## 3. Lobby Management

### 3.1 Lobby State Synchronization

```dart
// lib/presentation/screens/multiplayer/lobby/lobby_manager.dart
class LobbyManager {
  final String roomId;
  final MultiplayerGameBloc _gameBloc;
  final RealtimeService _realtimeService;
  final ConnectionMonitor _connectionMonitor;
  
  StreamSubscription? _playerUpdates;
  StreamSubscription? _readyStates;
  
  void initialize() {
    // Listen for player updates
    _playerUpdates = _realtimeService
        .subscribeToRoom(roomId)
        .where((msg) => msg.table == 'room_players')
        .listen(_handlePlayerUpdate);
    
    // Monitor ready states
    _readyStates = Stream.periodic(Duration(seconds: 1))
        .asyncMap((_) => _checkAllReady())
        .distinct()
        .listen(_handleReadyStateChange);
    
    // Start connection monitoring
    _connectionMonitor.startMonitoring();
  }
  
  void _handlePlayerUpdate(RealtimeMessage message) {
    switch (message.event) {
      case 'INSERT':
        _gameBloc.add(PlayerJoinedRoom(
          playerId: message.data['id'],
          playerName: message.data['player_name'],
        ));
        break;
      case 'UPDATE':
        if (!message.data['is_connected']) {
          _gameBloc.add(PlayerDisconnected(
            playerId: message.data['id'],
          ));
        } else {
          _gameBloc.add(PlayerReconnected(
            playerId: message.data['id'],
          ));
        }
        break;
    }
  }
  
  Future<bool> _checkAllReady() async {
    final players = await _gameBloc.repository.getRoomPlayers(roomId);
    return players.every((p) => p.isReady || !p.isConnected);
  }
  
  void _handleReadyStateChange(bool allReady) {
    _gameBloc.add(UpdateLobbyReadyState(allReady: allReady));
  }
  
  void toggleReady() {
    _gameBloc.add(TogglePlayerReady());
  }
  
  void startGame() {
    if (_gameBloc.state is MultiplayerGameInLobby) {
      final state = _gameBloc.state as MultiplayerGameInLobby;
      if (state.isHost && state.allPlayersReady) {
        _gameBloc.add(StartGame());
      }
    }
  }
  
  void dispose() {
    _playerUpdates?.cancel();
    _readyStates?.cancel();
    _connectionMonitor.dispose();
  }
}
```

### 3.2 Host Controls

```dart
// lib/presentation/widgets/host_controls.dart
class HostControls extends StatelessWidget {
  final String roomId;
  final List<RoomPlayer> players;
  final VoidCallback onStartGame;
  
  @override
  Widget build(BuildContext context) {
    final allReady = players.every((p) => p.isReady);
    final enoughPlayers = players.length >= 3;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Host-Kontrollen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            
            // Player management
            ...players.map((player) => ListTile(
              title: Text(player.playerName),
              trailing: player.userId != currentUserId
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => _kickPlayer(player.id),
                    )
                  : null,
            )),
            
            Divider(),
            
            // Start game button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allReady && enoughPlayers ? onStartGame : null,
                child: Text('Spiel starten'),
              ),
            ),
            
            if (!enoughPlayers)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Mindestens 3 Spieler erforderlich',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            
            if (!allReady && enoughPlayers)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Warte auf alle Spieler...',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _kickPlayer(String playerId) {
    // Implement kick functionality
  }
}
```

## 4. Game Start and Role Assignment

### 4.1 Game Start Coordinator

```dart
// lib/presentation/flows/game_start_coordinator.dart
class GameStartCoordinator {
  final String roomId;
  final GameRepository _repository;
  final RealtimeService _realtimeService;
  
  Future<void> startGame() async {
    try {
      // Step 1: Lock room
      await _repository.updateRoomState(roomId, 'starting');
      
      // Step 2: Create first round
      final round = await _repository.createRound(roomId, 1);
      
      // Step 3: Assign roles
      await _assignRoles(round.id);
      
      // Step 4: Notify all players
      await _realtimeService.broadcastMessage(
        roomId,
        'game_started',
        {
          'round_id': round.id,
          'round_number': 1,
        },
      );
      
      // Step 5: Update room state
      await _repository.updateRoomState(roomId, 'playing');
      
    } catch (e) {
      // Rollback on error
      await _repository.updateRoomState(roomId, 'waiting');
      rethrow;
    }
  }
  
  Future<void> _assignRoles(String roundId) async {
    // Get room settings and players
    final room = await _repository.getRoom(roomId);
    final players = await _repository.getActivePlayers(roomId);
    
    // Validate
    if (players.length < 3) {
      throw GameException('Nicht genug Spieler');
    }
    
    // Shuffle and assign
    final shuffled = List.from(players)..shuffle();
    final impostors = shuffled.take(room.impostorCount).toList();
    
    // Get words
    final words = await _repository.getWordsForRound(
      room.selectedCategories,
      room.difficulty,
    );
    
    // Create role assignments
    final roles = <PlayerRole>[];
    for (final player in players) {
      roles.add(PlayerRole(
        roundId: roundId,
        playerId: player.id,
        isImpostor: impostors.contains(player),
        assignedWordId: impostors.contains(player) 
            ? words.decoyWord.id 
            : words.mainWord.id,
      ));
    }
    
    // Save to database
    await _repository.assignRoles(roles);
  }
}
```

### 4.2 Role Distribution Manager

```dart
// lib/presentation/flows/role_distribution_manager.dart
class RoleDistributionManager {
  final String roundId;
  final RoundBloc _roundBloc;
  final RealtimeService _realtimeService;
  
  StreamSubscription? _roleViewSubscription;
  
  void startDistribution() {
    // Listen for role view confirmations
    _roleViewSubscription = _realtimeService
        .subscribeToRoom(roomId)
        .where((msg) => msg.event == 'role_viewed')
        .listen(_handleRoleViewed);
    
    // Navigate to role screen
    _roundBloc.add(StartRoleReveal(roundId: roundId));
  }
  
  void _handleRoleViewed(RealtimeMessage message) {
    final viewedCount = message.data['viewed_count'] as int;
    final totalCount = message.data['total_count'] as int;
    
    _roundBloc.add(UpdateRoleViewProgress(
      viewedCount: viewedCount,
      totalCount: totalCount,
    ));
    
    // All players viewed their roles
    if (viewedCount == totalCount) {
      _transitionToDiscussion();
    }
  }
  
  void _transitionToDiscussion() {
    Timer(Duration(seconds: 2), () {
      _roundBloc.add(StartDiscussion());
    });
  }
  
  void dispose() {
    _roleViewSubscription?.cancel();
  }
}
```

## 5. Discussion Phase

### 5.1 Discussion Timer Synchronization

```dart
// lib/presentation/screens/multiplayer/discussion/discussion_timer.dart
class SynchronizedDiscussionTimer {
  final String roundId;
  final Duration duration;
  final VoidCallback onComplete;
  
  DateTime? _startTime;
  Timer? _timer;
  StreamController<Duration> _remainingTime = StreamController.broadcast();
  
  Stream<Duration> get remainingTime => _remainingTime.stream;
  
  void start(DateTime serverStartTime) {
    _startTime = serverStartTime;
    
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(_startTime!);
      final remaining = duration - elapsed;
      
      if (remaining.isNegative) {
        _timer?.cancel();
        _remainingTime.add(Duration.zero);
        onComplete();
      } else {
        _remainingTime.add(remaining);
      }
    });
  }
  
  void dispose() {
    _timer?.cancel();
    _remainingTime.close();
  }
}
```

### 5.2 Discussion Screen Implementation

```dart
// lib/presentation/screens/multiplayer/discussion_screen.dart
class MultiplayerDiscussionScreen extends StatefulWidget {
  @override
  _MultiplayerDiscussionScreenState createState() => 
      _MultiplayerDiscussionScreenState();
}

class _MultiplayerDiscussionScreenState 
    extends State<MultiplayerDiscussionScreen> {
  SynchronizedDiscussionTimer? _timer;
  
  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }
  
  void _initializeTimer() {
    final roundState = context.read<RoundBloc>().state;
    if (roundState is RoundDiscussion) {
      _timer = SynchronizedDiscussionTimer(
        roundId: roundState.roundId,
        duration: Duration(seconds: roundState.timerDuration),
        onComplete: _onTimerComplete,
      );
      _timer!.start(roundState.startTime);
    }
  }
  
  void _onTimerComplete() {
    // Auto-transition to voting
    context.read<RoundBloc>().add(StartVoting());
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoundBloc, RoundState>(
      builder: (context, state) {
        if (state is! RoundDiscussion) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Diskussion'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: _DiscussionHeader(
                timer: _timer!,
                category: state.category,
              ),
            ),
          ),
          body: Column(
            children: [
              // Instructions
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Text(
                  'Diskutiert über das Wort ohne es zu nennen! '
                  'Findet die Spione unter euch.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Player list with status
              Expanded(
                child: _PlayerStatusList(
                  players: state.players,
                  currentPlayerId: state.currentPlayerId,
                ),
              ),
              
              // Quick actions
              _QuickActions(),
            ],
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _timer?.dispose();
    super.dispose();
  }
}

class _DiscussionHeader extends StatelessWidget {
  final SynchronizedDiscussionTimer timer;
  final String category;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategorie',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: timer.remainingTime,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              final minutes = duration.inMinutes;
              final seconds = duration.inSeconds % 60;
              
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: duration.inSeconds < 30 
                      ? Colors.red 
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${minutes}:${seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## 6. Voting Phase

### 6.1 Synchronized Voting Manager

```dart
// lib/presentation/flows/voting_manager.dart
class VotingManager {
  final String roundId;
  final RoundBloc _roundBloc;
  final RealtimeService _realtimeService;
  
  StreamSubscription? _voteUpdates;
  final Map<String, bool> _votedPlayers = {};
  
  void startVoting() {
    // Listen for vote updates
    _voteUpdates = _realtimeService
        .subscribeToRoom(roomId)
        .where((msg) => msg.event == 'vote_submitted')
        .listen(_handleVoteUpdate);
    
    // Initialize voting state
    _roundBloc.add(InitializeVoting(roundId: roundId));
  }
  
  void _handleVoteUpdate(RealtimeMessage message) {
    final voterId = message.data['voter_id'] as String;
    _votedPlayers[voterId] = true;
    
    _roundBloc.add(UpdateVotingProgress(
      votedCount: _votedPlayers.length,
      totalCount: message.data['total_players'] as int,
    ));
    
    // Check if all voted
    if (_votedPlayers.length == message.data['total_players']) {
      _processVotingResults();
    }
  }
  
  Future<void> submitVote(String targetPlayerId) async {
    try {
      await _realtimeService.functions.invoke(
        'submit-vote',
        body: {
          'round_id': roundId,
          'target_player_id': targetPlayerId,
        },
      );
      
      _roundBloc.add(VoteSubmitted());
      
    } catch (e) {
      _roundBloc.add(VoteError(e.toString()));
    }
  }
  
  void _processVotingResults() {
    Timer(Duration(seconds: 2), () {
      _roundBloc.add(ShowVotingResults());
    });
  }
  
  void dispose() {
    _voteUpdates?.cancel();
  }
}
```

### 6.2 Interactive Voting UI

```dart
// lib/presentation/screens/multiplayer/voting/voting_screen.dart
class InteractiveVotingScreen extends StatefulWidget {
  @override
  _InteractiveVotingScreenState createState() => 
      _InteractiveVotingScreenState();
}

class _InteractiveVotingScreenState extends State<InteractiveVotingScreen> 
    with SingleTickerProviderStateMixin {
  String? _selectedPlayerId;
  late AnimationController _animationController;
  late VotingManager _votingManager;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    final roundId = context.read<RoundBloc>().state.roundId;
    _votingManager = VotingManager(
      roundId: roundId,
      roundBloc: context.read<RoundBloc>(),
      realtimeService: locator<RealtimeService>(),
    );
    _votingManager.startVoting();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoundBloc, RoundState>(
      builder: (context, state) {
        if (state is! RoundVoting) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Abstimmung'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: _VotingProgress(
                votedCount: state.votedCount,
                totalCount: state.totalPlayers,
                hasVoted: state.hasVoted,
              ),
            ),
          ),
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: state.hasVoted
                ? _VotingWaitScreen(state: state)
                : _VotingSelectionScreen(
                    players: state.players,
                    currentPlayerId: state.currentPlayerId,
                    selectedPlayerId: _selectedPlayerId,
                    onPlayerSelected: (playerId) {
                      setState(() => _selectedPlayerId = playerId);
                      _animationController.forward();
                    },
                    onVoteSubmit: _submitVote,
                  ),
          ),
        );
      },
    );
  }
  
  void _submitVote() {
    if (_selectedPlayerId != null) {
      HapticFeedback.mediumImpact();
      _votingManager.submitVote(_selectedPlayerId!);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _votingManager.dispose();
    super.dispose();
  }
}

class _VotingSelectionScreen extends StatelessWidget {
  final List<Player> players;
  final String currentPlayerId;
  final String? selectedPlayerId;
  final Function(String) onPlayerSelected;
  final VoidCallback onVoteSubmit;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: players.length - 1, // Exclude self
            itemBuilder: (context, index) {
              final player = players
                  .where((p) => p.id != currentPlayerId)
                  .toList()[index];
                  
              final isSelected = player.id == selectedPlayerId;
              
              return _PlayerVoteCard(
                player: player,
                isSelected: isSelected,
                onTap: () => onPlayerSelected(player.id),
              );
            },
          ),
        ),
        
        // Submit button
        Padding(
          padding: EdgeInsets.all(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: selectedPlayerId != null ? onVoteSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPlayerId != null 
                    ? Colors.red 
                    : Colors.grey,
              ),
              child: Text(
                selectedPlayerId != null 
                    ? 'Abstimmen' 
                    : 'Wähle einen Spieler',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## 7. Resolution and Scoring

### 7.1 Resolution Flow

```dart
// lib/presentation/flows/resolution_flow.dart
class ResolutionFlow {
  final String roundId;
  final RoundBloc _roundBloc;
  final GameRepository _repository;
  
  Future<void> resolveRound() async {
    try {
      // Step 1: Get voting results
      final votes = await _repository.getVotes(roundId);
      final voteCounts = _calculateVoteCounts(votes);
      
      // Step 2: Determine eliminated players
      final eliminated = _getEliminatedPlayers(voteCounts);
      
      // Step 3: Check impostor status
      final impostorStatuses = await _checkImpostorStatus(eliminated);
      
      // Step 4: Allow word guessing for surviving impostors
      List<WordGuess>? wordGuesses;
      if (_hasSurvivingImpostors(impostorStatuses)) {
        wordGuesses = await _collectWordGuesses(impostorStatuses);
      }
      
      // Step 5: Calculate scores
      final scores = await _calculateScores(
        eliminated: eliminated,
        impostorStatuses: impostorStatuses,
        wordGuesses: wordGuesses,
      );
      
      // Step 6: Update database
      await _repository.saveRoundResult(
        roundId: roundId,
        eliminated: eliminated,
        scores: scores,
        impostorsWon: _didImpostorsWin(impostorStatuses, wordGuesses),
      );
      
      // Step 7: Show results
      _roundBloc.add(ShowRoundResults(
        eliminated: eliminated,
        impostorStatuses: impostorStatuses,
        scores: scores,
        wordGuesses: wordGuesses,
      ));
      
    } catch (e) {
      _roundBloc.add(ResolutionError(e.toString()));
    }
  }
  
  Map<String, int> _calculateVoteCounts(List<Vote> votes) {
    final counts = <String, int>{};
    for (final vote in votes) {
      counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
    }
    return counts;
  }
  
  List<String> _getEliminatedPlayers(Map<String, int> voteCounts) {
    if (voteCounts.isEmpty) return [];
    
    final maxVotes = voteCounts.values.reduce(max);
    return voteCounts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();
  }
}
```

### 7.2 Results Presentation

```dart
// lib/presentation/screens/multiplayer/results/results_screen.dart
class MultiplayerResultsScreen extends StatefulWidget {
  @override
  _MultiplayerResultsScreenState createState() => 
      _MultiplayerResultsScreenState();
}

class _MultiplayerResultsScreenState extends State<MultiplayerResultsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _scoreController;
  
  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _startRevealSequence();
  }
  
  void _startRevealSequence() async {
    await Future.delayed(Duration(milliseconds: 500));
    await _revealController.forward();
    await Future.delayed(Duration(milliseconds: 500));
    await _scoreController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoundBloc, RoundState>(
      builder: (context, state) {
        if (state is! RoundResults) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          backgroundColor: state.impostorsWon 
              ? Colors.red[900] 
              : Colors.green[900],
          body: SafeArea(
            child: Column(
              children: [
                // Winner announcement
                _WinnerAnnouncement(
                  impostorsWon: state.impostorsWon,
                  animation: _revealController,
                ),
                
                // Eliminated players reveal
                _EliminatedPlayersReveal(
                  eliminated: state.eliminated,
                  animation: _revealController,
                ),
                
                // Word reveal
                if (state.wordGuesses != null)
                  _WordGuessResults(
                    guesses: state.wordGuesses!,
                    mainWord: state.mainWord,
                    animation: _revealController,
                  ),
                
                // Score changes
                Expanded(
                  child: _ScoreBoard(
                    scores: state.scores,
                    animation: _scoreController,
                  ),
                ),
                
                // Next round button
                _NextRoundButton(
                  isLastRound: state.isLastRound,
                  onPressed: () => _handleNextRound(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _handleNextRound(RoundResults state) {
    if (state.isLastRound) {
      context.read<GameBloc>().add(ShowFinalResults());
    } else {
      context.read<GameBloc>().add(StartNextRound());
    }
  }
}

class _WinnerAnnouncement extends StatelessWidget {
  final bool impostorsWon;
  final Animation<double> animation;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: Container(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    impostorsWon ? Icons.warning : Icons.shield,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    impostorsWon ? 'SPIONE GEWINNEN!' : 'TEAM GEWINNT!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 8. Game End and Statistics

### 8.1 Final Results Screen

```dart
// lib/presentation/screens/multiplayer/game_end/final_results_screen.dart
class FinalResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is! GameFinished) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Winner podium
                  _WinnerPodium(
                    players: state.finalScores,
                  ),
                  
                  // Game statistics
                  _GameStatistics(
                    stats: state.gameStats,
                  ),
                  
                  // Player achievements
                  _PlayerAchievements(
                    achievements: state.achievements,
                  ),
                  
                  // Action buttons
                  _ActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WinnerPodium extends StatelessWidget {
  final List<PlayerScore> players;
  
  @override
  Widget build(BuildContext context) {
    final sorted = List.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    
    return Container(
      height: 300,
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (sorted.length > 1)
            _PodiumPlace(
              player: sorted[1],
              place: 2,
              height: 150,
            ),
          _PodiumPlace(
            player: sorted[0],
            place: 1,
            height: 200,
          ),
          if (sorted.length > 2)
            _PodiumPlace(
              player: sorted[2],
              place: 3,
              height: 100,
            ),
        ],
      ),
    );
  }
}
```

### 8.2 Statistics Tracking

```dart
// lib/data/services/statistics_service.dart
class StatisticsService {
  final GameRepository _repository;
  
  Future<GameStatistics> calculateGameStats(String gameId) async {
    final game = await _repository.getGame(gameId);
    final rounds = await _repository.getGameRounds(gameId);
    final players = await _repository.getGamePlayers(gameId);
    
    return GameStatistics(
      totalRounds: rounds.length,
      impostorWins: rounds.where((r) => r.impostorsWon).length,
      teamWins: rounds.where((r) => !r.impostorsWon).length,
      perfectRounds: rounds.where((r) => r.perfectRound).length,
      totalVotes: await _repository.getTotalVotes(gameId),
      correctVotes: await _repository.getCorrectVotes(gameId),
      wordGuesses: await _repository.getWordGuesses(gameId),
      mvpPlayer: _calculateMVP(players),
      bestImpostor: _calculateBestImpostor(players, rounds),
      bestDetective: _calculateBestDetective(players, rounds),
    );
  }
  
  PlayerStats _calculateMVP(List<Player> players) {
    return players.reduce((a, b) => a.score > b.score ? a : b);
  }
  
  PlayerStats _calculateBestImpostor(
    List<Player> players,
    List<Round> rounds,
  ) {
    // Calculate based on successful impostor rounds
    // Implementation...
  }
  
  PlayerStats _calculateBestDetective(
    List<Player> players,
    List<Round> rounds,
  ) {
    // Calculate based on correct votes against impostors
    // Implementation...
  }
}
```

## 9. Error Handling and Recovery

### 9.1 Game State Recovery

```dart
// lib/presentation/flows/game_recovery.dart
class GameRecoveryService {
  final GameRepository _repository;
  final RealtimeService _realtimeService;
  final NavigationService _navigation;
  
  Future<void> recoverGameState(String roomId, String playerId) async {
    try {
      // Get current game state
      final room = await _repository.getRoom(roomId);
      final player = await _repository.getPlayer(playerId);
      
      if (!room.isActive) {
        throw GameException('Spiel beendet');
      }
      
      // Determine current phase
      final phase = await _determineGamePhase(room);
      
      // Navigate to appropriate screen
      switch (phase) {
        case GamePhase.lobby:
          _navigation.navigateToLobby(roomId);
          break;
        case GamePhase.roleReveal:
          final hasViewed = await _repository.hasViewedRole(playerId);
          if (!hasViewed) {
            _navigation.navigateToRoleReveal();
          } else {
            _navigation.navigateToWaiting();
          }
          break;
        case GamePhase.discussion:
          _navigation.navigateToDiscussion();
          break;
        case GamePhase.voting:
          final hasVoted = await _repository.hasVoted(playerId);
          if (!hasVoted) {
            _navigation.navigateToVoting();
          } else {
            _navigation.navigateToWaitingForVotes();
          }
          break;
        case GamePhase.resolution:
          _navigation.navigateToResults();
          break;
        default:
          _navigation.navigateToHome();
      }
      
    } catch (e) {
      _handleRecoveryError(e);
    }
  }
  
  Future<GamePhase> _determineGamePhase(GameRoom room) async {
    if (room.gameState == 'waiting') return GamePhase.lobby;
    
    final currentRound = await _repository.getCurrentRound(room.id);
    if (currentRound == null) return GamePhase.lobby;
    
    switch (currentRound.roundState) {
      case 'role_assignment':
        return GamePhase.roleAssignment;
      case 'role_reveal':
        return GamePhase.roleReveal;
      case 'discussion':
        return GamePhase.discussion;
      case 'voting':
        return GamePhase.voting;
      case 'resolution':
        return GamePhase.resolution;
      default:
        return GamePhase.lobby;
    }
  }
}
```

## Verification Checklist

- [ ] Room creation flow complete
- [ ] Join room with validation
- [ ] Lobby synchronization working
- [ ] Game start coordinator functional
- [ ] Role assignment and distribution
- [ ] Discussion phase with timer
- [ ] Voting system synchronized
- [ ] Resolution flow calculating correctly
- [ ] Results presentation animated
- [ ] Final game statistics
- [ ] Error recovery implemented
- [ ] All transitions smooth

## Common Issues & Solutions

### Issue: Players stuck in role reveal
**Solution**: Implement timeout and force progression after 30 seconds

### Issue: Votes not syncing properly
**Solution**: Use database triggers to ensure consistency

### Issue: Timer desync between players
**Solution**: Use server time as single source of truth

## Next Steps

1. Test complete game flow
2. Add analytics events
3. Implement achievements
4. Proceed to [Testing Plan](./07-testing-plan.md)
