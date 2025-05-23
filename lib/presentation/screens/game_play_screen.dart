import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wortspion/core/router/app_router.dart'; // For navigation
import 'package:wortspion/blocs/round/round_bloc.dart'; // Corrected import path
import 'package:wortspion/blocs/round/round_event.dart'; // For LoadRound event
import 'package:wortspion/blocs/round/round_state.dart'; // For RoundState and its specific states
import 'package:wortspion/di/injection_container.dart'; // For sl<TimerBloc>()

@RoutePage()
class GamePlayScreen extends StatefulWidget {
  final String gameId;
  final int timerDuration; // in seconds
  final String roundId;

  const GamePlayScreen({
    super.key,
    required this.gameId,
    required this.timerDuration,
    required this.roundId,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  // Key for SharedPreferences
  static const String _keySkipDialogShown = 'skip_results_dialog_shown';

  Timer? _timer;
  late int _currentTimerValue;
  bool _isPaused = false;
  late final RoundBloc _roundBloc; // Made late final

  @override
  void initState() {
    super.initState();
    _currentTimerValue = widget.timerDuration;
    // Create and initialize RoundBloc instance
    _roundBloc = sl<RoundBloc>()..add(LoadRound(gameId: widget.gameId, roundId: widget.roundId));
    _startTimer();
  }

  void _startTimer() {
    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTimerValue > 0) {
        if (mounted) {
          setState(() {
            _currentTimerValue--;
          });
        }
      } else {
        timer.cancel();
        _navigateToVoting();
      }
    });
  }

  void _pauseTimer() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _isPaused = true;
        });
      }
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      _startTimer();
    }
  }

  void _navigateToVoting() {
    // Now uses the _roundBloc instance variable
    context.router.replace(VotingRoute(
      roundId: widget.roundId,
      gameId: widget.gameId,
      roundBloc: _roundBloc,
    ));
  }

  Future<void> _skipToResults() async {
    _timer?.cancel(); // Stop the timer

    // Load the current round data to get player roles
    _roundBloc.add(LoadRound(gameId: widget.gameId, roundId: widget.roundId));

    // Check if dialog has been shown before
    final prefs = await SharedPreferences.getInstance();
    final dialogShown = prefs.getBool(_keySkipDialogShown) ?? false;

    if (dialogShown) {
      // If dialog already shown before, skip directly to results
      _completeRoundAndSkip();
      return;
    }

    // Show dialog only if it hasn't been shown before
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Spiel überspringen'),
        content: const Text('Wenn du direkt zu den Ergebnissen springst, werden keine Abstimmungen durchgeführt. Möchtest du wirklich fortfahren?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (_timer?.isActive != true) {
                _startTimer(); // Resume timer if it was stopped
              }
            },
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              // Save preference
              await prefs.setBool(_keySkipDialogShown, true);

              Navigator.of(dialogContext).pop();
              _completeRoundAndSkip();
            },
            child: const Text('Überspringen'),
          ),
        ],
      ),
    );
  }

  void _completeRoundAndSkip() {
    // Complete the round directly without voting
    // Since we're skipping voting, we'll set impostorsWon to true
    // since they weren't caught, and wordGuessed to false since
    // they didn't have a chance to guess
    _roundBloc.add(CompleteRound(
      roundId: widget.roundId,
      impostorsWon: true,
      wordGuessed: false,
    ));
  }

  // Helper method to reset dialog preference (can be called externally if needed)
  static Future<void> resetSkipDialogPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySkipDialogShown, false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _roundBloc.close(); // Crucially, DO NOT close it here yet.
    // It will be closed by VotingScreen or ResultsScreen if they are the end of its lifecycle,
    // or by a higher-level provider if we refactor scoping.
    // For now, this manual management means we need to be careful.
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_currentTimerValue ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentTimerValue % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // The UI for GamePlayScreen itself will now listen to _roundBloc via BlocProvider.value
    return BlocProvider.value(
      value: _roundBloc,
      child: BlocListener<RoundBloc, RoundState>(
        bloc: _roundBloc,
        listener: (context, state) {
          if (state is RoundComplete) {
            // Navigate to results screen when round is completed (skipped)
            context.router.replace(ResultsRoute(
              votingResults: const [], // Empty voting results since we skipped voting
              mostVotedPlayer: null, // No player was voted out
              playerRoles: state.playerRoles,
              secretWord: state.secretWord,
              gameId: widget.gameId, // Added missing gameId parameter
            ));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Diskussion'),
            automaticallyImplyLeading: false,
          ),
          body: Builder(
            builder: (screenContext) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                        child: Text(
                          _formattedTime,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _currentTimerValue <= 10 && _currentTimerValue % 2 == 0
                                    ? Colors.red
                                    : Theme.of(context).textTheme.displayMedium?.color,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Diskutiert über das Wort!',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<RoundBloc, RoundState>(
                      builder: (context, roundState) {
                        if (roundState is RoundLoading) {
                          return const CircularProgressIndicator();
                        } else if (roundState is RoundError) {
                          return Text('Fehler beim Laden der Runde: ${roundState.message}', style: const TextStyle(color: Colors.red));
                        } else if (roundState is RoundStarted) {
                          return Text('Kategorie: ${roundState.categoryName}', style: const TextStyle(fontSize: 16));
                        } else if (roundState is RoundLoaded) {
                          return Text('Kategorie: ${roundState.categoryName}', style: const TextStyle(fontSize: 16));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Spione, versucht das Hauptwort herauszufinden!',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                              label: Text(_isPaused ? 'Fortsetzen' : 'Pause'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 50)),
                            ),
                            ElevatedButton.icon(
                              onPressed: _navigateToVoting,
                              icon: const Icon(Icons.how_to_vote),
                              label: const Text('Abstimmen'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(140, 50)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _skipToResults,
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Direkt zu den Ergebnissen'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(240, 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
