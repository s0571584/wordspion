import 'package:equatable/equatable.dart';

abstract class MultiplayerGameEvent extends Equatable {
  const MultiplayerGameEvent();

  @override
  List<Object?> get props => [];
}

// Room Management Events
class CreateGameRoom extends MultiplayerGameEvent {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final List<String> selectedCategories;

  const CreateGameRoom({
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    this.impostorsKnowEachOther = false,
    this.selectedCategories = const ['entertainment', 'sports', 'animals', 'food'],
  });

  @override
  List<Object?> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
        selectedCategories,
      ];
}

class JoinGameRoom extends MultiplayerGameEvent {
  final String roomCode;
  final String playerName;

  const JoinGameRoom({
    required this.roomCode,
    required this.playerName,
  });

  @override
  List<Object> get props => [roomCode, playerName];
}

class LeaveGameRoom extends MultiplayerGameEvent {}

class UpdatePlayerReadyStatus extends MultiplayerGameEvent {
  final bool isReady;

  const UpdatePlayerReadyStatus(this.isReady);

  @override
  List<Object> get props => [isReady];
}

class StartGame extends MultiplayerGameEvent {}

// Game Flow Events
class StartRound extends MultiplayerGameEvent {
  final int roundNumber;

  const StartRound(this.roundNumber);

  @override
  List<Object> get props => [roundNumber];
}

class MarkRoleAsViewed extends MultiplayerGameEvent {}

class StartDiscussion extends MultiplayerGameEvent {}

class StartVoting extends MultiplayerGameEvent {}

class SubmitVote extends MultiplayerGameEvent {
  final String targetPlayerId;

  const SubmitVote(this.targetPlayerId);

  @override
  List<Object> get props => [targetPlayerId];
}

class SubmitWordGuess extends MultiplayerGameEvent {
  final String guessedWord;

  const SubmitWordGuess(this.guessedWord);

  @override
  List<Object> get props => [guessedWord];
}

class CompleteRound extends MultiplayerGameEvent {}

class CompleteGame extends MultiplayerGameEvent {}

// Real-time Events
class RoomUpdated extends MultiplayerGameEvent {
  final dynamic roomData;

  const RoomUpdated(this.roomData);

  @override
  List<Object?> get props => [roomData];
}

class PlayersUpdated extends MultiplayerGameEvent {
  final List<dynamic> playersData;

  const PlayersUpdated(this.playersData);

  @override
  List<Object> get props => [playersData];
}

class RoundUpdated extends MultiplayerGameEvent {
  final dynamic roundData;

  const RoundUpdated(this.roundData);

  @override
  List<Object?> get props => [roundData];
}

class GameEventReceived extends MultiplayerGameEvent {
  final String eventType;
  final Map<String, dynamic> eventData;

  const GameEventReceived({
    required this.eventType,
    required this.eventData,
  });

  @override
  List<Object> get props => [eventType, eventData];
}

// Utility Events
class SendHeartbeat extends MultiplayerGameEvent {}

class LoadRoom extends MultiplayerGameEvent {
  final String roomId;

  const LoadRoom(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class ResetGameState extends MultiplayerGameEvent {}