import 'package:wortspion/core/utils/word_selection_utils.dart';
import 'package:wortspion/data/models/category.dart';
import 'package:wortspion/data/models/word.dart';
import 'package:wortspion/data/models/word_relation.dart';
import 'package:wortspion/data/sources/local/database_helper.dart';

abstract class WordRepository {
  // Categories operations
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getDefaultCategories();
  Future<Category> getCategoryById(String id);

  // Words operations
  Future<List<Word>> getWordsByCategoryId(String categoryId);
  Future<Word> getWordById(String id);
  Future<List<Word>> getRandomWordsByCategories(List<String> categoryIds, int count);

  // Word selection operations
  Future<Word> selectMainWord(List<String> categoryIds, int difficulty);
  Future<Word> selectDecoyWord(String mainWordId, List<String> categoryIds);
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
  Future<Word> selectDecoyWord(String mainWordId, List<String> categoryIds) async {
    // Hauptwort holen
    final mainWord = await getWordById(mainWordId);

    // Strategie 1: Versuche, ein Wort mit einer vordefinierten Ähnlichkeitsbeziehung zu finden
    final relatedWords = await getRelatedWords(mainWordId);

    if (relatedWords.isNotEmpty) {
      // Sortiere nach Ähnlichkeit (ideal ist 0.4-0.7)
      relatedWords.sort((a, b) {
        final aIdeal = (a.similarity - 0.55).abs();
        final bIdeal = (b.similarity - 0.55).abs();
        return aIdeal.compareTo(bIdeal);
      });

      // Wähle eines der Top 3 ähnlichen Wörter
      final topRelations = relatedWords.take(3).toList();
      final selectedRelation = topRelations[DateTime.now().microsecond % topRelations.length];

      // Wähle word_id_2, wenn word_id_1 das Hauptwort ist, ansonsten word_id_1
      final decoyWordId = selectedRelation.wordId1 == mainWordId ? selectedRelation.wordId2 : selectedRelation.wordId1;

      return getWordById(decoyWordId);
    }

    // Strategie 2: Holen und analysieren alle Wörter aus derselben Kategorie
    final sameCategoryWords = await databaseHelper.query(
      'words',
      where: 'category_id = ? AND id != ?',
      whereArgs: [mainWord.categoryId, mainWordId],
    );

    if (sameCategoryWords.isNotEmpty) {
      // Wandle zu Wort-Objekten um
      final wordObjects = sameCategoryWords.map((map) => Word.fromMap(map)).toList();

      // Berechne Ähnlichkeiten und nutze den WordSelectionUtils
      final candidates = wordObjects.map((w) => w.text).toList();
      final selectedText = WordSelectionUtils.selectBestDecoyWord(mainWord.text, candidates);

      // Finde das ausgewählte Wort-Objekt
      final selectedWord = wordObjects.firstWhere((w) => w.text == selectedText, orElse: () => wordObjects.first);

      return selectedWord;
    }

    // Strategie 3: Fallback - wähle ein Wort aus einer anderen Kategorie
    return (await getRandomWordsByCategories(categoryIds, 1)).first;
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
