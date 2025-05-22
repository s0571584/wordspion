# WortSpion - Datenbankschema

Dieses Dokument beschreibt das Datenbankschema für die WortSpion-App. Es umfasst sowohl die lokale SQLite-Implementierung für die Einzelgerät-Version als auch die zukünftige PostgreSQL-Implementierung für die Mehrspieler-Version mit Supabase.

## Einstellungsverwaltung mit SharedPreferences

Neben der SQLite-Datenbank verwendet die App `SharedPreferences` zur Speicherung von Spieleinstellungen und Benutzerpräferenzen.

### Schlüsselstruktur

```
// Spieleinstellungen
game_player_count         // Anzahl der Spieler
game_impostor_count       // Anzahl der Spione
game_round_count          // Anzahl der Runden
game_timer_duration       // Timer-Dauer in Sekunden
game_impostors_know_each_other // Boolean: Kennen Spione einander?
```

### Zugriffsschicht

Der Zugriff auf SharedPreferences erfolgt konsistent über alle Komponenten:

```dart
// Beispiel für das Lesen von Einstellungen
Future<void> _loadSavedSettings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Get the values with explicit defaults
    final loadedImpostorCount = prefs.getInt(_keyImpostorCount);
    final loadedRoundCount = prefs.getInt(_keyRoundCount);
    final loadedTimerDuration = prefs.getInt(_keyTimerDuration);
    final loadedImpostorsKnowEachOther = prefs.getBool(_keyImpostorsKnowEachOther);
    
    // Assign values with defaults
    _lastImpostorCount = loadedImpostorCount ?? 1;
    _lastRoundCount = loadedRoundCount ?? 3;
    _lastTimerDuration = loadedTimerDuration ?? 180;
    _lastImpostorsKnowEachOther = loadedImpostorsKnowEachOther ?? false;
  } catch (e) {
    print('Failed to load game settings: $e');
  }
}
```

### Koordination zwischen Komponenten

Wichtige Aspekte bei der Verwendung von SharedPreferences:

1. **Konsistente Schlüssel**: Alle Komponenten (GameBloc, PlayerBloc, GameSetupScreen) verwenden die gleichen Schlüsselkonstanten.

2. **Unmittelbare Aktualisierung**: Änderungen an Spieleinstellungen werden sofort in SharedPreferences gespeichert und bei Bedarf direkt verifiziert:

```dart
// Schreiben und Verifizieren von Einstellungen
await prefs.setInt(_keyImpostorCount, _impostorCount);
final savedImpostorCount = prefs.getInt(_keyImpostorCount);
print('Verification - Retrieved impostorCount: $savedImpostorCount');
```

3. **Defaultwerte**: Alle Komponenten verwenden konsistente Standardwerte für fehlende Einstellungen.

4. **Validierung**: Nach dem Laden werden die Einstellungen validiert, um Spielregelmäßigkeit sicherzustellen.

Diese Struktur gewährleistet, dass Spieleinstellungen persistent über App-Neustarts erhalten bleiben und konsistent zwischen verschiedenen Komponenten geteilt werden.

## Überblick

Die Datenbank muss folgende Informationen speichern:
- Spieler und ihre Rollen
- Spielkonfigurationen und -einstellungen
- Wörter nach Kategorien
- Rundenstände und Ergebnisse
- Abstimmungen und Punkte

## SQLite-Datenbankschema (V1 - Einzelgerät)

### Tabellen

#### 1. Categories

Speichert die verfügbaren Wortkategorien.

```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  is_default INTEGER DEFAULT 0
);
```

#### 2. Words

Speichert Wörter mit Kategoriezuordnung.

```sql
CREATE TABLE words (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  text TEXT NOT NULL,
  difficulty INTEGER DEFAULT 1,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  UNIQUE(category_id, text)
);
```

#### 3. WordRelations

Speichert Ähnlichkeitsbeziehungen zwischen Wörtern für die Täuschungswortauswahl.

