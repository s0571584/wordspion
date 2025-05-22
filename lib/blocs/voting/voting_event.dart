import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/vote.dart';
import 'package:wortspion/data/models/player.dart';

abstract class VotingEvent extends Equatable {
  const VotingEvent();

  @override
  List<Object?> get props => [];
}

class InitVoting extends VotingEvent {
  final String roundId;

  const InitVoting({required this.roundId});

  @override
  List<Object> get props => [roundId];
}

class CastVote extends VotingEvent {
  final String voterId;
  final String targetId;
  final String roundId;

  const CastVote({
    required this.voterId,
    required this.targetId,
    required this.roundId,
  });

  @override
  List<Object> get props => [voterId, targetId, roundId];
}

class SubmitVotes extends VotingEvent {
  final List<Vote> votes;
  final List<Player> players;

  const SubmitVotes(this.votes, this.players);

  @override
  List<Object> get props => [votes, players];
}

class TallyVotes extends VotingEvent {
  final String roundId;

  const TallyVotes({required this.roundId});

  @override
  List<Object> get props => [roundId];
}

class ClearVotes extends VotingEvent {
  final String roundId;

  const ClearVotes({required this.roundId});

  @override
  List<Object> get props => [roundId];
}

class CheckPlayerVoted extends VotingEvent {
  final String roundId;
  final String playerId;

  const CheckPlayerVoted({
    required this.roundId,
    required this.playerId,
  });

  @override
  List<Object> get props => [roundId, playerId];
}

class CountVotes extends VotingEvent {
  final String roundId;

  const CountVotes({required this.roundId});

  @override
  List<Object> get props => [roundId];
}
