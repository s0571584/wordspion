# Phase 5: Frontend Migration

This document covers the migration of the Flutter app from single-device to multiplayer functionality, maintaining backward compatibility.

## Prerequisites

- [ ] Database setup completed (Phase 1)
- [ ] Authentication implemented (Phase 2)
- [ ] Backend functions deployed (Phase 3)
- [ ] Realtime architecture ready (Phase 4)
- [ ] Understanding of existing app structure

## 1. App Architecture Updates

### 1.1 Dependency Injection Updates

```dart
// lib/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  // Core services
  locator.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  
  // Repositories - with mode switching
  locator.registerLazySingleton<GameRepository>(
    () => HybridGameRepository(
      local: SQLiteGameRepository(locator()),
      remote: SupabaseGameRepository(locator()),
    ),
  );
  
  locator.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(locator()),
  );
  
  locator.registerLazySingleton<RealtimeService>(
    () => SupabaseRealtimeService(locator()),
  );
  
  // BLoCs
  locator.registerFactory<AuthBloc>(
    () => AuthBloc(locator()),
  );
  
  locator.registerFactory<GameModeBloc>(
    () => GameModeBloc(),
  );
  
  locator.registerFactory<LocalGameBloc>(
    () => LocalGameBloc(locator()),
  );
  
  locator.registerFactory<MultiplayerGameBloc>(
    () => MultiplayerGameBloc(
      gameRepository: locator(),
      realtimeService: locator(),
    ),
  );
}
```

### 1.2 Hybrid Repository Pattern

```dart
// lib/data/repositories/hybrid_game_repository.dart
class HybridGameRepository implements GameRepository {
  final GameRepository local;
  final GameRepository remote;
  GameMode _currentMode = GameMode.local;
  
  HybridGameRepository({
    required this.local,
    required this.remote,
  });
  
  void setMode(GameMode mode) {
    _currentMode = mode;
  }
  
  GameRepository get _activeRepository {
    return _currentMode == GameMode.local ? local : remote;
  }
  
  @override
  Future<Game> createGame(GameSettings settings) {
    return _activeRepository.createGame(settings);
  }
  
  @override
  Future<void> saveGameState(Game game) {
    return _activeRepository.saveGameState(game);
  }
  
  // Implement all other methods with delegation...
}
```

## 2. Navigation Updates

### 2.1 Updated Router Configuration

```dart
// lib/core/navigation/app_router.dart
@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashScreen, initial: true),
    
    // Auth routes
    AutoRoute(page: SignInScreen),
    AutoRoute(page: SignUpScreen),
    
    // Main menu
    AutoRoute(page: HomeScreen),
    
    // Game mode selection
    AutoRoute(page: GameModeScreen),
    
    // Local game routes (existing)
    CustomRoute(
      page: LocalGameWrapper,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      children: [
        AutoRoute(page: GameSetupScreen),
        AutoRoute(page: PlayerRegistrationScreen),
        AutoRoute(page: RoleRevealScreen),
        AutoRoute(page: DiscussionScreen),
        AutoRoute(page: VotingScreen),
        AutoRoute(page: ResultsScreen),
      ],
    ),
    
    // Multiplayer routes (new)
    CustomRoute(
      page: MultiplayerGameWrapper,
      guards: [AuthGuard],
      transitionsBuilder: TransitionsBuilders.slideLeft,
      children: [
        AutoRoute(page: CreateRoomScreen),
        AutoRoute(page: JoinRoomScreen),
        AutoRoute(page: GameLobbyScreen),
        AutoRoute(page: MultiplayerRoleScreen),
        AutoRoute(page: MultiplayerDiscussionScreen),
        AutoRoute(page: MultiplayerVotingScreen),
        AutoRoute(page: MultiplayerResultsScreen),
      ],
    ),
    
    // Profile routes
    AutoRoute(page: ProfileScreen, guards: [AuthGuard]),
    AutoRoute(page: SettingsScreen),
  ],
)
class $AppRouter {}

// Auth guard
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authBloc = locator<AuthBloc>();
    
    if (authBloc.state is AuthAuthenticated) {
      resolver.next(true);
    } else {
      router.push(SignInRoute());
    }
  }
}
```

