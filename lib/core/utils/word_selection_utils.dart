import 'dart:math';

class WordSelectionUtils {
  // Private constructor to prevent instantiation
  WordSelectionUtils._();

  /// Calculates the similarity score between two words.
  /// Returns a value between 0.0 (completely different) and 1.0 (identical).
  ///
  /// This is a simple implementation using Levenshtein distance as baseline
  /// and additional heuristics for word relationship.
  static double calculateSimilarity(String word1, String word2) {
    if (word1.isEmpty || word2.isEmpty) return 0.0;
    if (word1 == word2) return 1.0;

    // Normalize to lowercase
    final a = word1.toLowerCase();
    final b = word2.toLowerCase();

    // Length-based similarity component
    final maxLength = max(a.length, b.length);
    final minLength = min(a.length, b.length);
    final lengthSimilarity = minLength / maxLength;

    // Levenshtein distance
    final distance = _levenshteinDistance(a, b);
    final distanceSimilarity = 1.0 - (distance / maxLength);

    // Common prefix
    int commonPrefixLength = 0;
    for (int i = 0; i < min(a.length, b.length); i++) {
      if (a[i] == b[i]) {
        commonPrefixLength++;
      } else {
        break;
      }
    }
    final prefixSimilarity = commonPrefixLength / maxLength;

    // Final similarity is a weighted average of the components
    return (distanceSimilarity * 0.6) + (lengthSimilarity * 0.3) + (prefixSimilarity * 0.1);
  }

  /// Calculates the Levenshtein distance between two strings.
  /// This is the minimum number of single-character edits required to change one string into the other.
  static int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<List<int>> distance = List.generate(a.length + 1, (i) => List.generate(b.length + 1, (j) => 0));

    for (int i = 0; i <= a.length; i++) {
      distance[i][0] = i;
    }

    for (int j = 0; j <= b.length; j++) {
      distance[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
        distance[i][j] = min(distance[i - 1][j] + 1, min(distance[i][j - 1] + 1, distance[i - 1][j - 1] + cost));
      }
    }

    return distance[a.length][b.length];
  }

  /// Selects the best decoy word from a list of candidates.
  ///
  /// The "best" decoy word has:
  /// 1. Medium similarity (not too obvious, not too different)
  /// 2. Similar length
  /// 3. Different starting letters if possible
  static String selectBestDecoyWord(String mainWord, List<String> candidates) {
    if (candidates.isEmpty) return '';
    if (candidates.length == 1) return candidates.first;

    // Calculate similarity scores
    final scores = <String, double>{};
    for (final candidate in candidates) {
      scores[candidate] = calculateSimilarity(mainWord, candidate);
    }

    // Sort candidates by how close their similarity is to the ideal range (0.4-0.6)
    candidates.sort((a, b) {
      final aDiff = (scores[a]! - 0.5).abs();
      final bDiff = (scores[b]! - 0.5).abs();
      return aDiff.compareTo(bDiff);
    });

    // Take the top 3 candidates (or fewer if less available)
    final topCandidates = candidates.take(min(3, candidates.length)).toList();

    // From the top candidates, prioritize those with different starting letter
    final mainFirstLetter = mainWord.toLowerCase().isNotEmpty ? mainWord.toLowerCase()[0] : '';
    final differentStartLetterCandidates = topCandidates.where((c) => c.toLowerCase().isNotEmpty && c.toLowerCase()[0] != mainFirstLetter).toList();

    if (differentStartLetterCandidates.isNotEmpty) {
      return differentStartLetterCandidates.first;
    }

    // If no candidates with different starting letter, return the best match
    return topCandidates.first;
  }
}
