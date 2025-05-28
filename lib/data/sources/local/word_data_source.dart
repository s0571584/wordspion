// Centralized word data source that aggregates all category files
// This file provides a clean interface for the database helper to access
// all words and spy words without duplicates

import 'entertainment_words.dart';
import 'sports_words.dart';
import 'animals_words.dart';
import 'food_words.dart';
import 'places_words.dart';
import 'professions_words.dart';
import 'technology_words.dart';
import 'everyday_words.dart';

class WordDataSource {
  // All available categories
  static const List<Map<String, dynamic>> categories = [
    {
      'id': EntertainmentWords.categoryId,
      'name': EntertainmentWords.categoryName,
      'description': EntertainmentWords.categoryDescription,
      'is_default': EntertainmentWords.isDefault ? 1 : 0,
    },
    {
      'id': SportsWords.categoryId,
      'name': SportsWords.categoryName,
      'description': SportsWords.categoryDescription,
      'is_default': SportsWords.isDefault ? 1 : 0,
    },
    {
      'id': AnimalsWords.categoryId,
      'name': AnimalsWords.categoryName,
      'description': AnimalsWords.categoryDescription,
      'is_default': AnimalsWords.isDefault ? 1 : 0,
    },
    {
      'id': FoodWords.categoryId,
      'name': FoodWords.categoryName,
      'description': FoodWords.categoryDescription,
      'is_default': FoodWords.isDefault ? 1 : 0,
    },
    {
      'id': PlacesWords.categoryId,
      'name': PlacesWords.categoryName,
      'description': PlacesWords.categoryDescription,
      'is_default': PlacesWords.isDefault ? 1 : 0,
    },
    {
      'id': ProfessionsWords.categoryId,
      'name': ProfessionsWords.categoryName,
      'description': ProfessionsWords.categoryDescription,
      'is_default': ProfessionsWords.isDefault ? 1 : 0,
    },
    {
      'id': TechnologyWords.categoryId,
      'name': TechnologyWords.categoryName,
      'description': TechnologyWords.categoryDescription,
      'is_default': TechnologyWords.isDefault ? 1 : 0,
    },
    {
      'id': EverydayWords.categoryId,
      'name': EverydayWords.categoryName,
      'description': EverydayWords.categoryDescription,
      'is_default': EverydayWords.isDefault ? 1 : 0,
    },
  ];

  // All words from all categories
  static List<Map<String, dynamic>> getAllWords() {
    final List<Map<String, dynamic>> allWords = [];

    // Add category_id to each word
    for (var word in EntertainmentWords.words) {
      allWords.add({...word, 'category_id': EntertainmentWords.categoryId});
    }

    for (var word in SportsWords.words) {
      allWords.add({...word, 'category_id': SportsWords.categoryId});
    }

    for (var word in AnimalsWords.words) {
      allWords.add({...word, 'category_id': AnimalsWords.categoryId});
    }

    for (var word in FoodWords.words) {
      allWords.add({...word, 'category_id': FoodWords.categoryId});
    }

    for (var word in PlacesWords.words) {
      allWords.add({...word, 'category_id': PlacesWords.categoryId});
    }

    for (var word in ProfessionsWords.words) {
      allWords.add({...word, 'category_id': ProfessionsWords.categoryId});
    }

    for (var word in TechnologyWords.words) {
      allWords.add({...word, 'category_id': TechnologyWords.categoryId});
    }

    for (var word in EverydayWords.words) {
      allWords.add({...word, 'category_id': EverydayWords.categoryId});
    }

    return allWords;
  }

