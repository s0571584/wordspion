import 'package:equatable/equatable.dart';

class WordGuess extends Equatable {
  final String id;
  final String roundId;
  final String playerId;
  final String guessedWord;
  final bool isCorrect;
  final DateTime createdAt;

  const WordGuess({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.guessedWord,
    required this.isCorrect,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        roundId,
        playerId,
        guessedWord,
        isCorrect,
        createdAt,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory WordGuess.fromMap(Map<String, dynamic> map) {
    return WordGuess(
      id: map['id'] as String,
      roundId: map['round_id'] as String,
      playerId: map['player_id'] as String,
      guessedWord: map['guessed_word'] as String,
      isCorrect: (map['is_correct'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Factory method for creating from JSON (Supabase data)
  factory WordGuess.fromJson(Map<String, dynamic> json) {
    return WordGuess(
      id: json['id'] as String,
      roundId: json['round_id'] as String,
      playerId: json['player_id'] as String,
      guessedWord: json['guessed_word'] as String,
      isCorrect: json['is_correct'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_id': roundId,
      'player_id': playerId,
      'guessed_word': guessedWord,
      'is_correct': isCorrect ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Kopieren mit neuen Werten
  WordGuess copyWith({
    String? id,
    String? roundId,
    String? playerId,
    String? guessedWord,
    bool? isCorrect,
    DateTime? createdAt,
  }) {
    return WordGuess(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      playerId: playerId ?? this.playerId,
      guessedWord: guessedWord ?? this.guessedWord,
      isCorrect: isCorrect ?? this.isCorrect,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'WordGuess(id: $id, roundId: $roundId, playerId: $playerId, '
        'guessedWord: $guessedWord, isCorrect: $isCorrect, createdAt: $createdAt)';
  }
}
