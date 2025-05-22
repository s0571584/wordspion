import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_event.dart';
import 'package:wortspion/blocs/player_group/player_group_state.dart';
import 'package:wortspion/core/router/app_router.dart'; // For navigation
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';

@RoutePage()
class PlayerGroupsScreen extends StatefulWidget {
  const PlayerGroupsScreen({super.key});

  @override
  State<PlayerGroupsScreen> createState() => _PlayerGroupsScreenState();
}

class _PlayerGroupsScreenState extends State<PlayerGroupsScreen> with RouteAware {
  final _focusNode = FocusNode();
  late PlayerGroupBloc _playerGroupBloc;

  @override
  void initState() {
    super.initState();
    _playerGroupBloc = sl<PlayerGroupBloc>();
    _playerGroupBloc.add(LoadPlayerGroups());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add a post-frame callback to set focus after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
              // Dispatch event to PlayerGroupBloc using the context from the main screen
              // which has the BlocProvider for PlayerGroupBloc.
              BlocProvider.of<PlayerGroupBloc>(context).add(DeletePlayerGroup(groupId: groupId));
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _playerGroupBloc,
        ),
        BlocProvider(
          create: (context) => sl<GameBloc>(),
        ),
      ],
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) {
          // Refresh groups list when screen regains focus
          if (hasFocus) {
            _playerGroupBloc.add(LoadPlayerGroups());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Spieler Gruppen'),
          ),
          body: BlocConsumer<PlayerGroupBloc, PlayerGroupState>(
            listener: (context, state) {
              if (state is PlayerGroupError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler: ${state.message}')),
                );
              }
              // Listener for PlayerGroupOperationSuccess can be added later for feedback
            },
            builder: (context, state) {
              if (state is PlayerGroupsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PlayerGroupsLoaded) {
                if (state.groups.isEmpty) {
                  return const Center(
                    child: Text(
                      'Noch keine Gruppen erstellt.\nDrücke + um eine neue Gruppe hinzuzufügen.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // TODO: Build list of groups
                return ListView.builder(
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return ListTile(
                      title: Text(group.groupName),
                      subtitle: Text('${group.playerNames.length} Spieler'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocListener<GameBloc, GameState>(
                            listener: (context, gameState) {
                              if (gameState is GameCreated) {
                                // Navigate to RoleRevealScreen or appropriate next screen
                                // This assumes GameCreated state implies players are ready for roles.
                                context.router.push(RoleRevealRoute(gameId: gameState.game.id));
                              }
                              // Optional: Handle GameError state if needed
                            },
                            child: IconButton(
                              icon: const Icon(Icons.play_circle_outline),
                              tooltip: 'Spiel starten',
                              onPressed: () {
                                // Dispatch CreateGameFromGroup to GameBloc
                                context.read<GameBloc>().add(CreateGameFromGroup(playerNames: group.playerNames));
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Gruppe bearbeiten',
                            onPressed: () {
                              context.router.push(CreateEditPlayerGroupRoute(groupId: group.id));
                            },
                          ),
                          IconButton(
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
                );
              }
              return const Center(child: Text('Etwas ist schiefgelaufen.')); // Fallback
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.router.push(CreateEditPlayerGroupRoute());
              // Refresh groups list when returning from create/edit screen
              if (mounted) {
                _playerGroupBloc.add(LoadPlayerGroups());
              }
            },
            tooltip: 'Neue Gruppe erstellen',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
