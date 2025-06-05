# Phase 7: Testing Plan

This document provides a comprehensive testing strategy for the WortSpion multiplayer implementation, covering unit tests, integration tests, and end-to-end testing.

## Prerequisites

- [ ] All implementation phases completed (1-6)
- [ ] Test environment configured
- [ ] Testing devices available
- [ ] Supabase test project created

## 1. Testing Architecture

### 1.1 Test Environment Setup

```yaml
# test/config/test_config.yaml
environments:
  unit:
    supabase_url: "http://localhost:54321"
    supabase_anon_key: "test-anon-key"
    use_mock_services: true
    
  integration:
    supabase_url: "https://test-project.supabase.co"
    supabase_anon_key: "test-project-anon-key"
    use_mock_services: false
    
  e2e:
    supabase_url: "https://staging-project.supabase.co"
    supabase_anon_key: "staging-anon-key"
    use_mock_services: false
```

### 1.2 Test Data Management

```dart
// test/fixtures/test_data_builder.dart
class TestDataBuilder {
  final SupabaseClient supabase;
  
  TestDataBuilder(this.supabase);
  
  Future<TestGame> createTestGame({
    int playerCount = 5,
    int impostorCount = 1,
    int roundCount = 3,
  }) async {
    // Create test users
    final users = await _createTestUsers(playerCount);
    
    // Create game room
    final room = await _createTestRoom(
      hostId: users.first.id,
      playerCount: playerCount,
      impostorCount: impostorCount,
      roundCount: roundCount,
    );
    
    // Add players to room
    await _addPlayersToRoom(room.id, users);
    
    return TestGame(
      room: room,
      users: users,
      players: await _getPlayers(room.id),
    );
  }
  
  Future<void> cleanupTestData(String prefix) async {
    // Delete test data in reverse order of dependencies
    await supabase.from('game_events').delete().ilike('room_id', '$prefix%');
    await supabase.from('word_guesses').delete().ilike('round_id', '$prefix%');
    await supabase.from('votes').delete().ilike('round_id', '$prefix%');
    await supabase.from('player_roles').delete().ilike('round_id', '$prefix%');
    await supabase.from('rounds').delete().ilike('room_id', '$prefix%');
    await supabase.from('room_players').delete().ilike('room_id', '$prefix%');
    await supabase.from('game_rooms').delete().ilike('id', '$prefix%');
    await supabase.auth.admin.deleteUser(prefix);
  }
}
```

## 2. Unit Tests

### 2.1 Repository Tests

```dart
// test/unit/repositories/game_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GameRepository', () {
    late MockSupabaseClient mockClient;
    late SupabaseGameRepository repository;
    
    setUp(() {
      mockClient = MockSupabaseClient();
      repository = SupabaseGameRepository(mockClient);
    });
    
    group('createRoom', () {
      test('should create room with valid settings', () async {
        // Arrange
        final settings = GameSettings(
          playerCount: 5,
          impostorCount: 1,
          roundCount: 3,
          timerDuration: 180,
        );
        
        when(mockClient.functions.invoke('create-game-room', body: any))
            .thenAnswer((_) async => FunctionResponse(
              data: {'room_id': 'test-id', 'room_code': 'ABC123'},
              status: 200,
            ));
        
        // Act
        final result = await repository.createRoom(settings, 'TestHost');
        
        // Assert
        expect(result.roomId, 'test-id');
        expect(result.roomCode, 'ABC123');
        verify(mockClient.functions.invoke('create-game-room', body: any)).called(1);
      });
      
      test('should throw exception on invalid impostor count', () async {
        // Arrange
        final settings = GameSettings(
          playerCount: 3,
          impostorCount: 3, // Invalid: should be <= playerCount - 2
          roundCount: 3,
          timerDuration: 180,
        );
        
        // Act & Assert
        expect(
          () => repository.createRoom(settings, 'TestHost'),
          throwsA(isA<ValidationException>()),
        );
      });
    });
    
    group('joinRoom', () {
      test('should join room with valid code', () async {
        // Arrange
        const roomCode = 'ABC123';
        const playerName = 'TestPlayer';
        
        when(mockClient.functions.invoke('join-game-room', body: any))
            .thenAnswer((_) async => FunctionResponse(
              data: {'room_id': 'test-id', 'player_id': 'player-id'},
              status: 200,
            ));
        
        // Act
        final result = await repository.joinRoom(roomCode, playerName);
        
        // Assert
        expect(result.roomId, 'test-id');
        expect(result.playerId, 'player-id');
      });
      
      test('should throw exception when room not found', () async {
        // Arrange
        when(mockClient.functions.invoke('join-game-room', body: any))
            .thenAnswer((_) async => FunctionResponse(
              data: {'error': 'Room not found'},
              status: 404,
            ));
        
        // Act & Assert
        expect(
          () => repository.joinRoom('INVALID', 'Player'),
          throwsA(isA<RoomNotFoundException>()),
        );
      });
    });
  });
}
```

