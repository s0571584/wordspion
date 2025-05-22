import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/game/game_event.dart';
import 'package:wortspion/blocs/game/game_state.dart';
import 'package:wortspion/blocs/player/player_bloc.dart';
import 'package:wortspion/blocs/settings/settings_bloc.dart';
import 'package:wortspion/blocs/settings/settings_event.dart';
import 'package:wortspion/blocs/settings/settings_state.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/di/injection_container.dart';
import 'package:wortspion/presentation/screens/player_registration_screen.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/presentation/widgets/app_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class GameSetupScreen extends StatefulWidget {
  final bool isSettingsOnly;

  const GameSetupScreen({
    super.key,
    this.isSettingsOnly = false,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _playerCount = 5;
  int _impostorCount = 1;
  int _roundCount = 3;
  int _timerDuration = 60;
  bool _impostorsKnowEachOther = false;
  bool _isEditingExistingGame = false;
  Game? _existingGame;

  // Constants for SharedPreferences keys
  static const String _keyImpostorCount = 'game_impostor_count';
  static const String _keyRoundCount = 'game_round_count';
  static const String _keyTimerDuration = 'game_timer_duration';
  static const String _keyImpostorsKnowEachOther = 'game_impostors_know_each_other';
  static const String _keyPlayerCount = 'game_player_count';
  
  // Check if the GameBloc uses the same keys
  static const String _gameBlocImpostorCountKey = 'game_impostor_count'; // Should match GameBloc's key

  @override
  void initState() {
    super.initState();

    _loadSettings();

    if (widget.isSettingsOnly) {
      _isEditingExistingGame = true;
    } else {
      _isEditingExistingGame = false;
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _playerCount = prefs.getInt(_keyPlayerCount) ?? 5;
        _impostorCount = prefs.getInt(_keyImpostorCount) ?? 1;
        _roundCount = prefs.getInt(_keyRoundCount) ?? 3;
        _timerDuration = prefs.getInt(_keyTimerDuration) ?? 60;
        _impostorsKnowEachOther = prefs.getBool(_keyImpostorsKnowEachOther) ?? false;
      });

      debugPrint('Loaded settings from SharedPreferences: $_playerCount players, $_impostorCount spies');
    } catch (e) {
      debugPrint('Failed to load settings from SharedPreferences: $e');
    }
  }

  // Directly save the game setup settings
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_keyPlayerCount, _playerCount);
      await prefs.setInt(_keyImpostorCount, _impostorCount);
      await prefs.setInt(_keyRoundCount, _roundCount);
      await prefs.setInt(_keyTimerDuration, _timerDuration);
      await prefs.setBool(_keyImpostorsKnowEachOther, _impostorsKnowEachOther);

      print('=== GameSetupScreen: _saveSettings ===');
      print('Saved settings to SharedPreferences:');
      print('- playerCount = $_playerCount');
      print('- impostorCount = $_impostorCount (THIS IS THE KEY VALUE!)');
      print('- roundCount = $_roundCount');
      print('- timerDuration = $_timerDuration');
      print('- impostorsKnowEachOther = $_impostorsKnowEachOther');
      
      // Double check if it was actually saved by retrieving it again
      final savedImpostorCount = prefs.getInt(_keyImpostorCount);
      print('Verification - Retrieved impostorCount from SharedPreferences: $savedImpostorCount');
      
      // Now ensure GameBloc receives these updated settings by updating its SettingsBloc
      try {
        if (context.mounted) {
          context.read<SettingsBloc>().add(
                UpdateGameSettings(
                  playerCount: _playerCount,
                  impostorCount: _impostorCount,
                  roundCount: _roundCount,
                  timerDuration: _timerDuration,
                  impostorsKnowEachOther: _impostorsKnowEachOther,
                ),
              );
          print('- Updated SettingsBloc with new settings');
        }
      } catch (e) {
        print('Note: Unable to update SettingsBloc - may not be mounted yet: $e');
      }
      
      debugPrint('Saved settings to SharedPreferences');
    } catch (e) {
      debugPrint('Failed to save settings to SharedPreferences: $e');
    }
  }

  void _checkExistingGame() {
    // if (!mounted) return;
    // try {
    //   final gameState = context.read<GameBloc>().state; // EXAMPLE of context usage
    //   if (gameState is GameCreated || gameState is GameInProgress) {
    //     final game = gameState is GameCreated ? gameState.game : (gameState as GameInProgress).game;
    //     setState(() {
    //       _isEditingExistingGame = true; // This was problematic for "new game"
    //       _existingGame = game;
    //       _playerCount = game.playerCount;
    //       // ... load other settings from game ...
    //     });
    //     // _saveSettings(); // Definitely remove this side-effect
    //   }
    // } catch (e) {
    //   debugPrint("No existing game found or error accessing game state: $e");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (blocContext) => sl<SettingsBloc>()
            ..add(
              UpdateGameSettings(
                playerCount: _playerCount,
                impostorCount: _impostorCount,
                roundCount: _roundCount,
                timerDuration: _timerDuration,
                impostorsKnowEachOther: _impostorsKnowEachOther,
              ),
            ),
        ),
      ],
      child: Builder(builder: (innerContext) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditingExistingGame ? 'Einstellungen bearbeiten' : 'Spieleinstellungen'),
          ),
          body: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  _isEditingExistingGame ? 'Einstellungen bearbeiten' : 'Spieleinstellungen',
                  style: AppTypography.headline2,
                ),
                const SizedBox(height: 32),
                _buildSettingsForm(),
                const Spacer(),
                _buildActionButton(innerContext),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettingsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spieleranzahl
        Text('Spieleranzahl: $_playerCount', style: AppTypography.subtitle1),
        const SizedBox(height: 8),
        AppSlider(
          value: _playerCount.toDouble(),
          min: 3,
          max: 10,
          divisions: 7,
          onChanged: (value) {
            setState(() {
              _playerCount = value.toInt();
              // Impostoranzahl anpassen, damit es immer weniger als Spieler sind
              if (_impostorCount >= _playerCount - 1) {
                _impostorCount = _playerCount - 2;
              }

              // Save settings immediately when changed
              _saveSettings();
            });
          },
        ),
        const SizedBox(height: 24),

        // Spion-Anzahl
        Text('Anzahl der Spione: $_impostorCount', style: AppTypography.subtitle1),
        const SizedBox(height: 8),
        AppSlider(
          value: _impostorCount.toDouble(),
          min: 1,
          max: _playerCount - 2 < 1 ? 1 : _playerCount - 2,
          divisions: (_playerCount - 2) < 1 ? 1 : _playerCount - 2,
          onChanged: (value) {
            setState(() {
              _impostorCount = value.toInt();
              print('GameSetupScreen: Impostor count set to: $_impostorCount for $_playerCount players');
              print('This will be saved to SharedPreferences with key: $_keyImpostorCount');

              // Save settings immediately when changed
              _saveSettings();
            });
          },
        ),
        const SizedBox(height: 24),

        // Rundenanzahl
        Text('Anzahl der Runden: $_roundCount', style: AppTypography.subtitle1),
        const SizedBox(height: 8),
        AppSlider(
          value: _roundCount.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (value) {
            setState(() {
              _roundCount = value.toInt();

              // Save settings immediately when changed
              _saveSettings();
            });
          },
        ),
        const SizedBox(height: 24),

        // Timer-Dauer
        Text(
          'Diskussionszeit: $_timerDuration Sekunden',
          style: AppTypography.subtitle1,
        ),
        const SizedBox(height: 8),
        AppSlider(
          value: _timerDuration.toDouble(),
          min: 30,
          max: 180,
          divisions: 5,
          onChanged: (value) {
            setState(() {
              _timerDuration = value.toInt();

              // Save settings immediately when changed
              _saveSettings();
            });
          },
        ),
        const SizedBox(height: 24),

        // Ob Spione sich untereinander kennen
        SwitchListTile(
          title: const Text(
            'Spione kennen einander',
            style: AppTypography.body1,
          ),
          subtitle: Text(
            'Spione sehen, wer die anderen Spione sind',
            style: AppTypography.caption,
          ),
          value: _impostorsKnowEachOther,
          onChanged: (value) {
            setState(() {
              _impostorsKnowEachOther = value;

              // Save settings immediately when changed
              _saveSettings();
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: widget.isSettingsOnly
          ? ElevatedButton(
              onPressed: () {
                _saveSettings(); // Save to SharedPreferences
                // Update SettingsBloc
                context.read<SettingsBloc>().add(
                      UpdateGameSettings(
                        playerCount: _playerCount,
                        impostorCount: _impostorCount,
                        roundCount: _roundCount,
                        timerDuration: _timerDuration,
                        impostorsKnowEachOther: _impostorsKnowEachOther,
                      ),
                    );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Einstellungen übernehmen'),
            )
          : BlocBuilder<GameBloc, GameState>(
              builder: (context, gameState) {
                return ElevatedButton(
                  onPressed: gameState is GameLoading
                      ? null
                      : () {
                          _saveSettings(); // Save to SharedPreferences
                          // Dispatch event to GameBloc
                          context.read<GameBloc>().add(
                                CreateGame(
                                  playerCount: _playerCount,
                                  impostorCount: _impostorCount,
                                  roundCount: _roundCount,
                                  timerDuration: _timerDuration,
                                  impostorsKnowEachOther: _impostorsKnowEachOther,
                                ),
                              );
                          // Navigation to PlayerRegistrationScreen is handled by HomeScreen's listener
                        },
                  child: gameState is GameLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Spiel erstellen'),
                );
              },
            ),
    );
  }
}
