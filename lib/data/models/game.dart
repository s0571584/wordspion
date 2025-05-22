import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String id;
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final String state;
  final int currentRound;
  final DateTime createdAt;
  
  const Game({
    required this.id,
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
    required this.state,
    required this.currentRound,
    required this.createdAt,
  });
  
  @override
  List<Object> get props => [
    id,
    playerCount,
    impostorCount,
    roundCount,
    timerDuration,
    impostorsKnowEachOther,
    state,
    currentRound,
    createdAt,
  ];
  
  // Factory-Methode zum Erstellen aus der Datenbank
  factory Game.fromMap(Map<String, dynamic> map) {
    print("=== Game.fromMap ====");
    print("Converting map to Game object:");
    print("map = $map");
    print("impostor_count in map = ${map['impostor_count']}");
    
    final game = Game(
      id: map['id'] as String,
      playerCount: map['player_count'] as int,
      impostorCount: map['impostor_count'] as int,
      roundCount: map['round_count'] as int,
      timerDuration: map['timer_duration'] as int,
      impostorsKnowEachOther: (map['impostors_know_each_other'] as int) == 1,
      state: map['state'] as String,
      currentRound: map['current_round'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
    
    print("Created game object: $game");
    print("impostorCount in Game object = ${game.impostorCount}");
    
    return game;
  }
  
  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player_count': playerCount,
      'impostor_count': impostorCount,
      'round_count': roundCount,
      'timer_duration': timerDuration,
      'impostors_know_each_other': impostorsKnowEachOther ? 1 : 0,
      'state': state,
      'current_round': currentRound,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
  
  // Kopieren mit neuen Werten
  Game copyWith({
    String? id,
    int? playerCount,
    int? impostorCount,
    int? roundCount,
    int? timerDuration,
    bool? impostorsKnowEachOther,
    String? state,
    int? currentRound,
    DateTime? createdAt,
  }) {
    return Game(
      id: id ?? this.id,
      playerCount: playerCount ?? this.playerCount,
      impostorCount: impostorCount ?? this.impostorCount,
      roundCount: roundCount ?? this.roundCount,
      timerDuration: timerDuration ?? this.timerDuration,
      impostorsKnowEachOther: impostorsKnowEachOther ?? this.impostorsKnowEachOther,
      state: state ?? this.state,
      currentRound: currentRound ?? this.currentRound,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'Game(id: $id, playerCount: $playerCount, impostorCount: $impostorCount, '
           'roundCount: $roundCount, timerDuration: $timerDuration, '
           'impostorsKnowEachOther: $impostorsKnowEachOther, state: $state, '
           'currentRound: $currentRound, createdAt: $createdAt)';
  }
}
