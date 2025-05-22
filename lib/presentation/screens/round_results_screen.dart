import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/presentation/widgets/app_button.dart';
import 'package:wortspion/core/utils/round_results_state.dart';
import 'package:get_it/get_it.dart';
import 'package:wortspion/blocs/game/game_state.dart';

@RoutePage()
class RoundResultsScreen extends StatelessWidget implements AutoRouteWrapper {
  final String gameId;
  final int roundNumber;
  final int totalRounds;
  final List<RoundScoreResult> scoreResults;
  final List<PlayerRoleInfo> playerRoles;
  final String secretWord;
  final bool impostorsWon;
  final bool wordGuessed;

  const RoundResultsScreen({
    super.key,
    required this.gameId,
    required this.roundNumber,
    required this.totalRounds,
    required this.scoreResults,
    required this.playerRoles,
    required this.secretWord,
    required this.impostorsWon,
    required this.wordGuessed,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<GameBloc>(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        print('=== RoundResultsScreen: State change ===');
        print('New state: ${state.runtimeType}');
        
        if (state is GameCompleted) {
          print('GameCompleted received - navigating to final results');
          print('Players: ${state.players?.length ?? 0}');
          print('Winner names: ${state.winnerNames}');
          
          // Navigate to final results with the completion data
          context.router.replace(
            FinalResultsRoute(
              players: state.players ?? [],
              winnerNames: state.winnerNames,
              gameId: gameId,
            ),
          );
        } else if (state is GameError) {
          print('GameError received: ${state.message}');
          // Show error message if game completion fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is GameLoading) {
          print('GameLoading state received');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Runde $roundNumber Ergebnisse'),
            // Disable the back button
            automaticallyImplyLeading: false,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with round information
              _buildRoundHeader(context),

              // Outcome card
              _buildOutcomeCard(context),

              // Secret word reveal
              _buildSecretWordCard(context),

              // Player scores list
              Expanded(
                child: _buildScoresList(context),
              ),

              // Next round / Final results button
              _buildNavigationButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoundHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Text(
        'Runde $roundNumber von $totalRounds',
        style: AppTypography.headline2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOutcomeCard(BuildContext context) {
    final String outcomeText = impostorsWon ? 'Die Spione haben gewonnen!' : 'Das Team hat gewonnen!';

    final String subtitleText = wordGuessed ? 'Ein Spion hat das Geheimwort erraten.' : '';

    final Color backgroundColor = impostorsWon ? AppColors.impostor.withOpacity(0.1) : AppColors.team.withOpacity(0.1);

    final Color textColor = impostorsWon ? AppColors.impostor : AppColors.team;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      color: backgroundColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Text(
              outcomeText,
              style: AppTypography.headline3.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (subtitleText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  subtitleText,
                  style: AppTypography.body2.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecretWordCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            const Text(
              'Geheimwort:',
              style: AppTypography.subtitle1,
            ),
            Text(
              secretWord,
              style: AppTypography.headline3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoresList(BuildContext context) {
    // Sort results by total score descending
    final sortedResults = List<RoundScoreResult>.from(scoreResults)..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final result = sortedResults[index];
        return _buildScoreCard(context, result, index);
      },
    );
  }

  Widget _buildScoreCard(BuildContext context, RoundScoreResult result, int position) {
    final IconData roleIcon = result.isSpy ? Icons.psychology_alt : Icons.person;
    final Color roleColor = result.isSpy ? AppColors.impostor : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(
          '${result.playerName} ${result.isSpy ? "(Spion)" : "(Team)"}',
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          result.reason,
          style: AppTypography.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildScoreChangeIndicator(result.scoreChange),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${result.totalScore} Pkt.',
              style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChangeIndicator(int points) {
    if (points == 0) {
      return const SizedBox.shrink();
    }

    final Color backgroundColor = points > 0 ? AppColors.team.withOpacity(0.2) : AppColors.impostor.withOpacity(0.2);

    final Color textColor = points > 0 ? AppColors.team : AppColors.impostor;

    final String text = points > 0 ? '+$points' : '$points';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context, GameState state) {
    final isLastRound = roundNumber >= totalRounds;
    final isLoading = state is GameLoading;
    
    String buttonText;
    if (isLastRound) {
      buttonText = isLoading ? 'Verarbeitung...' : 'Endergebnisse anzeigen';
    } else {
      buttonText = 'Nächste Runde';
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: AppButton(
        text: buttonText,
        isLoading: isLoading,
        onPressed: isLoading ? null : () {
          if (isLastRound) {
            print('=== RoundResultsScreen: Completing game ===');
            print('Dispatching CompleteGame event for gameId: $gameId');
            // Game is complete, dispatch event and wait for listener to navigate
            context.read<GameBloc>().add(CompleteGame(gameId: gameId));
          } else {
            // Move to next round
            context.read<GameBloc>().add(
                  StartRound(
                    gameId: gameId,
                    roundNumber: roundNumber + 1,
                  ),
                );
            // Navigate to next role reveal screen
            context.router.replace(RoleRevealRoute(gameId: gameId));
          }
        },
      ),
    );
  }
}
