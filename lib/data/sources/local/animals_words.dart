// Animals category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class AnimalsWords {
  static const String categoryId = 'animals';
  static const String categoryName = 'Tiere';
  static const String categoryDescription = 'Verschiedene Tierarten';
  static const bool isDefault = true;

  static const List<Map<String, dynamic>> words = [
    {'id': 'ani_001', 'text': 'Elefant', 'difficulty': 1},
    {'id': 'ani_002', 'text': 'Löwe', 'difficulty': 1},
    {'id': 'ani_003', 'text': 'Delfin', 'difficulty': 1},
    {'id': 'ani_004', 'text': 'Pinguin', 'difficulty': 1},
    {'id': 'ani_005', 'text': 'Adler', 'difficulty': 1},
    {'id': 'ani_006', 'text': 'Giraffe', 'difficulty': 1},
    {'id': 'ani_007', 'text': 'Nashorn', 'difficulty': 1},
    {'id': 'ani_008', 'text': 'Panda', 'difficulty': 1},
    {'id': 'ani_009', 'text': 'Krokodil', 'difficulty': 1},
    {'id': 'ani_010', 'text': 'Orca', 'difficulty': 2},
    {'id': 'ani_011', 'text': 'Schmetterling', 'difficulty': 1},
    {'id': 'ani_012', 'text': 'Hund', 'difficulty': 1},
    {'id': 'ani_013', 'text': 'Katze', 'difficulty': 1},
    {'id': 'ani_014', 'text': 'Bär', 'difficulty': 1},
    {'id': 'ani_015', 'text': 'Fuchs', 'difficulty': 1},
    {'id': 'ani_016', 'text': 'Eule', 'difficulty': 1},
    {'id': 'ani_017', 'text': 'Schildkröte', 'difficulty': 1},
    {'id': 'ani_018', 'text': 'Flamingo', 'difficulty': 1},
    {'id': 'ani_019', 'text': 'Koala', 'difficulty': 1},
    {'id': 'ani_020', 'text': 'Zebra', 'difficulty': 1},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Elefant spy words
    {'main_word_id': 'ani_001', 'spy_word': 'Afrika', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_001', 'spy_word': 'Vergessen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_001', 'spy_word': 'Stampfen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_001', 'spy_word': 'Gedächtnis', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_001', 'spy_word': 'Elfenbein', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Löwe spy words
    {'main_word_id': 'ani_002', 'spy_word': 'Brüllen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_002', 'spy_word': 'Mähne', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_002', 'spy_word': 'Savanne', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_002', 'spy_word': 'König', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_002', 'spy_word': 'Mut', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Delfin spy words
    {'main_word_id': 'ani_003', 'spy_word': 'Klicken', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_003', 'spy_word': 'Springen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_003', 'spy_word': 'Ozean', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_003', 'spy_word': 'Sonar', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ani_003', 'spy_word': 'Intelligenz', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Pinguin spy words
    {'main_word_id': 'ani_004', 'spy_word': 'Watscheln', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_004', 'spy_word': 'Rutschen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_004', 'spy_word': 'Antarktis', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_004', 'spy_word': 'Frack', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ani_004', 'spy_word': 'Kolonie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Adler spy words
    {'main_word_id': 'ani_005', 'spy_word': 'Kreisen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_005', 'spy_word': 'Schweben', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_005', 'spy_word': 'Berge', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_005', 'spy_word': 'Symbol', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_005', 'spy_word': 'Scharfblick', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Giraffe spy words
    {'main_word_id': 'ani_006', 'spy_word': 'Strecken', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_006', 'spy_word': 'Grasen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_006', 'spy_word': 'Savanne', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_006', 'spy_word': 'Flecken', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_006', 'spy_word': 'Höhe', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Nashorn spy words
    {'main_word_id': 'ani_007', 'spy_word': 'Rammen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_007', 'spy_word': 'Stampfen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_007', 'spy_word': 'Afrika', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_007', 'spy_word': 'Panzer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_007', 'spy_word': 'Wilderei', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Panda spy words
    {'main_word_id': 'ani_008', 'spy_word': 'Klettern', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_008', 'spy_word': 'Knabbern', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_008', 'spy_word': 'China', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_008', 'spy_word': 'Bambus', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_008', 'spy_word': 'Symbol', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Krokodil spy words
    {'main_word_id': 'ani_009', 'spy_word': 'Lauern', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_009', 'spy_word': 'Schnappen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_009', 'spy_word': 'Sumpf', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_009', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_009', 'spy_word': 'Urzeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Orca spy words
    {'main_word_id': 'ani_010', 'spy_word': 'Jagen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_010', 'spy_word': 'Kommunizieren', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_010', 'spy_word': 'Ozean', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_010', 'spy_word': 'Familie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_010', 'spy_word': 'Intelligenz', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Schmetterling spy words
    {'main_word_id': 'ani_011', 'spy_word': 'Flattern', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_011', 'spy_word': 'Verwandeln', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_011', 'spy_word': 'Garten', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_011', 'spy_word': 'Nektar', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_011', 'spy_word': 'Verwandlung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Hund spy words
    {'main_word_id': 'ani_012', 'spy_word': 'Bellen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_012', 'spy_word': 'Wedeln', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_012', 'spy_word': 'Haus', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_012', 'spy_word': 'Treue', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_012', 'spy_word': 'Freundschaft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Katze spy words
    {'main_word_id': 'ani_013', 'spy_word': 'Schnurren', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_013', 'spy_word': 'Schleichen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_013', 'spy_word': 'Dach', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_013', 'spy_word': 'Unabhängigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_013', 'spy_word': 'Neugier', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Bär spy words
    {'main_word_id': 'ani_014', 'spy_word': 'Brummen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_014', 'spy_word': 'Schlafen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_014', 'spy_word': 'Wald', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_014', 'spy_word': 'Stärke', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_014', 'spy_word': 'Honig', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Fuchs spy words
    {'main_word_id': 'ani_015', 'spy_word': 'Schleichen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_015', 'spy_word': 'Täuschen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_015', 'spy_word': 'Bau', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_015', 'spy_word': 'List', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'ani_015', 'spy_word': 'Märchen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Eule spy words
    {'main_word_id': 'ani_016', 'spy_word': 'Gleiten', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_016', 'spy_word': 'Beobachten', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_016', 'spy_word': 'Nacht', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_016', 'spy_word': 'Weisheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_016', 'spy_word': 'Stille', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Schildkröte spy words
    {'main_word_id': 'ani_017', 'spy_word': 'Zurückziehen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_017', 'spy_word': 'Kriechen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_017', 'spy_word': 'Teich', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_017', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_017', 'spy_word': 'Panzer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Flamingo spy words
    {'main_word_id': 'ani_018', 'spy_word': 'Balancieren', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_018', 'spy_word': 'Filtern', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_018', 'spy_word': 'Lagune', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_018', 'spy_word': 'Rosa', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_018', 'spy_word': 'Balance', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Koala spy words
    {'main_word_id': 'ani_019', 'spy_word': 'Klettern', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_019', 'spy_word': 'Dösen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_019', 'spy_word': 'Australien', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_019', 'spy_word': 'Eukalyptus', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_019', 'spy_word': 'Beutel', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Zebra spy words
    {'main_word_id': 'ani_020', 'spy_word': 'Galoppieren', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'ani_020', 'spy_word': 'Ausschlagen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'ani_020', 'spy_word': 'Savanne', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'ani_020', 'spy_word': 'Streifen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'ani_020', 'spy_word': 'Tarnung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},
  ];
}