### 2.2 BLoC Tests

```dart
// test/unit/blocs/multiplayer_game_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('MultiplayerGameBloc', () {
    late MockGameRepository mockRepository;
    late MockRealtimeService mockRealtimeService;
    late MultiplayerGameBloc bloc;
    
    setUp(() {
      mockRepository = MockGameRepository();
      mockRealtimeService = MockRealtimeService();
      bloc = MultiplayerGameBloc(
        gameRepository: mockRepository,
        realtimeService: mockRealtimeService,
      );
    });
    
    blocTest<MultiplayerGameBloc, MultiplayerGameState>(
      'emits [Loading, InLobby] when CreateRoom is successful',
      build: () => bloc,
      act: (bloc) => bloc.add(CreateRoom(
        hostName: 'TestHost',
        settings: testGameSettings,
      )),
      setUp: () {
        when(mockRepository.createRoom(any, any))
            .thenAnswer((_) async => CreateRoomResult(
              roomId: 'test-id',
              roomCode: 'ABC123',
            ));
        when(mockRepository.getRoom(any))
            .thenAnswer((_) async => testRoom);
        when(mockRepository.getRoomPlayers(any))
            .thenAnswer((_) async => [testPlayer]);
      },
      expect: () => [
        MultiplayerGameLoading(),
        MultiplayerGameInLobby(
          room: testRoom,
          players: [testPlayer],
          currentPlayerId: 'test-player-id',
        ),
      ],
      verify: (_) {
        verify(mockRealtimeService.subscribeToRoom('test-id')).called(1);
      },
    );
    
    blocTest<MultiplayerGameBloc, MultiplayerGameState>(
      'emits [Error] when room creation fails',
      build: () => bloc,
      act: (bloc) => bloc.add(CreateRoom(
        hostName: 'TestHost',
        settings: testGameSettings,
      )),
      setUp: () {
        when(mockRepository.createRoom(any, any))
            .thenThrow(NetworkException('Connection failed'));
      },
      expect: () => [
        MultiplayerGameLoading(),
        MultiplayerGameError('Connection failed'),
      ],
    );
  });
}
```

### 2.3 Service Tests

