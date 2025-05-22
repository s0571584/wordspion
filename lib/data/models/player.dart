import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String gameId;
  final String name;
  final int score;
  final bool isActive;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.gameId,
    required this.name,
    required this.score,
    required this.isActive,
    required this.createdAt,
  });

  // Convenience constructor for creating new players
  factory Player.create({
    required String id,
    required String name,
    String gameId = '',
    int score = 0,
    bool isActive = true,
  }) {
    return Player(
      id: id,
      gameId: gameId,
      name: name,
      score: score,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [
        id,
        gameId,
        name,
        score,
        isActive,
        createdAt,
      ];

  // Factory-Methode zum Erstellen aus der Datenbank
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      gameId: map['game_id'] as String,
      name: map['name'] as String,
      score: map['score'] as int,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'name': name,
      'score': score,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Kopieren mit neuen Werten
  Player copyWith({
    String? id,
    String? gameId,
    String? name,
    int? score,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      name: name ?? this.name,
      score: score ?? this.score,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Add points to player
  Player addPoints(int points) {
    return copyWith(score: score + points);
  }

  @override
  String toString() {
    return 'Player(id: $id, gameId: $gameId, name: $name, score: $score, isActive: $isActive, createdAt: $createdAt)';
  }
}
