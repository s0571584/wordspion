import 'package:wortspion/data/repositories/word_repository.dart';
import 'package:wortspion/data/models/spy_word_set.dart';
import 'package:wortspion/data/models/word.dart';
import 'package:wortspion/core/utils/spy_word_validator.dart';

class SpyWordCoverageTracker {
  final WordRepository wordRepository;
  
  SpyWordCoverageTracker({required this.wordRepository});

  /// Analyzes spy word coverage across all main words
  Future<CoverageReport> analyzeCoverage() async {
    print('🔍 Analyzing spy word coverage...');
    
    // Get all categories
    final categories = await wordRepository.getAllCategories();
    final Map<String, CoverageByCategory> coverageByCategory = {};
    
    int totalWords = 0;
    int coveredWords = 0;
    int excellentQuality = 0;
    int goodQuality = 0;
    int poorQuality = 0;
    final List<String> missingCoverage = [];
    final List<ValidationIssue> validationIssues = [];
    
    for (final category in categories) {
      print('  📂 Checking category: ${category.name}');
      
      final categoryWords = await wordRepository.getWordsByCategoryId(category.id);
      int categoryCovered = 0;
      final List<String> categoryMissing = [];
      final List<ValidationIssue> categoryIssues = [];
      
      for (final word in categoryWords) {
        totalWords++;
        
        try {
          final spyWordSet = await wordRepository.getSpyWordSet(word.id);
          
          // Check if we have sufficient predefined spy words (not just fallbacks)
          final predefinedCount = spyWordSet.spyWords.where((sw) => sw.priority <= 5).length;
          
          if (predefinedCount >= 5) {
            // We have full coverage
            coveredWords++;
            categoryCovered++;
            
            // Validate quality
            final validation = SpyWordValidator.validateSpyWordSet(spyWordSet);
            
            if (validation.score >= 85) {
              excellentQuality++;
            } else if (validation.score >= 70) {
              goodQuality++;
            } else {
              poorQuality++;
            }
            
            // Collect validation issues
            if (validation.hasIssues) {
              categoryIssues.add(ValidationIssue(
                wordId: word.id,
                wordText: word.text,
                validation: validation,
              ));
            }
            
          } else {
            // Missing or insufficient coverage
            missingCoverage.add('${word.text} (${category.name})');
            categoryMissing.add(word.text);
          }
          
        } catch (e) {
          // Error getting spy words - count as missing
          missingCoverage.add('${word.text} (${category.name}) - Error: $e');
          categoryMissing.add('${word.text} - Error');
        }
      }
      
      coverageByCategory[category.id] = CoverageByCategory(
        categoryName: category.name,
        totalWords: categoryWords.length,
        coveredWords: categoryCovered,
        missingWords: categoryMissing,
        validationIssues: categoryIssues,
      );
      
      validationIssues.addAll(categoryIssues);
    }
    
    final coveragePercentage = totalWords > 0 ? (coveredWords / totalWords * 100) : 0.0;
    
    print('✅ Coverage analysis complete!');
    print('   📊 Total: $coveredWords/$totalWords words (${coveragePercentage.toStringAsFixed(1)}%)');
    
    return CoverageReport(
      totalWords: totalWords,
      coveredWords: coveredWords,
      coveragePercentage: coveragePercentage,
      excellentQuality: excellentQuality,
      goodQuality: goodQuality,
      poorQuality: poorQuality,
      missingCoverage: missingCoverage,
      validationIssues: validationIssues,
      coverageByCategory: coverageByCategory,
    );
  }

