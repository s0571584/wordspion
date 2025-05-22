import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/player.dart';

abstract class RoundEvent extends Equatable {
  const RoundEvent();

  @override
  List<Object?> get props => [];
}

class CreateRound extends RoundEvent {
  final String gameId;
  final int roundNumber;
  final List<String> categoryIds;
  final int difficulty;

  const CreateRound({
    required this.gameId,
    required this.roundNumber,
    required this.categoryIds,
    this.difficulty = 0,
  });

  @override
  List<Object> get props => [gameId, roundNumber, categoryIds, difficulty];
}

class LoadRound extends RoundEvent {
  final String gameId;
  final String? roundId;

  const LoadRound({
    required this.gameId,
    this.roundId,
  });

  @override
  List<Object?> get props => [gameId, roundId];
}

class StartRound extends RoundEvent {
  final String gameId;
  final int roundNumber;
  final int playerCount;
  final int impostorCount;

  const StartRound({
    required this.gameId,
    required this.roundNumber,
    required this.playerCount,
    required this.impostorCount,
  });

  @override
  List<Object> get props => [gameId, roundNumber, playerCount, impostorCount];
}

class EndRound extends RoundEvent {
  final String roundId;
  final bool impostorsWon;
  final bool wordGuessed;

  const EndRound({
    required this.roundId,
    required this.impostorsWon,
    required this.wordGuessed,
  });

  @override
  List<Object> get props => [roundId, impostorsWon, wordGuessed];
}

class PauseRound extends RoundEvent {
  final String roundId;
  final int timeRemaining;

  const PauseRound({
    required this.roundId,
    required this.timeRemaining,
  });

  @override
  List<Object> get props => [roundId, timeRemaining];
}

class ResumeRound extends RoundEvent {
  final String roundId;

  const ResumeRound({required this.roundId});

  @override
  List<Object> get props => [roundId];
}

class LoadRoundStatus extends RoundEvent {
  final String roundId;

  const LoadRoundStatus({required this.roundId});

  @override
  List<Object> get props => [roundId];
}

class AssignRoles extends RoundEvent {
  final String roundId;
  final List<Player> players;
  final int impostorCount;

  const AssignRoles({
    required this.roundId,
    required this.players,
    required this.impostorCount,
  });

  @override
  List<Object> get props => [roundId, players, impostorCount];
}

class GuessWord extends RoundEvent {
  final String roundId;
  final String playerId;
  final String guessedWord;

  const GuessWord({
    required this.roundId,
    required this.playerId,
    required this.guessedWord,
  });

  @override
  List<Object> get props => [roundId, playerId, guessedWord];
}

class GetPlayerRole extends RoundEvent {
  final String roundId;
  final String playerId;

  const GetPlayerRole({
    required this.roundId,
    required this.playerId,
  });

  @override
  List<Object> get props => [roundId, playerId];
}

class GuessMainWord extends RoundEvent {
  final String roundId;
  final String playerId;
  final String guessedWord;
  final String mainWord;

  const GuessMainWord({
    required this.roundId,
    required this.playerId,
    required this.guessedWord,
    required this.mainWord,
  });

  @override
  List<Object> get props => [roundId, playerId, guessedWord, mainWord];
}

class CompleteRound extends RoundEvent {
  final String roundId;
  final bool impostorsWon;
  final bool wordGuessed;
  final List<String>? accusedPlayerIds;
  final String? wordGuesserId;
  final bool skipToResults;

  const CompleteRound({
    required this.roundId,
    required this.impostorsWon,
    required this.wordGuessed,
    this.accusedPlayerIds,
    this.wordGuesserId,
    this.skipToResults = false,
  });

  @override
  List<Object?> get props => [roundId, impostorsWon, wordGuessed, accusedPlayerIds, wordGuesserId, skipToResults];
}
