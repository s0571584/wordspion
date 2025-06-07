import 'package:wortspion/core/utils/word_selection_utils.dart';
import 'package:wortspion/data/models/category.dart';
import 'package:wortspion/data/models/word.dart';
import 'package:wortspion/data/models/word_relation.dart';
import 'package:wortspion/data/models/spy_word_set.dart';
import 'package:wortspion/data/sources/local/database_helper.dart';
import 'package:wortspion/core/constants/database_constants.dart';

abstract class WordRepository {
  // Categories operations
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getDefaultCategories();
  Future<Category> getCategoryById(String id);

  // Words operations
  Future<List<Word>> getWordsByCategoryId(String categoryId);
  Future<List<Word>> getWordsByCategory(String categoryName);
  Future<Word> getWordById(String id);
  Future<List<Word>> getRandomWordsByCategories(List<String> categoryIds, int count);

  // Word selection operations
  Future<Word> selectMainWord(List<String> categoryIds, int difficulty);
  Future<SpyWordSet> getSpyWordSet(String mainWordId);
  Future<bool> hasEnoughSpyWords(String mainWordId, int requiredCount);
  Future<List<WordRelation>> getRelatedWords(String wordId);

  // For development
  Future<void> seedWords();
}

class WordRepositoryImpl implements WordRepository {
  final DatabaseHelper databaseHelper;

  WordRepositoryImpl({required this.databaseHelper});

  @override
  Future<List<Category>> getAllCategories() async {
    final categories = await databaseHelper.query(
      'categories',
      orderBy: 'name ASC',
    );

    return categories.map((map) => Category.fromMap(map)).toList();
  }

  @override
  Future<List<Category>> getDefaultCategories() async {
    final categories = await databaseHelper.query(
      'categories',
      where: 'is_default = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return categories.map((map) => Category.fromMap(map)).toList();
  }

  @override
  Future<Category> getCategoryById(String id) async {
    final categories = await databaseHelper.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (categories.isEmpty) {
      throw Exception('Category not found');
    }

    return Category.fromMap(categories.first);
  }

  @override
  Future<List<Word>> getWordsByCategoryId(String categoryId) async {
    final words = await databaseHelper.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'text ASC',
    );

    return words.map((map) => Word.fromMap(map)).toList();
  }

  @override
  Future<List<Word>> getWordsByCategory(String categoryName) async {
    // First get the category by name
    final categories = await databaseHelper.query(
      'categories',
      where: 'name = ?',
      whereArgs: [categoryName],
    );

    if (categories.isEmpty) {
      throw Exception('Category not found: $categoryName');
    }

    final categoryId = categories.first['id'] as String;
    return getWordsByCategoryId(categoryId);
  }

  @override
  Future<Word> getWordById(String id) async {
    final words = await databaseHelper.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (words.isEmpty) {
      throw Exception('Word not found');
    }

    return Word.fromMap(words.first);
  }

  @override
  Future<List<Word>> getRandomWordsByCategories(List<String> categoryIds, int count) async {
    if (categoryIds.isEmpty) {
      throw Exception('No categories selected');
    }

    final placeholders = List.filled(categoryIds.length, '?').join(',');
    final words = await databaseHelper.rawQuery(
      'SELECT * FROM words WHERE category_id IN ($placeholders) ORDER BY RANDOM() LIMIT ?',
      [...categoryIds, count],
    );

    return words.map((map) => Word.fromMap(map)).toList();
  }

  @override
  Future<Word> selectMainWord(List<String> categoryIds, int difficulty) async {
    if (categoryIds.isEmpty) {
      throw Exception('No categories selected');
    }

    // Wähle Wörter aus ausgewählten Kategorien mit passender Schwierigkeit
    final placeholders = List.filled(categoryIds.length, '?').join(',');
    final difficultyCondition = difficulty > 0 ? ' AND difficulty = ?' : '';
    final args = difficulty > 0 ? [...categoryIds, difficulty] : categoryIds;

    final words = await databaseHelper.rawQuery(
      'SELECT * FROM words WHERE category_id IN ($placeholders)$difficultyCondition ORDER BY RANDOM() LIMIT 1',
      args,
    );

    if (words.isEmpty) {
      // Fallback: Ignoriere Schwierigkeit, wenn keine Wörter gefunden wurden
      return selectMainWord(categoryIds, 0);
    }

    return Word.fromMap(words.first);
  }