  /// Generates a detailed coverage report
  Future<String> generateReport() async {
    final coverage = await analyzeCoverage();
    final buffer = StringBuffer();
    
    buffer.writeln('# 🎯 Spy Word Coverage Report');
    buffer.writeln();
    buffer.writeln('## 📊 Overall Statistics');
    buffer.writeln('- **Total Words**: ${coverage.totalWords}');
    buffer.writeln('- **Covered Words**: ${coverage.coveredWords}');
    buffer.writeln('- **Coverage**: ${coverage.coveragePercentage.toStringAsFixed(1)}%');
    buffer.writeln();
    
    buffer.writeln('## 🏆 Quality Distribution');
    buffer.writeln('- **Excellent** (85+ score): ${coverage.excellentQuality}');
    buffer.writeln('- **Good** (70-84 score): ${coverage.goodQuality}');
    buffer.writeln('- **Poor** (<70 score): ${coverage.poorQuality}');
    buffer.writeln();
    
    // Coverage by category
    buffer.writeln('## 📂 Coverage by Category');
    for (final categoryEntry in coverage.coverageByCategory.entries) {
      final cat = categoryEntry.value;
      final percentage = cat.totalWords > 0 ? (cat.coveredWords / cat.totalWords * 100) : 0.0;
      buffer.writeln('- **${cat.categoryName}**: ${cat.coveredWords}/${cat.totalWords} (${percentage.toStringAsFixed(1)}%)');
      
      if (cat.missingWords.isNotEmpty) {
        buffer.writeln('  - Missing: ${cat.missingWords.join(", ")}');
      }
    }
    buffer.writeln();
    
    // Missing coverage
    if (coverage.missingCoverage.isNotEmpty) {
      buffer.writeln('## ❌ Missing Coverage (${coverage.missingCoverage.length} words)');
      for (final missing in coverage.missingCoverage.take(20)) {
        buffer.writeln('- $missing');
      }
      if (coverage.missingCoverage.length > 20) {
        buffer.writeln('- ... and ${coverage.missingCoverage.length - 20} more');
      }
      buffer.writeln();
    }
    
    // Validation issues
    if (coverage.validationIssues.isNotEmpty) {
      buffer.writeln('## ⚠️ Quality Issues (${coverage.validationIssues.length} words)');
      for (final issue in coverage.validationIssues.take(10)) {
        buffer.writeln('### ${issue.wordText}');
        if (issue.validation.errors.isNotEmpty) {
          buffer.writeln('**Errors:**');
          for (final error in issue.validation.errors) {
            buffer.writeln('- $error');
          }
        }
        if (issue.validation.warnings.isNotEmpty) {
          buffer.writeln('**Warnings:**');
          for (final warning in issue.validation.warnings) {
            buffer.writeln('- $warning');
          }
        }
        buffer.writeln();
      }
      if (coverage.validationIssues.length > 10) {
        buffer.writeln('... and ${coverage.validationIssues.length - 10} more issues');
      }
    }
    
    return buffer.toString();
  }

  /// Quick coverage statistics for logging
  Future<void> logCoverageStats() async {
    final coverage = await analyzeCoverage();
    print('🎯 Spy Word Coverage: ${coverage.coveredWords}/${coverage.totalWords} words (${coverage.coveragePercentage.toStringAsFixed(1)}%)');
    print('🏆 Quality: ${coverage.excellentQuality} excellent, ${coverage.goodQuality} good, ${coverage.poorQuality} poor');
  }
}

class CoverageReport {
  final int totalWords;
  final int coveredWords;
  final double coveragePercentage;
  final int excellentQuality;
  final int goodQuality;
  final int poorQuality;
  final List<String> missingCoverage;
  final List<ValidationIssue> validationIssues;
  final Map<String, CoverageByCategory> coverageByCategory;
  
  const CoverageReport({
    required this.totalWords,
    required this.coveredWords,
    required this.coveragePercentage,
    required this.excellentQuality,
    required this.goodQuality,
    required this.poorQuality,
    required this.missingCoverage,
    required this.validationIssues,
    required this.coverageByCategory,
  });
}

class CoverageByCategory {
  final String categoryName;
  final int totalWords;
  final int coveredWords;
  final List<String> missingWords;
  final List<ValidationIssue> validationIssues;
  
  const CoverageByCategory({
    required this.categoryName,
    required this.totalWords,
    required this.coveredWords,
    required this.missingWords,
    required this.validationIssues,
  });
}

class ValidationIssue {
  final String wordId;
  final String wordText;
  final ValidationResult validation;
  
  const ValidationIssue({
    required this.wordId,
    required this.wordText,
    required this.validation,
  });
}