```dart
// test/unit/services/realtime_service_test.dart
void main() {
  group('RealtimeService', () {
    late MockSupabaseClient mockClient;
    late SupabaseRealtimeService service;
    late MockRealtimeChannel mockChannel;
    
    setUp(() {
      mockClient = MockSupabaseClient();
      mockChannel = MockRealtimeChannel();
      service = SupabaseRealtimeService(mockClient);
      
      when(mockClient.channel(any)).thenReturn(mockChannel);
    });
    
    test('should subscribe to room events', () async {
      // Arrange
      const roomId = 'test-room';
      final controller = StreamController<RealtimeMessage>();
      
      when(mockChannel.onPostgresChanges(
        event: any,
        table: any,
        filter: any,
        callback: any,
      )).thenReturn(mockChannel);
      
      when(mockChannel.subscribe(any)).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0];
        callback(RealtimeSubscribeStatus.subscribed, null);
        return mockChannel;
      });
      
      // Act
      final stream = service.subscribeToRoom(roomId);
      
      // Assert
      expect(stream, isA<Stream<RealtimeMessage>>());
      verify(mockClient.channel('room:$roomId')).called(1);
      verify(mockChannel.subscribe(any)).called(1);
    });
    
    test('should handle connection errors', () async {
      // Arrange
      when(mockChannel.subscribe(any)).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0];
        callback(RealtimeSubscribeStatus.closed, 'Connection error');
        return mockChannel;
      });
      
      // Act
      final stream = service.subscribeToRoom('test-room');
      
      // Assert
      expect(
        stream,
        emitsError(isA<ConnectionException>()),
      );
    });
  });
}
```

## 3. Integration Tests

### 3.1 API Integration Tests

```dart
// test/integration/api/game_api_test.dart
void main() {
  late SupabaseClient supabase;
  late TestDataBuilder testData;
  
  setUpAll(() async {
    supabase = await createTestSupabaseClient();
    testData = TestDataBuilder(supabase);
  });
  
  tearDown(() async {
    await testData.cleanupTestData('test_');
  });
  
  group('Game API Integration', () {
    test('complete game creation flow', () async {
      // Create test user
      final auth = await supabase.auth.signUp(
        email: 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'testpassword123',
      );
      
      expect(auth.user, isNotNull);
      
      // Create game room
      final createResponse = await supabase.functions.invoke(
        'create-game-room',
        body: {
          'player_count': 5,
          'impostor_count': 1,
          'round_count': 3,
          'timer_duration': 180,
          'impostors_know_each_other': false,
          'selected_categories': ['entertainment', 'sports'],
          'host_name': 'TestHost',
        },
      );
      
      expect(createResponse.status, 200);
      expect(createResponse.data['room_code'], isNotNull);
      
      final roomCode = createResponse.data['room_code'];
      
      // Join room as another player
      final auth2 = await supabase.auth.signUp(
        email: 'test2_${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'testpassword123',
      );
      
      final joinResponse = await supabase.functions.invoke(
        'join-game-room',
        body: {
          'room_code': roomCode,
          'player_name': 'TestPlayer2',
        },
      );
      
      expect(joinResponse.status, 200);
      
      // Verify room state
      final room = await supabase
          .from('game_rooms')
          .select()
          .eq('room_code', roomCode)
          .single();
          
      expect(room['player_count'], 5);
      
      // Verify players
      final players = await supabase
          .from('room_players')
          .select()
          .eq('room_id', room['id']);
          
      expect(players.length, 2);
    });
  });
}
```

### 3.2 Realtime Integration Tests

