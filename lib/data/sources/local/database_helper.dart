import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wortspion/core/constants/database_constants.dart';
import 'word_data_source.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton Zugriff
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Instanz-Getter
  static Future<DatabaseHelper> get instance async {
    if (_database == null) {
      await _instance._initDatabase();
    }
    return _instance;
  }

  // Datenbank-Getter
  Future<Database> get database async {
    if (_database == null) {
      await _initDatabase();
    }
    return _database!;
  }

  // Initialisiert die Datenbank
  Future<void> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DatabaseConstants.databaseName);

    _database = await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Erstellen der Datenbank
  Future<void> _onCreate(Database db, int version) async {
    // Tabelle categories erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableCategories} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // Tabelle words erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableWords} (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        text TEXT NOT NULL,
        difficulty INTEGER DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES ${DatabaseConstants.tableCategories}(id),
        UNIQUE(category_id, text)
      )
    ''');

    // Tabelle word_relations erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableWordRelations} (
        word_id_1 TEXT NOT NULL,
        word_id_2 TEXT NOT NULL,
        similarity REAL NOT NULL,
        PRIMARY KEY (word_id_1, word_id_2),
        FOREIGN KEY (word_id_1) REFERENCES ${DatabaseConstants.tableWords}(id),
        FOREIGN KEY (word_id_2) REFERENCES ${DatabaseConstants.tableWords}(id),
        CHECK (word_id_1 < word_id_2),
        CHECK (similarity BETWEEN 0.0 AND 1.0)
      )
    ''');

    // Tabelle games erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableGames} (
        id TEXT PRIMARY KEY,
        player_count INTEGER NOT NULL,
        impostor_count INTEGER NOT NULL,
        saboteur_count INTEGER DEFAULT 0,
        round_count INTEGER NOT NULL,
        timer_duration INTEGER NOT NULL,
        impostors_know_each_other INTEGER DEFAULT 0,
        state TEXT NOT NULL,
        current_round INTEGER DEFAULT 0,
        selected_category_ids TEXT,
        created_at INTEGER NOT NULL,
        CHECK (impostor_count < player_count)
      )
    ''');

    // Tabelle players erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePlayers} (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        name TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (game_id) REFERENCES ${DatabaseConstants.tableGames}(id)
      )
    ''');

    // Tabelle rounds erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableRounds} (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        round_number INTEGER NOT NULL,
        main_word_id TEXT NOT NULL,
        decoy_word_id TEXT NOT NULL,
        category_id TEXT NOT NULL,  
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (game_id) REFERENCES ${DatabaseConstants.tableGames}(id),
        FOREIGN KEY (main_word_id) REFERENCES ${DatabaseConstants.tableWords}(id),
        FOREIGN KEY (decoy_word_id) REFERENCES ${DatabaseConstants.tableWords}(id),
        FOREIGN KEY (category_id) REFERENCES ${DatabaseConstants.tableCategories}(id),
        UNIQUE(game_id, round_number)
      )
    ''');

    // Tabelle player_roles erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePlayerRoles} (
        id TEXT PRIMARY KEY,
        round_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        is_impostor INTEGER NOT NULL,
        role_type TEXT DEFAULT "civilian",
        created_at INTEGER NOT NULL,
        FOREIGN KEY (round_id) REFERENCES ${DatabaseConstants.tableRounds}(id),
        FOREIGN KEY (player_id) REFERENCES ${DatabaseConstants.tablePlayers}(id),
        UNIQUE(round_id, player_id)
      )
    ''');

    // Tabelle votes erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableVotes} (
        id TEXT PRIMARY KEY,
        round_id TEXT NOT NULL,
        voter_id TEXT NOT NULL,
        target_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (round_id) REFERENCES ${DatabaseConstants.tableRounds}(id),
        FOREIGN KEY (voter_id) REFERENCES ${DatabaseConstants.tablePlayers}(id),
        FOREIGN KEY (target_id) REFERENCES ${DatabaseConstants.tablePlayers}(id),
        UNIQUE(round_id, voter_id)
      )
    ''');

    // Tabelle word_guesses erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableWordGuesses} (
        id TEXT PRIMARY KEY,
        round_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        guessed_word TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (round_id) REFERENCES ${DatabaseConstants.tableRounds}(id),
        FOREIGN KEY (player_id) REFERENCES ${DatabaseConstants.tablePlayers}(id),
        UNIQUE(round_id, player_id)
      )
    ''');

    // Tabelle round_results erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableRoundResults} (
        id TEXT PRIMARY KEY,
        round_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        player_name TEXT NOT NULL,
        score_change INTEGER NOT NULL,
        total_score INTEGER NOT NULL,
        is_spy INTEGER NOT NULL,
        reason TEXT,
        impostors_won INTEGER DEFAULT 0,
        word_guessed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (round_id) REFERENCES ${DatabaseConstants.tableRounds}(id),
        FOREIGN KEY (player_id) REFERENCES ${DatabaseConstants.tablePlayers}(id)
      )
    ''');

    // Indizes erstellen
    await db.execute('CREATE INDEX idx_players_game_id ON ${DatabaseConstants.tablePlayers}(game_id)');
    await db.execute('CREATE INDEX idx_rounds_game_id ON ${DatabaseConstants.tableRounds}(game_id)');
    await db.execute('CREATE INDEX idx_player_roles_round_id ON ${DatabaseConstants.tablePlayerRoles}(round_id)');
    await db.execute('CREATE INDEX idx_votes_round_id ON ${DatabaseConstants.tableVotes}(round_id)');
    await db.execute('CREATE INDEX idx_words_category_id ON ${DatabaseConstants.tableWords}(category_id)');

    // Create Player Groups tables (added in v2)
    await _createPlayerGroupTablesV2(db);

    // Create Advanced Spy Words table (added in v5)
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSpyWordRelations} (
        id TEXT PRIMARY KEY,
        main_word_id TEXT NOT NULL,
        spy_word TEXT NOT NULL,
        relationship_type TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (main_word_id) REFERENCES ${DatabaseConstants.tableWords}(id),
        UNIQUE(main_word_id, priority)
      )
    ''');

    // Create index for performance
    await db.execute('CREATE INDEX idx_spy_word_relations_main_word ON ${DatabaseConstants.tableSpyWordRelations}(main_word_id)');

    // Validate word data before seeding
    await _validateWordData();

    // Initial-Daten laden
    await _seedData(db);
  }

  // Aktualisieren der Datenbank
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade to version 2: Add Player Groups tables
      await _createPlayerGroupTablesV2(db);
    }
    if (oldVersion < 3) {
      // Upgrade to version 3: Update round_results table for scoring system
      await _updateRoundResultsTableV3(db);
    }
    if (oldVersion < 4) {
      // Upgrade to version 4: Add saboteur support
      await _addSaboteurSupportV4(db);
    }
    if (oldVersion < 5) {
      // Upgrade to version 5: Add advanced spy words system
      await _addAdvancedSpyWordsSystemV5(db);
    }
    if (oldVersion < 6) {
      // Upgrade to version 6: Update to balanced spy words
      await _updateSpyWordsV6(db);
    }
    if (oldVersion < 7) {
      // Upgrade to version 7: Expand word categories to 20 words each
      await _expandWordCategoriesV7(db);
    }
    if (oldVersion < 8) {
      // Upgrade to version 8: Add selected categories support
      await _addSelectedCategoriesV8(db);
    }
  }

  // Helper method to update round_results table for v3 (scoring system)
  Future<void> _updateRoundResultsTableV3(Database db) async {
    // Drop the old table and recreate with new schema
    await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tableRoundResults}');

    // Create the new round_results table with scoring fields
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableRoundResults} (
        id TEXT PRIMARY KEY,
        round_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        player_name TEXT NOT NULL,
        score_change INTEGER NOT NULL,
        total_score INTEGER NOT NULL,
        is_spy INTEGER NOT NULL,
        reason TEXT,
        impostors_won INTEGER DEFAULT 0,
        word_guessed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (round_id) REFERENCES ${DatabaseConstants.tableRounds}(id),
        FOREIGN KEY (player_id) REFERENCES ${DatabaseConstants.tablePlayers}(id)
      )
    ''');
  }

  // Helper method to add saboteur support for v4
  Future<void> _addSaboteurSupportV4(Database db) async {
    // Add saboteur_count column to games table
    await db.execute('ALTER TABLE ${DatabaseConstants.tableGames} ADD COLUMN saboteur_count INTEGER DEFAULT 0');

    // Add role_type column to player_roles table to support multiple role types
    // For now, we'll keep the existing is_impostor column for backward compatibility
    // In a future version, we might migrate fully to a role_type system
    await db.execute('ALTER TABLE ${DatabaseConstants.tablePlayerRoles} ADD COLUMN role_type TEXT DEFAULT "civilian"');

    // Update existing records to match role_type with is_impostor
    await db.execute('''
      UPDATE ${DatabaseConstants.tablePlayerRoles} 
      SET role_type = CASE 
        WHEN is_impostor = 1 THEN "impostor" 
        ELSE "civilian" 
      END
    ''');

    print('Database upgraded to v4: Added saboteur support');
  }

  // Helper method to add advanced spy words system for v5
  Future<void> _addAdvancedSpyWordsSystemV5(Database db) async {
    // Create enhanced spy word relations table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableSpyWordRelations} (
        id TEXT PRIMARY KEY,
        main_word_id TEXT NOT NULL,
        spy_word TEXT NOT NULL,
        relationship_type TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (main_word_id) REFERENCES ${DatabaseConstants.tableWords}(id),
        UNIQUE(main_word_id, priority)
      )
    ''');

    // Create index for performance
    await db.execute('CREATE INDEX idx_spy_word_relations_main_word ON ${DatabaseConstants.tableSpyWordRelations}(main_word_id)');

    // Remove decoy_word_id column from rounds table (no longer needed)
    // Note: SQLite doesn't support DROP COLUMN, so we'll leave it for backward compatibility
    // The Round model simply ignores this column now

    // Clear existing spy word relations and re-seed with new organized data
    await db.delete(DatabaseConstants.tableSpyWordRelations);
    await _seedSpyWords(db);

    print('Database upgraded to v5: Added advanced spy words system');
  }

  // Helper method to update spy words for v6
  Future<void> _updateSpyWordsV6(Database db) async {
    // Clear existing spy word relations
    await db.delete(DatabaseConstants.tableSpyWordRelations);

    // Re-seed with balanced spy words from WordDataSource
    await _seedSpyWords(db);

    print('Database upgraded to v6: Updated to balanced spy words');
  }

  // Helper method to expand word categories for v7
  Future<void> _expandWordCategoriesV7(Database db) async {
    // Clear existing words and categories
    await db.delete(DatabaseConstants.tableSpyWordRelations);
    await db.delete(DatabaseConstants.tableWords);
    await db.delete(DatabaseConstants.tableCategories);

    // Re-seed with complete organized data from WordDataSource
    await _seedData(db);

    print('Database upgraded to v7: Expanded word categories to 20 words each');
  }

  // Helper method to add selected categories support for v8
  Future<void> _addSelectedCategoriesV8(Database db) async {
    // Add selected_category_ids column to games table
    await db.execute('ALTER TABLE ${DatabaseConstants.tableGames} ADD COLUMN selected_category_ids TEXT');

    print('Database upgraded to v8: Added selected categories support');
  }

  // Helper method to create player group tables, used in onCreate and onUpgrade
  Future<void> _createPlayerGroupTablesV2(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePlayerGroups} (
        id TEXT PRIMARY KEY,
        group_name TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    // Tabelle player_group_members erstellen
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tablePlayerGroupMembers} (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        player_name TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES ${DatabaseConstants.tablePlayerGroups}(id) ON DELETE CASCADE
      )
    ''');

    // Optional: Index for faster retrieval of members for a group
    await db.execute('CREATE INDEX idx_player_group_members_group_id ON ${DatabaseConstants.tablePlayerGroupMembers}(group_id)');
  }

  // Validation method for word data integrity
  Future<void> _validateWordData() async {
    final validation = WordDataSource.validateData();
    
    if (validation['is_valid']) {
      print('✅ Word data validation passed!');
    } else {
      print('❌ Word data validation failed:');
      for (var issue in validation['issues']) {
        print('  - $issue');
      }
    }
    
    print('📊 Statistics: ${validation['statistics']}');
  }

  // Seeding der Datenbank mit Initial-Daten (NEW CLEAN VERSION)
  Future<void> _seedData(Database db) async {
    // Get organized data from WordDataSource
    final categories = WordDataSource.categories;
    final words = WordDataSource.getAllWords();
    final spyWords = WordDataSource.getAllSpyWords();

    // Batch-Insert for better performance
    final batch = db.batch();

    // Insert categories
    for (var category in categories) {
      batch.insert(DatabaseConstants.tableCategories, category);
    }

    // Insert words
    for (var word in words) {
      batch.insert(DatabaseConstants.tableWords, word);
    }

    // Insert spy word relations
    for (var spyWord in spyWords) {
      batch.insert(DatabaseConstants.tableSpyWordRelations, spyWord);
    }

    await batch.commit(noResult: true);
    
    print('✅ Database seeded successfully!');
    print('📊 Categories: ${categories.length}');
    print('📝 Words: ${words.length}');
    print('🕵️ Spy Words: ${spyWords.length}');
  }

  // Helper method to seed only spy words (used in upgrades)
  Future<void> _seedSpyWords(Database db) async {
    final spyWords = WordDataSource.getAllSpyWords();

    final batch = db.batch();
    for (var spyWord in spyWords) {
      batch.insert(DatabaseConstants.tableSpyWordRelations, spyWord);
    }
    await batch.commit(noResult: true);

    print('✅ Spy words seeded: ${spyWords.length}');
  }

  // =========================================================================
  // CATEGORY SELECTION METHODS - For filtering words by chosen categories
  // =========================================================================

  /// Get words filtered by specific categories
  /// This is the KEY METHOD for category selection functionality
  Future<List<Map<String, dynamic>>> getWordsByCategories(List<String> categoryIds) async {
    final db = await database;
    
    if (categoryIds.isEmpty) {
      // If no categories specified, return all words
      return await db.query(DatabaseConstants.tableWords);
    }

    // Create placeholders for IN clause
    final placeholders = categoryIds.map((id) => '?').join(',');
    
    final words = await db.query(
      DatabaseConstants.tableWords,
      where: 'category_id IN ($placeholders)',
      whereArgs: categoryIds,
      orderBy: 'category_id, text',
    );

    return words;
  }

  /// Get spy words for specific main words (filtered by categories)
  Future<List<Map<String, dynamic>>> getSpyWordsByCategories(List<String> categoryIds, {int? priority}) async {
    final db = await database;
    
    if (categoryIds.isEmpty) {
      // If no categories specified, return all spy words
      String whereClause = priority != null ? 'priority = ?' : '';
      List<dynamic> whereArgs = priority != null ? [priority] : [];
      
      return await db.query(
        DatabaseConstants.tableSpyWordRelations,
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'main_word_id, priority',
      );
    }

    // Create placeholders for IN clause
    final placeholders = categoryIds.map((id) => '?').join(',');
    
    // Join with words table to filter by category
    String whereClause = '''
      ${DatabaseConstants.tableSpyWordRelations}.main_word_id IN (
        SELECT id FROM ${DatabaseConstants.tableWords} 
        WHERE category_id IN ($placeholders)
      )
    ''';
    
    List<dynamic> whereArgs = List.from(categoryIds);
    
    if (priority != null) {
      whereClause += ' AND ${DatabaseConstants.tableSpyWordRelations}.priority = ?';
      whereArgs.add(priority);
    }

    final spyWords = await db.query(
      DatabaseConstants.tableSpyWordRelations,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${DatabaseConstants.tableSpyWordRelations}.main_word_id, ${DatabaseConstants.tableSpyWordRelations}.priority',
    );

    return spyWords;
  }

  /// Get random word from specific categories for game setup
  Future<Map<String, dynamic>?> getRandomWordFromCategories(List<String> categoryIds) async {
    final words = await getWordsByCategories(categoryIds);
    
    if (words.isEmpty) return null;
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % words.length;
    return words[randomIndex];
  }

  /// Get spy words for a specific main word
  Future<List<Map<String, dynamic>>> getSpyWordsForWord(String mainWordId, {int? maxCount}) async {
    final db = await database;
    
    final spyWords = await db.query(
      DatabaseConstants.tableSpyWordRelations,
      where: 'main_word_id = ?',
      whereArgs: [mainWordId],
      orderBy: 'priority',
      limit: maxCount,
    );

    return spyWords;
  }

  /// Validate that selected categories exist and have words
  Future<Map<String, dynamic>> validateCategorySelection(List<String> categoryIds) async {
    final db = await database;
    
    // Check if categories exist
    final placeholders = categoryIds.map((id) => '?').join(',');
    final existingCategories = await db.query(
      DatabaseConstants.tableCategories,
      where: 'id IN ($placeholders)',
      whereArgs: categoryIds,
    );

    // Check word count per category
    final Map<String, int> wordCounts = {};
    for (String categoryId in categoryIds) {
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseConstants.tableWords} WHERE category_id = ?',
        [categoryId],
      )) ?? 0;
      wordCounts[categoryId] = count;
    }

    // Calculate totals
    final totalWords = wordCounts.values.fold(0, (sum, count) => sum + count);
    final emptyCategoriesCount = wordCounts.values.where((count) => count == 0).length;

    return {
      'isValid': existingCategories.length == categoryIds.length && totalWords > 0,
      'existingCategories': existingCategories,
      'missingCategories': categoryIds.where((id) => 
        !existingCategories.any((cat) => cat['id'] == id)).toList(),
      'wordCounts': wordCounts,
      'totalWords': totalWords,
      'emptyCategoriesCount': emptyCategoriesCount,
      'hasEnoughWords': totalWords >= 10, // Minimum words needed for a game
    };
  }

  // =========================================================================
  // STANDARD DATABASE METHODS (Categories, Words, etc.)
  // =========================================================================

  /// Get all categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableCategories, orderBy: 'name');
  }

  /// Get default categories
  Future<List<Map<String, dynamic>>> getDefaultCategories() async {
    final db = await database;
    return await db.query(
      DatabaseConstants.tableCategories,
      where: 'is_default = ?',
      whereArgs: [1],
      orderBy: 'name',
    );
  }

  /// Get all words
  Future<List<Map<String, dynamic>>> getAllWords() async {
    final db = await database;
    return await db.query(DatabaseConstants.tableWords, orderBy: 'category_id, text');
  }

  /// Get words by category ID
  Future<List<Map<String, dynamic>>> getWordsByCategory(String categoryId) async {
    final db = await database;
    return await db.query(
      DatabaseConstants.tableWords,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'text',
    );
  }

  // =========================================================================
  // GENERIC DATABASE OPERATIONS - Used by repositories
  // =========================================================================

  /// Generic insert method
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  /// Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Generic update method
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Generic delete method
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Generic raw query method
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Run operations in a transaction
  Future<T> runTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
