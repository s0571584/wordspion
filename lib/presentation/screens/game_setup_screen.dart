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
import 'package:wortspion/presentation/screens/category_selection_screen.dart';
import 'package:wortspion/presentation/themes/app_spacing.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';
import 'package:wortspion/presentation/widgets/app_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as Math;

@RoutePage()
class GameSetupScreen extends StatefulWidget {
  final bool isSettingsOnly;
  final bool fromGroup;
  final List<String>? groupPlayerNames;

  const GameSetupScreen({
    super.key,
    this.isSettingsOnly = false,
    this.fromGroup = false,
    this.groupPlayerNames,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _playerCount = 5;
  int _impostorCount = 1;
  int _saboteurCount = 0; // 🆕 NEW: Add saboteur count with default 0
  int _roundCount = 3;
  int _timerDuration = 60;
  bool _impostorsKnowEachOther = false;
  bool _isEditingExistingGame = false;
  Game? _existingGame;

  // Constants for SharedPreferences keys
  static const String _keyImpostorCount = 'game_impostor_count';
  static const String _keySaboteurCount = 'game_saboteur_count'; // 🆕 NEW: Add saboteur count key
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

    // If from group, set player count but allow role counts to be adjustable
    if (widget.fromGroup && widget.groupPlayerNames != null) {
      _playerCount = widget.groupPlayerNames!.length;
      // Ensure role counts are valid for the group size
      _validateRoleCounts();
    }

    if (widget.isSettingsOnly) {
      _isEditingExistingGame = true;
    } else {
      _isEditingExistingGame = false;
    }
  }

  // 🆕 NEW: Helper method to validate role counts
  void _validateRoleCounts() {
    // Ensure at least 3 players
    _playerCount = Math.max(3, _playerCount);

    // At least 1 civilian is required
    final maxSpecialRoles = Math.max(1, _playerCount - 1);

    // Make sure impostorCount is at least 1
    _impostorCount = Math.max(1, _impostorCount);

    // Total special roles can't exceed maxSpecialRoles
    if (_impostorCount + _saboteurCount > maxSpecialRoles) {
      // Prioritize keeping impostors over saboteurs
      _impostorCount = Math.min(_impostorCount, maxSpecialRoles);
      _saboteurCount = Math.max(0, Math.min(_saboteurCount, maxSpecialRoles - _impostorCount));
    }

    // Final validation to ensure valid ranges
    _impostorCount = _impostorCount.clamp(1, Math.max(1, _playerCount - 1));
    _saboteurCount = _saboteurCount.clamp(0, Math.max(0, _playerCount - _impostorCount - 1));
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        // Only load player count if not from group
        if (!widget.fromGroup) {
          _playerCount = prefs.getInt(_keyPlayerCount) ?? 5;
        }
        _impostorCount = prefs.getInt(_keyImpostorCount) ?? 1;
        _saboteurCount = prefs.getInt(_keySaboteurCount) ?? 0; // 🆕 NEW: Load saboteur count
        _roundCount = prefs.getInt(_keyRoundCount) ?? 3;
        _timerDuration = prefs.getInt(_keyTimerDuration) ?? 60;
        _impostorsKnowEachOther = prefs.getBool(_keyImpostorsKnowEachOther) ?? false;

        // Ensure role counts are valid for current player count
        _validateRoleCounts();
      });

      debugPrint('Loaded settings from SharedPreferences: $_playerCount players, $_impostorCount spies, $_saboteurCount saboteurs');
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
      await prefs.setInt(_keySaboteurCount, _saboteurCount); // 🆕 NEW: Save saboteur count
      await prefs.setInt(_keyRoundCount, _roundCount);
      await prefs.setInt(_keyTimerDuration, _timerDuration);
      await prefs.setBool(_keyImpostorsKnowEachOther, _impostorsKnowEachOther);

