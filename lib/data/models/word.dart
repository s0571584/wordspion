import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final String id;
  final String categoryId;
  final String text;
  final int difficulty;

  const Word({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.difficulty,
  });

  @override
  List<Object> get props => [
        id,
        categoryId,
        text,
        difficulty,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      text: map['text'] as String,
      difficulty: map['difficulty'] as int,
    );
  }

  // Factory method for creating from JSON (Supabase data)
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      text: json['text'] as String,
      difficulty: json['difficulty'] as int,
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'text': text,
      'difficulty': difficulty,
    };
  }

  // Kopieren mit neuen Werten
  Word copyWith({
    String? id,
    String? categoryId,
    String? text,
    int? difficulty,
  }) {
    return Word(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  String toString() {
    return 'Word(id: $id, categoryId: $categoryId, text: $text, difficulty: $difficulty)';
  }
}
