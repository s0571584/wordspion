import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wortspion/core/constants/database_constants.dart';

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
        round_count INTEGER NOT NULL,
        timer_duration INTEGER NOT NULL,
        impostors_know_each_other INTEGER DEFAULT 0,
        state TEXT NOT NULL,
        current_round INTEGER DEFAULT 0,
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
    // Add more upgrade steps here for future versions, e.g.:
    // if (oldVersion < 4) {
    //   await db.execute('ALTER TABLE some_table ADD COLUMN new_column TEXT');
    // }
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

  // Seeding der Datenbank mit Initial-Daten
  Future<void> _seedData(Database db) async {
    // Kategorien einfügen
    final List<Map<String, dynamic>> categories = [
      {'id': 'entertainment', 'name': 'Unterhaltung', 'description': 'Filme, Serien, Musik und mehr', 'is_default': 1},
      {'id': 'sports', 'name': 'Sport', 'description': 'Sportarten, Teams und Athleten', 'is_default': 1},
      {'id': 'animals', 'name': 'Tiere', 'description': 'Verschiedene Tierarten', 'is_default': 1},
      {'id': 'food', 'name': 'Essen & Trinken', 'description': 'Gerichte, Zutaten und Getränke', 'is_default': 1},
      {'id': 'places', 'name': 'Orte', 'description': 'Städte, Länder und Sehenswürdigkeiten', 'is_default': 1},
      {'id': 'professions', 'name': 'Berufe', 'description': 'Berufe und Tätigkeiten', 'is_default': 1},
      {'id': 'technology', 'name': 'Technik', 'description': 'Geräte, Software und Internet', 'is_default': 0},
      {'id': 'everyday', 'name': 'Alltag', 'description': 'Alltagsgegenstände und -aktivitäten', 'is_default': 0},
    ];

    // Wörter für die Kategorien
    final List<Map<String, dynamic>> words = [
      // Unterhaltung
      {'id': 'ent_001', 'category_id': 'entertainment', 'text': 'Star Wars', 'difficulty': 1},
      {'id': 'ent_002', 'category_id': 'entertainment', 'text': 'Netflix', 'difficulty': 1},
      {'id': 'ent_003', 'category_id': 'entertainment', 'text': 'Beethoven', 'difficulty': 2},
      {'id': 'ent_004', 'category_id': 'entertainment', 'text': 'Harry Potter', 'difficulty': 1},
      {'id': 'ent_005', 'category_id': 'entertainment', 'text': 'Game of Thrones', 'difficulty': 2},
      {'id': 'ent_006', 'category_id': 'entertainment', 'text': 'Herr der Ringe', 'difficulty': 2},
      {'id': 'ent_007', 'category_id': 'entertainment', 'text': 'Mozart', 'difficulty': 2},
      {'id': 'ent_008', 'category_id': 'entertainment', 'text': 'Disney', 'difficulty': 1},
      {'id': 'ent_009', 'category_id': 'entertainment', 'text': 'Superheld', 'difficulty': 1},
      {'id': 'ent_010', 'category_id': 'entertainment', 'text': 'Kino', 'difficulty': 1},

      // Sport
      {'id': 'spo_001', 'category_id': 'sports', 'text': 'Fußball', 'difficulty': 1},
      {'id': 'spo_002', 'category_id': 'sports', 'text': 'Basketball', 'difficulty': 1},
      {'id': 'spo_003', 'category_id': 'sports', 'text': 'Tennis', 'difficulty': 1},
      {'id': 'spo_004', 'category_id': 'sports', 'text': 'Olympiade', 'difficulty': 2},
      {'id': 'spo_005', 'category_id': 'sports', 'text': 'Schwimmen', 'difficulty': 1},
      {'id': 'spo_006', 'category_id': 'sports', 'text': 'Handball', 'difficulty': 1},
      {'id': 'spo_007', 'category_id': 'sports', 'text': 'Formel 1', 'difficulty': 2},
      {'id': 'spo_008', 'category_id': 'sports', 'text': 'Marathon', 'difficulty': 2},
      {'id': 'spo_009', 'category_id': 'sports', 'text': 'Golf', 'difficulty': 1},
      {'id': 'spo_010', 'category_id': 'sports', 'text': 'Volleyball', 'difficulty': 1},

      // Tiere
      {'id': 'ani_001', 'category_id': 'animals', 'text': 'Elefant', 'difficulty': 1},
      {'id': 'ani_002', 'category_id': 'animals', 'text': 'Löwe', 'difficulty': 1},
      {'id': 'ani_003', 'category_id': 'animals', 'text': 'Delfin', 'difficulty': 1},
      {'id': 'ani_004', 'category_id': 'animals', 'text': 'Pinguin', 'difficulty': 1},
      {'id': 'ani_005', 'category_id': 'animals', 'text': 'Adler', 'difficulty': 1},
      {'id': 'ani_006', 'category_id': 'animals', 'text': 'Giraffe', 'difficulty': 1},
      {'id': 'ani_007', 'category_id': 'animals', 'text': 'Nashorn', 'difficulty': 1},
      {'id': 'ani_008', 'category_id': 'animals', 'text': 'Panda', 'difficulty': 1},
      {'id': 'ani_009', 'category_id': 'animals', 'text': 'Krokodil', 'difficulty': 1},
      {'id': 'ani_010', 'category_id': 'animals', 'text': 'Orca', 'difficulty': 2},

      // Essen & Trinken
      {'id': 'food_001', 'category_id': 'food', 'text': 'Pizza', 'difficulty': 1},
      {'id': 'food_002', 'category_id': 'food', 'text': 'Sushi', 'difficulty': 1},
      {'id': 'food_003', 'category_id': 'food', 'text': 'Pasta', 'difficulty': 1},
      {'id': 'food_004', 'category_id': 'food', 'text': 'Kaffee', 'difficulty': 1},
      {'id': 'food_005', 'category_id': 'food', 'text': 'Schokolade', 'difficulty': 1},
      {'id': 'food_006', 'category_id': 'food', 'text': 'Hamburger', 'difficulty': 1},
      {'id': 'food_007', 'category_id': 'food', 'text': 'Erdbeere', 'difficulty': 1},
      {'id': 'food_008', 'category_id': 'food', 'text': 'Kartoffel', 'difficulty': 1},
      {'id': 'food_009', 'category_id': 'food', 'text': 'Käse', 'difficulty': 1},
      {'id': 'food_010', 'category_id': 'food', 'text': 'Champagner', 'difficulty': 2},

      // Orte
      {'id': 'plc_001', 'category_id': 'places', 'text': 'Paris', 'difficulty': 1},
      {'id': 'plc_002', 'category_id': 'places', 'text': 'New York', 'difficulty': 1},
      {'id': 'plc_003', 'category_id': 'places', 'text': 'Berlin', 'difficulty': 1},
      {'id': 'plc_004', 'category_id': 'places', 'text': 'Tokio', 'difficulty': 1},
      {'id': 'plc_005', 'category_id': 'places', 'text': 'Rom', 'difficulty': 1},
      {'id': 'plc_006', 'category_id': 'places', 'text': 'Ägypten', 'difficulty': 1},
      {'id': 'plc_007', 'category_id': 'places', 'text': 'Australien', 'difficulty': 1},
      {'id': 'plc_008', 'category_id': 'places', 'text': 'Himalaya', 'difficulty': 2},
      {'id': 'plc_009', 'category_id': 'places', 'text': 'Amazonas', 'difficulty': 2},
      {'id': 'plc_010', 'category_id': 'places', 'text': 'Venedig', 'difficulty': 1},

      // Berufe
      {'id': 'prof_001', 'category_id': 'professions', 'text': 'Arzt', 'difficulty': 1},
      {'id': 'prof_002', 'category_id': 'professions', 'text': 'Lehrer', 'difficulty': 1},
      {'id': 'prof_003', 'category_id': 'professions', 'text': 'Koch', 'difficulty': 1},
      {'id': 'prof_004', 'category_id': 'professions', 'text': 'Pilot', 'difficulty': 1},
      {'id': 'prof_005', 'category_id': 'professions', 'text': 'Polizist', 'difficulty': 1},
      {'id': 'prof_006', 'category_id': 'professions', 'text': 'Anwalt', 'difficulty': 1},
      {'id': 'prof_007', 'category_id': 'professions', 'text': 'Ingenieur', 'difficulty': 1},
      {'id': 'prof_008', 'category_id': 'professions', 'text': 'Künstler', 'difficulty': 1},
      {'id': 'prof_009', 'category_id': 'professions', 'text': 'Schauspieler', 'difficulty': 1},
      {'id': 'prof_010', 'category_id': 'professions', 'text': 'Astronaut', 'difficulty': 2},

      // Technik
      {'id': 'tech_001', 'category_id': 'technology', 'text': 'Smartphone', 'difficulty': 1},
      {'id': 'tech_002', 'category_id': 'technology', 'text': 'Internet', 'difficulty': 1},
      {'id': 'tech_003', 'category_id': 'technology', 'text': 'Computer', 'difficulty': 1},
      {'id': 'tech_004', 'category_id': 'technology', 'text': 'Roboter', 'difficulty': 1},
      {'id': 'tech_005', 'category_id': 'technology', 'text': 'Künstliche Intelligenz', 'difficulty': 2},

      // Alltag
      {'id': 'day_001', 'category_id': 'everyday', 'text': 'Schlüssel', 'difficulty': 1},
      {'id': 'day_002', 'category_id': 'everyday', 'text': 'Uhr', 'difficulty': 1},
      {'id': 'day_003', 'category_id': 'everyday', 'text': 'Brille', 'difficulty': 1},
      {'id': 'day_004', 'category_id': 'everyday', 'text': 'Tasche', 'difficulty': 1},
      {'id': 'day_005', 'category_id': 'everyday', 'text': 'Buch', 'difficulty': 1},
    ];

    // Ähnlichkeitsbeziehungen zwischen Wörtern
    final List<Map<String, dynamic>> relations = [
      {'word_id_1': 'ent_001', 'word_id_2': 'ent_006', 'similarity': 0.6}, // Star Wars - Herr der Ringe
      {'word_id_1': 'ent_003', 'word_id_2': 'ent_007', 'similarity': 0.8}, // Beethoven - Mozart
      {'word_id_1': 'ent_004', 'word_id_2': 'ent_006', 'similarity': 0.7}, // Harry Potter - Herr der Ringe
      {'word_id_1': 'spo_001', 'word_id_2': 'spo_006', 'similarity': 0.6}, // Fußball - Handball
      {'word_id_1': 'spo_002', 'word_id_2': 'spo_010', 'similarity': 0.5}, // Basketball - Volleyball
      {'word_id_1': 'ani_001', 'word_id_2': 'ani_007', 'similarity': 0.4}, // Elefant - Nashorn
      {'word_id_1': 'ani_003', 'word_id_2': 'ani_010', 'similarity': 0.7}, // Delfin - Orca
      {'word_id_1': 'food_001', 'word_id_2': 'food_006', 'similarity': 0.5}, // Pizza - Hamburger
      {'word_id_1': 'food_003', 'word_id_2': 'food_008', 'similarity': 0.3}, // Pasta - Kartoffel
      {'word_id_1': 'plc_001', 'word_id_2': 'plc_005', 'similarity': 0.5}, // Paris - Rom
      {'word_id_1': 'plc_006', 'word_id_2': 'plc_009', 'similarity': 0.4}, // Ägypten - Amazonas
      {'word_id_1': 'prof_001', 'word_id_2': 'prof_005', 'similarity': 0.3}, // Arzt - Polizist
      {'word_id_1': 'prof_003', 'word_id_2': 'prof_009', 'similarity': 0.2}, // Koch - Schauspieler
      {'word_id_1': 'tech_001', 'word_id_2': 'tech_003', 'similarity': 0.6}, // Smartphone - Computer
      {'word_id_1': 'day_001', 'word_id_2': 'day_004', 'similarity': 0.2}, // Schlüssel - Tasche
    ];

    // Batch-Insert für bessere Performance
    final batch = db.batch();

    for (var category in categories) {
      batch.insert(DatabaseConstants.tableCategories, category);
    }

    for (var word in words) {
      batch.insert(DatabaseConstants.tableWords, word);
    }

    for (var relation in relations) {
      batch.insert(DatabaseConstants.tableWordRelations, relation);
    }

    await batch.commit(noResult: true);
  }

  // Hilfsmethode zum Ausführen von Transaktionen
  Future<T> runTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  // CRUD-Methoden

  // Einfügen
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  // Lesen
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

  // Aktualisieren
  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      row,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Löschen
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

  // Raw-Query ausführen
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Datenbank schließen
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
