import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/presentation/widgets/app_button.dart';

@RoutePage()
class FinalResultsScreen extends StatelessWidget {
  const FinalResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GameCompleted) {
          return _buildCompletedScreen(context, state);
        } else if (state is GameLoading) {
          return _buildLoadingScreen();
        } else {
          return _buildErrorScreen(context);
        }
      },
    );
  }

  Widget _buildCompletedScreen(BuildContext context, GameCompleted state) {
    final List<Player> players = state.players ?? [];
    final List<Player> sortedPlayers;
    if (players.isNotEmpty) {
      sortedPlayers = List<Player>.from(players);
      sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sortedPlayers = <Player>[];
    }

    final String winnerName =
        sortedPlayers.isNotEmpty ? sortedPlayers.first.name : (state.winnerNames.isNotEmpty ? state.winnerNames.first : 'Unbekannt');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spielergebnisse'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Winner announcement
          _buildWinnerCard(context, winnerName),

          // Player rankings
          Expanded(
            child: _buildRankings(context, sortedPlayers),
          ),

          // Return to main menu button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: AppButton(
              text: 'Zurück zum Hauptmenü',
              onPressed: () {
                context.router.replaceNamed('/home');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(BuildContext context, String winnerName) {
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
            const Text(
              '🏆 Gewinner 🏆',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.team,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              winnerName,
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

  Widget _buildRankings(BuildContext context, List<Player> players) {
    if (players.isEmpty) {
      return const Center(
        child: Text('Keine Spielerdaten verfügbar'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isFirst = index == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          color: isFirst ? AppColors.team.withOpacity(0.3) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isFirst ? AppColors.team : AppColors.accent,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isFirst ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              player.name,
              style: TextStyle(
                fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isFirst ? AppColors.team.withOpacity(0.1) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${player.score} Pkt.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isFirst ? AppColors.team : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Spielergebnisse')),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fehler')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Fehler beim Laden der Ergebnisse'),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('Zurück zum Hauptmenü'),
            ),
          ],
        ),
      ),
    );
  }
}
