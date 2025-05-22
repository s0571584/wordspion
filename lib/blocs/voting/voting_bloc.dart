import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/voting/voting_event.dart';
import 'package:wortspion/blocs/voting/voting_state.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/vote.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/data/repositories/round_repository.dart';

class VotingBloc extends Bloc<VotingEvent, VotingState> {
  final GameRepository gameRepository;
  final RoundRepository roundRepository;

  VotingBloc({
    required this.gameRepository,
    required this.roundRepository,
  }) : super(VotingInitial()) {
    on<InitVoting>(_onInitVoting);
    on<CastVote>(_onCastVote);
    on<SubmitVotes>(_onSubmitVotes);
    on<TallyVotes>(_onTallyVotes);
    on<ClearVotes>(_onClearVotes);
  }

  Future<void> _onInitVoting(
    InitVoting event,
    Emitter<VotingState> emit,
  ) async {
    emit(VotingLoading());
    try {
      // Initialize voting for a round
      emit(VotingLoaded(
        votingResults: const [],
        roundId: event.roundId,
      ));
    } catch (e) {
      emit(VotingError(message: 'Failed to initialize voting: $e'));
    }
  }

  Future<void> _onCastVote(
    CastVote event,
    Emitter<VotingState> emit,
  ) async {
    try {
      // Create a new vote
      final vote = Vote.create(
        voterId: event.voterId,
        targetId: event.targetId,
        roundId: event.roundId,
      );

      // In a real implementation, save the vote to the repository
      // For now, just emit a success state
      emit(VoteCasted(
        vote: vote,
        allVotes: const [], // Replace with actual votes from the repository in a real implementation
      ));
    } catch (e) {
      emit(VotingError(message: 'Failed to cast vote: $e'));
    }
  }

  Future<void> _onSubmitVotes(
    SubmitVotes event,
    Emitter<VotingState> emit,
  ) async {
    print("[VotingBloc] _onSubmitVotes called. Number of votes: ${event.votes.length}");
    event.votes.asMap().forEach((index, vote) {
      print("[VotingBloc] Vote $index: voterId=${vote.voterId}, targetId=${vote.targetId}, roundId=${vote.roundId}");
    });

    emit(VotingLoading());
    try {
      final votes = event.votes;
      final players = event.players;
      final Map<String, Player> playerMap = {for (var player in players) player.id: player};
      print("[VotingBloc] PlayerMap contents: ${playerMap.entries.map((e) => 'ID=${e.key}, Name=${e.value.name}').toList()}");

      final Map<String, int> voteCounts = {};
      for (final vote in votes) {
        voteCounts[vote.targetId] = (voteCounts[vote.targetId] ?? 0) + 1;
      }
      print("[VotingBloc] Vote counts: $voteCounts");

      final results = voteCounts.entries.map((entry) {
        final Player? votedPlayer = playerMap[entry.key];
        return VotingResult(
          playerId: entry.key,
          playerName: votedPlayer?.name ?? 'Unbekannt',
          voteCount: entry.value,
        );
      }).toList();
      results.sort((a, b) => b.voteCount.compareTo(a.voteCount));
      print("[VotingBloc] Sorted results: ${results.map((r) => '${r.playerName}:${r.voteCount}').toList()}");

      Player? mostVotedPlayerObject;
      bool impostorsWonCalculation = false; // Default winner logic

      if (results.isNotEmpty) {
        final firstResultPlayerId = results.first.playerId;
        mostVotedPlayerObject = playerMap[firstResultPlayerId];

        if (mostVotedPlayerObject != null) {
          print(
              "[VotingBloc] Most voted player determined: ${mostVotedPlayerObject.name} (ID: ${mostVotedPlayerObject.id}) with ${results.first.voteCount} votes.");
          // Simple win condition: if most voted is an impostor, civilians win (impostorsWon=false)
          // This needs PlayerRoleType which isn't available here directly without more state/repo calls.
          // For now, let's assume a placeholder or pass this logic to RoundBloc via CompleteRound event.
          // The current structure in VotingScreen tries to get roles from RoundBloc.state.
          // So, VotingBloc will just pass along the determined player.
          // The actual determination of `impostorsWon` will be in VotingScreen listener for now.
        } else {
          print("[VotingBloc] Most voted player ID $firstResultPlayerId not found in playerMap. This is unexpected.");
        }
      } else {
        print("[VotingBloc] No results, so mostVotedPlayerObject is null.");
        // If no one is voted, perhaps impostors win by default if not caught?
        // Or game continues? For now, let's say this means impostors were not caught via voting.
      }

      // The actual `impostorsWon` will be determined in VotingScreen's listener for VotingTallied,
      // as it has access to RoundBloc.state for roles.
      // Here, we just prepare the voting data.

      final roundIdForEmit = votes.isNotEmpty ? votes.first.roundId : (state is VotingLoaded ? (state as VotingLoaded).roundId : '');
      // If state is not VotingLoaded (e.g. VotingInitial), and votes is empty, roundId could be problematic.
      // Best to get roundId from the event if possible, or an InitVoting earlier.
      // Assuming InitVoting always sets a roundId that VotingLoaded carries.
      // For SubmitVotes, the votes themselves should have the roundId.
      String currentRoundId = event.votes.isNotEmpty ? event.votes.first.roundId : '';
      if (currentRoundId.isEmpty && state is VotingLoaded) {
        currentRoundId = (state as VotingLoaded).roundId;
      } else if (currentRoundId.isEmpty && state is VotingTallied) {
        // If re-submitting after a tally
        currentRoundId = (state as VotingTallied).roundId;
      }
      // If currentRoundId is still empty, this is an issue.

      print("[VotingBloc] Emitting VotingTallied with mostVotedPlayer: ${mostVotedPlayerObject?.name}");
      emit(VotingTallied(
        votingResults: results,
        mostVotedPlayer: mostVotedPlayerObject,
        roundId: currentRoundId,
        impostorsWon: false, // Placeholder - VotingScreen will calculate this
        wordGuessed: false, // Placeholder - VotingScreen will set this
      ));
    } catch (e) {
      print("[VotingBloc] Error in _onSubmitVotes: $e");
      emit(VotingError(message: 'Failed to submit votes: $e'));
    }
  }

  Future<void> _onTallyVotes(
    TallyVotes event,
    Emitter<VotingState> emit,
  ) async {
    // This could be used to count votes without submitting final results
    // Implementation similar to _onSubmitVotes but without completing the voting process
  }

  Future<void> _onClearVotes(
    ClearVotes event,
    Emitter<VotingState> emit,
  ) async {
    emit(VotingLoading());
    try {
      // Clear votes for a round
      emit(VotingLoaded(
        votingResults: const [],
        roundId: event.roundId,
      ));
    } catch (e) {
      emit(VotingError(message: 'Failed to clear votes: $e'));
    }
  }
}
