import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/round_score_result.dart';

abstract class GameState extends Equatable {
  const GameState();
  
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameCreated extends GameState {
  final Game game;
  
  const GameCreated(this.game);
  
  @override
  List<Object> get props => [game];
}

class GameInProgress extends GameState {
  final Game game;
  
  const GameInProgress(this.game);
  
  @override
  List<Object> get props => [game];
}

class GameRoundCompleted extends GameState {
  final Game game;
  final int roundNumber;
  final List<RoundScoreResult>? scoreResults;
  
  const GameRoundCompleted({
    required this.game,
    required this.roundNumber,
    this.scoreResults,
  });
  
  @override
  List<Object?> get props => [game, roundNumber, scoreResults];
}

class GameCompleted extends GameState {
  final Game game;
  final List<String> winnerNames;
  final List<Player>? players;
  final Map<String, int>? finalScores;
  final String? winnerId;
  
  const GameCompleted({
    required this.game,
    required this.winnerNames,
    this.players,
    this.finalScores,
    this.winnerId,
  });
  
  @override
  List<Object?> get props => [game, winnerNames, players, finalScores, winnerId];
}

class GameError extends GameState {
  final String message;
  
  const GameError(this.message);
  
  @override
  List<Object> get props => [message];
}
