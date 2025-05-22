class DatabaseConstants {
  // Private Konstruktor, um Instanziierung zu verhindern
  DatabaseConstants._();

  // Datenbank-Informationen
  static const String databaseName = 'wortspion.db';
  static const int databaseVersion = 2;

  // Tabellennamen
  static const String tableCategories = 'categories';
  static const String tableWords = 'words';
  static const String tableWordRelations = 'word_relations';
  static const String tableGames = 'games';
  static const String tablePlayers = 'players';
  static const String tableRounds = 'rounds';
  static const String tablePlayerRoles = 'player_roles';
  static const String tableVotes = 'votes';
  static const String tableWordGuesses = 'word_guesses';
  static const String tableRoundResults = 'round_results';

  // New table names for Player Groups
  static const String tablePlayerGroups = 'player_groups';
  static const String tablePlayerGroupMembers = 'player_group_members';

  // Spiel-Zustände
  static const String gameStateSetup = 'SETUP';
  static const String gameStatePlaying = 'PLAYING';
  static const String gameStateVoting = 'VOTING';
  static const String gameStateResult = 'RESULT';
  static const String gameStateFinished = 'FINISHED';
}
