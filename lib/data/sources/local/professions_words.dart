// Professions category words and spy words
// Each word has exactly 5 spy words for balanced gameplay

class ProfessionsWords {
  static const String categoryId = 'professions';
  static const String categoryName = 'Berufe';
  static const String categoryDescription = 'Berufe und Tätigkeiten';
  static const bool isDefault = true;

  static const List<Map<String, dynamic>> words = [
    {'id': 'prof_001', 'text': 'Arzt', 'difficulty': 1},
    {'id': 'prof_002', 'text': 'Lehrer', 'difficulty': 1},
    {'id': 'prof_003', 'text': 'Koch', 'difficulty': 1},
    {'id': 'prof_004', 'text': 'Pilot', 'difficulty': 1},
    {'id': 'prof_005', 'text': 'Polizist', 'difficulty': 1},
    {'id': 'prof_006', 'text': 'Anwalt', 'difficulty': 1},
    {'id': 'prof_007', 'text': 'Ingenieur', 'difficulty': 1},
    {'id': 'prof_008', 'text': 'Künstler', 'difficulty': 1},
    {'id': 'prof_009', 'text': 'Schauspieler', 'difficulty': 1},
    {'id': 'prof_010', 'text': 'Astronaut', 'difficulty': 2},
    {'id': 'prof_011', 'text': 'Entwickler', 'difficulty': 1},
    {'id': 'prof_012', 'text': 'Designer', 'difficulty': 1},
    {'id': 'prof_013', 'text': 'Journalist', 'difficulty': 1},
    {'id': 'prof_014', 'text': 'Architekt', 'difficulty': 1},
    {'id': 'prof_015', 'text': 'Fotograf', 'difficulty': 1},
    {'id': 'prof_016', 'text': 'Übersetzer', 'difficulty': 2},
    {'id': 'prof_017', 'text': 'Berater', 'difficulty': 1},
    {'id': 'prof_018', 'text': 'Trainer', 'difficulty': 1},
    {'id': 'prof_019', 'text': 'Therapeut', 'difficulty': 1},
    {'id': 'prof_020', 'text': 'Influencer', 'difficulty': 1},
  ];

