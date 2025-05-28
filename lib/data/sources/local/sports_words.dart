// Sports category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class SportsWords {
  static const String categoryId = 'sports';
  static const String categoryName = 'Sport';
  static const String categoryDescription = 'Sportarten, Teams und Athleten';
  static const bool isDefault = true;

  static const List<Map<String, dynamic>> words = [
    {'id': 'spo_001', 'text': 'Fußball', 'difficulty': 1},
    {'id': 'spo_002', 'text': 'Basketball', 'difficulty': 1},
    {'id': 'spo_003', 'text': 'Tennis', 'difficulty': 1},
    {'id': 'spo_004', 'text': 'Olympiade', 'difficulty': 2},
    {'id': 'spo_005', 'text': 'Schwimmen', 'difficulty': 1},
    {'id': 'spo_006', 'text': 'Handball', 'difficulty': 1},
    {'id': 'spo_007', 'text': 'Formel 1', 'difficulty': 2},
    {'id': 'spo_008', 'text': 'Marathon', 'difficulty': 2},
    {'id': 'spo_009', 'text': 'Golf', 'difficulty': 1},
    {'id': 'spo_010', 'text': 'Volleyball', 'difficulty': 1},
    {'id': 'spo_011', 'text': 'Eishockey', 'difficulty': 1},
    {'id': 'spo_012', 'text': 'Skifahren', 'difficulty': 1},
    {'id': 'spo_013', 'text': 'Boxen', 'difficulty': 1},
    {'id': 'spo_014', 'text': 'Radfahren', 'difficulty': 1},
    {'id': 'spo_015', 'text': 'Yoga', 'difficulty': 1},
    {'id': 'spo_016', 'text': 'Segeln', 'difficulty': 2},
    {'id': 'spo_017', 'text': 'Klettern', 'difficulty': 1},
    {'id': 'spo_018', 'text': 'Surfen', 'difficulty': 1},
    {'id': 'spo_019', 'text': 'Tauchen', 'difficulty': 2},
    {'id': 'spo_020', 'text': 'Reiten', 'difficulty': 1},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Fußball spy words
    {'main_word_id': 'spo_001', 'spy_word': 'Sommer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_001', 'spy_word': 'Kneipe', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_001', 'spy_word': 'Emotion', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_001', 'spy_word': 'Vereint', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_001', 'spy_word': 'Sonntag', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Basketball spy words
    {'main_word_id': 'spo_002', 'spy_word': 'Größe', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_002', 'spy_word': 'Amerika', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_002', 'spy_word': 'Tempo', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_002', 'spy_word': 'Sprung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_002', 'spy_word': 'Team', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Tennis spy words
    {'main_word_id': 'spo_003', 'spy_word': 'Eleganz', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_003', 'spy_word': 'Konzentration', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_003', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_003', 'spy_word': 'Einzelkampf', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_003', 'spy_word': 'Präzision', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Olympiade spy words
    {'main_word_id': 'spo_004', 'spy_word': 'Fackel', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_004', 'spy_word': 'Medaille', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_004', 'spy_word': 'Athlet', 'relationship_type': 'person', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_004', 'spy_word': 'Rekord', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_004', 'spy_word': 'Zeremonie', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Schwimmen spy words
    {'main_word_id': 'spo_005', 'spy_word': 'Becken', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_005', 'spy_word': 'Chlor', 'relationship_type': 'component', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'spo_005', 'spy_word': 'Badeanzug', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_005', 'spy_word': 'Kraulen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_005', 'spy_word': 'Schwimmbrille', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 5},

    // Handball spy words
    {'main_word_id': 'spo_006', 'spy_word': 'Sprungwurf', 'relationship_type': 'action', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'spo_006', 'spy_word': 'Kreis', 'relationship_type': 'location', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'spo_006', 'spy_word': 'Torwart', 'relationship_type': 'person', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_006', 'spy_word': 'Harz', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_006', 'spy_word': 'Siebenmeter', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Formel 1 spy words
    {'main_word_id': 'spo_007', 'spy_word': 'Geschwindigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_007', 'spy_word': 'Monaco', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_007', 'spy_word': 'Technik', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_007', 'spy_word': 'Adrenalin', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_007', 'spy_word': 'Glamour', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Marathon spy words
    {'main_word_id': 'spo_008', 'spy_word': 'Ausdauer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_008', 'spy_word': 'Grenze', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_008', 'spy_word': 'Mental', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_008', 'spy_word': 'Ziel', 'relationship_type': 'location', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_008', 'spy_word': 'Triumph', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Golf spy words
    {'main_word_id': 'spo_009', 'spy_word': 'Ruhe', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_009', 'spy_word': 'Präzision', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_009', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_009', 'spy_word': 'Grün', 'relationship_type': 'location', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_009', 'spy_word': 'Etikette', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Volleyball spy words
    {'main_word_id': 'spo_010', 'spy_word': 'Netz', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_010', 'spy_word': 'Strand', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_010', 'spy_word': 'Sprung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_010', 'spy_word': 'Koordination', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_010', 'spy_word': 'Teamwork', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Eishockey spy words
    {'main_word_id': 'spo_011', 'spy_word': 'Kälte', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_011', 'spy_word': 'Kanada', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_011', 'spy_word': 'Körperkontakt', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_011', 'spy_word': 'Geschwindigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_011', 'spy_word': 'Helm', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Skifahren spy words
    {'main_word_id': 'spo_012', 'spy_word': 'Schnee', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_012', 'spy_word': 'Berg', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_012', 'spy_word': 'Winter', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_012', 'spy_word': 'Urlaub', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_012', 'spy_word': 'Adrenalin', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Boxen spy words
    {'main_word_id': 'spo_013', 'spy_word': 'Kraft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_013', 'spy_word': 'Ring', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_013', 'spy_word': 'Disziplin', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_013', 'spy_word': 'Respekt', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'spo_013', 'spy_word': 'Training', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // Radfahren spy words
    {'main_word_id': 'spo_014', 'spy_word': 'Umwelt', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_014', 'spy_word': 'Frische', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_014', 'spy_word': 'Nachhaltigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_014', 'spy_word': 'Kondition', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_014', 'spy_word': 'Freiheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Yoga spy words
    {'main_word_id': 'spo_015', 'spy_word': 'Ruhe', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_015', 'spy_word': 'Flexibilität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_015', 'spy_word': 'Meditation', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_015', 'spy_word': 'Balance', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_015', 'spy_word': 'Spiritualität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Segeln spy words
    {'main_word_id': 'spo_016', 'spy_word': 'Wind', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_016', 'spy_word': 'Meer', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_016', 'spy_word': 'Luxus', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_016', 'spy_word': 'Romantik', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_016', 'spy_word': 'Navigation', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Klettern spy words
    {'main_word_id': 'spo_017', 'spy_word': 'Höhe', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_017', 'spy_word': 'Mut', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_017', 'spy_word': 'Vertrauen', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_017', 'spy_word': 'Fokus', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_017', 'spy_word': 'Überwindung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Surfen spy words
    {'main_word_id': 'spo_018', 'spy_word': 'Welle', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_018', 'spy_word': 'Strand', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_018', 'spy_word': 'Freiheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'spo_018', 'spy_word': 'Balance', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_018', 'spy_word': 'Flow', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Tauchen spy words
    {'main_word_id': 'spo_019', 'spy_word': 'Stille', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_019', 'spy_word': 'Unterwelt', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_019', 'spy_word': 'Schwerelosigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_019', 'spy_word': 'Abenteuer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_019', 'spy_word': 'Faszination', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Reiten spy words
    {'main_word_id': 'spo_020', 'spy_word': 'Eleganz', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'spo_020', 'spy_word': 'Vertrauen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'spo_020', 'spy_word': 'Harmonie', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'spo_020', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'spo_020', 'spy_word': 'Privileg', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},
  ];
}
