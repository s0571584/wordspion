import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/round/round_bloc.dart';
import 'package:wortspion/blocs/round/round_event.dart' as round_events;
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/player_role.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/di/injection_container.dart';

@RoutePage()
class RoleRevealScreen extends StatefulWidget {
  final String gameId;

  const RoleRevealScreen({super.key, required this.gameId});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isRevealed = false;
  Player? _currentPlayer;
  int _currentPlayerIndex = 0;
  List<Player> _players = [];

  Game? _currentGame;
  String? _currentRoundId;
  late RoundBloc _roundBloc;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _roundBloc = sl<RoundBloc>();

    // Load game and start round after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    if (!mounted) return;

    debugPrint("RoleRevealScreen: Initializing for game ID: ${widget.gameId}");

    try {
      // Load game details
      final game = await sl<GameRepository>().getGameById(widget.gameId);
      if (game != null && mounted) {
        setState(() {
          _currentGame = game;
        });
        debugPrint("Game details fetched for ${game.id}: Timer ${game.timerDuration}");

        // DEBUG PRINT ADDED HERE
        print("=== RoleRevealScreen: _initializeGame ====");
        print("Game retrieved from DB: ${game.toString()}");
        print("impostorCount in the game object = ${_currentGame!.impostorCount}, playerCount = ${_currentGame!.playerCount}");

        // Use the game's impostor count directly
        print("RoleRevealScreen: Using game's impostorCount=${_currentGame!.impostorCount} from database");

        // Start the round
        _roundBloc.add(round_events.StartRound(
          gameId: widget.gameId,
          roundNumber: 1,
          playerCount: _currentGame!.playerCount,
          impostorCount: _currentGame!.impostorCount,
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: Spielinformationen nicht geladen für die angegebene ID.')),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error loading game: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden des Spiels: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _revealRole() {
    setState(() {
      _isRevealed = true;
    });
    _animationController.forward();
  }

  void _resetForNextPlayer() {
    setState(() {
      _isRevealed = false;
      _currentPlayerIndex++;
    });

    _animationController.reset();

    // Check if all players have seen their roles
    if (_currentPlayerIndex >= _players.length) {
      if (_currentGame != null && _currentRoundId != null) {
        debugPrint("Alle ${_players.length} Spieler haben ihre Rolle gesehen. Navigiere zum Spielbildschirm.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.router.replace(GamePlayRoute(
            gameId: _currentGame!.id,
            timerDuration: _currentGame!.timerDuration,
            roundId: _currentRoundId!,
          ));
        });
      } else {
        debugPrint("Fehler: Spiel- oder Rundendetails fehlen für die Navigation.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: Spielinformationen nicht geladen.')),
        );
      }
    } else {
      setState(() {
        _currentPlayer = _players[_currentPlayerIndex];
        debugPrint("Zeige Spieler ${_currentPlayerIndex + 1} von ${_players.length}: ${_currentPlayer?.name}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _roundBloc,
      child: BlocConsumer<RoundBloc, RoundState>(
        listener: (context, state) {
          if (state is RoundStarted) {
            setState(() {
              _players = state.players;
              _currentRoundId = state.roundId;
              debugPrint("Spieler geladen: ${_players.length}, Runde gestartet: ${state.roundId}");

              if (_players.isEmpty) {
                debugPrint("WARNING: No players found for this game!");
              }

              _currentPlayerIndex = 0;
              if (_players.isNotEmpty) {
                _currentPlayer = _players[0];
                debugPrint("Erster Spieler: ${_currentPlayer?.name}");
              }
            });
          } else if (state is RoundError) {
            debugPrint("Round Error: ${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Rollenverteilung'),
              automaticallyImplyLeading: false,
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RoundState state) {
    if (state is RoundLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RoundError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fehler: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _roundBloc.add(round_events.StartRound(
                  gameId: widget.gameId,
                  roundNumber: 1,
                  playerCount: _currentGame!.playerCount,
                  impostorCount: _currentGame!.impostorCount,
                ));
              },
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    if (_players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Fehler: Keine Spieler gefunden'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Zurück'),
            ),
          ],
        ),
      );
    }

    if (_currentPlayerIndex >= _players.length && _isRevealed) {
      return const Center(child: CircularProgressIndicator());
    } else if (_currentPlayerIndex >= _players.length) {
      return const Center(child: Text("Alle Rollen verteilt. Navigiere..."));
    }

    final bool isLastPlayer = _currentPlayerIndex == _players.length - 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Spieler: ${_currentPlayer?.name ?? "Unbekannt"}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            _buildRoleCard(context, state),
            const SizedBox(height: 32),
            if (_isRevealed) ...[
              ElevatedButton(
                onPressed: _resetForNextPlayer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: Text(
                  isLastPlayer ? 'Spiel starten' : 'Nächster Spieler',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _revealRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Rolle aufdecken',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, RoundState state) {
    final cardHeight = MediaQuery.of(context).size.height * 0.3;
    final cardWidth = MediaQuery.of(context).size.width * 0.9;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: cardHeight,
      width: cardWidth,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _isRevealed ? Colors.white : Theme.of(context).primaryColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isRevealed ? _buildRevealedContent(context, state) : _buildHiddenContent(context),
        ),
      ),
    );
  }

  Widget _buildRevealedContent(BuildContext context, RoundState state) {
    if (state is! RoundStarted || _currentPlayer == null) {
      return const Center(child: Text("Rolleninformationen werden geladen..."));
    }

    final roleType = state.playerRoles[_currentPlayer!.id];
    final word = state.playerWords[_currentPlayer!.id] ?? "";

    // Get the game to check if impostors should know each other
    final game = _currentGame;
    final bool showOtherImpostors = game?.impostorsKnowEachOther ?? false;

    // Get other impostor names if this player is an impostor and should know others
    List<String> otherImpostorNames = [];
    if (roleType == PlayerRoleType.impostor && showOtherImpostors) {
      // Find all other players who are impostors
      for (final player in state.players) {
        if (player.id != _currentPlayer!.id && state.playerRoles[player.id] == PlayerRoleType.impostor) {
          otherImpostorNames.add(player.name);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getRoleName(roleType),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: roleType == PlayerRoleType.impostor ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Geheimwort: $word',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Kategorie: ${state.categoryName}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          // Show other impostors if applicable
          if (roleType == PlayerRoleType.impostor && showOtherImpostors && otherImpostorNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Andere Spione:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              otherImpostorNames.join(', '),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHiddenContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility,
            size: 48,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tippe auf den Button unten,\num deine Rolle zu sehen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getRoleName(PlayerRoleType? role) {
    switch (role) {
      case PlayerRoleType.impostor:
        return 'Spion';
      case PlayerRoleType.detective:
        return 'Detektiv';
      case PlayerRoleType.civilian:
        return 'Teammitglied';
      default:
        return 'Unbekannt';
    }
  }
}
