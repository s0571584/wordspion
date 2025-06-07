import 'dart:math' as math;
import '../../data/models/room_player.dart';
import '../../data/models/word.dart';
import '../../data/models/multiplayer_player_role.dart';
import '../../data/repositories/word_repository.dart';

class MultiplayerGameService {
  final WordRepository _wordRepository;
  final math.Random _random = math.Random();

  MultiplayerGameService(this._wordRepository);

  /// Assigns roles to players for a new round
  Future<List<MultiplayerPlayerRole>> assignPlayerRoles({
    required String roundId,
    required List<RoomPlayer> players,
    required int impostorCount,
    required List<String> selectedCategories,
    required bool impostorsKnowEachOther,
  }) async {
    if (players.length < 3) {
      throw Exception('At least 3 players required');
    }

    if (impostorCount >= players.length - 1) {
      throw Exception('Too many impostors for player count');
    }

    // Get words for the round
    final wordPair = await _selectWordPair(selectedCategories);
    final mainWord = wordPair['main']!;
    final decoyWord = wordPair['decoy']!;

    // Randomly select impostors
    final shuffledPlayers = List<RoomPlayer>.from(players)..shuffle(_random);
    final impostorPlayerIds = shuffledPlayers.take(impostorCount).map((p) => p.id).toSet();

    // Assign roles and words
    final roles = <MultiplayerPlayerRole>[];

    for (final player in players) {
      final isImpostor = impostorPlayerIds.contains(player.id);
      final assignedWord = isImpostor ? decoyWord : mainWord;

      roles.add(MultiplayerPlayerRole(
        id: _generateId(),
        roundId: roundId,
        playerId: player.id,
        isImpostor: isImpostor,
        assignedWordId: assignedWord.id,
      ));
    }

    return roles;
  }

  /// Selects a main word and similar decoy word for the round
  Future<Map<String, Word>> _selectWordPair(List<String> selectedCategories) async {
    // Get random category
    final category = selectedCategories[_random.nextInt(selectedCategories.length)];

    // Get words from category
    final words = await _wordRepository.getWordsByCategory(category);
    if (words.length < 2) {
      throw Exception('Not enough words in category $category');
    }

    // Select main word
    final mainWord = words[_random.nextInt(words.length)];

    // For now, select a different word as decoy
    // In a real implementation, you'd want semantically similar words
    final remainingWords = words.where((w) => w.id != mainWord.id).toList();
    final decoyWord = remainingWords[_random.nextInt(remainingWords.length)];

    return {
      'main': mainWord,
      'decoy': decoyWord,
    };
  }

  /// Calculates round results based on votes
  Map<String, dynamic> calculateRoundResults({
    required List<RoomPlayer> players,
    required List<MultiplayerPlayerRole> roles,
    required Map<String, String> votes, // voter_id -> target_id
    required Map<String, String> wordGuesses, // player_id -> guessed_word
    required String correctWord,
  }) {
    final impostors = roles.where((r) => r.isImpostor).toList();
    final regularPlayers = roles.where((r) => !r.isImpostor).toList();

    // Count votes against each player
    final voteCount = <String, int>{};
    for (final targetId in votes.values) {
      voteCount[targetId] = (voteCount[targetId] ?? 0) + 1;
    }

    // Find most voted player(s)
    final maxVotes = voteCount.values.isEmpty ? 0 : voteCount.values.reduce(math.max);
    final mostVotedPlayerIds = voteCount.entries.where((entry) => entry.value == maxVotes).map((entry) => entry.key).toList();

    // Check if an impostor was eliminated
    final eliminatedImpostors = mostVotedPlayerIds.where((playerId) => impostors.any((role) => role.playerId == playerId)).toList();

    // Check word guesses
    final correctWordGuesses = wordGuesses.entries
        .where((entry) => entry.value.toLowerCase().trim() == correctWord.toLowerCase().trim() && impostors.any((role) => role.playerId == entry.key))
        .toList();

    // Determine round outcome
    bool impostorsWon = false;

    if (correctWordGuesses.isNotEmpty) {
      // Impostors win if they guess the word
      impostorsWon = true;
    } else if (eliminatedImpostors.length == impostors.length) {
      // Regular players win if all impostors are eliminated
      impostorsWon = false;
    } else if (eliminatedImpostors.isNotEmpty) {
      // Some impostors eliminated but not all
      impostorsWon = false;
    } else {
      // No impostors eliminated
      impostorsWon = true;
    }

    // Calculate scores
    final scores = <String, int>{};

    for (final player in players) {
      final role = roles.firstWhere((r) => r.playerId == player.id);

      if (role.isImpostor) {
        // Impostor scoring
        int score = 0;
        if (impostorsWon) {
          score += 3; // Base points for winning
        }
        if (correctWordGuesses.any((guess) => guess.key == player.id)) {
          score += 2; // Bonus for guessing word
        }
        scores[player.id] = score;
      } else {
        // Regular player scoring
        int score = 0;
        if (!impostorsWon) {
          score += 1; // Point for team winning
        }
        // Bonus point for correctly voting for an impostor
        final targetId = votes[player.id];
        if (targetId != null && eliminatedImpostors.contains(targetId)) {
          score += 1;
        }
        scores[player.id] = score;
      }
    }

    return {
      'impostors_won': impostorsWon,
      'eliminated_players': mostVotedPlayerIds,
      'eliminated_impostors': eliminatedImpostors,
      'correct_word_guesses': correctWordGuesses,
      'vote_count': voteCount,
      'scores': scores,
      'word_guessed': correctWordGuesses.isNotEmpty,
    };
  }

  /// Checks if game should end (all rounds completed or impostors eliminated)
  bool shouldGameEnd({
    required int currentRound,
    required int totalRounds,
    required int totalImpostors,
    required int eliminatedImpostors,
  }) {
    return currentRound >= totalRounds || eliminatedImpostors >= totalImpostors;
  }

  /// Calculates final game scores
  Map<String, int> calculateFinalScores(List<Map<String, int>> roundScores) {
    final finalScores = <String, int>{};

    for (final roundScore in roundScores) {
      for (final entry in roundScore.entries) {
        finalScores[entry.key] = (finalScores[entry.key] ?? 0) + entry.value;
      }
    }

    return finalScores;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(1000).toString();
  }
}