  static const List<Map<String, dynamic>> spyWords = [
    // Arzt spy words
    {'main_word_id': 'prof_001', 'spy_word': 'Vertrauen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_001', 'spy_word': 'Krankenhaus', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_001', 'spy_word': 'Diagnose', 'relationship_type': 'action', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'prof_001', 'spy_word': 'Patient', 'relationship_type': 'person', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'prof_001', 'spy_word': 'Rezept', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Lehrer spy words
    {'main_word_id': 'prof_002', 'spy_word': 'Wissen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_002', 'spy_word': 'Schule', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_002', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_002', 'spy_word': 'Ferien', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_002', 'spy_word': 'Inspiration', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Koch spy words
    {'main_word_id': 'prof_003', 'spy_word': 'Kreativität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_003', 'spy_word': 'Küche', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_003', 'spy_word': 'Rezept', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_003', 'spy_word': 'Leidenschaft', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'prof_003', 'spy_word': 'Gewürz', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Pilot spy words
    {'main_word_id': 'prof_004', 'spy_word': 'Himmel', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_004', 'spy_word': 'Verantwortung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_004', 'spy_word': 'Präzision', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'prof_004', 'spy_word': 'Reisen', 'relationship_type': 'action', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'prof_004', 'spy_word': 'Uniform', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Polizist spy words
    {'main_word_id': 'prof_005', 'spy_word': 'Sicherheit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_005', 'spy_word': 'Dienst', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_005', 'spy_word': 'Uniform', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_005', 'spy_word': 'Ordnung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_005', 'spy_word': 'Schutz', 'relationship_type': 'action', 'difficulty': 2, 'priority': 5},

    // Anwalt spy words
    {'main_word_id': 'prof_006', 'spy_word': 'Gerechtigkeit', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_006', 'spy_word': 'Gericht', 'relationship_type': 'location', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_006', 'spy_word': 'Verteidigung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_006', 'spy_word': 'Rhetorik', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_006', 'spy_word': 'Paragraf', 'relationship_type': 'component', 'difficulty': 3, 'priority': 5},

    // Ingenieur spy words
    {'main_word_id': 'prof_007', 'spy_word': 'Technik', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_007', 'spy_word': 'Konstruktion', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_007', 'spy_word': 'Problem', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_007', 'spy_word': 'Innovation', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_007', 'spy_word': 'Berechnung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Künstler spy words
    {'main_word_id': 'prof_008', 'spy_word': 'Inspiration', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_008', 'spy_word': 'Kreativität', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_008', 'spy_word': 'Atelier', 'relationship_type': 'location', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_008', 'spy_word': 'Expression', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_008', 'spy_word': 'Bohème', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Schauspieler spy words
    {'main_word_id': 'prof_009', 'spy_word': 'Bühne', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_009', 'spy_word': 'Emotion', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_009', 'spy_word': 'Rolle', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_009', 'spy_word': 'Applaus', 'relationship_type': 'action', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_009', 'spy_word': 'Verwandlung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Astronaut spy words
    {'main_word_id': 'prof_010', 'spy_word': 'Weltall', 'relationship_type': 'location', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_010', 'spy_word': 'Schwerelosigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'prof_010', 'spy_word': 'Mut', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_010', 'spy_word': 'Pionier', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_010', 'spy_word': 'Grenze', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Entwickler spy words
    {'main_word_id': 'prof_011', 'spy_word': 'Code', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_011', 'spy_word': 'Kaffee', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_011', 'spy_word': 'Bug', 'relationship_type': 'component', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'prof_011', 'spy_word': 'Homeoffice', 'relationship_type': 'location', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'prof_011', 'spy_word': 'Innovation', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Designer spy words
    {'main_word_id': 'prof_012', 'spy_word': 'Ästhetik', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_012', 'spy_word': 'Inspiration', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_012', 'spy_word': 'Skizze', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_012', 'spy_word': 'Perfektionismus', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_012', 'spy_word': 'Minimalismus', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Journalist spy words
    {'main_word_id': 'prof_013', 'spy_word': 'Neugier', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_013', 'spy_word': 'Deadline', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_013', 'spy_word': 'Recherche', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_013', 'spy_word': 'Objektivität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_013', 'spy_word': 'Wahrheit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 5},

    // Architekt spy words
    {'main_word_id': 'prof_014', 'spy_word': 'Vision', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_014', 'spy_word': 'Bauplan', 'relationship_type': 'component', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_014', 'spy_word': 'Räume', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_014', 'spy_word': 'Nachhaltigkeit', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_014', 'spy_word': 'Gebäude', 'relationship_type': 'component', 'difficulty': 2, 'priority': 5},

    // Fotograf spy words
    {'main_word_id': 'prof_015', 'spy_word': 'Licht', 'relationship_type': 'component', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_015', 'spy_word': 'Moment', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_015', 'spy_word': 'Perspektive', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_015', 'spy_word': 'Erinnerung', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_015', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Übersetzer spy words
    {'main_word_id': 'prof_016', 'spy_word': 'Brücke', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_016', 'spy_word': 'Kulturen', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_016', 'spy_word': 'Nuancen', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'prof_016', 'spy_word': 'Verständnis', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_016', 'spy_word': 'Dolmetscher', 'relationship_type': 'person', 'difficulty': 2, 'priority': 5},

    // Berater spy words
    {'main_word_id': 'prof_017', 'spy_word': 'Expertise', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_017', 'spy_word': 'Lösung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_017', 'spy_word': 'Optimierung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 3},
    {'main_word_id': 'prof_017', 'spy_word': 'Effizienz', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_017', 'spy_word': 'Strategie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Trainer spy words
    {'main_word_id': 'prof_018', 'spy_word': 'Motivation', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_018', 'spy_word': 'Unterstützung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_018', 'spy_word': 'Fortschritt', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_018', 'spy_word': 'Geduld', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_018', 'spy_word': 'Transformation', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},

    // Therapeut spy words
    {'main_word_id': 'prof_019', 'spy_word': 'Empathie', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_019', 'spy_word': 'Heilung', 'relationship_type': 'action', 'difficulty': 2, 'priority': 2},
    {'main_word_id': 'prof_019', 'spy_word': 'Zuhören', 'relationship_type': 'action', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_019', 'spy_word': 'Vertrauen', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 4},
    {'main_word_id': 'prof_019', 'spy_word': 'Beziehung', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 5},

    // Influencer spy words
    {'main_word_id': 'prof_020', 'spy_word': 'Reichweite', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 1},
    {'main_word_id': 'prof_020', 'spy_word': 'Authentizität', 'relationship_type': 'attribute', 'difficulty': 3, 'priority': 2},
    {'main_word_id': 'prof_020', 'spy_word': 'Content', 'relationship_type': 'component', 'difficulty': 2, 'priority': 3},
    {'main_word_id': 'prof_020', 'spy_word': 'Trend', 'relationship_type': 'attribute', 'difficulty': 2, 'priority': 4},
    {'main_word_id': 'prof_020', 'spy_word': 'Inszenierung', 'relationship_type': 'action', 'difficulty': 3, 'priority': 5},
  ];
}
