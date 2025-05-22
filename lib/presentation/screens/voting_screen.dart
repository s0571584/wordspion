import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/voting/voting_bloc.dart';
import 'package:wortspion/blocs/voting/voting_event.dart';
import 'package:wortspion/blocs/voting/voting_state.dart';
import 'package:wortspion/blocs/player/player_bloc.dart';
import 'package:wortspion/blocs/player/player_event.dart';
import 'package:wortspion/blocs/player/player_state.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/vote.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/blocs/round/round_bloc.dart';
import 'package:wortspion/blocs/round/round_event.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/data/models/player_role.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/core/utils/round_results_state.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/presentation/screens/round_results_screen.dart';

@RoutePage()
class VotingScreen extends StatefulWidget {
  final String roundId;
  final String gameId;
  final RoundBloc roundBloc;

  const VotingScreen({
    super.key,
    required this.roundId,
    required this.gameId,
    required this.roundBloc,
  });

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  int _currentVoterIndex = 0;
  Player? _selectedPlayer;
  List<Player> _players = [];
  final List<Vote> _votes = [];
  bool _wordGuessed = false;
  String? _wordGuesserId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<PlayerBloc>()..add(LoadPlayers(gameId: widget.gameId)),
        ),
        BlocProvider.value(
          value: widget.roundBloc,
        ),
        BlocProvider(
          create: (context) => sl<VotingBloc>()..add(InitVoting(roundId: widget.roundId)),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<VotingBloc, VotingState>(
            listener: (context, votingState) {
              print("[VotingScreen] VotingBloc listener received state: ${votingState.runtimeType}");
              if (votingState is VotingTallied) {
                print("[VotingScreen] VotingTallied received: mostVotedPlayer: ${votingState.mostVotedPlayer?.name}");

                bool finalImpostorsWon = votingState.impostorsWon;
                final roundBlocCurrentState = widget.roundBloc.state;

                // Collect accused player IDs (those who were voted out)
                List<String> accusedPlayerIds = [];
                if (votingState.mostVotedPlayer != null) {
                  accusedPlayerIds.add(votingState.mostVotedPlayer!.id);

                  // Determine if impostor was voted out
                  bool impostorWasVotedOut = false;
                  if (roundBlocCurrentState is RoundStarted) {
                    final mostVotedPlayerRole = roundBlocCurrentState.playerRoles[votingState.mostVotedPlayer!.id];
                    if (mostVotedPlayerRole == PlayerRoleType.impostor) {
                      impostorWasVotedOut = true;
                    }
                  }
                  finalImpostorsWon = !impostorWasVotedOut;
                  if (votingState.votingResults.isEmpty) {
                    finalImpostorsWon = true;
                  }
                } else {
                  finalImpostorsWon = false;
                }

                print("[VotingScreen] Dispatching CompleteRound to RoundBloc. ImpostorsWon: $finalImpostorsWon");
                widget.roundBloc.add(CompleteRound(
                  roundId: votingState.roundId,
                  impostorsWon: finalImpostorsWon,
                  wordGuessed: _wordGuessed,
                  accusedPlayerIds: accusedPlayerIds,
                  wordGuesserId: _wordGuesserId,
                ));
              } else if (votingState is VotingError) {
                print("[VotingScreen] VotingError: ${votingState.message}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voting Error: ${votingState.message}')),
                );
              } else if (votingState is VotingLoaded) {
                print("[VotingScreen] VotingLoaded (initial). UI should build. Players: ${_players.length}");
              }
            },
          ),
          BlocListener<RoundBloc, RoundState>(
            bloc: widget.roundBloc,
            listener: (context, roundState) {
              print("[VotingScreen] RoundBloc listener received state: ${roundState.runtimeType}");
              if (roundState is RoundComplete) {
                print("[VotingScreen] RoundComplete: Navigating to RoundResults screen...");

                // Store round results in state manager
                RoundResultsState().setRoundResults(
                  gameId: widget.gameId,
                  roundNumber: roundState.roundNumber,
                  totalRounds: roundState.totalRounds,
                  scoreResults: roundState.scoreResults,
                  playerRoles: roundState.playerRoles,
                  secretWord: roundState.secretWord,
                  impostorsWon: roundState.impostorsWon,
                  wordGuessed: roundState.wordGuessed,
                );

                // Navigate to new round results screen
                context.router.replace(
                  RoundResultsRoute(
                    gameId: widget.gameId,
                    roundNumber: roundState.roundNumber,
                    totalRounds: roundState.totalRounds,
                    scoreResults: roundState.scoreResults,
                    playerRoles: roundState.playerRoles,
                    secretWord: roundState.secretWord,
                    impostorsWon: roundState.impostorsWon,
                    wordGuessed: roundState.wordGuessed,
                  ),
                );
              } else if (roundState is RoundError) {
                print("[VotingScreen] RoundError: ${roundState.message}");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Round Error: ${roundState.message}')),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Abstimmung'),
            automaticallyImplyLeading: false,
          ),
          body: BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, playerState) {
              print("[VotingScreen] PlayerBloc state: ${playerState.runtimeType}");
              if (playerState is PlayersLoaded || playerState is PlayersRegistered) {
                _players = playerState is PlayersLoaded ? playerState.players : (playerState as PlayersRegistered).players;
                print("[VotingScreen] Players loaded: ${_players.length} players.");
                _players.asMap().forEach((index, player) {
                  print("[VotingScreen] Player $index: ID=${player.id}, Name=${player.name}");
                });

                final currentVoter = _currentVoterIndex < _players.length ? _players[_currentVoterIndex] : null;
                print("[VotingScreen] Current voter index: $_currentVoterIndex, Current voter: ${currentVoter?.name}");

                if (currentVoter == null) {
                  print("[VotingScreen] Current voter is null, building VotingComplete.");
                  return _buildVotingComplete(context);
                }
                print("[VotingScreen] Building VotingSection for ${currentVoter.name}.");
                return _buildVotingSection(context, currentVoter);
              }

              if (playerState is PlayerError) {
                print("[VotingScreen] PlayerBloc error: ${playerState.message}");
                return Center(child: Text('Fehler beim Laden der Spieler: ${playerState.message}'));
              }
              print("[VotingScreen] PlayerBloc in initial or loading state.");
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVotingSection(BuildContext buildContext, Player currentVoter) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${currentVoter.name} ist an der Reihe',
                    style: Theme.of(buildContext).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Wer ist deiner Meinung nach der Spion?',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                if (player.id == currentVoter.id) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: _selectedPlayer?.id == player.id ? Colors.blue.shade100 : null,
                  child: ListTile(
                    title: Text(player.name),
                    trailing: _selectedPlayer?.id == player.id ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                    onTap: () {
                      setState(() {
                        _selectedPlayer = player;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Word guess checkbox for spies
          if (widget.roundBloc.state is RoundStarted &&
              (widget.roundBloc.state as RoundStarted).playerRoles[currentVoter.id] == PlayerRoleType.impostor)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: CheckboxListTile(
                title: const Text('Ich kann das Geheimwort erraten'),
                value: _wordGuessed && _wordGuesserId == currentVoter.id,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _wordGuessed = true;
                      _wordGuesserId = currentVoter.id;
                    } else if (_wordGuesserId == currentVoter.id) {
                      _wordGuessed = false;
                      _wordGuesserId = null;
                    }
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedPlayer == null
                ? null
                : () {
                    _votes.add(Vote.create(
                      voterId: currentVoter.id,
                      targetId: _selectedPlayer!.id,
                      roundId: widget.roundId,
                    ));

                    BlocProvider.of<VotingBloc>(buildContext).add(CastVote(
                      voterId: currentVoter.id,
                      targetId: _selectedPlayer!.id,
                      roundId: widget.roundId,
                    ));

                    setState(() {
                      _currentVoterIndex++;
                      _selectedPlayer = null;
                    });
                  },
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Abstimmen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingComplete(BuildContext blocContext) {
    // Check if we have spies and the roundBloc state is accessible
    final hasSpies =
        widget.roundBloc.state is RoundStarted && (widget.roundBloc.state as RoundStarted).playerRoles.values.contains(PlayerRoleType.impostor);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.how_to_vote,
            size: 64,
            color: AppColors.team,
          ),
          const SizedBox(height: 16),
          Text(
            'Alle Stimmen abgegeben!',
            style: Theme.of(blocContext).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          // Add "Skip to Results" option that will count as impostor win
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  const Text(
                    'Möchtet ihr diese Runde überspringen?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bei Überspringen gewinnen automatisch die Spione.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ElevatedButton(
                    onPressed: () {
                      // Skip to results - Impostors win by default
                      widget.roundBloc.add(CompleteRound(
                        roundId: widget.roundId,
                        impostorsWon: true,
                        wordGuessed: false,
                        skipToResults: true,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.impostor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Überspringen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<VotingBloc>(blocContext).add(SubmitVotes(_votes, _players));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              child: Text('Ergebnisse anzeigen'),
            ),
          ),
        ],
      ),
    );
  }
}