      print('=== GameSetupScreen: _saveSettings ===');
      print('Saved settings to SharedPreferences:');
      print('- playerCount = $_playerCount');
      print('- impostorCount = $_impostorCount (THIS IS THE KEY VALUE!)');
      print('- saboteurCount = $_saboteurCount'); // 🆕 NEW: Debug print saboteur count
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
                  saboteurCount: _saboteurCount, // 🆕 NEW: Include saboteur count
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
                saboteurCount: _saboteurCount, // 🆕 NEW: Include saboteur count
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
            title: Text(_isEditingExistingGame
                ? 'Einstellungen bearbeiten'
                : widget.fromGroup
                    ? 'Spieleinstellungen für Gruppe'
                    : 'Spieleinstellungen'),
          ),
          body: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  _isEditingExistingGame
                      ? 'Einstellungen bearbeiten'
                      : widget.fromGroup
                          ? 'Spieleinstellungen für Gruppe'
                          : 'Spieleinstellungen',
                  style: AppTypography.headline2,
                ),
                const SizedBox(height: 32),
                // 🆕 NEW: Make settings form scrollable to prevent overflow
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildSettingsForm(),
                  ),
                ),
                const SizedBox(height: 16), // Reduce spacing before button
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
        // Show group players if from group
        if (widget.fromGroup && widget.groupPlayerNames != null) ...[
          const Text('Spieler aus Gruppe:', style: AppTypography.subtitle1),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 150), // Limit height to prevent overflow
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              // Make scrollable for many players
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < widget.groupPlayerNames!.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${i + 1}. ${widget.groupPlayerNames![i]}', style: AppTypography.body1),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Anzahl Spieler: ${widget.groupPlayerNames!.length}', style: AppTypography.body2.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 24),
        ] else ...[
          // Regular player count slider
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
                // Validate all role counts when player count changes
                _validateRoleCounts();

                // Save settings immediately when changed
                _saveSettings();
              });
            },
          ),
          const SizedBox(height: 24),
        ],

        // Spion-Anzahl
        Text('Anzahl der Spione: $_impostorCount', style: AppTypography.subtitle1),
        const SizedBox(height: 8),
        AppSlider(
          value: _impostorCount.toDouble(),
          min: 1,
          max: _playerCount > 3 ? _playerCount - 2 : 1,
          divisions: _playerCount > 3 ? _playerCount - 2 : 1,
          onChanged: (value) {
            setState(() {
              _impostorCount = value.toInt();
              // Validate role counts to ensure saboteur count is still valid
              _validateRoleCounts();
              print('GameSetupScreen: Impostor count set to: $_impostorCount for $_playerCount players (saboteurs: $_saboteurCount)');

              // Save settings immediately when changed
              _saveSettings();
            });
          },
        ),
        const SizedBox(height: 24),

        // 🆕 NEW: Saboteur count slider
        Text('Anzahl der Saboteure: $_saboteurCount', style: AppTypography.subtitle1),
        const SizedBox(height: 8),
        AppSlider(
          value: _saboteurCount.toDouble(),
          min: 0,
          max: Math.max(0, _playerCount - _impostorCount - 1),
          divisions: Math.max(1, _playerCount - _impostorCount - 1),
          onChanged: (value) {
            setState(() {
              _saboteurCount = value.toInt();
              print('GameSetupScreen: Saboteur count set to: $_saboteurCount for $_playerCount players (impostors: $_impostorCount)');

              // Save settings immediately when changed
              _saveSettings();
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          _saboteurCount > 0 ? 'Saboteure kennen das Hauptwort und gewinnen, wenn sie beschuldigt werden' : 'Saboteure sind deaktiviert',
          style: AppTypography.caption.copyWith(
            color: _saboteurCount > 0 ? Colors.orange : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
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
                        saboteurCount: _saboteurCount, // 🆕 NEW: Include saboteur count
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
                      : () async {
                          // Save settings and wait for completion
                          await _saveSettings();

                          // Navigate to category selection screen
                          if (widget.fromGroup && widget.groupPlayerNames != null) {
                            // Small delay to ensure settings are persisted
                            await Future.delayed(const Duration(milliseconds: 50));
                            // Navigate to category selection for group game
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<GameBloc>()),
                                  ],
                                  child: CategorySelectionScreen(
                                    playerCount: _playerCount,
                                    impostorCount: _impostorCount,
                                    saboteurCount: _saboteurCount, // 🆕 NEW: Pass saboteur count
                                    roundCount: _roundCount,
                                    timerDuration: _timerDuration,
                                    impostorsKnowEachOther: _impostorsKnowEachOther,
                                    groupPlayerNames: widget.groupPlayerNames,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Navigate to category selection for regular game
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<GameBloc>()),
                                  ],
                                  child: CategorySelectionScreen(
                                    playerCount: _playerCount,
                                    impostorCount: _impostorCount,
                                    saboteurCount: _saboteurCount, // 🆕 NEW: Pass saboteur count
                                    roundCount: _roundCount,
                                    timerDuration: _timerDuration,
                                    impostorsKnowEachOther: _impostorsKnowEachOther,
                                  ),
                                ),
                              ),
                            );
                          }
                          // Navigation to next screen is handled by HomeScreen's listener
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
                      : Text(widget.fromGroup ? 'Spiel mit Gruppe starten' : 'Spiel erstellen'),
                );
              },
            ),
    );
  }
}