```dart
// test/integration/realtime/realtime_sync_test.dart
void main() {
  group('Realtime Synchronization', () {
    late SupabaseClient client1;
    late SupabaseClient client2;
    late TestGame testGame;
    
    setUp(() async {
      client1 = await createTestSupabaseClient();
      client2 = await createTestSupabaseClient();
      
      // Create test game
      testGame = await TestDataBuilder(client1).createTestGame();
    });
    
    test('player join events are synchronized', () async {
      // Player 1 subscribes to room
      final events1 = <GameEvent>[];
      client1
          .channel('room:${testGame.room.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            table: 'game_events',
            callback: (payload) {
              events1.add(GameEvent.fromJson(payload.newRecord));
            },
          )
          .subscribe();
      
      // Wait for subscription
      await Future.delayed(Duration(seconds: 1));
      
      // Player 2 joins
      await client2.functions.invoke(
        'join-game-room',
        body: {
          'room_code': testGame.room.roomCode,
          'player_name': 'NewPlayer',
        },
      );
      
      // Wait for event propagation
      await Future.delayed(Duration(seconds: 2));
      
      // Verify player 1 received join event
      expect(events1.any((e) => e.eventType == 'player_joined'), isTrue);
      
      final joinEvent = events1.firstWhere((e) => e.eventType == 'player_joined');
      expect(joinEvent.eventData['player_name'], 'NewPlayer');
    });
    
    test('voting synchronization works correctly', () async {
      // Start game and assign roles
      await startTestGame(testGame);
      
      // Subscribe both clients to voting updates
      final voteCounts = <int>[];
      
      client1
          .channel('room:${testGame.room.id}')
          .onBroadcast(
            event: 'vote_update',
            callback: (payload) {
              voteCounts.add(payload['votes_count']);
            },
          )
          .subscribe();
      
      // Simulate voting
      for (final player in testGame.players) {
        await client1.functions.invoke(
          'submit-vote',
          body: {
            'round_id': testGame.currentRound.id,
            'target_player_id': testGame.players.first.id,
          },
        );
        
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      // Verify vote count updates
      expect(voteCounts.length, testGame.players.length);
      expect(voteCounts.last, testGame.players.length);
    });
  });
}
```

## 4. Widget Tests

### 4.1 Screen Widget Tests

```dart
// test/widget/screens/lobby_screen_test.dart
void main() {
  group('GameLobbyScreen', () {
    late MockMultiplayerGameBloc mockBloc;
    
    setUp(() {
      mockBloc = MockMultiplayerGameBloc();
    });
    
    testWidgets('displays room code prominently', (tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(
        MultiplayerGameInLobby(
          room: GameRoom(
            id: 'test-id',
            roomCode: 'ABC123',
            hostId: 'host-id',
          ),
          players: [],
          currentPlayerId: 'current-id',
        ),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MultiplayerGameBloc>.value(
            value: mockBloc,
            child: GameLobbyScreen(roomId: 'test-id'),
          ),
        ),
      );
      
      // Assert
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });
    
    testWidgets('shows player list with status', (tester) async {
      // Arrange
      final players = [
        RoomPlayer(
          id: 'p1',
          playerName: 'Player 1',
          isReady: true,
          isConnected: true,
        ),
        RoomPlayer(
          id: 'p2',
          playerName: 'Player 2',
          isReady: false,
          isConnected: true,
        ),
      ];
      
      when(mockBloc.state).thenReturn(
        MultiplayerGameInLobby(
          room: testRoom,
          players: players,
          currentPlayerId: 'p1',
        ),
      );
      
      // Act
      await tester.pumpWidget(createTestWidget(mockBloc));
      
      // Assert
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Ready icon
    });
    
    testWidgets('host can start game when all ready', (tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(
        MultiplayerGameInLobby(
          room: GameRoom(
            id: 'test-id',
            roomCode: 'ABC123',
            hostId: 'current-id', // Current user is host
          ),
          players: [
            RoomPlayer(id: 'p1', isReady: true),
            RoomPlayer(id: 'p2', isReady: true),
          ],
          currentPlayerId: 'current-id',
        ),
      );
      
      // Act
      await tester.pumpWidget(createTestWidget(mockBloc));
      
      // Assert
      final startButton = find.widgetWithText(ElevatedButton, 'Spiel starten');
      expect(startButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(startButton).enabled, isTrue);
      
      // Tap start button
      await tester.tap(startButton);
      verify(mockBloc.add(any)).called(1);
    });
  });
}
```

### 4.2 Component Widget Tests

