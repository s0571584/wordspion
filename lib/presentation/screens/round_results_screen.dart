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

@RoutePage()
class RoundResultsScreen extends StatelessWidget {
  final String gameId;
  final int roundNumber;
  final int totalRounds;
  final List<RoundScoreResult> scoreResults;
  final List<PlayerRoleInfo> playerRoles;
  final String secretWord;
  final bool impostorsWon;
  final bool wordGuessed;

  const RoundResultsScreen({
    Key? key,
    required this.gameId,
    required this.roundNumber,
    required this.totalRounds,
    required this.scoreResults,
    required this.playerRoles,
    required this.secretWord,
    required this.impostorsWon,
    required this.wordGuessed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _buildNavigationButton(context),
        ],
      ),
    );
  }

  Widget _buildRoundHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Text(
        'Runde $roundNumber von $totalRounds',
        style: AppTypography.title,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOutcomeCard(BuildContext context) {
    final String outcomeText = impostorsWon
        ? 'Die Spione haben gewonnen!'
        : 'Das Team hat gewonnen!';
    
    final String subtitleText = wordGuessed
        ? 'Ein Spion hat das Geheimwort erraten.'
        : '';
    
    final Color backgroundColor = impostorsWon
        ? AppColors.errorBackground
        : AppColors.successBackground;
    
    final Color textColor = impostorsWon
        ? AppColors.errorText
        : AppColors.successText;
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      color: backgroundColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Text(
              outcomeText,
              style: AppTypography.title.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            if (subtitleText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.small),
                child: Text(
                  subtitleText,
                  style: AppTypography.body.copyWith(color: textColor),
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
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Text(
              'Geheimwort:',
              style: AppTypography.subtitle,
            ),
            Text(
              secretWord,
              style: AppTypography.title.copyWith(
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
    final sortedResults = List<RoundScoreResult>.from(scoreResults)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final result = sortedResults[index];
        return _buildScoreCard(context, result, index);
      },
    );
  }

  Widget _buildScoreCard(BuildContext context, RoundScoreResult result, int position) {
    final IconData roleIcon = result.isSpy ? Icons.psychology_alt : Icons.person;
    final Color roleColor = result.isSpy ? AppColors.error : AppColors.primary;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(
          '${result.playerName} ${result.isSpy ? "(Spion)" : "(Team)"}',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          result.reason,
          style: AppTypography.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildScoreChangeIndicator(result.scoreChange),
            const SizedBox(width: AppSpacing.small),
            Text(
              '${result.totalScore} Pkt.',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
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
    
    final Color backgroundColor = points > 0
        ? AppColors.success.withOpacity(0.2)
        : AppColors.error.withOpacity(0.2);
    
    final Color textColor = points > 0
        ? AppColors.success
        : AppColors.error;
    
    final String text = points > 0 ? '+$points' : '$points';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
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

  Widget _buildNavigationButton(BuildContext context) {
    final isLastRound = roundNumber >= totalRounds;
    final buttonText = isLastRound ? 'Endergebnisse anzeigen' : 'Nächste Runde';
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: AppButton(
        label: buttonText,
        onPressed: () {
          if (isLastRound) {
            // Game is complete, navigate to final results
            context.read<GameBloc>().add(CompleteGame(gameId: gameId));
            Navigator.of(context).pushReplacementNamed('/final_results');
          } else {
            // Move to next round
            context.read<GameBloc>().add(
              StartRound(
                gameId: gameId,
                roundNumber: roundNumber + 1,
              ),
            );
            // Navigate to next role reveal screen
            Navigator.of(context).pushReplacementNamed('/role_reveal');
          }
        },
      ),
    );
  }
}
