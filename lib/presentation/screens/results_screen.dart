import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/voting/voting_state.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/widgets/app_button.dart';

@RoutePage()
class ResultsScreen extends StatefulWidget {
  final List<VotingResult> votingResults;
  final Player? mostVotedPlayer;
  final List<PlayerRoleInfo> playerRoles;
  final String secretWord;
  final String gameId; // Added gameId parameter

  const ResultsScreen({
    super.key,
    required this.votingResults,
    this.mostVotedPlayer,
    required this.playerRoles,
    required this.secretWord,
    required this.gameId, // Added gameId parameter
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isPlayingAgain = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>(),
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameCreated) {
            print('New game created for "Play Again" from Results: ${state.game.id}');
            // Navigate to role reveal screen with the new game
            context.router.replace(RoleRevealRoute(gameId: state.game.id));
          } else if (state is GameError) {
            print('Error creating new game: ${state.message}');
            setState(() {
              _isPlayingAgain = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fehler beim Starten des neuen Spiels: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _buildResultsScreen(context),
      ),
    );
  }

  /// Restart the game with the same players and configuration
  Future<void> _playAgain(BuildContext context) async {
    setState(() {
      _isPlayingAgain = true;
    });

    try {
      print('=== Play Again: Starting new game from Results ===');

      // Get the current game configuration from the database
      final gameRepository = sl<GameRepository>();
      final currentGame = await gameRepository.getGameById(widget.gameId);

      if (currentGame == null) {
        throw Exception('Original game not found');
      }

      print('Original game config: ${currentGame.playerCount} players, ${currentGame.impostorCount} impostors');

      // Extract player names from playerRoles
      final playerNames = widget.playerRoles.map((role) => role.playerName).toList();

      print('Players for new game: ${playerNames.join(", ")}');

      // Create a new game with the same configuration but using CreateGameFromGroup
      final gameBloc = context.read<GameBloc>();

      // First, clean up any existing game state
      final currentState = gameBloc.state;
      if (currentState is GameCreated || currentState is GameInProgress || currentState is GameCompleted) {
        // Delete the current game
        gameBloc.add(DeleteGame(gameId: widget.gameId));
        // Wait a moment for the deletion to process
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Create the new game from the group of players
      gameBloc.add(CreateGameFromGroup(playerNames: playerNames));

      print('Dispatched CreateGameFromGroup event');
    } catch (e) {
      print('Error in _playAgain: $e');
      setState(() {
        _isPlayingAgain = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Neustarten: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildResultsScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ergebnisse'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Abstimmungsergebnisse',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildVotingResultsWidget(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Spielerrollen & Geheimwort',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildPlayerRolesWidget(),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Play Again button
                BlocBuilder<GameBloc, GameState>(
                  builder: (context, state) {
                    final isLoading = state is GameLoading || _isPlayingAgain;

                    return AppButton(
                      text: 'Nochmal spielen',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _playAgain(context),
                      backgroundColor: AppColors.team,
                      icon: Icons.refresh,
                      isFullWidth: true,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s),
                // Return to main menu button
                AppButton(
                  text: 'Zurück zum Hauptmenü',
                  onPressed: _isPlayingAgain
                      ? null
                      : () {
                          context.router.replace(const HomeRoute());
                        },
                  backgroundColor: Colors.grey.shade600,
                  icon: Icons.home,
                  isFullWidth: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingResultsWidget() {
    // This widget implementation uses widget.votingResults and widget.mostVotedPlayer
    if (widget.votingResults.isEmpty && widget.mostVotedPlayer == null) {
      return const Center(child: Text('Keine Abstimmungsergebnisse verfügbar'));
    }
    return Column(
      children: [
        for (final result in widget.votingResults)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${result.playerName}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${result.voteCount} Stimmen'),
              ],
            ),
          ),
        if (widget.votingResults.isNotEmpty) const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meiste Stimmen:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.mostVotedPlayer?.name ?? 'Unentschieden'),
          ],
        ),
      ],
    );
  }

  // Renamed from _buildPlayerRoles and updated
  Widget _buildPlayerRolesWidget() {
    if (widget.playerRoles.isEmpty) {
      return const Center(child: Text('Keine Rolleninformationen verfügbar'));
    }
    return Column(
      children: [
        for (final playerRole in widget.playerRoles)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${playerRole.playerName}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  playerRole.roleName,
                  style: TextStyle(
                    color: _getRoleColor(playerRole.roleName, playerRole.isImpostor),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Geheimwort:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.secretWord),
          ],
        ),
      ],
    );
  }

  // Helper method to determine the color for a player role
  Color _getRoleColor(String roleName, bool isImpostor) {
    if (isImpostor) return Colors.red;
    if (roleName.toLowerCase().contains('saboteur')) return Colors.orange;
    return Colors.green;
  }
}
