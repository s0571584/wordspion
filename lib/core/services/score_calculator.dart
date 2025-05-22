import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/round_score_result.dart';

/// Service class for calculating scores in the game
class ScoreCalculator {
  /// Calculates scores for all players based on round outcome
  /// 
  /// Parameters:
  /// - players: List of all players in the game
  /// - spies: List of spy player IDs
  /// - accusedSpies: List of player IDs accused as spies
  /// - wordGuessed: Whether any spy successfully guessed the secret word
  /// - wordGuesserId: ID of the player who guessed the word (if applicable)
  /// 
  /// Returns a list of RoundScoreResult objects with score changes for each player
  List<RoundScoreResult> calculateRoundScores({
    required List<Player> players,
    required List<String> spies,
    required List<String> accusedSpies,
    required bool wordGuessed,
    String? wordGuesserId,
  }) {
    final List<RoundScoreResult> results = [];
    
    // Determine if team identified all spies correctly
    final bool identifiedAllSpies = _teamIdentifiedAllSpies(spies, accusedSpies);
    
    for (final player in players) {
      final bool isSpy = spies.contains(player.id);
      int scoreChange = 0;
      String reason = '';
      
      if (isSpy) {
        // Score calculation for spies
        if (!accusedSpies.contains(player.id)) {
          // Spy remained undetected
          scoreChange += 3;
          reason = 'Spion unentdeckt (+3)';
        } else {
          reason = 'Spion entdeckt (0)';
        }
        
        // Bonus points for guessing the word
        if (wordGuessed && player.id == wordGuesserId) {
          scoreChange += 2;
          reason = reason.isEmpty ? 'Wort erraten (+2)' : '$reason, Wort erraten (+2)';
        }
      } else {
        // Score calculation for team members
        if (identifiedAllSpies) {
          // Team correctly identified all spies
          scoreChange += 2;
          reason = 'Alle Spione entdeckt (+2)';
        } else {
          reason = 'Spione nicht vollständig entdeckt (0)';
        }
        
        // Penalty for being falsely accused
        if (accusedSpies.contains(player.id)) {
          scoreChange -= 1;
          reason = 'Fälschlicherweise beschuldigt (-1)';
        }
      }
      
      results.add(RoundScoreResult(
        playerId: player.id,
        playerName: player.name,
        scoreChange: scoreChange,
        totalScore: player.score + scoreChange,
        isSpy: isSpy,
        reason: reason,
      ));
    }
    
    return results;
  }
  
  /// Calculate score for "Skip to Results" which results in spy win by default
  List<RoundScoreResult> calculateSkipResults({
    required List<Player> players,
    required List<String> spies,
  }) {
    final List<RoundScoreResult> results = [];
    
    for (final player in players) {
      final bool isSpy = spies.contains(player.id);
      int scoreChange = 0;
      String reason = '';
      
      if (isSpy) {
        // Spies win when skipping
        scoreChange += 3;
        reason = 'Runde übersprungen, Spione gewinnen (+3)';
      } else {
        // Team members don't get points when skipping
        reason = 'Runde übersprungen, Team verliert (0)';
      }
      
      results.add(RoundScoreResult(
        playerId: player.id,
        playerName: player.name,
        scoreChange: scoreChange,
        totalScore: player.score + scoreChange,
        isSpy: isSpy,
        reason: reason,
      ));
    }
    
    return results;
  }
  
  /// Determines the winner of the game based on final scores
  Player determineWinner(List<Player> players) {
    if (players.isEmpty) {
      throw ArgumentError('Cannot determine winner from empty player list');
    }
    
    // Sort by score in descending order
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    
    return sortedPlayers.first;
  }
  
  /// Check if the team correctly identified all spies
  bool _teamIdentifiedAllSpies(List<String> spies, List<String> accusedSpies) {
    // All spies must be accused (no spy undetected)
    final bool allSpiesAccused = spies.every((spyId) => accusedSpies.contains(spyId));
    
    // Only spies should be accused (no false accusations)
    final bool onlySpiesAccused = accusedSpies.every((accusedId) => spies.contains(accusedId));
    
    return allSpiesAccused && onlySpiesAccused;
  }
}
