import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/player_role.dart';
import 'package:wortspion/data/models/round.dart';
import 'package:wortspion/data/models/round_result.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/data/models/word.dart';
import 'package:wortspion/data/models/word_guess.dart';

abstract class RoundState extends Equatable {
  const RoundState();

  @override
  List<Object?> get props => [];
}

class RoundInitial extends RoundState {}

class RoundLoading extends RoundState {}

class RoundStarted extends RoundState {
  final String roundId;
  final int roundNumber;
  final List<Player> players;
  final String categoryName;
  final Map<String, PlayerRoleType> playerRoles;
  final Map<String, String> playerWords;

  const RoundStarted({
    required this.roundId,
    required this.roundNumber,
    required this.players,
    required this.categoryName,
    required this.playerRoles,
    required this.playerWords,
  });

  @override
  List<Object> get props => [
        roundId,
        roundNumber,
        players,
        categoryName,
        playerRoles,
        playerWords,
      ];

  PlayerRoleType getRoleForPlayer(String playerId) {
    return playerRoles[playerId] ?? PlayerRoleType.civilian;
  }

  String getWordForPlayer(String playerId) {
    return playerWords[playerId] ?? 'Unknown';
  }
}

class RoundComplete extends RoundState {
  final String roundId;
  final List<PlayerRoleInfo> playerRoles;
  final String secretWord;
  final bool impostorsWon;
  final bool wordGuessed;
  final List<RoundScoreResult> scoreResults;
  final int roundNumber;
  final int totalRounds;

  const RoundComplete({
    required this.roundId,
    required this.playerRoles,
    required this.secretWord,
    required this.impostorsWon,
    required this.wordGuessed,
    required this.scoreResults,
    required this.roundNumber,
    required this.totalRounds,
  });

  @override
  List<Object> get props => [
        roundId,
        playerRoles,
        secretWord,
        impostorsWon,
        wordGuessed,
        scoreResults,
        roundNumber,
        totalRounds,
      ];
}

class RoundPaused extends RoundState {
  final String roundId;
  final int timeRemaining;

  const RoundPaused({
    required this.roundId,
    required this.timeRemaining,
  });

  @override
  List<Object> get props => [roundId, timeRemaining];
}

class RoundError extends RoundState {
  final String message;

  const RoundError({required this.message});

  @override
  List<Object> get props => [message];
}

class PlayerRoleInfo {
  final String playerId;
  final String playerName;
  final String roleName;
  final bool isImpostor;

  const PlayerRoleInfo({
    required this.playerId,
    required this.playerName,
    required this.roleName,
    required this.isImpostor,
  });
}

class RoundCreated extends RoundState {
  final Round round;
  final Word mainWord;
  final Word decoyWord;

  const RoundCreated({
    required this.round,
    required this.mainWord,
    required this.decoyWord,
  });

  @override
  List<Object> get props => [round, mainWord, decoyWord];
}

class RoundLoaded extends RoundState {
  final Round round;
  final Word mainWord;
  final Word decoyWord;
  final String categoryName;

  const RoundLoaded({
    required this.round,
    required this.mainWord,
    required this.decoyWord,
    required this.categoryName,
  });

  @override
  List<Object> get props => [round, mainWord, decoyWord, categoryName];
}

class RolesAssigned extends RoundState {
  final Round round;
  final List<PlayerRole> roles;
  final Word mainWord;
  final Word decoyWord;
  final List<String> impostorIds;
  final bool impostorsKnowEachOther;

  const RolesAssigned({
    required this.round,
    required this.roles,
    required this.mainWord,
    required this.decoyWord,
    this.impostorIds = const [],
    this.impostorsKnowEachOther = false,
  });

  @override
  List<Object> get props => [
        round,
        roles,
        mainWord,
        decoyWord,
        impostorIds,
        impostorsKnowEachOther,
      ];
}

class PlayerRoleLoaded extends RoundState {
  final PlayerRole role;
  final Word word;

  const PlayerRoleLoaded({
    required this.role,
    required this.word,
  });

  @override
  List<Object> get props => [role, word];
}

class WordGuessed extends RoundState {
  final WordGuess wordGuess;
  final Round round;

  const WordGuessed({
    required this.wordGuess,
    required this.round,
  });

  @override
  List<Object> get props => [wordGuess, round];
}

class RoundCompleted extends RoundState {
  final Round round;
  final RoundResult result;
  final Word mainWord;
  final Word decoyWord;

  const RoundCompleted({
    required this.round,
    required this.result,
    required this.mainWord,
    required this.decoyWord,
  });

  @override
  List<Object> get props => [round, result, mainWord, decoyWord];
}
