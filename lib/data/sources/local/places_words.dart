// Places category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class PlacesWords {
  static const String categoryId = 'places';
  static const String categoryName = 'Orte';
  static const String categoryDescription = 'Städte, Länder und Sehenswürdigkeiten';
  static const bool isDefault = true;

  static const List<Map<String, dynamic>> words = [
    {'id': 'plc_001', 'text': 'Paris', 'difficulty': 1},
    {'id': 'plc_002', 'text': 'New York', 'difficulty': 1},
    {'id': 'plc_003', 'text': 'Berlin', 'difficulty': 1},
    {'id': 'plc_004', 'text': 'Tokio', 'difficulty': 1},
    {'id': 'plc_005', 'text': 'Rom', 'difficulty': 1},
    {'id': 'plc_006', 'text': 'Ägypten', 'difficulty': 1},
    {'id': 'plc_007', 'text': 'Australien', 'difficulty': 1},
    {'id': 'plc_008', 'text': 'Himalaya', 'difficulty': 2},
    {'id': 'plc_009', 'text': 'Amazonas', 'difficulty': 2},
    {'id': 'plc_010', 'text': 'Venedig', 'difficulty': 1},
    {'id': 'plc_011', 'text': 'London', 'difficulty': 1},
    {'id': 'plc_012', 'text': 'Barcelona', 'difficulty': 1},
    {'id': 'plc_013', 'text': 'Amsterdam', 'difficulty': 1},
    {'id': 'plc_014', 'text': 'Dubai', 'difficulty': 1},
    {'id': 'plc_015', 'text': 'Island', 'difficulty': 1},
    {'id': 'plc_016', 'text': 'Brasilien', 'difficulty': 1},
    {'id': 'plc_017', 'text': 'Thailand', 'difficulty': 1},
    {'id': 'plc_018', 'text': 'Schweiz', 'difficulty': 1},
    {'id': 'plc_019', 'text': 'Kanada', 'difficulty': 1},
    {'id': 'plc_020', 'text': 'Malediven', 'difficulty': 2},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Paris spy words
    {'main_word_id': 'plc_001', 'spy_word': 'Eiffelturm', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_001', 'spy_word': 'Frankreich', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_001', 'spy_word': 'Mode', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'plc_001', 'spy_word': 'Seine', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_001', 'spy_word': 'Louvre', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // New York spy words
    {'main_word_id': 'plc_002', 'spy_word': 'Wolkenkratzer', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_002', 'spy_word': 'Broadway', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_002', 'spy_word': 'Taxi', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_002', 'spy_word': 'Freiheitsstatue', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'plc_002', 'spy_word': 'Großstadt', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Berlin spy words
    {'main_word_id': 'plc_003', 'spy_word': 'Mauer', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_003', 'spy_word': 'Hauptstadt', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_003', 'spy_word': 'Brandenburger', 'relationship_type': 'component', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'plc_003', 'spy_word': 'Currywurst', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_003', 'spy_word': 'Geschichte', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Tokio spy words
    {'main_word_id': 'plc_004', 'spy_word': 'Neon', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_004', 'spy_word': 'Sushi', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_004', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_004', 'spy_word': 'Moderne', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_004', 'spy_word': 'Überfüllung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Rom spy words
    {'main_word_id': 'plc_005', 'spy_word': 'Kolosseum', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_005', 'spy_word': 'Geschichte', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_005', 'spy_word': 'Antike', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_005', 'spy_word': 'Vatikan', 'relationship_type': 'location', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_005', 'spy_word': 'Ewigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Ägypten spy words
    {'main_word_id': 'plc_006', 'spy_word': 'Pyramiden', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_006', 'spy_word': 'Wüste', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_006', 'spy_word': 'Pharao', 'relationship_type': 'person', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_006', 'spy_word': 'Sphinx', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_006', 'spy_word': 'Mysterium', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Australien spy words
    {'main_word_id': 'plc_007', 'spy_word': 'Känguru', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_007', 'spy_word': 'Kontinent', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_007', 'spy_word': 'Outback', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_007', 'spy_word': 'Abenteuer', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_007', 'spy_word': 'Isolation', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Himalaya spy words
    {'main_word_id': 'plc_008', 'spy_word': 'Everest', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_008', 'spy_word': 'Kälte', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_008', 'spy_word': 'Herausforderung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'plc_008', 'spy_word': 'Spiritualität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_008', 'spy_word': 'Grenzen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Amazonas spy words
    {'main_word_id': 'plc_009', 'spy_word': 'Regenwald', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_009', 'spy_word': 'Biodiversität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'plc_009', 'spy_word': 'Gefahr', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_009', 'spy_word': 'Unerforscht', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_009', 'spy_word': 'Lunge', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Venedig spy words
    {'main_word_id': 'plc_010', 'spy_word': 'Gondel', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_010', 'spy_word': 'Kanäle', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_010', 'spy_word': 'Romantik', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_010', 'spy_word': 'Untergang', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_010', 'spy_word': 'Maske', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // London spy words
    {'main_word_id': 'plc_011', 'spy_word': 'Nebel', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_011', 'spy_word': 'Tee', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_011', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_011', 'spy_word': 'Akzent', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_011', 'spy_word': 'Geschichte', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Barcelona spy words
    {'main_word_id': 'plc_012', 'spy_word': 'Architektur', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_012', 'spy_word': 'Mittelmeer', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_012', 'spy_word': 'Kunst', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_012', 'spy_word': 'Lebensfreude', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_012', 'spy_word': 'Siesta', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Amsterdam spy words
    {'main_word_id': 'plc_013', 'spy_word': 'Kanäle', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_013', 'spy_word': 'Fahrrad', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_013', 'spy_word': 'Freiheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_013', 'spy_word': 'Toleranz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_013', 'spy_word': 'Tulpen', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Dubai spy words
    {'main_word_id': 'plc_014', 'spy_word': 'Luxus', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_014', 'spy_word': 'Wüste', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_014', 'spy_word': 'Zukunft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_014', 'spy_word': 'Klimaanlage', 'relationship_type': 'tool', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_014', 'spy_word': 'Shopping', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // Island spy words
    {'main_word_id': 'plc_015', 'spy_word': 'Naturkraft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_015', 'spy_word': 'Geysir', 'relationship_type': 'component', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'plc_015', 'spy_word': 'Nordlicht', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_015', 'spy_word': 'Reinheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_015', 'spy_word': 'Abgeschiedenheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Brasilien spy words
    {'main_word_id': 'plc_016', 'spy_word': 'Karneval', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_016', 'spy_word': 'Samba', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_016', 'spy_word': 'Regenwald', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_016', 'spy_word': 'Lebensfreude', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'plc_016', 'spy_word': 'Vielfalt', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Thailand spy words
    {'main_word_id': 'plc_017', 'spy_word': 'Tempel', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_017', 'spy_word': 'Massage', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_017', 'spy_word': 'Paradies', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_017', 'spy_word': 'Backpacker', 'relationship_type': 'person', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_017', 'spy_word': 'Spiritualität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Schweiz spy words
    {'main_word_id': 'plc_018', 'spy_word': 'Berge', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_018', 'spy_word': 'Präzision', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_018', 'spy_word': 'Schokolade', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_018', 'spy_word': 'Neutralität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_018', 'spy_word': 'Sauberkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Kanada spy words
    {'main_word_id': 'plc_019', 'spy_word': 'Weite', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_019', 'spy_word': 'Höflichkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_019', 'spy_word': 'Wildnis', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_019', 'spy_word': 'Multikulti', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_019', 'spy_word': 'Ahornsirup', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Malediven spy words
    {'main_word_id': 'plc_020', 'spy_word': 'Traumurlaub', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'plc_020', 'spy_word': 'Türkis', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'plc_020', 'spy_word': 'Flitterwochen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'plc_020', 'spy_word': 'Exklusiv', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'plc_020', 'spy_word': 'Vergessen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},
  ];
}