```dart
// test/widget/components/voting_card_test.dart
void main() {
  testWidgets('VotingCard shows selection state', (tester) async {
    // Arrange
    final player = Player(
      id: 'test-id',
      name: 'Test Player',
      score: 10,
    );
    
    bool isSelected = false;
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PlayerVoteCard(
                player: player,
                isSelected: isSelected,
                onTap: () {
                  setState(() => isSelected = true);
                },
              );
            },
          ),
        ),
      ),
    );
    
    // Assert initial state
    expect(find.text('Test Player'), findsOneWidget);
    expect(
      tester.widget<Container>(find.byType(Container)).decoration,
      isNot(contains(Colors.red)),
    );
    
    // Tap card
    await tester.tap(find.byType(PlayerVoteCard));
    await tester.pump();
    
    // Assert selected state
    expect(
      tester.widget<Container>(find.byType(Container)).decoration,
      contains(Colors.red),
    );
  });
}
```

## 5. End-to-End Tests

### 5.1 Complete Game Flow Test

```dart
// test/e2e/complete_game_test.dart
void main() {
  group('Complete Game E2E', () {
    test('5 player game with 1 impostor', () async {
      // Setup
      final testRunner = E2ETestRunner();
      await testRunner.initialize();
      
      // Create 5 test users
      final users = await testRunner.createTestUsers(5);
      
      // Host creates game
      final gameCode = await testRunner.asUser(users[0], (client) async {
        final response = await client.createRoom(
          playerCount: 5,
          impostorCount: 1,
          hostName: 'Host',
        );
        return response.roomCode;
      });
      
      // Other players join
      for (int i = 1; i < 5; i++) {
        await testRunner.asUser(users[i], (client) async {
          await client.joinRoom(gameCode, 'Player$i');
        });
      }
      
      // All players ready up
      await testRunner.allUsers(users, (client) async {
        await client.setReady(true);
      });
      
      // Host starts game
      await testRunner.asUser(users[0], (client) async {
        await client.startGame();
      });
      
      // Wait for role assignment
      await testRunner.waitForGamePhase('role_reveal');
      
      // All players view roles
      final roles = await testRunner.allUsers(users, (client) async {
        return await client.viewRole();
      });
      
      // Verify role distribution
      final impostors = roles.where((r) => r.isImpostor).length;
      expect(impostors, 1);
      
      // Discussion phase
      await testRunner.waitForGamePhase('discussion');
      await testRunner.waitForDuration(Duration(seconds: 10));
      
      // Voting phase
      await testRunner.waitForGamePhase('voting');
      
      // Everyone votes for a random player
      await testRunner.allUsers(users, (client) async {
        final players = await client.getPlayers();
        final target = players.where((p) => p.id != client.playerId).first;
        await client.vote(target.id);
      });
      
      // Wait for results
      await testRunner.waitForGamePhase('resolution');
      
      // Verify round completed
      final roundResult = await testRunner.getRoundResult();
      expect(roundResult, isNotNull);
      expect(roundResult.impostorsWon, isNotNull);
      
      // Continue for remaining rounds...
    });
  });
}
```

### 5.2 Stress Test

```dart
// test/e2e/stress_test.dart
void main() {
  test('handles 10 concurrent games', () async {
    final futures = <Future>[];
    
    for (int i = 0; i < 10; i++) {
      futures.add(_runConcurrentGame(i));
    }
    
    // All games should complete without errors
    await Future.wait(futures);
  });
  
  Future<void> _runConcurrentGame(int gameIndex) async {
    final testRunner = E2ETestRunner();
    await testRunner.initialize();
    
    // Create game with 5 players
    final users = await testRunner.createTestUsers(5, prefix: 'game${gameIndex}_');
    
    // Run through complete game
    await testRunner.runCompleteGame(users);
    
    // Cleanup
    await testRunner.cleanup();
  }
}
```

## 6. Performance Tests

### 6.1 Load Testing

