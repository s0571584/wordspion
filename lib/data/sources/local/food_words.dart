// Food category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class FoodWords {
  static const String categoryId = 'food';
  static const String categoryName = 'Essen & Trinken';
  static const String categoryDescription = 'Gerichte, Zutaten und Getränke';
  static const bool isDefault = true;

  static const List<Map<String, dynamic>> words = [
    {'id': 'food_001', 'text': 'Pizza', 'difficulty': 1},
    {'id': 'food_002', 'text': 'Sushi', 'difficulty': 1},
    {'id': 'food_003', 'text': 'Pasta', 'difficulty': 1},
    {'id': 'food_004', 'text': 'Kaffee', 'difficulty': 1},
    {'id': 'food_005', 'text': 'Schokolade', 'difficulty': 1},
    {'id': 'food_006', 'text': 'Hamburger', 'difficulty': 1},
    {'id': 'food_007', 'text': 'Erdbeere', 'difficulty': 1},
    {'id': 'food_008', 'text': 'Kartoffel', 'difficulty': 1},
    {'id': 'food_009', 'text': 'Käse', 'difficulty': 1},
    {'id': 'food_010', 'text': 'Champagner', 'difficulty': 2},
    {'id': 'food_011', 'text': 'Taco', 'difficulty': 1},
    {'id': 'food_012', 'text': 'Curry', 'difficulty': 1},
    {'id': 'food_013', 'text': 'Salat', 'difficulty': 1},
    {'id': 'food_014', 'text': 'Eis', 'difficulty': 1},
    {'id': 'food_015', 'text': 'Smoothie', 'difficulty': 1},
    {'id': 'food_016', 'text': 'Croissant', 'difficulty': 1},
    {'id': 'food_017', 'text': 'Ramen', 'difficulty': 1},
    {'id': 'food_018', 'text': 'Avocado', 'difficulty': 1},
    {'id': 'food_019', 'text': 'Quinoa', 'difficulty': 2},
    {'id': 'food_020', 'text': 'Matcha', 'difficulty': 2},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Pizza spy words
    {'main_word_id': 'food_001', 'spy_word': 'Ofen', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_001', 'spy_word': 'Italien', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_001', 'spy_word': 'Geselligkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_001', 'spy_word': 'Abend', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_001', 'spy_word': 'Lieferung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // Sushi spy words
    {'main_word_id': 'food_002', 'spy_word': 'Frische', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_002', 'spy_word': 'Japan', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_002', 'spy_word': 'Stäbchen', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_002', 'spy_word': 'Kunst', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_002', 'spy_word': 'Wasabi', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Pasta spy words
    {'main_word_id': 'food_003', 'spy_word': 'Gabel', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_003', 'spy_word': 'Sauce', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_003', 'spy_word': 'Kochen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_003', 'spy_word': 'Parmesan', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_003', 'spy_word': 'Aldente', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Kaffee spy words
    {'main_word_id': 'food_004', 'spy_word': 'Bohne', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_004', 'spy_word': 'Tasse', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_004', 'spy_word': 'Espresso', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_004', 'spy_word': 'Wachmachen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_004', 'spy_word': 'Morgen', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Schokolade spy words
    {'main_word_id': 'food_005', 'spy_word': 'Süße', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_005', 'spy_word': 'Trost', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_005', 'spy_word': 'Kakao', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_005', 'spy_word': 'Versuchung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_005', 'spy_word': 'Endorphine', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Hamburger spy words
    {'main_word_id': 'food_006', 'spy_word': 'Amerika', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_006', 'spy_word': 'Fastfood', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_006', 'spy_word': 'Brötchen', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_006', 'spy_word': 'Ungeduld', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_006', 'spy_word': 'Sättigung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Erdbeere spy words
    {'main_word_id': 'food_007', 'spy_word': 'Sommer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_007', 'spy_word': 'Süße', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_007', 'spy_word': 'Vitamine', 'relationship_type': 'component', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'food_007', 'spy_word': 'Marmelade', 'relationship_type': 'component', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_007', 'spy_word': 'Kindheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Kartoffel spy words
    {'main_word_id': 'food_008', 'spy_word': 'Grundnahrung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 1},
    {'main_word_id': 'food_008', 'spy_word': 'Vielseitigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_008', 'spy_word': 'Erde', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_008', 'spy_word': 'Sättigung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_008', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Käse spy words
    {'main_word_id': 'food_009', 'spy_word': 'Milch', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_009', 'spy_word': 'Reifung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_009', 'spy_word': 'Vielfalt', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_009', 'spy_word': 'Tradition', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_009', 'spy_word': 'Geschmack', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Champagner spy words
    {'main_word_id': 'food_010', 'spy_word': 'Feier', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_010', 'spy_word': 'Eleganz', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_010', 'spy_word': 'Frankreich', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_010', 'spy_word': 'Luxus', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_010', 'spy_word': 'Perlend', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Taco spy words
    {'main_word_id': 'food_011', 'spy_word': 'Mexiko', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_011', 'spy_word': 'Schärfe', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_011', 'spy_word': 'Straßenstand', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_011', 'spy_word': 'Authentizität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_011', 'spy_word': 'Zusammenklappen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Curry spy words
    {'main_word_id': 'food_012', 'spy_word': 'Gewürze', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_012', 'spy_word': 'Indien', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_012', 'spy_word': 'Wärme', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_012', 'spy_word': 'Vielfalt', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_012', 'spy_word': 'Aroma', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Salat spy words
    {'main_word_id': 'food_013', 'spy_word': 'Frische', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_013', 'spy_word': 'Gesundheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_013', 'spy_word': 'Dressing', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_013', 'spy_word': 'Knackig', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_013', 'spy_word': 'Vitamine', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Eis spy words
    {'main_word_id': 'food_014', 'spy_word': 'Kälte', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_014', 'spy_word': 'Sommer', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_014', 'spy_word': 'Kindheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_014', 'spy_word': 'Erfrischung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_014', 'spy_word': 'Schmelzen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // Smoothie spy words
    {'main_word_id': 'food_015', 'spy_word': 'Energie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_015', 'spy_word': 'Frühstück', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_015', 'spy_word': 'Fitness', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_015', 'spy_word': 'Mixer', 'relationship_type': 'tool', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_015', 'spy_word': 'Trend', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Croissant spy words
    {'main_word_id': 'food_016', 'spy_word': 'Frankreich', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_016', 'spy_word': 'Butter', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_016', 'spy_word': 'Café', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_016', 'spy_word': 'Blätterteig', 'relationship_type': 'component', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_016', 'spy_word': 'Eleganz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Ramen spy words
    {'main_word_id': 'food_017', 'spy_word': 'Brühe', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_017', 'spy_word': 'Japan', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_017', 'spy_word': 'Komfort', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_017', 'spy_word': 'Schlürfen', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_017', 'spy_word': 'Wärme', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Avocado spy words
    {'main_word_id': 'food_018', 'spy_word': 'Cremig', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_018', 'spy_word': 'Gesund', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_018', 'spy_word': 'Toast', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'food_018', 'spy_word': 'Instagram', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'food_018', 'spy_word': 'Millennial', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Quinoa spy words
    {'main_word_id': 'food_019', 'spy_word': 'Superfood', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_019', 'spy_word': 'Protein', 'relationship_type': 'component', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'food_019', 'spy_word': 'Südamerika', 'relationship_type': 'location', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'food_019', 'spy_word': 'Trend', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_019', 'spy_word': 'Aussprache', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Matcha spy words
    {'main_word_id': 'food_020', 'spy_word': 'Grün', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'food_020', 'spy_word': 'Pulver', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'food_020', 'spy_word': 'Zeremonie', 'relationship_type': 'action', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'food_020', 'spy_word': 'Bitterkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'food_020', 'spy_word': 'Achtsamkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},
  ];
}
