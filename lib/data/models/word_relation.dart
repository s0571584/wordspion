import 'package:equatable/equatable.dart';

class WordRelation extends Equatable {
  final String wordId1;
  final String wordId2;
  final double similarity;

  const WordRelation({
    required this.wordId1,
    required this.wordId2,
    required this.similarity,
  });

  @override
  List<Object> get props => [
        wordId1,
        wordId2,
        similarity,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory WordRelation.fromMap(Map<String, dynamic> map) {
    return WordRelation(
      wordId1: map['word_id_1'] as String,
      wordId2: map['word_id_2'] as String,
      similarity: (map['similarity'] as num).toDouble(),
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'word_id_1': wordId1,
      'word_id_2': wordId2,
      'similarity': similarity,
    };
  }

  // Kopieren mit neuen Werten
  WordRelation copyWith({
    String? wordId1,
    String? wordId2,
    double? similarity,
  }) {
    return WordRelation(
      wordId1: wordId1 ?? this.wordId1,
      wordId2: wordId2 ?? this.wordId2,
      similarity: similarity ?? this.similarity,
    );
  }

  @override
  String toString() {
    return 'WordRelation(wordId1: $wordId1, wordId2: $wordId2, similarity: $similarity)';
  }
}