```sql
CREATE TABLE word_relations (
  word_id_1 TEXT NOT NULL,
  word_id_2 TEXT NOT NULL,
  similarity REAL NOT NULL,
  PRIMARY KEY (word_id_1, word_id_2),
  FOREIGN KEY (word_id_1) REFERENCES words(id),
  FOREIGN KEY (word_id_2) REFERENCES words(id),
  CHECK (word_id_1 < word_id_2), -- Verhindert doppelte Einträge
  CHECK (similarity BETWEEN 0.0 AND 1.0)
);
```

#### 4. Games

Speichert Spielsessions.

```sql
CREATE TABLE games (
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
);
```

#### 5. Players

Speichert Spieler in einem Spiel.

```sql
CREATE TABLE players (
  id TEXT PRIMARY KEY,
  game_id TEXT NOT NULL,
  name TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (game_id) REFERENCES games(id)
);
```

#### 6. Rounds

Speichert Rundeninformationen.

```sql
CREATE TABLE rounds (
  id TEXT PRIMARY KEY,
  game_id TEXT NOT NULL,
  round_number INTEGER NOT NULL,
  main_word_id TEXT NOT NULL,
  decoy_word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  is_completed INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (game_id) REFERENCES games(id),
  FOREIGN KEY (main_word_id) REFERENCES words(id),
  FOREIGN KEY (decoy_word_id) REFERENCES words(id),
  FOREIGN KEY (category_id) REFERENCES categories(id),
  UNIQUE(game_id, round_number)
);
```

#### 7. PlayerRoles

Speichert die Rollen der Spieler pro Runde.

```sql
CREATE TABLE player_roles (
  id TEXT PRIMARY KEY,
  round_id TEXT NOT NULL,
  player_id TEXT NOT NULL,
  is_impostor INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (round_id) REFERENCES rounds(id),
  FOREIGN KEY (player_id) REFERENCES players(id),
  UNIQUE(round_id, player_id)
);
```

#### 8. Votes

Speichert Abstimmungen.

```sql
CREATE TABLE votes (
  id TEXT PRIMARY KEY,
  round_id TEXT NOT NULL,
  voter_id TEXT NOT NULL,
  target_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (round_id) REFERENCES rounds(id),
  FOREIGN KEY (voter_id) REFERENCES players(id),
  FOREIGN KEY (target_id) REFERENCES players(id),
  UNIQUE(round_id, voter_id)
);
```

#### 9. WordGuesses

Speichert Wortrateversuche der Impostoren.

```sql
CREATE TABLE word_guesses (
  id TEXT PRIMARY KEY,
  round_id TEXT NOT NULL,
  player_id TEXT NOT NULL,
  guessed_word TEXT NOT NULL,
  is_correct INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (round_id) REFERENCES rounds(id),
  FOREIGN KEY (player_id) REFERENCES players(id),
  UNIQUE(round_id, player_id)
);
```

#### 10. RoundResults

Speichert Rundenergebnisse.

```sql
CREATE TABLE round_results (
  id TEXT PRIMARY KEY,
  round_id TEXT NOT NULL,
  impostors_won INTEGER NOT NULL,
  word_guessed INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (round_id) REFERENCES rounds(id),
  UNIQUE(round_id)
);
```

### Indizes

```sql
-- Performanceoptimierung durch Indizes
CREATE INDEX idx_players_game_id ON players(game_id);
CREATE INDEX idx_rounds_game_id ON rounds(game_id);
CREATE INDEX idx_player_roles_round_id ON player_roles(round_id);
CREATE INDEX idx_votes_round_id ON votes(round_id);
CREATE INDEX idx_words_category_id ON words(category_id);
```

## Datenbank-Repository

Das Datenbank-Repository bietet eine Abstraktionsschicht für den Zugriff auf die Datenbank:

