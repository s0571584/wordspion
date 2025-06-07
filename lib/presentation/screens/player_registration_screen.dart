import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/player/player_bloc.dart';
import 'package:wortspion/blocs/player/player_event.dart';
import 'package:wortspion/blocs/player/player_state.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/di/injection_container.dart';

@RoutePage()
class PlayerRegistrationScreen extends StatefulWidget {
  final Game? game;

  const PlayerRegistrationScreen({
    super.key,
    this.game,
  });

  @override
  State<PlayerRegistrationScreen> createState() => _PlayerRegistrationScreenState();
}

class _PlayerRegistrationScreenState extends State<PlayerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameControllers = <TextEditingController>[];
  final int _minPlayers = 3;
  late int _playerCount;
  late Game? _game;
  late PlayerBloc _playerBloc;

  @override
  void initState() {
    super.initState();

    _game = widget.game;
    _playerBloc = sl<PlayerBloc>();

    // Initialize with the game's player count or default to min players
    _playerCount = _game?.playerCount ?? _minPlayers;

    // Initialize controllers based on the game's player count
    for (int i = 0; i < _playerCount; i++) {
      _nameControllers.add(TextEditingController());
    }

    debugPrint('PlayerRegistrationScreen initialized with $_playerCount players');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If game wasn't passed as a parameter, try to get it from the GameBloc
    if (_game == null) {
      try {
        final gameState = context.read<GameBloc>().state;
        if (gameState is GameCreated) {
          setState(() {
            _game = gameState.game;

            // Update player count if needed
            if (_game!.playerCount != _playerCount) {
              _updatePlayerCount(_game!.playerCount);
            }
          });
        } else if (gameState is GameInProgress) {
          setState(() {
            _game = gameState.game;

            // Update player count if needed
            if (_game!.playerCount != _playerCount) {
              _updatePlayerCount(_game!.playerCount);
            }
          });
        }
      } catch (e) {
        debugPrint('Error accessing GameBloc: $e');
      }
    }
  }

  void _updatePlayerCount(int newCount) {
    // Remove excess controllers
    while (_nameControllers.length > newCount) {
      final controller = _nameControllers.removeLast();
      controller.dispose();
    }

    // Add new controllers if needed
    while (_nameControllers.length < newCount) {
      _nameControllers.add(TextEditingController());
    }

    _playerCount = newCount;
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    setState(() {
      _playerCount++;
      _nameControllers.add(TextEditingController());
    });
  }

  void _removePlayer() {
    if (_playerCount > _minPlayers) {
      setState(() {
        _playerCount--;
        final controller = _nameControllers.removeLast();
        controller.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _playerBloc),
      ],
      child: Builder(
        builder: (context) => BlocListener<PlayerBloc, PlayerState>(
          listener: (context, state) {
            if (state is PlayersRegistered) {
              if (state.players.isNotEmpty) {
                final gameId = state.players.first.gameId;
                debugPrint('Navigation to RoleRevealScreen with gameId: $gameId');

                // Read GameBloc BEFORE navigation, while context is still valid
                final gameBloc = context.read<GameBloc>();

                // Navigate to role reveal screen
                context.router.navigate(RoleRevealRoute(gameId: gameId));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fehler: Keine Spieler für das Spiel registriert oder gameId fehlt.')),
                );
              }
            } else if (state is PlayerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fehler: ${state.message}')),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Spieleranmeldung'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Spieleinstellungen ändern',
                  onPressed: () async {
                    // Navigate to game setup screen using AutoRoute
                    await context.router.push(GameSetupRoute(isSettingsOnly: true));

                    // When returning, check if game was updated
                    if (mounted) {
                      final gameBloc = context.read<GameBloc>();
                      final playerBloc = context.read<PlayerBloc>(); // Get PlayerBloc from context

                      final gameState = gameBloc.state;
                      if (gameState is GameCreated || gameState is GameInProgress) {
                        final game = gameState is GameCreated ? gameState.game : (gameState as GameInProgress).game;

                        // Update the UI with the potentially updated game settings
                        setState(() {
                          _game = game;
                          _updatePlayerCount(game.playerCount);
                        });

                        // Reset PlayerBloc to its initial state to force re-registration
                        // if settings (like player count) changed.
                        playerBloc.add(const ResetPlayerState());
                      }
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spieler Namen eingeben',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _playerCount,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextFormField(
                              controller: _nameControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Spieler ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte gib einen Namen ein';
                                }
                                return null;
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spieler ($_playerCount)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _removePlayer,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addPlayer,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_game != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Spiel mit ${_game!.impostorCount} Spion${_game!.impostorCount > 1 ? "en" : ""}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<PlayerBloc, PlayerState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is PlayerLoading ? null : () => _submitPlayers(context),
                            child: state is PlayerLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Weiter'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitPlayers(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final players = <Player>[];

      for (int i = 0; i < _playerCount; i++) {
        if (_nameControllers[i].text.isNotEmpty) {
          players.add(Player.create(
            id: 'player_${i + 1}',
            name: _nameControllers[i].text.trim(),
          ));
        }
      }

      if (players.length >= _minPlayers) {
        _playerBloc.add(RegisterPlayers(players));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mindestens $_minPlayers Spieler werden benötigt')),
        );
      }
    }
  }
}
