import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/presentation/widgets/app_button.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/core/router/app_router.dart';

// Helper class to hold player ranking information
class PlayerRanking {
  final Player player;
  final int position;
  final String positionText;

  PlayerRanking({
    required this.player,
    required this.position,
    required this.positionText,
  });
}

@RoutePage()
class FinalResultsScreen extends StatefulWidget {
  final List<Player> players;
  final List<String> winnerNames;
  final String gameId;

  const FinalResultsScreen({
    super.key,
    required this.players,
    required this.winnerNames,
    required this.gameId,
  });

  @override
  State<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends State<FinalResultsScreen> {
  bool _isPlayingAgain = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>(),
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameCreated) {
            print('New game created for "Play Again": ${state.game.id}');
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
        child: _buildCompletedScreen(context),
      ),
    );
  }
  
  /// Restart the game with the same players and configuration
  Future<void> _playAgain(BuildContext context) async {
    setState(() {
      _isPlayingAgain = true;
    });
    
    try {
      print('=== Play Again: Starting new game ===');
      
      // Get the current game configuration from the database
      final gameRepository = sl<GameRepository>();
      final currentGame = await gameRepository.getGameById(widget.gameId);
      
      if (currentGame == null) {
        throw Exception('Original game not found');
      }
      
      print('Original game config: ${currentGame.playerCount} players, ${currentGame.impostorCount} impostors');
      
      // Get current players (but reset their scores)
      final currentPlayers = widget.players;
      final playerNames = currentPlayers.map((p) => p.name).toList();
      
      print('Players for new game: ${playerNames.join(", ")}');
      
      // Create a new game with the same configuration but using CreateGameFromGroup
      // This will automatically add the players and set up everything correctly
      final gameBloc = context.read<GameBloc>();
      
      // First, clean up any existing game state
      final currentState = gameBloc.state;
      if (currentState is GameCreated || currentState is GameInProgress || currentState is GameCompleted) {
        // Delete the completed game
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

  Widget _buildCompletedScreen(BuildContext context) {
    final List<Player> sortedPlayers;
    if (widget.players.isNotEmpty) {
      sortedPlayers = List<Player>.from(widget.players);
      sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sortedPlayers = <Player>[];
    }

    // Calculate rankings with ties
    final List<PlayerRanking> rankedPlayers = _calculateRankings(sortedPlayers);

    // Get winners (all players with the highest score)
    final List<String> actualWinners = rankedPlayers.isNotEmpty
        ? rankedPlayers.where((p) => p.position == 1).map((p) => p.player.name).toList()
        : (widget.winnerNames.isNotEmpty ? widget.winnerNames : ['Unbekannt']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spielergebnisse'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Winner announcement
          _buildWinnerCard(context, actualWinners),

          // Player rankings
          Expanded(
            child: _buildRankings(context, rankedPlayers),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
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
                  onPressed: _isPlayingAgain ? null : () {
                    context.router.replaceNamed('/home');
                  },
                  backgroundColor: Colors.grey.shade600,
                  icon: Icons.home,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate rankings with proper tie handling
  List<PlayerRanking> _calculateRankings(List<Player> sortedPlayers) {
    if (sortedPlayers.isEmpty) return [];

    final List<PlayerRanking> rankings = [];
    int currentPosition = 1;

    for (int i = 0; i < sortedPlayers.length; i++) {
      final player = sortedPlayers[i];

      // Check if this player has the same score as the previous player
      if (i > 0 && sortedPlayers[i - 1].score != player.score) {
        // Different score from previous player, update position
        currentPosition = i + 1;
      }

      final positionText = _getPositionText(currentPosition);

      rankings.add(PlayerRanking(
        player: player,
        position: currentPosition,
        positionText: positionText,
      ));
    }

    return rankings;
  }

  /// Get the ordinal text for a position (1st, 2nd, 3rd, etc.)
  String _getPositionText(int position) {
    switch (position) {
      case 1:
        return '1.';
      case 2:
        return '2.';
      case 3:
        return '3.';
      default:
        return '$position.';
    }
  }

  Widget _buildWinnerCard(BuildContext context, List<String> winnerNames) {
    // Handle multiple winners
    String winnerText;
    if (winnerNames.length == 1) {
      winnerText = winnerNames.first;
    } else if (winnerNames.length == 2) {
      winnerText = '${winnerNames[0]} & ${winnerNames[1]}';
    } else if (winnerNames.length > 2) {
      final lastWinner = winnerNames.last;
      final otherWinners = winnerNames.take(winnerNames.length - 1).join(', ');
      winnerText = '$otherWinners & $lastWinner';
    } else {
      winnerText = 'Unbekannt';
    }

    final String titleText = winnerNames.length > 1 ? '🏆 Gewinner 🏆' : '🏆 Gewinner 🏆';

    return Card(
      margin: const EdgeInsets.all(AppSpacing.m),
      color: AppColors.team.withOpacity(0.1),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.team.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.team,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              winnerText,
              style: AppTypography.headline1.copyWith(
                color: AppColors.team,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankings(BuildContext context, List<PlayerRanking> rankedPlayers) {
    if (rankedPlayers.isEmpty) {
      return const Center(
        child: Text('Keine Spielerdaten verfügbar'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      itemCount: rankedPlayers.length,
      itemBuilder: (context, index) {
        final ranking = rankedPlayers[index];
        final isWinner = ranking.position == 1;
        final isTopThree = ranking.position <= 3;

        // Determine colors based on position
        Color backgroundColor;
        Color positionColor;
        Color textColor;

        if (isWinner) {
          backgroundColor = AppColors.team.withOpacity(0.3);
          positionColor = AppColors.team;
          textColor = Colors.black;
        } else if (isTopThree) {
          backgroundColor = AppColors.accent.withOpacity(0.2);
          positionColor = AppColors.accent;
          textColor = Colors.black;
        } else {
          backgroundColor = Colors.transparent;
          positionColor = Colors.grey.shade600;
          textColor = Colors.black;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          color: backgroundColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: positionColor,
              child: Text(
                ranking.positionText,
                style: TextStyle(
                  color: isWinner || isTopThree ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              ranking.player.name,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                fontSize: isWinner ? 18 : 16,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isWinner ? AppColors.team.withOpacity(0.1) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: isWinner ? Border.all(color: AppColors.team.withOpacity(0.3)) : null,
              ),
              child: Text(
                '${ranking.player.score} Pkt.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isWinner ? AppColors.team : Colors.black,
                  fontSize: isWinner ? 16 : 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
