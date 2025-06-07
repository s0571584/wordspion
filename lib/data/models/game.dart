import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String id;
  final int playerCount;
  final int impostorCount;
  final int saboteurCount; // 🆕 NEW: Added saboteur count
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final String state;
  final int currentRound;
  final DateTime createdAt;
  final List<String>? selectedCategoryIds; // NEW: Store selected categories
  
  const Game({
    required this.id,
    required this.playerCount,
    required this.impostorCount,
    this.saboteurCount = 0, // 🆕 NEW: Default to 0 for backward compatibility
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
    required this.state,
    required this.currentRound,
    required this.createdAt,
    this.selectedCategoryIds, // NEW: Add to constructor
  });
  
  @override
  List<Object?> get props => [
    id,
    playerCount,
    impostorCount,
    saboteurCount, // 🆕 NEW: Include in equality check
    roundCount,
    timerDuration,
    impostorsKnowEachOther,
    state,
    currentRound,
    createdAt,
    selectedCategoryIds, // NEW: Include in equality check
  ];
  
  // Factory-Methode zum Erstellen aus der Datenbank
  factory Game.fromMap(Map<String, dynamic> map) {
    
    final game = Game(
      id: map['id'] as String,
      playerCount: map['player_count'] as int,
      impostorCount: map['impostor_count'] as int,
      saboteurCount: (map['saboteur_count'] as int?) ?? 0, // 🆕 NEW: Handle null for backward compatibility
      roundCount: map['round_count'] as int,
      timerDuration: map['timer_duration'] as int,
      impostorsKnowEachOther: (map['impostors_know_each_other'] as int) == 1,
      state: map['state'] as String,
      currentRound: map['current_round'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      selectedCategoryIds: map['selected_category_ids'] != null && (map['selected_category_ids'] as String).isNotEmpty
          ? (map['selected_category_ids'] as String).split(',')
          : null, // NEW: Parse comma-separated string back to list, handle empty strings
    );
    
    
    return game;
  }
  
  // Methode zum Konvertieren in Map
  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'player_count': playerCount,
      'impostor_count': impostorCount,
      'saboteur_count': saboteurCount, // 🆕 NEW: Include in database map
      'round_count': roundCount,
      'timer_duration': timerDuration,
      'impostors_know_each_other': impostorsKnowEachOther ? 1 : 0,
      'state': state,
      'current_round': currentRound,
      'created_at': createdAt.millisecondsSinceEpoch,
      'selected_category_ids': selectedCategoryIds?.join(','), // NEW: Store as comma-separated string
    };
    
    
    return map;
  }
  
  // Kopieren mit neuen Werten
  Game copyWith({
    String? id,
    int? playerCount,
    int? impostorCount,
    int? saboteurCount, // 🆕 NEW: Add saboteur count parameter
    int? roundCount,
    int? timerDuration,
    bool? impostorsKnowEachOther,
    String? state,
    int? currentRound,
    DateTime? createdAt,
    List<String>? selectedCategoryIds, // NEW: Add selected categories parameter
  }) {
    return Game(
      id: id ?? this.id,
      playerCount: playerCount ?? this.playerCount,
      impostorCount: impostorCount ?? this.impostorCount,
      saboteurCount: saboteurCount ?? this.saboteurCount, // 🆕 NEW: Use provided or current value
      roundCount: roundCount ?? this.roundCount,
      timerDuration: timerDuration ?? this.timerDuration,
      impostorsKnowEachOther: impostorsKnowEachOther ?? this.impostorsKnowEachOther,
      state: state ?? this.state,
      currentRound: currentRound ?? this.currentRound,
      createdAt: createdAt ?? this.createdAt,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds, // NEW: Use provided or current value
    );
  }
  
  @override
  String toString() {
    return 'Game(id: $id, playerCount: $playerCount, impostorCount: $impostorCount, '
           'saboteurCount: $saboteurCount, ' // 🆕 NEW: Include in string representation
           'roundCount: $roundCount, timerDuration: $timerDuration, '
           'impostorsKnowEachOther: $impostorsKnowEachOther, state: $state, '
           'currentRound: $currentRound, createdAt: $createdAt, '
           'selectedCategoryIds: $selectedCategoryIds)'; // NEW: Include in string representation
  }
}