## 3. Home Screen Updates

### 3.1 Enhanced Home Screen

```dart
// lib/presentation/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is AuthAuthenticated;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('WortSpion'),
            actions: [
              if (isAuthenticated)
                IconButton(
                  icon: CircleAvatar(
                    child: Text(authState.profile.displayName[0]),
                  ),
                  onPressed: () => context.router.push(ProfileRoute()),
                ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                SizedBox(height: 48),
                
                // Play button
                _MenuButton(
                  icon: Icons.play_arrow,
                  label: 'Spielen',
                  onPressed: () => context.router.push(GameModeRoute()),
                ),
                
                // Player groups (existing feature)
                _MenuButton(
                  icon: Icons.group,
                  label: 'Spielergruppen',
                  onPressed: () => context.router.push(PlayerGroupsRoute()),
                ),
                
                // Profile/Login
                if (!isAuthenticated)
                  _MenuButton(
                    icon: Icons.person,
                    label: 'Anmelden',
                    onPressed: () => context.router.push(SignInRoute()),
                  )
                else
                  _MenuButton(
                    icon: Icons.leaderboard,
                    label: 'Bestenliste',
                    onPressed: () => context.router.push(LeaderboardRoute()),
                  ),
                
                // Settings
                _MenuButton(
                  icon: Icons.settings,
                  label: 'Einstellungen',
                  onPressed: () => context.router.push(SettingsRoute()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### 3.2 Game Mode Selection

```dart
// lib/presentation/screens/game_mode_screen.dart
class GameModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spielmodus wählen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Local game mode
            _ModeCard(
              icon: Icons.phone_android,
              title: 'Lokal spielen',
              subtitle: 'Ein Gerät wird herumgereicht',
              features: [
                '3-10 Spieler',
                'Kein Internet nötig',
                'Klassisches Spielerlebnis',
              ],
              onTap: () {
                context.read<GameModeBloc>().add(SelectLocalMode());
                context.router.push(GameSetupRoute());
              },
            ),
            
            SizedBox(height: 24),
            
            // Multiplayer mode
            _ModeCard(
              icon: Icons.wifi,
              title: 'Online spielen',
              subtitle: 'Jeder nutzt sein eigenes Gerät',
              features: [
                '3-10 Spieler',
                'Echtzeit-Synchronisation',
                'Statistiken & Rangliste',
              ],
              requiresAuth: true,
              onTap: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<GameModeBloc>().add(SelectMultiplayerMode());
                  _showMultiplayerOptions(context);
                } else {
                  context.router.push(SignInRoute());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showMultiplayerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Neues Spiel erstellen'),
              subtitle: Text('Erstelle einen Raum für deine Freunde'),
              onTap: () {
                Navigator.pop(context);
                context.router.push(CreateRoomRoute());
              },
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Spiel beitreten'),
              subtitle: Text('Tritt einem bestehenden Spiel bei'),
              onTap: () {
                Navigator.pop(context);
                context.router.push(JoinRoomRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 4. Multiplayer Screens

### 4.1 Create Room Screen

```dart
// lib/presentation/screens/multiplayer/create_room_screen.dart
class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  
  // Game settings (reuse from local game)
  int _playerCount = 5;
  int _impostorCount = 1;
  int _roundCount = 3;
  int _timerDuration = 180;
  bool _impostorsKnowEachOther = false;
  List<String> _selectedCategories = ['entertainment', 'sports', 'animals', 'food'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spiel erstellen'),
      ),
      body: BlocConsumer<MultiplayerGameBloc, MultiplayerGameState>(
        listener: (context, state) {
          if (state is MultiplayerGameInLobby) {
            context.router.replace(GameLobbyRoute(roomId: state.room.id));
          } else if (state is MultiplayerGameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MultiplayerGameLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Player name
                TextFormField(
                  controller: _playerNameController,
                  decoration: InputDecoration(
                    labelText: 'Dein Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Bitte Namen eingeben';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 32),
                Text(
                  'Spieleinstellungen',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                
                // Player count
                _SettingTile(
                  icon: Icons.group,
                  title: 'Spieleranzahl',
                  value: _playerCount.toString(),
                  onTap: () => _showNumberPicker(
                    title: 'Spieleranzahl',
                    min: 3,
                    max: 10,
                    current: _playerCount,
                    onChanged: (value) {
                      setState(() {
                        _playerCount = value;
                        // Adjust impostor count if needed
                        if (_impostorCount > _playerCount - 2) {
                          _impostorCount = max(1, _playerCount - 2);
                        }
                      });
                    },
                  ),
                ),
                
                // Impostor count
                _SettingTile(
                  icon: Icons.person_outline,
                  title: 'Anzahl Spione',
                  value: _impostorCount.toString(),
                  onTap: () => _showNumberPicker(
                    title: 'Anzahl Spione',
                    min: 1,
                    max: _playerCount - 2,
                    current: _impostorCount,
                    onChanged: (value) {
                      setState(() => _impostorCount = value);
                    },
                  ),
                ),
                
                // Round count
                _SettingTile(
                  icon: Icons.repeat,
                  title: 'Rundenanzahl',
                  value: _roundCount.toString(),
                  onTap: () => _showNumberPicker(
                    title: 'Rundenanzahl',
                    min: 1,
                    max: 10,
                    current: _roundCount,
                    onChanged: (value) {
                      setState(() => _roundCount = value);
                    },
                  ),
                ),
                
                // Timer
                _SettingTile(
                  icon: Icons.timer,
                  title: 'Timer',
                  value: '${_timerDuration ~/ 60}:${(_timerDuration % 60).toString().padLeft(2, '0')}',
                  onTap: () => _showTimerPicker(),
                ),
                
                // Impostors know each other
                SwitchListTile(
                  secondary: Icon(Icons.visibility),
                  title: Text('Spione kennen sich'),
                  value: _impostorsKnowEachOther,
                  onChanged: (value) {
                    setState(() => _impostorsKnowEachOther = value);
                  },
                ),
                
                // Categories
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Kategorien'),
                  subtitle: Text('${_selectedCategories.length} ausgewählt'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => _showCategorySelection(),
                ),
                
                SizedBox(height: 32),
                
                // Create button
                ElevatedButton(
                  onPressed: _createRoom,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Raum erstellen'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _createRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MultiplayerGameBloc>().add(
        CreateRoom(
          hostName: _playerNameController.text,
          settings: GameSettings(
            playerCount: _playerCount,
            impostorCount: _impostorCount,
            roundCount: _roundCount,
            timerDuration: _timerDuration,
            impostorsKnowEachOther: _impostorsKnowEachOther,
            selectedCategories: _selectedCategories,
          ),
        ),
      );
    }
  }
}
```

### 4.2 Join Room Screen

```dart
// lib/presentation/screens/multiplayer/join_room_screen.dart
class JoinRoomScreen extends StatefulWidget {
  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();
  final _playerNameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spiel beitreten'),
      ),
      body: BlocConsumer<MultiplayerGameBloc, MultiplayerGameState>(
        listener: (context, state) {
          if (state is MultiplayerGameInLobby) {
            context.router.replace(GameLobbyRoute(roomId: state.room.id));
          } else if (state is MultiplayerGameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MultiplayerGameLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Room code input
                  TextFormField(
                    controller: _roomCodeController,
                    decoration: InputDecoration(
                      labelText: 'Raumcode',
                      hintText: 'z.B. ABC123',
                      prefixIcon: Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code_scanner),
                        onPressed: () => _scanQRCode(),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bitte Raumcode eingeben';
                      }
                      if (value!.length != 6) {
                        return 'Raumcode muss 6 Zeichen haben';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Player name
                  TextFormField(
                    controller: _playerNameController,
                    decoration: InputDecoration(
                      labelText: 'Dein Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bitte Namen eingeben';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 48),
                  
                  // Join button
                  ElevatedButton(
                    onPressed: _joinRoom,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      child: Text('Beitreten'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _joinRoom() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MultiplayerGameBloc>().add(
        JoinRoom(
          roomCode: _roomCodeController.text.toUpperCase(),
          playerName: _playerNameController.text,
        ),
      );
    }
  }
  
  Future<void> _scanQRCode() async {
    // Implement QR code scanning
    // Set _roomCodeController.text with scanned code
  }
}
```

### 4.3 Multiplayer Role Screen

```dart
// lib/presentation/screens/multiplayer/multiplayer_role_screen.dart
class MultiplayerRoleScreen extends StatefulWidget {
  @override
  _MultiplayerRoleScreenState createState() => _MultiplayerRoleScreenState();
}

class _MultiplayerRoleScreenState extends State<MultiplayerRoleScreen> {
  bool _roleViewed = false;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoundBloc, RoundState>(
      listener: (context, state) {
        if (state is RoundDiscussionStarted) {
          context.router.replace(MultiplayerDiscussionRoute());
        }
      },
      builder: (context, state) {
        if (state is! RoundRoleReady && state is! RoundRoleRevealed) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final role = state is RoundRoleRevealed ? state.role : null;
        
        return Scaffold(
          backgroundColor: _roleViewed && role?.isImpostor == true
              ? Colors.red[900]
              : Theme.of(context).colorScheme.primary,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_roleViewed) ...[
                    Icon(
                      Icons.touch_app,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Tippe um deine Rolle zu sehen',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _revealRole,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        child: Text('Rolle anzeigen'),
                      ),
                    ),
                  ] else if (role != null) ...[
                    Icon(
                      role.isImpostor ? Icons.person_outline : Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      role.isImpostor ? 'SPION' : 'TEAMMITGLIED',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Dein Wort:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      role.word,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (role.isImpostor && role.otherImpostors.isNotEmpty) ...[
                      SizedBox(height: 32),
                      Text(
                        'Andere Spione:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...role.otherImpostors.map((name) => Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      )),
                    ],
                    SizedBox(height: 48),
                    if (state is RoundRoleRevealed) ...[
                      Text(
                        'Warte auf andere Spieler...',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: state.viewedCount / state.totalPlayers,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${state.viewedCount} / ${state.totalPlayers}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _revealRole() {
    setState(() => _roleViewed = true);
    context.read<RoundBloc>().add(ViewRole());
  }
}
```

## 5. State Management Updates

### 5.1 Game Mode BLoC

```dart
// lib/blocs/game_mode/game_mode_bloc.dart
enum GameMode { local, multiplayer }

class GameModeBloc extends Bloc<GameModeEvent, GameModeState> {
  GameModeBloc() : super(GameModeState(mode: GameMode.local)) {
    on<SelectLocalMode>((event, emit) {
      emit(GameModeState(mode: GameMode.local));
      // Update repository mode
      locator<HybridGameRepository>().setMode(GameMode.local);
    });
    
    on<SelectMultiplayerMode>((event, emit) {
      emit(GameModeState(mode: GameMode.multiplayer));
      // Update repository mode
      locator<HybridGameRepository>().setMode(GameMode.multiplayer);
    });
  }
}
```

### 5.2 Unified Game Interface

```dart
// lib/core/interfaces/game_interface.dart
abstract class GameInterface {
  Stream<GameState> get gameState;
  Stream<List<Player>> get players;
  Stream<RoundState> get currentRound;
  
  Future<void> createGame(GameSettings settings);
  Future<void> joinGame(String code, String playerName);
  Future<void> startGame();
  Future<void> submitVote(String targetPlayerId);
  Future<void> submitWordGuess(String word);
  
  void dispose();
}

// Local implementation
class LocalGameInterface implements GameInterface {
  final LocalGameBloc _gameBloc;
  final PlayerBloc _playerBloc;
  final RoundBloc _roundBloc;
  
  // Implementation...
}

// Multiplayer implementation
class MultiplayerGameInterface implements GameInterface {
  final MultiplayerGameBloc _gameBloc;
  final RoundBloc _roundBloc;
  
  // Implementation...
}
```

## 6. UI Components Updates

### 6.1 Adaptive Components

```dart
// lib/presentation/widgets/adaptive_player_list.dart
class AdaptivePlayerList extends StatelessWidget {
  final List<Player> players;
  final bool isMultiplayer;
  final String? currentPlayerId;
  
  @override
  Widget build(BuildContext context) {
    if (isMultiplayer) {
      return _MultiplayerPlayerList(
        players: players,
        currentPlayerId: currentPlayerId,
      );
    } else {
      return _LocalPlayerList(players: players);
    }
  }
}

class _MultiplayerPlayerList extends StatelessWidget {
  final List<Player> players;
  final String? currentPlayerId;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isCurrentPlayer = player.id == currentPlayerId;
        
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: player.isConnected 
                    ? Colors.green 
                    : Colors.grey,
                child: Text(player.name[0]),
              ),
              if (!player.isConnected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            player.name,
            style: TextStyle(
              fontWeight: isCurrentPlayer ? FontWeight.bold : null,
            ),
          ),
          subtitle: Text('${player.score} Punkte'),
          trailing: player.hasVoted 
              ? Icon(Icons.check, color: Colors.green)
              : null,
        );
      },
    );
  }
}
```

### 6.2 Connection Status Banner

```dart
// lib/presentation/widgets/connection_banner.dart
class ConnectionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        if (state is ConnectionConnected) {
          return SizedBox.shrink();
        }
        
        return MaterialBanner(
          content: Row(
            children: [
              if (state is ConnectionReconnecting)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              SizedBox(width: 8),
              Text(_getMessage(state)),
            ],
          ),
          backgroundColor: _getColor(state),
          actions: [
            if (state is ConnectionFailed)
              TextButton(
                onPressed: () {
                  context.read<ConnectionBloc>().add(RetryConnection());
                },
                child: Text('Wiederholen'),
              ),
          ],
        );
      },
    );
  }
  
  String _getMessage(ConnectionState state) {
    if (state is ConnectionDisconnected) {
      return 'Verbindung verloren';
    } else if (state is ConnectionReconnecting) {
      return 'Verbindung wird wiederhergestellt...';
    } else if (state is ConnectionFailed) {
      return 'Verbindung fehlgeschlagen';
    }
    return '';
  }
  
  Color _getColor(ConnectionState state) {
    if (state is ConnectionDisconnected) return Colors.orange;
    if (state is ConnectionReconnecting) return Colors.blue;
    if (state is ConnectionFailed) return Colors.red;
    return Colors.transparent;
  }
}
```

## 7. Settings Migration

### 7.1 Settings Service Update

```dart
// lib/core/services/settings_service.dart
class SettingsService {
  static const String _keyGameMode = 'game_mode';
  static const String _keyUsername = 'username';
  static const String _keyAutoLogin = 'auto_login';
  
  final SharedPreferences _prefs;
  
  SettingsService(this._prefs);
  
  // Game mode preference
  GameMode get preferredGameMode {
    final mode = _prefs.getString(_keyGameMode);
    return mode == 'multiplayer' ? GameMode.multiplayer : GameMode.local;
  }
  
  Future<void> setPreferredGameMode(GameMode mode) async {
    await _prefs.setString(_keyGameMode, mode.name);
  }
  
  // Username for quick join
  String? get savedUsername => _prefs.getString(_keyUsername);
  
  Future<void> setSavedUsername(String username) async {
    await _prefs.setString(_keyUsername, username);
  }
  
  // Auto login preference
  bool get autoLogin => _prefs.getBool(_keyAutoLogin) ?? true;
  
  Future<void> setAutoLogin(bool value) async {
    await _prefs.setBool(_keyAutoLogin, value);
  }
  
  // Migrate old settings
  Future<void> migrateSettings() async {
    // Check if migration needed
    if (!_prefs.containsKey('settings_version')) {
      // Migrate game settings keys
      final oldPlayerCount = _prefs.getInt('playerCount');
      if (oldPlayerCount != null) {
        await _prefs.setInt('game_player_count', oldPlayerCount);
        await _prefs.remove('playerCount');
      }
      
      // Set migration complete
      await _prefs.setInt('settings_version', 1);
    }
  }
}
```

## 8. Asset Updates

### 8.1 New Assets Required

```yaml
# pubspec.yaml
flutter:
  assets:
    # Existing assets
    - assets/images/logo.png
    - assets/images/spies/
    - assets/images/teammembers/
    
    # New assets for multiplayer
    - assets/images/multiplayer/
    - assets/animations/
    - assets/sounds/
    
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/custom-regular.ttf
        - asset: assets/fonts/custom-bold.ttf
          weight: 700
```

### 8.2 Localization Updates

```dart
// lib/core/localization/app_localizations.dart
class AppLocalizations {
  // New multiplayer strings
  static const multiplayerStrings = {
    'create_room': 'Raum erstellen',
    'join_room': 'Raum beitreten',
    'room_code': 'Raumcode',
    'waiting_for_players': 'Warte auf Spieler...',
    'player_disconnected': '{name} hat die Verbindung verloren',
    'player_joined': '{name} ist beigetreten',
    'all_players_ready': 'Alle Spieler sind bereit!',
    'connection_lost': 'Verbindung verloren',
    'reconnecting': 'Verbindung wird wiederhergestellt...',
    'vote_submitted': 'Stimme abgegeben',
    'waiting_for_votes': 'Warte auf andere Spieler...',
  };
}
```

## 9. Performance Optimizations

### 9.1 Lazy Loading

```dart
// lib/core/navigation/app_router.dart
// Use lazy loading for multiplayer features
AutoRoute(
  page: EmptyRouterPage,
  name: 'MultiplayerRouter',
  children: [
    AutoRoute(
      page: CreateRoomScreen,
      customRouteBuilder: (context, child, page) {
        return PageRouteBuilder(
          settings: page,
          pageBuilder: (context, animation, secondaryAnimation) {
            return FutureBuilder(
              future: _loadMultiplayerModule(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return child;
                }
                return Center(child: CircularProgressIndicator());
              },
            );
          },
        );
      },
    ),
  ],
),
```

### 9.2 State Caching

```dart
// lib/core/cache/game_cache.dart
class GameCache {
  final Map<String, CachedGame> _cache = {};
  final Duration _cacheDuration = Duration(minutes: 5);
  
  void cacheGame(String gameId, Game game) {
    _cache[gameId] = CachedGame(
      game: game,
      timestamp: DateTime.now(),
    );
  }
  
  Game? getCachedGame(String gameId) {
    final cached = _cache[gameId];
    if (cached == null) return null;
    
    final age = DateTime.now().difference(cached.timestamp);
    if (age > _cacheDuration) {
      _cache.remove(gameId);
      return null;
    }
    
    return cached.game;
  }
  
  void clearCache() {
    _cache.clear();
  }
}
```

## Verification Checklist

- [ ] Dependency injection updated with Supabase
- [ ] Hybrid repository pattern implemented
- [ ] Navigation updated with auth guards
- [ ] Home screen shows multiplayer option
- [ ] Game mode selection working
- [ ] Create room flow complete
- [ ] Join room with code/QR working
- [ ] Multiplayer screens adapted
- [ ] Connection status shown
- [ ] Settings migrated properly
- [ ] Localization updated
- [ ] Performance optimizations applied
- [ ] Backward compatibility maintained

## Common Issues & Solutions

### Issue: State not syncing between screens
**Solution**: Ensure BLoCs are provided at the correct level in widget tree

### Issue: Navigation guards not working
**Solution**: Check AuthBloc is initialized before navigation

### Issue: Connection banner showing incorrectly
**Solution**: Verify ConnectionBloc is listening to realtime service

## Next Steps

1. Test all screens with mock data
2. Verify local game mode still works
3. Test multiplayer flow end-to-end
4. Proceed to [Game Flow](./06-game-flow.md)