```dart
// test/performance/load_test.dart
void main() {
  group('Performance Tests', () {
    test('room creation performance', () async {
      final times = <Duration>[];
      
      for (int i = 0; i < 100; i++) {
        final stopwatch = Stopwatch()..start();
        
        await createTestRoom();
        
        stopwatch.stop();
        times.add(stopwatch.elapsed);
      }
      
      // Calculate statistics
      final avgTime = times.reduce((a, b) => a + b) ~/ times.length;
      final maxTime = times.reduce((a, b) => a > b ? a : b);
      
      print('Average room creation time: ${avgTime.inMilliseconds}ms');
      print('Max room creation time: ${maxTime.inMilliseconds}ms');
      
      // Assert performance requirements
      expect(avgTime.inMilliseconds, lessThan(500));
      expect(maxTime.inMilliseconds, lessThan(1000));
    });
    
    test('realtime message latency', () async {
      final latencies = <Duration>[];
      
      // Setup two connected clients
      final client1 = await createTestClient();
      final client2 = await createTestClient();
      final room = await createTestRoom();
      
      // Measure message latency
      for (int i = 0; i < 50; i++) {
        final timestamp = DateTime.now();
        
        // Client 1 sends message
        await client1.broadcastMessage(room.id, 'test', {
          'timestamp': timestamp.toIso8601String(),
        });
        
        // Client 2 receives message
        final received = await client2.waitForMessage('test');
        final receivedTime = DateTime.parse(received['timestamp']);
        
        latencies.add(DateTime.now().difference(receivedTime));
      }
      
      // Calculate statistics
      final avgLatency = latencies.reduce((a, b) => a + b) ~/ latencies.length;
      final p95Latency = _calculatePercentile(latencies, 95);
      
      print('Average message latency: ${avgLatency.inMilliseconds}ms');
      print('P95 message latency: ${p95Latency.inMilliseconds}ms');
      
      // Assert latency requirements
      expect(avgLatency.inMilliseconds, lessThan(100));
      expect(p95Latency.inMilliseconds, lessThan(200));
    });
  });
}
```

## 7. Security Tests

### 7.1 Authorization Tests

```dart
// test/security/authorization_test.dart
void main() {
  group('Authorization Tests', () {
    test('non-host cannot start game', () async {
      // Create game as host
      final host = await createTestUser();
      final room = await host.createRoom();
      
      // Join as regular player
      final player = await createTestUser();
      await player.joinRoom(room.roomCode);
      
      // Try to start game as non-host
      expect(
        () => player.startGame(room.id),
        throwsA(isA<UnauthorizedException>()),
      );
    });
    
    test('cannot vote twice in same round', () async {
      final game = await createAndStartTestGame();
      final player = game.players.first;
      
      // First vote should succeed
      await player.vote(game.players[1].id);
      
      // Second vote should fail
      expect(
        () => player.vote(game.players[2].id),
        throwsA(isA<AlreadyVotedException>()),
      );
    });
    
    test('cannot see other players roles', () async {
      final game = await createAndStartTestGame();
      final player1 = game.players[0];
      final player2 = game.players[1];
      
      // Try to access another player's role
      expect(
        () => player1.getPlayerRole(player2.id),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
```

### 7.2 Input Validation Tests

```dart
// test/security/validation_test.dart
void main() {
  group('Input Validation', () {
    test('rejects invalid room codes', () async {
      final invalidCodes = [
        '',          // Empty
        'ABC',       // Too short
        'ABCDEFG',   // Too long
        'ABC 123',   // Contains space
        'ABC-123',   // Contains invalid character
        '<script>',  // XSS attempt
      ];
      
      for (final code in invalidCodes) {
        expect(
          () => validateRoomCode(code),
          throwsA(isA<ValidationException>()),
          reason: 'Should reject: $code',
        );
      }
    });
    
    test('sanitizes player names', () async {
      final testCases = {
        '<script>alert("xss")</script>': 'alert("xss")',
        'Normal Name': 'Normal Name',
        '   Trimmed   ': 'Trimmed',
        'Very Long Name That Exceeds Maximum Length': 'Very Long Name That Ex',
      };
      
      for (final entry in testCases.entries) {
        final sanitized = sanitizePlayerName(entry.key);
        expect(sanitized, entry.value);
      }
    });
  });
}
```

