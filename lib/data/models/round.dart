import 'package:equatable/equatable.dart';

class Round extends Equatable {
  final String id;
  final String gameId;
  final int roundNumber;
  final String mainWordId;
  final String decoyWordId;
  final String categoryId;
  final bool isCompleted;
  final DateTime createdAt;

  const Round({
    required this.id,
    required this.gameId,
    required this.roundNumber,
    required this.mainWordId,
    required this.decoyWordId,
    required this.categoryId,
    required this.isCompleted,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        gameId,
        roundNumber,
        mainWordId,
        decoyWordId,
        categoryId,
        isCompleted,
        createdAt,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory Round.fromMap(Map<String, dynamic> map) {
    return Round(
      id: map['id'] as String,
      gameId: map['game_id'] as String,
      roundNumber: map['round_number'] as int,
      mainWordId: map['main_word_id'] as String,
      decoyWordId: map['decoy_word_id'] as String,
      categoryId: map['category_id'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'round_number': roundNumber,
      'main_word_id': mainWordId,
      'decoy_word_id': decoyWordId,
      'category_id': categoryId,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Kopieren mit neuen Werten
  Round copyWith({
    String? id,
    String? gameId,
    int? roundNumber,
    String? mainWordId,
    String? decoyWordId,
    String? categoryId,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Round(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      roundNumber: roundNumber ?? this.roundNumber,
      mainWordId: mainWordId ?? this.mainWordId,
      decoyWordId: decoyWordId ?? this.decoyWordId,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Round(id: $id, gameId: $gameId, roundNumber: $roundNumber, '
        'mainWordId: $mainWordId, decoyWordId: $decoyWordId, '
        'categoryId: $categoryId, isCompleted: $isCompleted, '
        'createdAt: $createdAt)';
  }
}
