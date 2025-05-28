// Technology category words and spy words
// Each word has exactly 5 spy words for balanced gameplay
// Note: "Podcast" was moved to Entertainment category to avoid duplicates

class TechnologyWords {
  static const String categoryId = 'technology';
  static const String categoryName = 'Technik';
  static const String categoryDescription = 'Geräte, Software und Internet';
  static const bool isDefault = false;

  static const List<Map<String, dynamic>> words = [
    {'id': 'tech_001', 'text': 'Smartphone', 'difficulty': 1},
    {'id': 'tech_002', 'text': 'Internet', 'difficulty': 1},
    {'id': 'tech_003', 'text': 'Computer', 'difficulty': 1},
    {'id': 'tech_004', 'text': 'Roboter', 'difficulty': 1},
    {'id': 'tech_005', 'text': 'Künstliche Intelligenz', 'difficulty': 2},
    {'id': 'tech_006', 'text': 'Social Media', 'difficulty': 1},
    {'id': 'tech_007', 'text': 'App', 'difficulty': 1},
    {'id': 'tech_008', 'text': 'Cloud', 'difficulty': 1},
    {'id': 'tech_009', 'text': 'Blockchain', 'difficulty': 2},
    {'id': 'tech_010', 'text': 'VR-Brille', 'difficulty': 1},
    {'id': 'tech_011', 'text': 'Drohne', 'difficulty': 1},
    {'id': 'tech_012', 'text': 'Streaming', 'difficulty': 1},
    {'id': 'tech_013', 'text': 'E-Auto', 'difficulty': 1},
    {'id': 'tech_014', 'text': 'Smart Home', 'difficulty': 1},
    {'id': 'tech_015', 'text': 'Laptop', 'difficulty': 1},
    {'id': 'tech_016', 'text': 'Tablet', 'difficulty': 1},
    {'id': 'tech_017', 'text': 'Webcam', 'difficulty': 1},
    {'id': 'tech_018', 'text': 'Alexa', 'difficulty': 1},
    {'id': 'tech_019', 'text': 'Kryptowährung', 'difficulty': 2},
    {'id': 'tech_020', 'text': 'Augmented Reality', 'difficulty': 2},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Smartphone spy words
    {'main_word_id': 'tech_001', 'spy_word': 'Touchscreen', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_001', 'spy_word': 'Apps', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_001', 'spy_word': 'Sucht', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'tech_001', 'spy_word': 'Mobilität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'tech_001', 'spy_word': 'Revolution', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Internet spy words
    {'main_word_id': 'tech_002', 'spy_word': 'Vernetzung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_002', 'spy_word': 'Information', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_002', 'spy_word': 'Global', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_002', 'spy_word': 'Anonymität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_002', 'spy_word': 'Bandbreite', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Computer spy words
    {'main_word_id': 'tech_003', 'spy_word': 'Prozessor', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_003', 'spy_word': 'Tastatur', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_003', 'spy_word': 'Produktivität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_003', 'spy_word': 'Büro', 'relationship_type': 'location', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_003', 'spy_word': 'Digitalisierung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Roboter spy words
    {'main_word_id': 'tech_004', 'spy_word': 'Automatisierung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_004', 'spy_word': 'Präzision', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_004', 'spy_word': 'Zukunft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_004', 'spy_word': 'Effizienz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_004', 'spy_word': 'Bedrohung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Künstliche Intelligenz spy words
    {'main_word_id': 'tech_005', 'spy_word': 'Lernen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_005', 'spy_word': 'Algorithmus', 'relationship_type': 'component', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'tech_005', 'spy_word': 'Verstehen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_005', 'spy_word': 'Revolution', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_005', 'spy_word': 'Singularität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Social Media spy words
    {'main_word_id': 'tech_006', 'spy_word': 'Vernetzung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_006', 'spy_word': 'Sucht', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_006', 'spy_word': 'Likes', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_006', 'spy_word': 'Filterblase', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_006', 'spy_word': 'Algorithmus', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // App spy words
    {'main_word_id': 'tech_007', 'spy_word': 'Download', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_007', 'spy_word': 'Update', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_007', 'spy_word': 'Benachrichtigung', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_007', 'spy_word': 'Bequemlichkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_007', 'spy_word': 'Abhängigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Cloud spy words
    {'main_word_id': 'tech_008', 'spy_word': 'Speicher', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_008', 'spy_word': 'Zugriff', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_008', 'spy_word': 'Backup', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_008', 'spy_word': 'Datenschutz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_008', 'spy_word': 'Skalierbarkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Blockchain spy words
    {'main_word_id': 'tech_009', 'spy_word': 'Dezentral', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'tech_009', 'spy_word': 'Transparenz', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_009', 'spy_word': 'Vertrauen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_009', 'spy_word': 'Revolution', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_009', 'spy_word': 'Komplexität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // VR-Brille spy words
    {'main_word_id': 'tech_010', 'spy_word': 'Eintauchen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_010', 'spy_word': 'Realität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_010', 'spy_word': 'Simulation', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_010', 'spy_word': 'Schwindel', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_010', 'spy_word': 'Zukunft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Drohne spy words
    {'main_word_id': 'tech_011', 'spy_word': 'Perspektive', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_011', 'spy_word': 'Fernsteuerung', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_011', 'spy_word': 'Lieferung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_011', 'spy_word': 'Privatsphäre', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_011', 'spy_word': 'Luftraum', 'relationship_type': 'location', 'difficulty': 3, 'priority': 5},

    // Streaming spy words
    {'main_word_id': 'tech_012', 'spy_word': 'Bandbreite', 'relationship_type': 'component', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'tech_012', 'spy_word': 'Pufferung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'tech_012', 'spy_word': 'Echtzeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_012', 'spy_word': 'Qualität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'tech_012', 'spy_word': 'Unterbrechung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // E-Auto spy words
    {'main_word_id': 'tech_013', 'spy_word': 'Lautlos', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_013', 'spy_word': 'Ladekabel', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_013', 'spy_word': 'Reichweite', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_013', 'spy_word': 'Nachhaltigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_013', 'spy_word': 'Zukunft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Smart Home spy words
    {'main_word_id': 'tech_014', 'spy_word': 'Automatisierung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_014', 'spy_word': 'Bequemlichkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_014', 'spy_word': 'Energie', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_014', 'spy_word': 'Sicherheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'tech_014', 'spy_word': 'Vernetzung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Laptop spy words
    {'main_word_id': 'tech_015', 'spy_word': 'Mobilität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_015', 'spy_word': 'Akku', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_015', 'spy_word': 'Klappen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_015', 'spy_word': 'Produktivität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_015', 'spy_word': 'Ergonomie', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Tablet spy words
    {'main_word_id': 'tech_016', 'spy_word': 'Touch', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_016', 'spy_word': 'Leichtigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_016', 'spy_word': 'Kreativität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_016', 'spy_word': 'Intuition', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_016', 'spy_word': 'Flexibilität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Webcam spy words
    {'main_word_id': 'tech_017', 'spy_word': 'Videokonferenz', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_017', 'spy_word': 'Privatsphäre', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'tech_017', 'spy_word': 'Abkleben', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_017', 'spy_word': 'Überwachung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_017', 'spy_word': 'Verbindung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Alexa spy words
    {'main_word_id': 'tech_018', 'spy_word': 'Sprachsteuerung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'tech_018', 'spy_word': 'Zuhören', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_018', 'spy_word': 'Assistent', 'relationship_type': 'person', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_018', 'spy_word': 'Paranoia', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_018', 'spy_word': 'Datensammlung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Kryptowährung spy words
    {'main_word_id': 'tech_019', 'spy_word': 'Volatil', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'tech_019', 'spy_word': 'Spekulation', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_019', 'spy_word': 'Digital', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_019', 'spy_word': 'Mining', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'tech_019', 'spy_word': 'Revolution', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Augmented Reality spy words
    {'main_word_id': 'tech_020', 'spy_word': 'Überlagerung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'tech_020', 'spy_word': 'Brille', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'tech_020', 'spy_word': 'Information', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'tech_020', 'spy_word': 'Zukunft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'tech_020', 'spy_word': 'Erweitert', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},
  ];
}
