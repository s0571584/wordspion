// Entertainment category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class EntertainmentWords {
  static const String categoryId = 'entertainment';
  static const String categoryName = 'Unterhaltung';
  static const String categoryDescription = 'Filme, Serien, Musik und mehr';
  static const bool isDefault = true;

  static const List<Map<String, dynamic>> words = [
    {'id': 'ent_001', 'text': 'Star Wars', 'difficulty': 1},
    {'id': 'ent_002', 'text': 'Netflix', 'difficulty': 1},
    {'id': 'ent_003', 'text': 'Beethoven', 'difficulty': 2},
    {'id': 'ent_004', 'text': 'Harry Potter', 'difficulty': 1},
    {'id': 'ent_005', 'text': 'Game of Thrones', 'difficulty': 2},
    {'id': 'ent_006', 'text': 'Herr der Ringe', 'difficulty': 2},
    {'id': 'ent_007', 'text': 'Mozart', 'difficulty': 2},
    {'id': 'ent_008', 'text': 'Disney', 'difficulty': 1},
    {'id': 'ent_009', 'text': 'Superheld', 'difficulty': 1},
    {'id': 'ent_010', 'text': 'Kino', 'difficulty': 1},
    {'id': 'ent_011', 'text': 'Podcast', 'difficulty': 1},
    {'id': 'ent_012', 'text': 'Videospiel', 'difficulty': 1},
    {'id': 'ent_013', 'text': 'Konzert', 'difficulty': 1},
    {'id': 'ent_014', 'text': 'Theater', 'difficulty': 2},
    {'id': 'ent_015', 'text': 'YouTube', 'difficulty': 1},
    {'id': 'ent_016', 'text': 'Brettspiel', 'difficulty': 1},
    {'id': 'ent_017', 'text': 'Festival', 'difficulty': 1},
    {'id': 'ent_018', 'text': 'Karaoke', 'difficulty': 1},
    {'id': 'ent_019', 'text': 'Stand-up', 'difficulty': 2},
    {'id': 'ent_020', 'text': 'Escape Room', 'difficulty': 1},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Star Wars spy words
    {'main_word_id': 'ent_001', 'spy_word': 'Trilogie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_001', 'spy_word': 'Merchandise', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_001', 'spy_word': 'Generationen', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_001', 'spy_word': 'Sammeln', 'relationship_type': 'action', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_001', 'spy_word': 'Kino', 'relationship_type': 'location', 'difficulty': 2, 'priority': 5},

    // Netflix spy words
    {'main_word_id': 'ent_002', 'spy_word': 'Wochenende', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_002', 'spy_word': 'Empfehlung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_002', 'spy_word': 'Sucht', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_002', 'spy_word': 'Entspannung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_002', 'spy_word': 'Auswahl', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Beethoven spy words
    {'main_word_id': 'ent_003', 'spy_word': 'Genie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_003', 'spy_word': 'Taubheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'ent_003', 'spy_word': 'Wien', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_003', 'spy_word': 'Unsterblich', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_003', 'spy_word': 'Leidenschaft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Harry Potter spy words
    {'main_word_id': 'ent_004', 'spy_word': 'Kindheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_004', 'spy_word': 'Freundschaft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_004', 'spy_word': 'Internat', 'relationship_type': 'location', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_004', 'spy_word': 'Mut', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_004', 'spy_word': 'Buch', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Game of Thrones spy words
    {'main_word_id': 'ent_005', 'spy_word': 'Thron', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_005', 'spy_word': 'Schwert', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_005', 'spy_word': 'König', 'relationship_type': 'person', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_005', 'spy_word': 'Drache', 'relationship_type': 'person', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_005', 'spy_word': 'Burg', 'relationship_type': 'location', 'difficulty': 2, 'priority': 5},

    // Herr der Ringe spy words
    {'main_word_id': 'ent_006', 'spy_word': 'Ring', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_006', 'spy_word': 'Hobbit', 'relationship_type': 'person', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_006', 'spy_word': 'Mittelerde', 'relationship_type': 'location', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_006', 'spy_word': 'Schwert', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_006', 'spy_word': 'Abenteuer', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Mozart spy words
    {'main_word_id': 'ent_007', 'spy_word': 'Klaviatur', 'relationship_type': 'tool', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'ent_007', 'spy_word': 'Salzburg', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_007', 'spy_word': 'Oper', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_007', 'spy_word': 'Genie', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_007', 'spy_word': 'Partitur', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Disney spy words
    {'main_word_id': 'ent_008', 'spy_word': 'Maus', 'relationship_type': 'person', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_008', 'spy_word': 'Schloss', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_008', 'spy_word': 'Prinzessin', 'relationship_type': 'person', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_008', 'spy_word': 'Zauber', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_008', 'spy_word': 'Kindheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Superheld spy words
    {'main_word_id': 'ent_009', 'spy_word': 'Umhang', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_009', 'spy_word': 'Rettung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_009', 'spy_word': 'Superkraft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_009', 'spy_word': 'Maske', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_009', 'spy_word': 'Bösewicht', 'relationship_type': 'person', 'difficulty': 3, 'priority': 5},

    // Kino spy words
    {'main_word_id': 'ent_010', 'spy_word': 'Leinwand', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_010', 'spy_word': 'Popcorn', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_010', 'spy_word': 'Ticket', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_010', 'spy_word': 'Projektor', 'relationship_type': 'tool', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_010', 'spy_word': 'Premiere', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Podcast spy words
    {'main_word_id': 'ent_011', 'spy_word': 'Stimme', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_011', 'spy_word': 'Spaziergang', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_011', 'spy_word': 'Intimität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_011', 'spy_word': 'Pendeln', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_011', 'spy_word': 'Routine', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Videospiel spy words
    {'main_word_id': 'ent_012', 'spy_word': 'Controller', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_012', 'spy_word': 'Stunden', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_012', 'spy_word': 'Fortschritt', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_012', 'spy_word': 'Multiplayer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_012', 'spy_word': 'Sucht', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Konzert spy words
    {'main_word_id': 'ent_013', 'spy_word': 'Lautstärke', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_013', 'spy_word': 'Ticket', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_013', 'spy_word': 'Menschenmenge', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_013', 'spy_word': 'Adrenalin', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_013', 'spy_word': 'Erinnerung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Theater spy words
    {'main_word_id': 'ent_014', 'spy_word': 'Vorhang', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_014', 'spy_word': 'Kultur', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_014', 'spy_word': 'Kostüm', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_014', 'spy_word': 'Aufregung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_014', 'spy_word': 'Interpretation', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // YouTube spy words
    {'main_word_id': 'ent_015', 'spy_word': 'Kanal', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_015', 'spy_word': 'Werbung', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_015', 'spy_word': 'Prokrastination', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_015', 'spy_word': 'Tutorial', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_015', 'spy_word': 'Algorithmus', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Brettspiel spy words
    {'main_word_id': 'ent_016', 'spy_word': 'Geselligkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_016', 'spy_word': 'Strategie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_016', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_016', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_016', 'spy_word': 'Wettbewerb', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Festival spy words
    {'main_word_id': 'ent_017', 'spy_word': 'Zelt', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_017', 'spy_word': 'Jugend', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_017', 'spy_word': 'Camping', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_017', 'spy_word': 'Gemeinschaft', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_017', 'spy_word': 'Euphorie', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Karaoke spy words
    {'main_word_id': 'ent_018', 'spy_word': 'Mut', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_018', 'spy_word': 'Mikrofon', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_018', 'spy_word': 'Peinlichkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'ent_018', 'spy_word': 'Befreiung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_018', 'spy_word': 'Applaus', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // Stand-up spy words
    {'main_word_id': 'ent_019', 'spy_word': 'Humor', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_019', 'spy_word': 'Timing', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'ent_019', 'spy_word': 'Nervosität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_019', 'spy_word': 'Scheinwerfer', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ent_019', 'spy_word': 'Spontaneität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Escape Room spy words
    {'main_word_id': 'ent_020', 'spy_word': 'Rätsel', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ent_020', 'spy_word': 'Teamwork', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ent_020', 'spy_word': 'Zeitdruck', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ent_020', 'spy_word': 'Logik', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ent_020', 'spy_word': 'Triumph', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},
  ];
}