  // All spy words from all categories
  static List<Map<String, dynamic>> getAllSpyWords() {
    final List<Map<String, dynamic>> allSpyWords = [];
    final now = DateTime.now().millisecondsSinceEpoch;

    // Add spy words with unique IDs and created_at timestamp
    int spyWordCounter = 1;

    for (var spyWord in EntertainmentWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in SportsWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in AnimalsWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in FoodWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in PlacesWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in ProfessionsWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in TechnologyWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    for (var spyWord in EverydayWords.spyWords) {
      allSpyWords.add({
        'id': 'spy_${spyWordCounter.toString().padLeft(4, '0')}',
        'created_at': now,
        ...spyWord,
      });
      spyWordCounter++;
    }

    return allSpyWords;
  }

  // Get words by category
  static List<Map<String, dynamic>> getWordsByCategory(String categoryId) {
    switch (categoryId) {
      case 'entertainment':
        return EntertainmentWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'sports':
        return SportsWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'animals':
        return AnimalsWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'food':
        return FoodWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'places':
        return PlacesWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'professions':
        return ProfessionsWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'technology':
        return TechnologyWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      case 'everyday':
        return EverydayWords.words.map((word) => {...word, 'category_id': categoryId}).toList();
      default:
        return [];
    }
  }

  // Get spy words by category
  static List<Map<String, dynamic>> getSpyWordsByCategory(String categoryId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    int spyWordCounter = 1;

    List<Map<String, dynamic>> spyWords;

    switch (categoryId) {
      case 'entertainment':
        spyWords = EntertainmentWords.spyWords;
        break;
      case 'sports':
        spyWords = SportsWords.spyWords;
        break;
      case 'animals':
        spyWords = AnimalsWords.spyWords;
        break;
      case 'food':
        spyWords = FoodWords.spyWords;
        break;
      case 'places':
        spyWords = PlacesWords.spyWords;
        break;
      case 'professions':
        spyWords = ProfessionsWords.spyWords;
        break;
      case 'technology':
        spyWords = TechnologyWords.spyWords;
        break;
      case 'everyday':
        spyWords = EverydayWords.spyWords;
        break;
      default:
        return [];
    }
    return spyWords.map((spyWord) {
      final id = 'spy_${categoryId}_${spyWordCounter.toString().padLeft(3, '0')}';
      spyWordCounter++;
      return {
        'id': id,
        'created_at': now,
        ...spyWord,
      };
    }).toList();
  }

  // Statistics
  static Map<String, int> getStatistics() {
    final stats = <String, int>{};

    stats['total_categories'] = categories.length;
    stats['total_words'] = getAllWords().length;
    stats['total_spy_words'] = getAllSpyWords().length;

    // Words per category
    stats['entertainment_words'] = EntertainmentWords.words.length;
    stats['sports_words'] = SportsWords.words.length;
    stats['animals_words'] = AnimalsWords.words.length;
    stats['food_words'] = FoodWords.words.length;
    stats['places_words'] = PlacesWords.words.length;
    stats['professions_words'] = ProfessionsWords.words.length;
    stats['technology_words'] = TechnologyWords.words.length;
    stats['everyday_words'] = EverydayWords.words.length;

    // Spy words per category
    stats['entertainment_spy_words'] = EntertainmentWords.spyWords.length;
    stats['sports_spy_words'] = SportsWords.spyWords.length;
    stats['animals_spy_words'] = AnimalsWords.spyWords.length;
    stats['food_spy_words'] = FoodWords.spyWords.length;
    stats['places_spy_words'] = PlacesWords.spyWords.length;
    stats['professions_spy_words'] = ProfessionsWords.spyWords.length;
    stats['technology_spy_words'] = TechnologyWords.spyWords.length;
    stats['everyday_spy_words'] = EverydayWords.spyWords.length;

    return stats;
  }

  // Validation - ensure data integrity
  static Map<String, dynamic> validateData() {
    final validation = <String, dynamic>{};
    final issues = <String>[];

    // Check for duplicate word IDs
    final wordIds = <String>{};
    final duplicateWordIds = <String>{};

    for (var word in getAllWords()) {
      final id = word['id'] as String;
      if (wordIds.contains(id)) {
        duplicateWordIds.add(id);
      } else {
        wordIds.add(id);
      }
    }

    if (duplicateWordIds.isNotEmpty) {
      issues.add('Duplicate word IDs: ${duplicateWordIds.join(', ')}');
    }

    // Check that each word has exactly 5 spy words
    final spyWordsPerWord = <String, int>{};
    for (var spyWord in getAllSpyWords()) {
      final mainWordId = spyWord['main_word_id'] as String;
      spyWordsPerWord[mainWordId] = (spyWordsPerWord[mainWordId] ?? 0) + 1;
    }

    final wordsWithoutCorrectSpyWords = <String>[];
    for (var word in getAllWords()) {
      final wordId = word['id'] as String;
      final spyWordCount = spyWordsPerWord[wordId] ?? 0;
      if (spyWordCount != 5) {
        wordsWithoutCorrectSpyWords.add('$wordId has $spyWordCount spy words');
      }
    }

    if (wordsWithoutCorrectSpyWords.isNotEmpty) {
      issues.add('Words without exactly 5 spy words: ${wordsWithoutCorrectSpyWords.join(', ')}');
    }

    // Check that each category has 20 words
    final wordsPerCategory = <String, int>{};
    for (var word in getAllWords()) {
      final categoryId = word['category_id'] as String;
      wordsPerCategory[categoryId] = (wordsPerCategory[categoryId] ?? 0) + 1;
    }

    final categoriesWithIncorrectWordCount = <String>[];
    for (var entry in wordsPerCategory.entries) {
      if (entry.value != 20) {
        categoriesWithIncorrectWordCount.add('${entry.key} has ${entry.value} words');
      }
    }

    if (categoriesWithIncorrectWordCount.isNotEmpty) {
      issues.add('Categories without exactly 20 words: ${categoriesWithIncorrectWordCount.join(', ')}');
    }

    validation['is_valid'] = issues.isEmpty;
    validation['issues'] = issues;
    validation['statistics'] = getStatistics();

    return validation;
  }
}