```dart
abstract class GameRepository {
  Future<Game> createGame(GameSettings settings);
  Future<void> saveGameState(Game game);
  Future<Game?> getCurrentGame();
  Future<void> endGame(String gameId);
  Future<List<Player>> getPlayersByGameId(String gameId);
  Future<Round> createRound(String gameId, int roundNumber, String categoryId);
  Future<void> assignRoles(String roundId, List<Player> players, int impostorCount);
  Future<void> recordVote(String roundId, String voterId, String targetId);
  Future<void> recordWordGuess(String roundId, String playerId, String guessedWord, bool isCorrect);
  Future<void> saveRoundResult(String roundId, bool impostorsWon, bool wordGuessed);
  Future<RoundResult?> getRoundResult(String roundId);
  Future<List<Round>> getRoundsByGameId(String gameId);
}
```

### SQLite-Implementierung

Die SQLite-Implementierung verwendet die `sqflite`-Bibliothek:

```dart
class SQLiteGameRepository implements GameRepository {
  final Database _database;
  
  SQLiteGameRepository(this._database);
  
  // Implementierung der Repository-Methoden mit SQL-Abfragen
}
```

## Wortdatenbank

Die Wortdatenbank wird zu Beginn mit einer Grundausstattung an Kategorien und Wörtern befüllt:

```dart
Future<void> seedDatabase(Database db) async {
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
  
  // Wörter einfügen (über 100 je nach Kategorie)
  final List<Map<String, dynamic>> words = [
    // Beispielwörter für Unterhaltung
    {'id': 'ent_001', 'category_id': 'entertainment', 'text': 'Star Wars', 'difficulty': 1},
    {'id': 'ent_002', 'category_id': 'entertainment', 'text': 'Netflix', 'difficulty': 1},
    {'id': 'ent_003', 'category_id': 'entertainment', 'text': 'Beethoven', 'difficulty': 2},
    // ... weitere Wörter
  ];
  
  // Ähnlichkeitsbeziehungen zwischen Wörtern
  final List<Map<String, dynamic>> relations = [
    {'word_id_1': 'ent_001', 'word_id_2': 'ent_004', 'similarity': 0.7}, // Star Wars -> Sci-Fi Film
    // ... weitere Beziehungen
  ];
  
  // Batch-Insert für bessere Performance
  final batch = db.batch();
  
  for (var category in categories) {
    batch.insert('categories', category);
  }
  
  for (var word in words) {
    batch.insert('words', word);
  }
  
  for (var relation in relations) {
    batch.insert('word_relations', relation);
  }
  
  await batch.commit(noResult: true);
}
```

## Migration zu Supabase (V2)

Für die zukünftige Mehrspieler-Version wird die Datenbank zu Supabase (PostgreSQL) migriert. Das Schema bleibt weitgehend gleich, mit einigen Anpassungen:

1. Verwendung von UUID-Typen statt TEXT für IDs
2. Verwendung von TIMESTAMP WITH TIME ZONE statt INTEGER für Zeitstempel
3. Hinzufügen von Tabellen für Benutzerauthentifizierung und Spielräume
4. Implementierung von Row-Level Security für Datenschutz

```sql
-- Beispiel für PostgreSQL-Tabellen in Supabase
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  host_id UUID REFERENCES user_profiles(id) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  max_players INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weitere Tabellen wie in SQLite, angepasst an PostgreSQL
```

## Datenbankzugriffsstrategie

### Offline-Modus (V1)
- Alle Daten werden lokal in SQLite gespeichert
- Datenbankanfragen werden synchron verarbeitet
- Transaktionen für atomare Operationen

### Online-Modus (V2)
- Primäre Daten in Supabase (PostgreSQL)
- Lokale Zwischenspeicherung für Offline-Unterstützung
- Realtime-Subscriptions für Echtzeit-Updates
- Konfliktauflösung bei Synchronisierung

## Datenmigrationsplan

Für den Übergang von der Einzelgerät-Version (V1) zur Mehrspieler-Version (V2):

1. **Strukturmigration:** Anpassung der Datenmodelle für Supabase-Kompatibilität
2. **Datenmigration:** Optionaler Import lokaler Spieldaten in die Cloud
3. **Hybrid-Modus:** Unterstützung für sowohl Offline- als auch Online-Spiele