## 8. Test Utilities

### 8.1 Test Helpers

```dart
// test/helpers/test_helpers.dart
class TestHelpers {
  static Future<Widget> createTestApp({
    required Widget child,
    List<BlocProvider> providers = const [],
  }) async {
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        home: child,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('de')],
      ),
    );
  }
  
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  }
  
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);
    
    do {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    } while (DateTime.now().isBefore(end));
    
    throw TestFailure('Timeout waiting for $finder');
  }
}
```

### 8.2 Mock Factories

```dart
// test/mocks/mock_factories.dart
class MockFactories {
  static GameRoom createMockRoom({
    String? id,
    String? roomCode,
    String? hostId,
    int playerCount = 5,
  }) {
    return GameRoom(
      id: id ?? 'mock-room-${Random().nextInt(1000)}',
      roomCode: roomCode ?? 'MOCK${Random().nextInt(1000)}',
      hostId: hostId ?? 'mock-host-id',
      playerCount: playerCount,
      impostorCount: 1,
      roundCount: 3,
      timerDuration: 180,
      gameState: 'waiting',
      selectedCategories: ['entertainment', 'sports'],
      createdAt: DateTime.now(),
    );
  }
  
  static RoomPlayer createMockPlayer({
    String? id,
    String? userId,
    String? playerName,
    bool isReady = false,
    bool isConnected = true,
  }) {
    return RoomPlayer(
      id: id ?? 'mock-player-${Random().nextInt(1000)}',
      userId: userId ?? 'mock-user-${Random().nextInt(1000)}',
      playerName: playerName ?? 'MockPlayer${Random().nextInt(100)}',
      playerOrder: Random().nextInt(10) + 1,
      isReady: isReady,
      isConnected: isConnected,
      score: 0,
    );
  }
}
```

## 9. Test Execution Strategy

### 9.1 Test Pipeline

```yaml
# .github/workflows/test.yml
name: Test Pipeline

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/unit --coverage
      - uses: codecov/codecov-action@v3
  
  widget-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/widget
  
  integration-tests:
    runs-on: ubuntu-latest
    services:
      supabase:
        image: supabase/postgres:14
        env:
          POSTGRES_PASSWORD: postgres
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/integration
  
  e2e-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - uses: futureware-tech/simulator-action@v2
      - run: flutter pub get
      - run: flutter test test/e2e
```

### 9.2 Test Coverage Requirements

```yaml
# coverage_config.yaml
coverage:
  minimum: 80
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/generated/**"
  
  thresholds:
    unit: 90
    widget: 80
    integration: 70
    
  report:
    html: true
    lcov: true
    console: true
```

## 10. Test Checklist

### Unit Tests
- [ ] All repositories have 90%+ coverage
- [ ] All BLoCs have complete event/state tests
- [ ] All services have error case tests
- [ ] All validators have edge case tests

### Integration Tests
- [ ] API endpoints tested with real Supabase
- [ ] Realtime synchronization verified
- [ ] Error handling flows tested
- [ ] Performance benchmarks passing

### Widget Tests
- [ ] All screens have basic widget tests
- [ ] Interactive components tested
- [ ] Navigation flows verified
- [ ] Accessibility tests passing

### E2E Tests
- [ ] Complete game flow works
- [ ] Concurrent games supported
- [ ] Reconnection scenarios handled
- [ ] Edge cases covered

### Security Tests
- [ ] Authorization rules enforced
- [ ] Input validation comprehensive
- [ ] No data leaks between players
- [ ] Rate limiting functional

### Performance Tests
- [ ] Room creation < 500ms avg
- [ ] Message latency < 100ms avg
- [ ] 10+ concurrent games supported
- [ ] Memory usage stable

## Next Steps

1. Set up CI/CD pipeline
2. Configure test environments
3. Create test data seeders
4. Proceed to [Deployment](./08-deployment.md)
