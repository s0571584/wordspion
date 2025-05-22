import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/vote.dart';

abstract class VotingState extends Equatable {
  const VotingState();

  @override
  List<Object?> get props => [];
}

class VotingInitial extends VotingState {}

class VotingLoading extends VotingState {}

class VotingLoaded extends VotingState {
  final List<VotingResult> votingResults;
  final Player? mostVotedPlayer;
  final String roundId;

  const VotingLoaded({
    required this.votingResults,
    this.mostVotedPlayer,
    required this.roundId,
  });

  @override
  List<Object?> get props => [votingResults, mostVotedPlayer, roundId];
}

class VotingError extends VotingState {
  final String message;

  const VotingError({required this.message});

  @override
  List<Object> get props => [message];
}

class VoteCasted extends VotingState {
  final Vote vote;
  final List<Vote> allVotes;

  const VoteCasted({
    required this.vote,
    required this.allVotes,
  });

  @override
  List<Object> get props => [vote, allVotes];
}

class VoteSubmitted extends VotingState {
  final List<Vote> votes;

  const VoteSubmitted({required this.votes});

  @override
  List<Object> get props => [votes];
}

class PlayerVoteStatus extends VotingState {
  final bool hasVoted;
  final String playerId;

  const PlayerVoteStatus({
    required this.hasVoted,
    required this.playerId,
  });

  @override
  List<Object> get props => [hasVoted, playerId];
}

class VotesCount extends VotingState {
  final Map<String, int> voteCounts;
  final String? mostVotedPlayerId;
  final bool isTied;

  const VotesCount({
    required this.voteCounts,
    this.mostVotedPlayerId,
    required this.isTied,
  });

  @override
  List<Object?> get props => [voteCounts, mostVotedPlayerId, isTied];
}

class VotingResult {
  final String playerId;
  final String playerName;
  final int voteCount;

  const VotingResult({
    required this.playerId,
    required this.playerName,
    required this.voteCount,
  });
}

class VotingTallied extends VotingState {
  final List<VotingResult> votingResults;
  final Player? mostVotedPlayer;
  final String roundId;
  final bool impostorsWon;
  final bool wordGuessed;

  const VotingTallied({
    required this.votingResults,
    this.mostVotedPlayer,
    required this.roundId,
    required this.impostorsWon,
    required this.wordGuessed,
  });

  @override
  List<Object?> get props => [votingResults, mostVotedPlayer, roundId, impostorsWon, wordGuessed];
}
