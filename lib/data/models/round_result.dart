import 'package:equatable/equatable.dart';

class RoundResult extends Equatable {
  final String id;
  final String roundId;
  final bool impostorsWon;
  final bool wordGuessed;
  final DateTime createdAt;

  const RoundResult({
    required this.id,
    required this.roundId,
    required this.impostorsWon,
    required this.wordGuessed,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        roundId,
        impostorsWon,
        wordGuessed,
        createdAt,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory RoundResult.fromMap(Map<String, dynamic> map) {
    return RoundResult(
      id: map['id'] as String,
      roundId: map['round_id'] as String,
      impostorsWon: (map['impostors_won'] as int) == 1,
      wordGuessed: (map['word_guessed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_id': roundId,
      'impostors_won': impostorsWon ? 1 : 0,
      'word_guessed': wordGuessed ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Kopieren mit neuen Werten
  RoundResult copyWith({
    String? id,
    String? roundId,
    bool? impostorsWon,
    bool? wordGuessed,
    DateTime? createdAt,
  }) {
    return RoundResult(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      impostorsWon: impostorsWon ?? this.impostorsWon,
      wordGuessed: wordGuessed ?? this.wordGuessed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'RoundResult(id: $id, roundId: $roundId, impostorsWon: $impostorsWon, '
        'wordGuessed: $wordGuessed, createdAt: $createdAt)';
  }
}
