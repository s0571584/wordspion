import 'package:flutter_test/flutter_test.dart';
import 'package:wortspion/core/services/score_calculator.dart';
import 'package:wortspion/data/models/player.dart';

void main() {
  group('ScoreCalculator Tests', () {
    late ScoreCalculator scoreCalculator;
    late List<Player> testPlayers;

    setUp(() {
      scoreCalculator = ScoreCalculator();
      testPlayers = [
        Player.create(id: 'p1', name: 'Alice', score: 0),
        Player.create(id: 'p2', name: 'Bob', score: 0),
        Player.create(id: 'p3', name: 'Charlie', score: 0),
        Player.create(id: 'p4', name: 'David', score: 0),
        Player.create(id: 'p5', name: 'Eve', score: 0),
      ];
    });

    test('Team correctly identifies all spies - Team gets +2 points', () {
      final spies = ['p1', 'p2']; // Alice and Bob are spies
      final accusedSpies = ['p1', 'p2']; // All spies correctly identified
      
      final results = scoreCalculator.calculateRoundScores(
        players: testPlayers,
        spies: spies,
        accusedSpies: accusedSpies,
        wordGuessed: false,
      );

      // Team members should get +2 points
      final charlieResult = results.firstWhere((r) => r.playerId == 'p3');
      final davidResult = results.firstWhere((r) => r.playerId == 'p4');
      final eveResult = results.firstWhere((r) => r.playerId == 'p5');
      
      expect(charlieResult.scoreChange, 2);
      expect(davidResult.scoreChange, 2);
      expect(eveResult.scoreChange, 2);
      
      // Spies should get 0 points (they were caught)
      final aliceResult = results.firstWhere((r) => r.playerId == 'p1');
      final bobResult = results.firstWhere((r) => r.playerId == 'p2');
      
      expect(aliceResult.scoreChange, 0);
      expect(bobResult.scoreChange, 0);
    });

    test('Spies remain undetected - Spies get +3 points', () {
      final spies = ['p1', 'p2']; // Alice and Bob are spies
      final accusedSpies = ['p3']; // Charlie falsely accused
      
      final results = scoreCalculator.calculateRoundScores(
        players: testPlayers,
        spies: spies,
        accusedSpies: accusedSpies,
        wordGuessed: false,
      );

      // Spies should get +3 points each
      final aliceResult = results.firstWhere((r) => r.playerId == 'p1');
      final bobResult = results.firstWhere((r) => r.playerId == 'p2');
      
      expect(aliceResult.scoreChange, 3);
      expect(bobResult.scoreChange, 3);
      
      // Falsely accused team member should get -1 point
      final charlieResult = results.firstWhere((r) => r.playerId == 'p3');
      expect(charlieResult.scoreChange, -1);
      
      // Other team members should get 0 points
      final davidResult = results.firstWhere((r) => r.playerId == 'p4');
      final eveResult = results.firstWhere((r) => r.playerId == 'p5');
      
      expect(davidResult.scoreChange, 0);
      expect(eveResult.scoreChange, 0);
    });

    test('Spy guesses word correctly - Spy gets +2 bonus points', () {
      final spies = ['p1']; // Alice is spy
      final accusedSpies = <String>[]; // No one accused
      
      final results = scoreCalculator.calculateRoundScores(
        players: testPlayers,
        spies: spies,
        accusedSpies: accusedSpies,
        wordGuessed: true,
        wordGuesserId: 'p1', // Alice guessed the word
      );

      // Alice should get +3 (undetected) + 2 (word guess) = +5 points
      final aliceResult = results.firstWhere((r) => r.playerId == 'p1');
      expect(aliceResult.scoreChange, 5);
    });

    test('Skip to results - Spies automatically win', () {
      final spies = ['p1', 'p2']; // Alice and Bob are spies
      
      final results = scoreCalculator.calculateSkipResults(
        players: testPlayers,
        spies: spies,
      );

      // Spies should get +3 points each
      final aliceResult = results.firstWhere((r) => r.playerId == 'p1');
      final bobResult = results.firstWhere((r) => r.playerId == 'p2');
      
      expect(aliceResult.scoreChange, 3);
      expect(bobResult.scoreChange, 3);
      
      // Team members should get 0 points
      final charlieResult = results.firstWhere((r) => r.playerId == 'p3');
      final davidResult = results.firstWhere((r) => r.playerId == 'p4');
      final eveResult = results.firstWhere((r) => r.playerId == 'p5');
      
      expect(charlieResult.scoreChange, 0);
      expect(davidResult.scoreChange, 0);
      expect(eveResult.scoreChange, 0);
    });

    test('Determine winner correctly', () {
      final playersWithScores = [
        Player.create(id: 'p1', name: 'Alice', score: 5),
        Player.create(id: 'p2', name: 'Bob', score: 8),
        Player.create(id: 'p3', name: 'Charlie', score: 3),
      ];
      
      final winner = scoreCalculator.determineWinner(playersWithScores);
      expect(winner.id, 'p2'); // Bob has highest score
      expect(winner.name, 'Bob');
    });
  });
}