  @override
  Future<SpyWordSet> getSpyWordSet(String mainWordId) async {
    try {
      final mainWord = await getWordById(mainWordId);

      final spyRelations = await databaseHelper.query(
        DatabaseConstants.tableSpyWordRelations,
        where: 'main_word_id = ?',
        whereArgs: [mainWordId],
        orderBy: 'priority ASC',
      );

      final List<SpyWordInfo> spyWords = spyRelations
          .map((relation) {
            try {
              return SpyWordInfo.fromMap(relation);
            } catch (e) {
              return null;
            }
          })
          .where((spyWord) => spyWord != null)
          .cast<SpyWordInfo>()
          .toList();

      // Validate spy words
      final validSpyWords = spyWords.where((spyWord) {
        // Basic validation
        if (spyWord.text.isEmpty) {
          return false;
        }
        if (spyWord.text.toLowerCase() == mainWord.text.toLowerCase()) {
          return false;
        }
        return true;
      }).toList();

      // Fallback strategy if insufficient spy words
      if (validSpyWords.length < 5) {
        final fallbackWords = await _generateFallbackSpyWords(mainWord, 5 - validSpyWords.length);
        validSpyWords.addAll(fallbackWords);
      }

      return SpyWordSet(
        mainWordText: mainWord.text,
        spyWords: validSpyWords,
      );
    } catch (e) {
      // Emergency fallback - return generic spy words
      final mainWord = await getWordById(mainWordId);
      final emergencySpyWords = await _generateEmergencySpyWords(mainWord);

      return SpyWordSet(
        mainWordText: mainWord.text,
        spyWords: emergencySpyWords,
      );
    }
  }

  @override
  Future<bool> hasEnoughSpyWords(String mainWordId, int requiredCount) async {
    try {
      final spyRelations = await databaseHelper.query(
        DatabaseConstants.tableSpyWordRelations,
        where: 'main_word_id = ?',
        whereArgs: [mainWordId],
      );

      return spyRelations.length >= requiredCount;
    } catch (e) {
      return false; // Conservative approach - assume we don't have enough
    }
  }

