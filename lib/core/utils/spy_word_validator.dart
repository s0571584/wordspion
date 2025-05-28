import 'package:wortspion/data/models/spy_word_set.dart';
import 'package:wortspion/data/repositories/word_repository.dart';

class SpyWordValidator {
  static const int minSpyWords = 5;
  static const int maxSpyWords = 5;
  static const List<String> validRelationshipTypes = [
    SpyWordRelationshipType.location,
    SpyWordRelationshipType.component,
    SpyWordRelationshipType.tool,
    SpyWordRelationshipType.person,
    SpyWordRelationshipType.action,
    SpyWordRelationshipType.attribute,
  ];

  /// Validates a spy word set for quality and completeness
  static ValidationResult validateSpyWordSet(SpyWordSet spyWordSet) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Check minimum spy words
    if (spyWordSet.spyWords.length < minSpyWords) {
      errors.add('Insufficient spy words: ${spyWordSet.spyWords.length} < $minSpyWords required');
    }
    
    // Check for duplicate spy words
    final spyWordTexts = spyWordSet.spyWords.map((w) => w.text.toLowerCase()).toList();
    final uniqueTexts = spyWordTexts.toSet();
    if (spyWordTexts.length != uniqueTexts.length) {
      errors.add('Duplicate spy words detected');
    }
    
    // Check for spy word same as main word
    final mainWordLower = spyWordSet.mainWordText.toLowerCase();
    for (final spyWord in spyWordSet.spyWords) {
      if (spyWord.text.toLowerCase() == mainWordLower) {
        errors.add('Spy word "${spyWord.text}" is identical to main word');
      }
    }
    
    // Check relationship type diversity
    final relationshipTypes = spyWordSet.spyWords.map((w) => w.relationshipType).toSet();
    if (relationshipTypes.length < 3) {
      warnings.add('Low relationship diversity: only ${relationshipTypes.length} types used');
    }
    
    // Check difficulty balance
    final difficulties = spyWordSet.spyWords.map((w) => w.difficulty).toList();
    final avgDifficulty = difficulties.reduce((a, b) => a + b) / difficulties.length;
    if (avgDifficulty < 1.5 || avgDifficulty > 2.8) {
      warnings.add('Unbalanced difficulty: average $avgDifficulty (ideal: 1.5-2.8)');
    }
    
    // Check for valid relationship types
    for (final spyWord in spyWordSet.spyWords) {
      if (!validRelationshipTypes.contains(spyWord.relationshipType)) {
        errors.add('Invalid relationship type: ${spyWord.relationshipType}');
      }
    }
    
    // Check for too obvious relationships
    for (final spyWord in spyWordSet.spyWords) {
      if (_isTooObvious(spyWordSet.mainWordText, spyWord.text)) {
        warnings.add('Potentially too obvious: "${spyWord.text}" for "${spyWordSet.mainWordText}"');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      score: _calculateQualityScore(spyWordSet, errors.length, warnings.length),
    );
  }

  /// Checks if a spy word might be too obvious for the main word
  static bool _isTooObvious(String mainWord, String spyWord) {
    final mainLower = mainWord.toLowerCase();
    final spyLower = spyWord.toLowerCase();
    
    // Check if spy word contains main word or vice versa
    if (mainLower.contains(spyLower) || spyLower.contains(mainLower)) {
      return true;
    }
    
    // Check for very similar words (simple heuristic)
    if (_levenshteinDistance(mainLower, spyLower) <= 2 && 
        (mainLower.length > 4 || spyLower.length > 4)) {
      return true;
    }
    
    return false;
  }

  /// Simple Levenshtein distance calculation
  static int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  /// Calculates a quality score for the spy word set (0-100)
  static double _calculateQualityScore(SpyWordSet spyWordSet, int errorCount, int warningCount) {
    double score = 100.0;
    
    // Deduct for errors (critical issues)
    score -= errorCount * 25.0;
    
    // Deduct for warnings (quality issues)
    score -= warningCount * 5.0;
    
    // Bonus for good relationship diversity
    final relationshipTypes = spyWordSet.spyWords.map((w) => w.relationshipType).toSet();
    if (relationshipTypes.length >= 4) {
      score += 10.0;
    }
    
    // Bonus for difficulty balance
    final difficulties = spyWordSet.spyWords.map((w) => w.difficulty).toList();
    final avgDifficulty = difficulties.reduce((a, b) => a + b) / difficulties.length;
    if (avgDifficulty >= 1.8 && avgDifficulty <= 2.5) {
      score += 5.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final double score;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.score,
  });
  
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;
  
  String get summary {
    if (isValid && warnings.isEmpty) {
      return 'Excellent (Score: ${score.toStringAsFixed(1)})';
    } else if (isValid) {
      return 'Good with warnings (Score: ${score.toStringAsFixed(1)})';
    } else {
      return 'Invalid (Score: ${score.toStringAsFixed(1)})';
    }
  }
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Validation Result: $summary');
    
    if (errors.isNotEmpty) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('Warnings:');
      for (final warning in warnings) {
        buffer.writeln('  - $warning');
      }
    }
    
    return buffer.toString();
  }
}
