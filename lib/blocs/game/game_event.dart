import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class CreateGame extends GameEvent {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;

  const CreateGame({
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
  });

  @override
  List<Object> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
      ];
}

class LoadGame extends GameEvent {
  final String? id;

  const LoadGame({this.id});

  @override
  List<Object?> get props => [id];
}

class StartGame extends GameEvent {
  final String gameId;

  const StartGame({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

class StartRound extends GameEvent {
  final String gameId;
  final int roundNumber;

  const StartRound({
    required this.gameId,
    required this.roundNumber,
  });

  @override
  List<Object> get props => [gameId, roundNumber];
}

class CompleteRound extends GameEvent {
  final String gameId;
  final int roundNumber;

  const CompleteRound({
    required this.gameId,
    required this.roundNumber,
  });

  @override
  List<Object> get props => [gameId, roundNumber];
}

class CompleteGame extends GameEvent {
  final String gameId;

  const CompleteGame({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

class DeleteGame extends GameEvent {
  final String gameId;

  const DeleteGame({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

// New event for creating a game from a player group
class CreateGameFromGroup extends GameEvent {
  final List<String> playerNames;
  // final GameSettings settings; // For now, use default settings or fetch from a global config
  // For simplicity in this phase, we'll assume default game settings are used internally
  // or that GameSetupScreen might be shown briefly after this.

  const CreateGameFromGroup({required this.playerNames});

  @override
  List<Object> get props => [playerNames];
}

// New event for creating a game with selected categories
class CreateGameWithCategories extends GameEvent {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final List<String> selectedCategoryIds;

  const CreateGameWithCategories({
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
    required this.selectedCategoryIds,
  });

  @override
  List<Object> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
        selectedCategoryIds,
      ];
}

// New event for creating a game from group with selected categories
class CreateGameFromGroupWithCategories extends GameEvent {
  final List<String> playerNames;
  final List<String> selectedCategoryIds;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;

  const CreateGameFromGroupWithCategories({
    required this.playerNames,
    required this.selectedCategoryIds,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
  });

  @override
  List<Object> get props => [
        playerNames,
        selectedCategoryIds,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
      ];
}