  // Intelligent fallback for words without predefined spy words
  Future<List<SpyWordInfo>> _generateFallbackSpyWords(Word mainWord, int count) async {
    final List<SpyWordInfo> fallbacks = [];

    // Strategy 1: Find words from same category with similar patterns
    final categoryWords = await getWordsByCategoryId(mainWord.categoryId);
    final candidates = categoryWords.where((w) => w.id != mainWord.id).map((w) => w.text).toList();

    if (candidates.isNotEmpty && fallbacks.length < count) {
      // Use existing word selection logic for best matches
      final selectedText = WordSelectionUtils.selectBestDecoyWord(mainWord.text, candidates);
      fallbacks.add(SpyWordInfo(
        text: selectedText,
        relationshipType: 'component',
        difficulty: 2,
        priority: 6,
      ));
    }

    // Strategy 2: Category-specific fallbacks
    switch (mainWord.categoryId) {
      case 'food':
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Teller', relationshipType: 'tool', difficulty: 2, priority: 7),
            const SpyWordInfo(text: 'Restaurant', relationshipType: 'location', difficulty: 2, priority: 8),
            const SpyWordInfo(text: 'Hunger', relationshipType: 'attribute', difficulty: 3, priority: 9),
            const SpyWordInfo(text: 'Geschmack', relationshipType: 'attribute', difficulty: 3, priority: 10),
          ]);
        }
        break;
      case 'sports':
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Training', relationshipType: 'action', difficulty: 2, priority: 7),
            const SpyWordInfo(text: 'Mannschaft', relationshipType: 'person', difficulty: 2, priority: 8),
            const SpyWordInfo(text: 'Sieg', relationshipType: 'attribute', difficulty: 3, priority: 9),
            const SpyWordInfo(text: 'Wettkampf', relationshipType: 'attribute', difficulty: 3, priority: 10),
          ]);
        }
        break;
      case 'animals':
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Zoo', relationshipType: 'location', difficulty: 2, priority: 7),
            const SpyWordInfo(text: 'Wild', relationshipType: 'attribute', difficulty: 3, priority: 8),
            const SpyWordInfo(text: 'Futter', relationshipType: 'component', difficulty: 2, priority: 9),
            const SpyWordInfo(text: 'Käfig', relationshipType: 'location', difficulty: 3, priority: 10),
          ]);
        }
        break;
      case 'entertainment':
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Theater', relationshipType: 'location', difficulty: 2, priority: 7),
            const SpyWordInfo(text: 'Publikum', relationshipType: 'person', difficulty: 2, priority: 8),
            const SpyWordInfo(text: 'Applaus', relationshipType: 'action', difficulty: 3, priority: 9),
            const SpyWordInfo(text: 'Bühne', relationshipType: 'location', difficulty: 2, priority: 10),
          ]);
        }
        break;
      case 'places':
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Reise', relationshipType: 'action', difficulty: 2, priority: 7),
            const SpyWordInfo(text: 'Tourist', relationshipType: 'person', difficulty: 2, priority: 8),
            const SpyWordInfo(text: 'Kultur', relationshipType: 'attribute', difficulty: 3, priority: 9),
            const SpyWordInfo(text: 'Geschichte', relationshipType: 'attribute', difficulty: 3, priority: 10),
          ]);
        }
        break;
      case 'professions':
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Arbeit', relationshipType: 'action', difficulty: 2, priority: 7),
            const SpyWordInfo(text: 'Kollege', relationshipType: 'person', difficulty: 2, priority: 8),
            const SpyWordInfo(text: 'Büro', relationshipType: 'location', difficulty: 2, priority: 9),
            const SpyWordInfo(text: 'Gehalt', relationshipType: 'attribute', difficulty: 3, priority: 10),
          ]);
        }
        break;
      default:
        // Generic fallbacks for unknown categories
        if (fallbacks.length < count) {
          fallbacks.addAll([
            const SpyWordInfo(text: 'Zeit', relationshipType: 'attribute', difficulty: 3, priority: 7),
            const SpyWordInfo(text: 'Mensch', relationshipType: 'person', difficulty: 3, priority: 8),
            const SpyWordInfo(text: 'Welt', relationshipType: 'location', difficulty: 3, priority: 9),
            const SpyWordInfo(text: 'Leben', relationshipType: 'attribute', difficulty: 3, priority: 10),
          ]);
        }
    }

    return fallbacks.take(count).toList();
  }

  // Emergency fallback for critical errors
  Future<List<SpyWordInfo>> _generateEmergencySpyWords(Word mainWord) async {

    // Basic emergency spy words that should work for any context
    final emergencyWords = [
      const SpyWordInfo(text: 'Zeit', relationshipType: 'attribute', difficulty: 3, priority: 101),
      const SpyWordInfo(text: 'Ort', relationshipType: 'location', difficulty: 3, priority: 102),
      const SpyWordInfo(text: 'Person', relationshipType: 'person', difficulty: 3, priority: 103),
      const SpyWordInfo(text: 'Sache', relationshipType: 'component', difficulty: 3, priority: 104),
      const SpyWordInfo(text: 'Idee', relationshipType: 'attribute', difficulty: 3, priority: 105),
    ];

    return emergencyWords;
  }

  @override
  Future<List<WordRelation>> getRelatedWords(String wordId) async {
    final relations = await databaseHelper.rawQuery(
      'SELECT * FROM word_relations WHERE word_id_1 = ? OR word_id_2 = ?',
      [wordId, wordId],
    );

    return relations.map((map) => WordRelation.fromMap(map)).toList();
  }

  @override
  Future<void> seedWords() async {
    // In einer produktiven App würden hier Wörter aus einer Datei geladen
    // Dies ist nur ein Beispiel für Testzwecke
    // Implementierung könnte erweitert werden
  }
}
