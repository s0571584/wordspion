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
import 'package:wortspion/data/repositories/game_repository.dart';
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
          create: (context) => sl<GameBloc>(),
        ),
        BlocProvider.value(
          value: _playerGroupBloc,
        ),
      ],
      child: BlocListener<GameBloc, GameState>(
        listener: (context, gameState) async {
          if (gameState is GameCreated) {
            print('GameCreated received, checking if players are already registered...');

            try {
              final gameRepository = sl<GameRepository>();
              final players = await gameRepository.getPlayersByGameId(gameState.game.id);

              print('Found ${players.length} existing players in game ${gameState.game.id}');

              if (players.isNotEmpty) {
                print('Players already exist, skipping player registration and going to role reveal');
                context.router.push(RoleRevealRoute(gameId: gameState.game.id));
              } else {
                print('No players found, navigating to player registration');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (navContext) => MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (_) => sl<PlayerBloc>()),
                        BlocProvider.value(
                          value: BlocProvider.of<GameBloc>(context),
                        ),
                      ],
                      child: PlayerRegistrationScreen(game: gameState.game),
                    ),
                  ),
                );
              }
            } catch (e) {
              print('Error checking players: $e');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (navContext) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => sl<PlayerBloc>()),
                      BlocProvider.value(
                        value: BlocProvider.of<GameBloc>(context),
                      ),
                    ],
                    child: PlayerRegistrationScreen(game: gameState.game),
                  ),
                ),
              );
            }
          } else if (gameState is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: ${gameState.message}')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEFF6FF), // blue-50
                  Color(0xFFE0E7FF), // indigo-100
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Column(
                    children: [
                      // Hero Section
                      _buildHeroSection(context),
                      const SizedBox(height: 48),

                      // Content Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 768) {
                            // Desktop/Tablet: Two columns
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildPlayerGroupsCard(context)),
                                const SizedBox(width: 32),
                                Expanded(child: _buildQuickActionsCard(context)),
                              ],
                            );
                          } else {
                            // Mobile: Single column
                            return Column(
                              children: [
                                _buildPlayerGroupsCard(context),
                                const SizedBox(height: 32),
                                _buildQuickActionsCard(context),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(height: 48),

        // Main Title - Responsive
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Wort',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.15).clamp(48.0, 80.0),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'Spion',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.15).clamp(48.0, 80.0),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4F46E5), // indigo-600
                    height: 1.0,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        const Text(
          'Finde die Spione unter euch!',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Main CTA Button
        _buildMainButton(context),
      ],
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GameLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: const CircularProgressIndicator(),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], // indigo-600 to purple-600
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final gameBloc = BlocProvider.of<GameBloc>(context);
                final currentState = gameBloc.state;

                if (currentState is GameCreated) {
                  gameBloc.add(DeleteGame(gameId: currentState.game.id));
                } else if (currentState is GameInProgress) {
                  gameBloc.add(DeleteGame(gameId: currentState.game.id));
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: gameBloc),
                        BlocProvider(create: (context) => sl<SettingsBloc>()),
                      ],
                      child: const GameSetupScreen(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Neues Spiel starten',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerGroupsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: Color(0xFF4F46E5),
                      size: 24,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await context.router.push(CreateEditPlayerGroupRoute());
                      if (mounted) {
                        _playerGroupBloc.add(LoadPlayerGroups());
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Color(0xFF4F46E5),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Neue Gruppe',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Groups List
          BlocBuilder<PlayerGroupBloc, PlayerGroupState>(
            builder: (context, state) {
              if (state is PlayerGroupsLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is PlayerGroupsLoaded) {
                if (state.groups.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(
                      child: Text(
                        'Keine Gruppen vorhanden.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...state.groups.map((group) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.groupName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          Text(
                                            '${group.playerNames.length} Spieler',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildActionButton(
                                          icon: Icons.play_circle_outline,
                                          color: Colors.green,
                                          tooltip: 'Spiel starten',
                                          onPressed: () {
                                            final gameBloc = context.read<GameBloc>();
                                            final currentState = gameBloc.state;

                                            if (currentState is GameCreated) {
                                              gameBloc.add(DeleteGame(gameId: currentState.game.id));
                                            } else if (currentState is GameInProgress) {
                                              gameBloc.add(DeleteGame(gameId: currentState.game.id));
                                            }

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider.value(value: gameBloc),
                                                    BlocProvider(create: (context) => sl<SettingsBloc>()),
                                                  ],
                                                  child: GameSetupScreen(
                                                    fromGroup: true,
                                                    groupPlayerNames: group.playerNames,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _buildActionButton(
                                          icon: Icons.edit_outlined,
                                          color: Colors.grey,
                                          tooltip: 'Gruppe bearbeiten',
                                          onPressed: () async {
                                            await context.router.push(CreateEditPlayerGroupRoute(groupId: group.id));
                                            if (mounted) {
                                              _playerGroupBloc.add(LoadPlayerGroups());
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _buildActionButton(
                                          icon: Icons.delete_outline,
                                          color: Colors.red,
                                          tooltip: 'Gruppe löschen',
                                          onPressed: () {
                                            _showDeleteConfirmDialog(context, group.id, group.groupName);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),

                    const SizedBox(height: 16),

                    // View All Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF4F46E5)),
                        ),
                        onPressed: () {
                          context.router.push(const PlayerGroupsRoute());
                        },
                        child: const Text(
                          'Alle Gruppen anzeigen',
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Color(0xFF4F46E5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Schnellzugriff',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Action Items
          _buildQuickActionItem(
            context: context,
            icon: Icons.menu_book,
            title: 'Spielregeln',
            subtitle: 'Erfahre, wie WortSpion gespielt wird',
            onTap: () => _showRulesDialog(context),
          ),

          const SizedBox(height: 16),

          _buildQuickActionItem(
            context: context,
            icon: Icons.settings,
            title: 'Einstellungen',
            subtitle: 'Spiel-Konfiguration anpassen',
            onTap: () {
              context.router.push(GameSetupRoute(isSettingsOnly: true));
            },
          ),

          const SizedBox(height: 16),

          _buildQuickActionItem(
            context: context,
            icon: Icons.bar_chart,
            title: 'Statistiken',
            subtitle: 'Siehe deine Spielergebnisse',
            onTap: () {
              // TODO: Navigate to statistics
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String groupId, String groupName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gruppe löschen?'),
        content: Text('Bist du sicher, dass du die Gruppe "$groupName" löschen möchtest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _playerGroupBloc.add(DeletePlayerGroup(groupId: groupId));
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Spielregeln',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'So funktioniert WortSpion:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...[
                        '1. Alle Spieler bekommen eine Rolle zugewiesen: Teammitglied oder Spion.',
                        '2. Teammitglieder kennen das Hauptwort, Spione bekommen ein Täuschungswort.',
                        '3. Die Spieler diskutieren reihum und beschreiben ihr Wort, ohne es direkt zu nennen.',
                        '4. Nach der Diskussion stimmen alle ab, wer ihrer Meinung nach ein Spion ist.',
                        '5. Die Spione versuchen, das Hauptwort zu erraten.',
                      ].map((rule) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              rule,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                          )),
                      const SizedBox(height: 24),
                      const Text(
                        'Punkte:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...[
                        '• Teammitglieder: 1 Punkt für jeden korrekt identifizierten Spion',
                        '• Spione: 3 Punkte, wenn sie unentdeckt bleiben, plus 2 Punkte, wenn sie das Hauptwort erraten',
                      ].map((point) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              point,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Verstanden',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
