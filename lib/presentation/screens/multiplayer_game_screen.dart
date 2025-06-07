import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../blocs/multiplayer_game/multiplayer_game_bloc.dart';
import '../../blocs/multiplayer_game/multiplayer_game_state.dart';
import '../../blocs/multiplayer_game/multiplayer_game_event.dart';
import '../../data/models/room_player.dart';
import '../../core/router/app_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import '../themes/app_spacing.dart';
import '../../di/injection_container.dart' as di;

@RoutePage()
class MultiplayerGameScreen extends StatelessWidget {
  final String roomId;

  const MultiplayerGameScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<MultiplayerGameBloc>()..add(LoadRoom(roomId)),
      child: BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.onBackground),
                onPressed: () {
                  context.read<MultiplayerGameBloc>().add(LeaveGameRoom());
                  context.router.pop();
                },
              ),
              title: Text(
                'Multiplayer Spiel',
                style: AppTypography.headline3.copyWith(
                  color: AppColors.onBackground,
                ),
              ),
              centerTitle: true,
            ),
            body: _buildGameContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, MultiplayerGameState state) {
    switch (state.runtimeType) {
      case MultiplayerGameLoading:
        return _buildLoadingState();
      case MultiplayerGameError:
        return _buildErrorState(context, state as MultiplayerGameError);
      case RoleAssignmentPhase:
        return _buildRoleAssignmentPhase(context, state as RoleAssignmentPhase);
      case RoleRevealPhase:
        return _buildRoleRevealPhase(context, state as RoleRevealPhase);
      case DiscussionPhase:
        return _buildDiscussionPhase(context, state as DiscussionPhase);
      case VotingPhase:
        return _buildVotingPhase(context, state as VotingPhase);
      case RoundCompleted:
        return _buildRoundCompletedPhase(context, state as RoundCompleted);
      case GameCompleted:
        return _buildGameCompletedPhase(context, state as GameCompleted);
      default:
        return _buildWaitingState(context);
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, MultiplayerGameError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Fehler',
              style: AppTypography.headline2.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              state.message,
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            ElevatedButton(
              onPressed: () => context.router.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Zurück'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Warten auf Spielstart...',
              style: AppTypography.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Raum-ID: $roomId',
              style: AppTypography.caption.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleAssignmentPhase(BuildContext context, RoleAssignmentPhase state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Runde ${state.currentRound.roundNumber}',
              style: AppTypography.headline2,
            ),
            const SizedBox(height: AppSpacing.l),
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Rollen werden zugewiesen...',
                style: AppTypography.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!state.hasViewedRole)
              ElevatedButton(
                onPressed: () {
                  context.read<MultiplayerGameBloc>().add(MarkRoleAsViewed());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('Meine Rolle anzeigen'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleRevealPhase(BuildContext context, RoleRevealPhase state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: state.isImpostor ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    state.isImpostor ? 'Du bist ein Spion!' : 'Du bist ein Teammitglied!',
                    style: AppTypography.headline2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Dein Wort:',
                    style: AppTypography.body1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    state.assignedWord,
                    style: AppTypography.headline1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              state.isImpostor
                  ? 'Versuche herauszufinden, was das echte Wort ist!'
                  : 'Finde die Spione, aber verrate nicht dein Wort!',
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () {
                context.read<MultiplayerGameBloc>().add(StartDiscussion());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Diskussion starten'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionPhase(BuildContext context, DiscussionPhase state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diskussion', style: AppTypography.headline3),
                      if (state.remainingTime != null)
                        Text(
                          '${state.remainingTime!.inMinutes}:${(state.remainingTime!.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: AppTypography.headline3.copyWith(color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Dein Wort: ${state.assignedWord}',
                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spieler (${state.players.length})', style: AppTypography.subtitle1),
                    const SizedBox(height: AppSpacing.s),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.players.length,
                        itemBuilder: (context, index) {
                          final player = state.players[index];
                          final isCurrentPlayer = player.id == state.currentPlayer.id;
                          return ListTile(
                            leading: Icon(
                              isCurrentPlayer ? Icons.person : Icons.person_outline,
                              color: isCurrentPlayer ? AppColors.primary : null,
                            ),
                            title: Text(
                              player.playerName,
                              style: TextStyle(
                                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(isCurrentPlayer ? 'Du' : 'Spieler'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<MultiplayerGameBloc>().add(StartVoting());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Zur Abstimmung'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingPhase(BuildContext context, VotingPhase state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  Text('Abstimmung', style: AppTypography.headline3),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Wähle den Spieler, von dem du denkst, dass er ein Spion ist:',
                    style: AppTypography.body1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: ListView.builder(
              itemCount: state.players.length,
              itemBuilder: (context, index) {
                final player = state.players[index];
                final isCurrentPlayer = player.id == state.currentPlayer.id;
                final isVoted = state.votedPlayerId == player.id;
                final voteCount = state.voteCount[player.id] ?? 0;

                if (isCurrentPlayer) return const SizedBox.shrink();

                return Card(
                  color: isVoted ? AppColors.primary.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: isVoted ? AppColors.primary : null,
                    ),
                    title: Text(player.playerName),
                    subtitle: Text('$voteCount Stimme(n)'),
                    trailing: isVoted
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: state.hasVoted
                        ? null
                        : () {
                            context.read<MultiplayerGameBloc>().add(
                                  SubmitVote(player.id),
                                );
                          },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (state.hasVoted)
            Text(
              'Du hast abgestimmt. Warte auf andere Spieler...',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<MultiplayerGameBloc>().add(CompleteRound());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Runde beenden'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundCompletedPhase(BuildContext context, RoundCompleted state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Text(
            'Runde ${state.completedRound.roundNumber} beendet',
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.l),
          Card(
            color: state.impostorsWon ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  Icon(
                    state.impostorsWon ? Icons.visibility : Icons.visibility_off,
                    size: 48,
                    color: state.impostorsWon ? AppColors.error : AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    state.impostorsWon ? 'Spione gewinnen!' : 'Teammitglieder gewinnen!',
                    style: AppTypography.headline3.copyWith(
                      color: state.impostorsWon ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (state.eliminatedPlayers.isNotEmpty) ...[
            Text('Eliminierte Spieler:', style: AppTypography.subtitle1),
            const SizedBox(height: AppSpacing.s),
            ...state.eliminatedPlayers.map((playerId) {
              final player = state.players.firstWhere((p) => p.id == playerId);
              return Text(player.playerName, style: AppTypography.body1);
            }),
            const SizedBox(height: AppSpacing.l),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Check if this was the last round
                if (state.completedRound.roundNumber >= state.room.roundCount) {
                  context.read<MultiplayerGameBloc>().add(CompleteGame());
                } else {
                  context.read<MultiplayerGameBloc>().add(
                        StartRound(state.completedRound.roundNumber + 1),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(
                state.completedRound.roundNumber >= state.room.roundCount
                    ? 'Spiel beenden'
                    : 'Nächste Runde',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCompletedPhase(BuildContext context, GameCompleted state) {
    final sortedScores = state.finalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Text(
            'Spiel beendet!',
            style: AppTypography.headline1,
          ),
          const SizedBox(height: AppSpacing.l),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  Text('Endergebnis', style: AppTypography.headline3),
                  const SizedBox(height: AppSpacing.m),
                  ...sortedScores.map((entry) {
                    final player = state.finalPlayers.firstWhere((p) => p.id == entry.key);
                    final isWinner = entry.value == sortedScores.first.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isWinner)
                                Icon(Icons.emoji_events, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                player.playerName,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${entry.value} Punkte',
                            style: AppTypography.body1.copyWith(
                              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<MultiplayerGameBloc>().add(LeaveGameRoom());
                context.router.navigate(const HomeRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Zur Startseite'),
            ),
          ),
        ],
      ),
    );
  }
}