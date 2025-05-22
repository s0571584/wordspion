import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // Removed
import 'package:auto_route/auto_route.dart';
// import 'package:wortspion/blocs/round/round_bloc.dart'; // Removed
import 'package:wortspion/blocs/voting/voting_state.dart'; // Keep for VotingResult if still needed by constructor.
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/player.dart';
// import 'package:wortspion/di/injection_container.dart'; // Removed
import 'package:wortspion/blocs/round/round_state.dart'; // For PlayerRoleInfo

@RoutePage()
class ResultsScreen extends StatelessWidget {
  final List<VotingResult> votingResults;
  final Player? mostVotedPlayer;
  final List<PlayerRoleInfo> playerRoles; // Added
  final String secretWord; // Added

  const ResultsScreen({
    super.key,
    required this.votingResults,
    this.mostVotedPlayer,
    required this.playerRoles, // Added
    required this.secretWord, // Added
  });

  @override
  Widget build(BuildContext context) {
    // Removed BlocProvider<RoundBloc>
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
                    _buildVotingResultsWidget(), // This widget remains the same
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
                      'Spielerrollen & Geheimwort', // Updated title
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildPlayerRolesWidget(), // Renamed and uses direct data
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.router.replace(const HomeRoute());
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Zurück zum Startbildschirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingResultsWidget() {
    // This widget implementation remains unchanged for now
    // It uses this.votingResults and this.mostVotedPlayer
    if (votingResults.isEmpty && mostVotedPlayer == null) {
      return const Center(child: Text('Keine Abstimmungsergebnisse verfügbar'));
    }
    return Column(
      children: [
        for (final result in votingResults)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${result.playerName}:', // This should be correct now from previous fix
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${result.voteCount} Stimmen'),
              ],
            ),
          ),
        if (votingResults.isNotEmpty) const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meiste Stimmen:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(mostVotedPlayer?.name ?? 'Unentschieden'), // This should be correct
          ],
        ),
      ],
    );
  }

  // Renamed from _buildPlayerRoles and updated
  Widget _buildPlayerRolesWidget() {
    if (playerRoles.isEmpty) {
      return const Center(child: Text('Keine Rolleninformationen verfügbar'));
    }
    return Column(
      children: [
        for (final playerRole in playerRoles)
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
                    color: playerRole.isImpostor ? Colors.red : Colors.green,
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
            Text(secretWord),
          ],
        ),
      ],
    );
  }
}
