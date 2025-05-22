import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/blocs/player/player_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_event.dart';
import 'package:wortspion/blocs/player_group/player_group_state.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/blocs/settings/settings_bloc.dart';
import 'package:wortspion/presentation/screens/game_setup_screen.dart';
import 'package:wortspion/presentation/screens/player_registration_screen.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PlayerGroupBloc _playerGroupBloc;

  @override
  void initState() {
    super.initState();
    _playerGroupBloc = sl<PlayerGroupBloc>();
    _playerGroupBloc.add(LoadPlayerGroups());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GameBloc>()..add(const LoadGame()),
        ),
        BlocProvider.value(
          value: _playerGroupBloc,
        ),
      ],
      child: BlocListener<GameBloc, GameState>(
        listener: (context, gameState) {
          if (gameState is GameCreated) {
            // Navigate to player registration screen when a game is created
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (navContext) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => sl<PlayerBloc>()),
                    BlocProvider.value(
                      value: BlocProvider.of<GameBloc>(context), // Use GameBloc from HomeScreen
                    ),
                  ],
                  child: PlayerRegistrationScreen(game: gameState.game),
                ),
              ),
            );
          } else if (gameState is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: ${gameState.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('WortSpion'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Spieleinstellungen',
                onPressed: () {
                  context.router.push(GameSetupRoute(isSettingsOnly: true));
                },
              ),
            ],
          ),
          body: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  'WortSpion',
                  style: AppTypography.headline1.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Finde die Spione unter euch!',
                  style: AppTypography.headline3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildGameButtons(context),
                const SizedBox(height: 24),
                _buildPlayerGroups(context),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    _showRulesDialog(context);
                  },
                  child: const Text('Spielregeln'),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerGroups(BuildContext context) {
    return BlocBuilder<PlayerGroupBloc, PlayerGroupState>(
      builder: (context, state) {
        if (state is PlayerGroupsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlayerGroupsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Spieler Gruppen',
                    style: AppTypography.subtitle1,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Neue Gruppe'),
                    onPressed: () async {
                      await context.router.push(CreateEditPlayerGroupRoute());
                      if (mounted) {
                        _playerGroupBloc.add(LoadPlayerGroups());
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (state.groups.isEmpty)
                const Center(
                  child: Text(
                    'Keine Gruppen vorhanden.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: state.groups.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        return ListTile(
                          dense: true,
                          title: Text(group.groupName),
                          subtitle: Text('${group.playerNames.length} Spieler'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.play_circle_outline),
                                tooltip: 'Spiel starten',
                                onPressed: () {
                                  context.read<GameBloc>().add(CreateGameFromGroup(playerNames: group.playerNames));
                                },
                              ),
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Gruppe bearbeiten',
                                onPressed: () async {
                                  await context.router.push(CreateEditPlayerGroupRoute(groupId: group.id));
                                  if (mounted) {
                                    _playerGroupBloc.add(LoadPlayerGroups());
                                  }
                                },
                              ),
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Gruppe löschen',
                                onPressed: () {
                                  _showDeleteConfirmDialog(context, group.id, group.groupName);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  context.router.push(const PlayerGroupsRoute());
                },
                child: const Text('Alle Gruppen anzeigen'),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String groupId, String groupName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gruppe löschen?'),
        content: Text('Bist du sicher, dass du die Gruppe "$groupName" löschen möchtest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _playerGroupBloc.add(DeletePlayerGroup(groupId: groupId));
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButtons(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GameLoading) {
          return const CircularProgressIndicator();
        } else if (state is GameInProgress || state is GameCreated) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Zum laufenden Spiel navigieren
                  if (state is GameInProgress) {
                    // Navigation je nach Spielstatus anpassen
                    if (state.game.currentRound > 0) {
                      context.router.push(RoleRevealRoute(gameId: state.game.id));
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider(create: (_) => sl<PlayerBloc>()),
                              BlocProvider.value(
                                value: context.read<GameBloc>(),
                              ),
                            ],
                            child: PlayerRegistrationScreen(game: state.game),
                          ),
                        ),
                      );
                    }
                  } else if (state is GameCreated) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(create: (_) => sl<PlayerBloc>()),
                            BlocProvider.value(
                              value: context.read<GameBloc>(),
                            ),
                          ],
                          child: PlayerRegistrationScreen(game: state.game),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Spiel fortsetzen'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // Spiel beenden
                  _showEndGameConfirmDialog(context, state);
                },
                child: const Text('Spiel beenden'),
              ),
            ],
          );
        } else {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Modified to ensure settings flow through GameSetupScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: BlocProvider.of<GameBloc>(context),
                        ),
                        BlocProvider(
                          create: (context) => sl<SettingsBloc>(),
                        ),
                      ],
                      child: const GameSetupScreen(),
                    ),
                  ),
                );
              },
              child: const Text('Neues Spiel starten'),
            ),
          );
        }
      },
    );
  }

  void _showEndGameConfirmDialog(BuildContext outerContext, GameState state) {
    // Capture GameBloc instance using the context that is known to have it.
    final GameBloc gameBloc = BlocProvider.of<GameBloc>(outerContext);

    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Spiel beenden?'),
        content: const Text(
          'Bist du sicher, dass du das laufende Spiel beenden möchtest? '
          'Alle Fortschritte gehen verloren.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Use the captured gameBloc instance directly.
              if (state is GameInProgress) {
                gameBloc.add(DeleteGame(gameId: state.game.id));
              } else if (state is GameCreated) {
                gameBloc.add(DeleteGame(gameId: state.game.id));
              }
            },
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spielregeln'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('So funktioniert WortSpion:', style: AppTypography.subtitle1),
              SizedBox(height: 8),
              Text(
                '1. Alle Spieler bekommen eine Rolle zugewiesen: Teammitglied oder Spion.',
                style: AppTypography.body2,
              ),
              SizedBox(height: 4),
              Text(
                '2. Teammitglieder kennen das Hauptwort, Spione bekommen ein Täuschungswort.',
                style: AppTypography.body2,
              ),
              SizedBox(height: 4),
              Text(
                '3. Die Spieler diskutieren reihum und beschreiben ihr Wort, ohne es direkt zu nennen.',
                style: AppTypography.body2,
              ),
              SizedBox(height: 4),
              Text(
                '4. Nach der Diskussion stimmen alle ab, wer ihrer Meinung nach ein Spion ist.',
                style: AppTypography.body2,
              ),
              SizedBox(height: 4),
              Text(
                '5. Die Spione versuchen, das Hauptwort zu erraten.',
                style: AppTypography.body2,
              ),
              SizedBox(height: 8),
              Text('Punkte:', style: AppTypography.subtitle1),
              SizedBox(height: 8),
              Text(
                '• Teammitglieder: 1 Punkt für jeden korrekt identifizierten Spion',
                style: AppTypography.body2,
              ),
              SizedBox(height: 4),
              Text(
                '• Spione: 3 Punkte, wenn sie unentdeckt bleiben, plus 2 Punkte, wenn sie das Hauptwort erraten',
                style: AppTypography.body2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}
