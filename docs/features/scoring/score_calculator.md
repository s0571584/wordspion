# Score Calculator Implementation

## Overview

The ScoreCalculator is a service class that handles all score calculation logic for WortSpion. It ensures consistent point allocation across the application.

## Implementation

Create this file at `lib/core/services/score_calculator.dart`:

```dart
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/blocs/round/round_state.dart';

class ScoreCalculator {
  /// Calculates scores for all players based on round outcome
  /// 
  /// Returns a map of player IDs to RoundScoreResult objects
  static Map<String, RoundScoreResult> calculateRoundScores({
    required List<PlayerRoleInfo> playerRoles,
    required Player? votedOutPlayer,
    required bool wordGuessed,
    required String wordGuesserId,
  }) {
    final Map<String, RoundScoreResult> results = {};
    
    // Get list of impostor IDs
    final List<String> impostorIds = playerRoles
        .where((role) => role.isImpostor)
        .map((role) => role.playerId)
        .toList();
    
    // Determine if impostors won
    // Impostors win if no impostor was voted out or if no one was voted out
    final bool impostorsWon = votedOutPlayer == null || 
        !impostorIds.contains(votedOutPlayer.id);
    
    // Calculate scores for each player
    for (final role in playerRoles) {
      int points = 0;
      String reason = '';
      
      if (role.isImpostor) {
        // Impostor scoring
        if (impostorsWon) {
          points += 3;
          reason = 'Spion unentdeckt (+3)';
        }
        
        // Word guess bonus
        if (wordGuessed && role.playerId == wordGuesserId) {
          points += 2;
          reason += reason.isNotEmpty ? ', ' : '';
          reason += 'Wort erraten (+2)';
        }
        
        // Voted out penalty
        if (votedOutPlayer != null && votedOutPlayer.id == role.playerId) {
          reason = 'Entdeckt (0)';
        }
      } else {
        // Team member scoring
        if (!impostorsWon) {
          points += 2;
          reason = 'Spion entdeckt (+2)';
        } else {
          reason = 'Spion nicht entdeckt (0)';
        }
        
        // Wrongly accused penalty
        if (votedOutPlayer != null && votedOutPlayer.id == role.playerId) {
          points -= 1;
          reason = 'Fälschlicherweise beschuldigt (-1)';
        }
      }
      
      results[role.playerId] = RoundScoreResult(
        playerId: role.playerId,
        pointsAwarded: points,
        reason: reason,
        createdAt: DateTime.now(),
      );
    }
    
    return results;
  }
  
  /// Determines the winner player from a list of players
  /// 
  /// Returns the player with highest score
  /// In case of a tie, first player in the list wins
  static Player determineWinner(List<Player> players) {
    if (players.isEmpty) {
      throw ArgumentError('Cannot determine winner from empty player list');
    }
    
    // Sort by score descending
    players.sort((a, b) => b.score.compareTo(a.score));
    
    return players.first;
  }
}
```

## Usage

The ScoreCalculator should be called at these key points:

1. In VotingScreen when processing voting results:
   ```dart
   // After determining votedOutPlayer and wordGuessed:
   final scoreResults = ScoreCalculator.calculateRoundScores(
     playerRoles: roundState.playerRoles,
     votedOutPlayer: votedOutPlayer,
     wordGuessed: wordGuessed,
     wordGuesserId: wordGuesserId,
   );
   
   // Pass to round completion
   roundBloc.add(CompleteRound(
     roundId: roundId,
     impostorsWon: impostorsWon,
     wordGuessed: wordGuessed,
     scoreResults: scoreResults,
   ));
   ```

2. In GamePlayScreen when skipping directly to results:
   ```dart
   void _completeRoundAndSkip() {
     // When skipping, impostors win by default
     final scoreResults = ScoreCalculator.calculateRoundScores(
       playerRoles: (_roundBloc.state as RoundStarted).playerRoles.entries
           .map((e) => PlayerRoleInfo(
               playerId: e.key,
               playerName: _getPlayerName(e.key),
               roleName: _getRoleName(e.value),
               isImpostor: e.value == PlayerRoleType.impostor))
           .toList(),
       votedOutPlayer: null, // No one was voted out
       wordGuessed: false,   // No word guessing
       wordGuesserId: '',    // No guesser
     );
     
     _roundBloc.add(CompleteRound(
       roundId: widget.roundId,
       impostorsWon: true,
       wordGuessed: false,
       scoreResults: scoreResults,
     ));
   }
   ```

## Testing

Create unit tests to verify scoring logic:

```dart
void main() {
  group('ScoreCalculator', () {
    test('should award points correctly when impostors win', () {
      // Test setup
      final playerRoles = [
        PlayerRoleInfo(playerId: 'p1', playerName: 'P1', roleName: 'Impostor', isImpostor: true),
        PlayerRoleInfo(playerId: 'p2', playerName: 'P2', roleName: 'Civilian', isImpostor: false),
      ];
      
      final results = ScoreCalculator.calculateRoundScores(
        playerRoles: playerRoles,
        votedOutPlayer: null, // No one voted out = impostors win
        wordGuessed: false,
        wordGuesserId: '',
      );
      
      // Verification
      expect(results['p1']?.pointsAwarded, 3); // Impostor gets 3 points
      expect(results['p2']?.pointsAwarded, 0); // Team member gets 0 points
    });
    
    // Add more test cases for other scenarios
  });
}
```
