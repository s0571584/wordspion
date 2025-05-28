// Everyday category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class EverydayWords {
  static const String categoryId = 'everyday';
  static const String categoryName = 'Alltag';
  static const String categoryDescription = 'Alltagsgegenstände und -aktivitäten';
  static const bool isDefault = false;

  static const List<Map<String, dynamic>> words = [
    {'id': 'day_001', 'text': 'Schlüssel', 'difficulty': 1},
    {'id': 'day_002', 'text': 'Uhr', 'difficulty': 1},
    {'id': 'day_003', 'text': 'Brille', 'difficulty': 1},
    {'id': 'day_004', 'text': 'Tasche', 'difficulty': 1},
    {'id': 'day_005', 'text': 'Buch', 'difficulty': 1},
    {'id': 'day_006', 'text': 'Handy', 'difficulty': 1},
    {'id': 'day_007', 'text': 'Geldbörse', 'difficulty': 1},
    {'id': 'day_008', 'text': 'Regenschirm', 'difficulty': 1},
    {'id': 'day_009', 'text': 'Kopfhörer', 'difficulty': 1},
    {'id': 'day_010', 'text': 'Zahnbürste', 'difficulty': 1},
    {'id': 'day_011', 'text': 'Ladekabel', 'difficulty': 1},
    {'id': 'day_012', 'text': 'Küchenrolle', 'difficulty': 1},
    {'id': 'day_013', 'text': 'Fernbedienung', 'difficulty': 1},
    {'id': 'day_014', 'text': 'Handtuch', 'difficulty': 1},
    {'id': 'day_015', 'text': 'Kissen', 'difficulty': 1},
    {'id': 'day_016', 'text': 'Decke', 'difficulty': 1},
    {'id': 'day_017', 'text': 'Kerze', 'difficulty': 1},
    {'id': 'day_018', 'text': 'Spiegel', 'difficulty': 1},
    {'id': 'day_019', 'text': 'Pflanzen', 'difficulty': 1},
    {'id': 'day_020', 'text': 'Staubsauger', 'difficulty': 1},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Schlüssel spy words
    {'main_word_id': 'day_001', 'spy_word': 'Zugang', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_001', 'spy_word': 'Sicherheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_001', 'spy_word': 'Verlieren', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_001', 'spy_word': 'Metall', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_001', 'spy_word': 'Bund', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Uhr spy words  
    {'main_word_id': 'day_002', 'spy_word': 'Zeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_002', 'spy_word': 'Pünktlichkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_002', 'spy_word': 'Zeiger', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_002', 'spy_word': 'Armband', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_002', 'spy_word': 'Routine', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Brille spy words
    {'main_word_id': 'day_003', 'spy_word': 'Sehen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_003', 'spy_word': 'Klarheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_003', 'spy_word': 'Gläser', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_003', 'spy_word': 'Intelligenz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_003', 'spy_word': 'Gestell', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Tasche spy words
    {'main_word_id': 'day_004', 'spy_word': 'Aufbewahrung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_004', 'spy_word': 'Mobilität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_004', 'spy_word': 'Essentials', 'relationship_type': 'component', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'day_004', 'spy_word': 'Mode', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_004', 'spy_word': 'Griff', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Buch spy words
    {'main_word_id': 'day_005', 'spy_word': 'Wissen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_005', 'spy_word': 'Entspannung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_005', 'spy_word': 'Seiten', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_005', 'spy_word': 'Flucht', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_005', 'spy_word': 'Papier', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Handy spy words
    {'main_word_id': 'day_006', 'spy_word': 'Erreichbarkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_006', 'spy_word': 'Sucht', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_006', 'spy_word': 'Akku', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_006', 'spy_word': 'Vernetzung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_006', 'spy_word': 'Display', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Geldbörse spy words
    {'main_word_id': 'day_007', 'spy_word': 'Portemonnaie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_007', 'spy_word': 'Karten', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_007', 'spy_word': 'Bargeld', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_007', 'spy_word': 'Sicherheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_007', 'spy_word': 'Leder', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Regenschirm spy words
    {'main_word_id': 'day_008', 'spy_word': 'Schutz', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_008', 'spy_word': 'Unvorhersehbar', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'day_008', 'spy_word': 'Aufspannen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_008', 'spy_word': 'Vorsicht', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_008', 'spy_word': 'Tropfen', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Kopfhörer spy words
    {'main_word_id': 'day_009', 'spy_word': 'Isolation', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_009', 'spy_word': 'Musik', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_009', 'spy_word': 'Privatsphäre', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_009', 'spy_word': 'Konzentration', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_009', 'spy_word': 'Kabel', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Zahnbürste spy words
    {'main_word_id': 'day_010', 'spy_word': 'Hygiene', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_010', 'spy_word': 'Routine', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_010', 'spy_word': 'Borsten', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_010', 'spy_word': 'Morgen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_010', 'spy_word': 'Zahnpasta', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Ladekabel spy words
    {'main_word_id': 'day_011', 'spy_word': 'Abhängigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_011', 'spy_word': 'Energie', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_011', 'spy_word': 'Verlegen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_011', 'spy_word': 'Universal', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_011', 'spy_word': 'Steckdose', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Küchenrolle spy words
    {'main_word_id': 'day_012', 'spy_word': 'Sauberkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_012', 'spy_word': 'Praktisch', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_012', 'spy_word': 'Abreißen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_012', 'spy_word': 'Wegwerfen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_012', 'spy_word': 'Vorrat', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Fernbedienung spy words
    {'main_word_id': 'day_013', 'spy_word': 'Kontrolle', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_013', 'spy_word': 'Bequemlichkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_013', 'spy_word': 'Batterien', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_013', 'spy_word': 'Verlegen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_013', 'spy_word': 'Sofa', 'relationship_type': 'location', 'difficulty': 2, 'priority': 5},

    // Handtuch spy words
    {'main_word_id': 'day_014', 'spy_word': 'Trocknen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_014', 'spy_word': 'Weichheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_014', 'spy_word': 'Badezimmer', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_014', 'spy_word': 'Frottee', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_014', 'spy_word': 'Sauberkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Kissen spy words
    {'main_word_id': 'day_015', 'spy_word': 'Komfort', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_015', 'spy_word': 'Schlaf', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_015', 'spy_word': 'Entspannung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_015', 'spy_word': 'Füllung', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_015', 'spy_word': 'Gemütlichkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Decke spy words
    {'main_word_id': 'day_016', 'spy_word': 'Wärme', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_016', 'spy_word': 'Geborgenheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_016', 'spy_word': 'Kuscheln', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_016', 'spy_word': 'Winter', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_016', 'spy_word': 'Textil', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Kerze spy words
    {'main_word_id': 'day_017', 'spy_word': 'Atmosphäre', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_017', 'spy_word': 'Romantik', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_017', 'spy_word': 'Flamme', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_017', 'spy_word': 'Entspannung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_017', 'spy_word': 'Wachs', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Spiegel spy words
    {'main_word_id': 'day_018', 'spy_word': 'Reflektion', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_018', 'spy_word': 'Eitelkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_018', 'spy_word': 'Wahrheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'day_018', 'spy_word': 'Morgenroutine', 'relationship_type': 'action', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_018', 'spy_word': 'Glas', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Pflanzen spy words
    {'main_word_id': 'day_019', 'spy_word': 'Leben', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_019', 'spy_word': 'Sauerstoff', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_019', 'spy_word': 'Verantwortung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_019', 'spy_word': 'Gießen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'day_019', 'spy_word': 'Grün', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Staubsauger spy words
    {'main_word_id': 'day_020', 'spy_word': 'Lärm', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'day_020', 'spy_word': 'Sauberkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'day_020', 'spy_word': 'Hausarbeit', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'day_020', 'spy_word': 'Effizienz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'day_020', 'spy_word': 'Beutel', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},
  ];
}
