// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    CreateEditPlayerGroupRoute.name: (routeData) {
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<CreateEditPlayerGroupRouteArgs>(
          orElse: () => CreateEditPlayerGroupRouteArgs(
              groupId: queryParams.optString('groupId')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CreateEditPlayerGroupScreen(
          key: args.key,
          groupId: args.groupId,
        ),
      );
    },
    FinalResultsRoute.name: (routeData) {
      final args = routeData.argsAs<FinalResultsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FinalResultsScreen(
          key: args.key,
          players: args.players,
          winnerNames: args.winnerNames,
          gameId: args.gameId,
        ),
      );
    },
    GamePlayRoute.name: (routeData) {
      final args = routeData.argsAs<GamePlayRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GamePlayScreen(
          key: args.key,
          gameId: args.gameId,
          timerDuration: args.timerDuration,
          roundId: args.roundId,
        ),
      );
    },
    GameSetupRoute.name: (routeData) {
      final args = routeData.argsAs<GameSetupRouteArgs>(
          orElse: () => const GameSetupRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GameSetupScreen(
          key: args.key,
          isSettingsOnly: args.isSettingsOnly,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    PlayerGroupsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PlayerGroupsScreen(),
      );
    },
    PlayerRegistrationRoute.name: (routeData) {
      final args = routeData.argsAs<PlayerRegistrationRouteArgs>(
          orElse: () => const PlayerRegistrationRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PlayerRegistrationScreen(
          key: args.key,
          game: args.game,
        ),
      );
    },
    ResultsRoute.name: (routeData) {
      final args = routeData.argsAs<ResultsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ResultsScreen(
          key: args.key,
          votingResults: args.votingResults,
          mostVotedPlayer: args.mostVotedPlayer,
          playerRoles: args.playerRoles,
          secretWord: args.secretWord,
        ),
      );
    },
    RoleRevealRoute.name: (routeData) {
      final args = routeData.argsAs<RoleRevealRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RoleRevealScreen(
          key: args.key,
          gameId: args.gameId,
        ),
      );
    },
    RoundResultsRoute.name: (routeData) {
      final args = routeData.argsAs<RoundResultsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: RoundResultsScreen(
          key: args.key,
          gameId: args.gameId,
          roundNumber: args.roundNumber,
          totalRounds: args.totalRounds,
          scoreResults: args.scoreResults,
          playerRoles: args.playerRoles,
          secretWord: args.secretWord,
          impostorsWon: args.impostorsWon,
          wordGuessed: args.wordGuessed,
        )),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    VotingRoute.name: (routeData) {
      final args = routeData.argsAs<VotingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VotingScreen(
          key: args.key,
          roundId: args.roundId,
          gameId: args.gameId,
          roundBloc: args.roundBloc,
        ),
      );
    },
  };
}

/// generated route for
/// [CreateEditPlayerGroupScreen]
class CreateEditPlayerGroupRoute
    extends PageRouteInfo<CreateEditPlayerGroupRouteArgs> {
  CreateEditPlayerGroupRoute({
    Key? key,
    String? groupId,
    List<PageRouteInfo>? children,
  }) : super(
          CreateEditPlayerGroupRoute.name,
          args: CreateEditPlayerGroupRouteArgs(
            key: key,
            groupId: groupId,
          ),
          rawQueryParams: {'groupId': groupId},
          initialChildren: children,
        );

  static const String name = 'CreateEditPlayerGroupRoute';

  static const PageInfo<CreateEditPlayerGroupRouteArgs> page =
      PageInfo<CreateEditPlayerGroupRouteArgs>(name);
}

class CreateEditPlayerGroupRouteArgs {
  const CreateEditPlayerGroupRouteArgs({
    this.key,
    this.groupId,
  });

  final Key? key;

  final String? groupId;

  @override
  String toString() {
    return 'CreateEditPlayerGroupRouteArgs{key: $key, groupId: $groupId}';
  }
}

/// generated route for
/// [FinalResultsScreen]
class FinalResultsRoute extends PageRouteInfo<FinalResultsRouteArgs> {
  FinalResultsRoute({
    Key? key,
    required List<Player> players,
    required List<String> winnerNames,
    required String gameId,
    List<PageRouteInfo>? children,
  }) : super(
          FinalResultsRoute.name,
          args: FinalResultsRouteArgs(
            key: key,
            players: players,
            winnerNames: winnerNames,
            gameId: gameId,
          ),
          initialChildren: children,
        );

  static const String name = 'FinalResultsRoute';

  static const PageInfo<FinalResultsRouteArgs> page =
      PageInfo<FinalResultsRouteArgs>(name);
}

class FinalResultsRouteArgs {
  const FinalResultsRouteArgs({
    this.key,
    required this.players,
    required this.winnerNames,
    required this.gameId,
  });

  final Key? key;

  final List<Player> players;

  final List<String> winnerNames;

  final String gameId;

  @override
  String toString() {
    return 'FinalResultsRouteArgs{key: $key, players: $players, winnerNames: $winnerNames, gameId: $gameId}';
  }
}

/// generated route for
/// [GamePlayScreen]
class GamePlayRoute extends PageRouteInfo<GamePlayRouteArgs> {
  GamePlayRoute({
    Key? key,
    required String gameId,
    required int timerDuration,
    required String roundId,
    List<PageRouteInfo>? children,
  }) : super(
          GamePlayRoute.name,
          args: GamePlayRouteArgs(
            key: key,
            gameId: gameId,
            timerDuration: timerDuration,
            roundId: roundId,
          ),
          initialChildren: children,
        );

  static const String name = 'GamePlayRoute';

  static const PageInfo<GamePlayRouteArgs> page =
      PageInfo<GamePlayRouteArgs>(name);
}

class GamePlayRouteArgs {
  const GamePlayRouteArgs({
    this.key,
    required this.gameId,
    required this.timerDuration,
    required this.roundId,
  });

  final Key? key;

  final String gameId;

  final int timerDuration;

  final String roundId;

  @override
  String toString() {
    return 'GamePlayRouteArgs{key: $key, gameId: $gameId, timerDuration: $timerDuration, roundId: $roundId}';
  }
}

/// generated route for
/// [GameSetupScreen]
class GameSetupRoute extends PageRouteInfo<GameSetupRouteArgs> {
  GameSetupRoute({
    Key? key,
    bool isSettingsOnly = false,
    List<PageRouteInfo>? children,
  }) : super(
          GameSetupRoute.name,
          args: GameSetupRouteArgs(
            key: key,
            isSettingsOnly: isSettingsOnly,
          ),
          initialChildren: children,
        );

  static const String name = 'GameSetupRoute';

  static const PageInfo<GameSetupRouteArgs> page =
      PageInfo<GameSetupRouteArgs>(name);
}

class GameSetupRouteArgs {
  const GameSetupRouteArgs({
    this.key,
    this.isSettingsOnly = false,
  });

  final Key? key;

  final bool isSettingsOnly;

  @override
  String toString() {
    return 'GameSetupRouteArgs{key: $key, isSettingsOnly: $isSettingsOnly}';
  }
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PlayerGroupsScreen]
class PlayerGroupsRoute extends PageRouteInfo<void> {
  const PlayerGroupsRoute({List<PageRouteInfo>? children})
      : super(
          PlayerGroupsRoute.name,
          initialChildren: children,
        );

  static const String name = 'PlayerGroupsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PlayerRegistrationScreen]
class PlayerRegistrationRoute
    extends PageRouteInfo<PlayerRegistrationRouteArgs> {
  PlayerRegistrationRoute({
    Key? key,
    Game? game,
    List<PageRouteInfo>? children,
  }) : super(
          PlayerRegistrationRoute.name,
          args: PlayerRegistrationRouteArgs(
            key: key,
            game: game,
          ),
          initialChildren: children,
        );

  static const String name = 'PlayerRegistrationRoute';

  static const PageInfo<PlayerRegistrationRouteArgs> page =
      PageInfo<PlayerRegistrationRouteArgs>(name);
}

class PlayerRegistrationRouteArgs {
  const PlayerRegistrationRouteArgs({
    this.key,
    this.game,
  });

  final Key? key;

  final Game? game;

  @override
  String toString() {
    return 'PlayerRegistrationRouteArgs{key: $key, game: $game}';
  }
}

/// generated route for
/// [ResultsScreen]
class ResultsRoute extends PageRouteInfo<ResultsRouteArgs> {
  ResultsRoute({
    Key? key,
    required List<VotingResult> votingResults,
    Player? mostVotedPlayer,
    required List<PlayerRoleInfo> playerRoles,
    required String secretWord,
    List<PageRouteInfo>? children,
  }) : super(
          ResultsRoute.name,
          args: ResultsRouteArgs(
            key: key,
            votingResults: votingResults,
            mostVotedPlayer: mostVotedPlayer,
            playerRoles: playerRoles,
            secretWord: secretWord,
          ),
          initialChildren: children,
        );

  static const String name = 'ResultsRoute';

  static const PageInfo<ResultsRouteArgs> page =
      PageInfo<ResultsRouteArgs>(name);
}

class ResultsRouteArgs {
  const ResultsRouteArgs({
    this.key,
    required this.votingResults,
    this.mostVotedPlayer,
    required this.playerRoles,
    required this.secretWord,
  });

  final Key? key;

  final List<VotingResult> votingResults;

  final Player? mostVotedPlayer;

  final List<PlayerRoleInfo> playerRoles;

  final String secretWord;

  @override
  String toString() {
    return 'ResultsRouteArgs{key: $key, votingResults: $votingResults, mostVotedPlayer: $mostVotedPlayer, playerRoles: $playerRoles, secretWord: $secretWord}';
  }
}

/// generated route for
/// [RoleRevealScreen]
class RoleRevealRoute extends PageRouteInfo<RoleRevealRouteArgs> {
  RoleRevealRoute({
    Key? key,
    required String gameId,
    List<PageRouteInfo>? children,
  }) : super(
          RoleRevealRoute.name,
          args: RoleRevealRouteArgs(
            key: key,
            gameId: gameId,
          ),
          initialChildren: children,
        );

  static const String name = 'RoleRevealRoute';

  static const PageInfo<RoleRevealRouteArgs> page =
      PageInfo<RoleRevealRouteArgs>(name);
}

class RoleRevealRouteArgs {
  const RoleRevealRouteArgs({
    this.key,
    required this.gameId,
  });

  final Key? key;

  final String gameId;

  @override
  String toString() {
    return 'RoleRevealRouteArgs{key: $key, gameId: $gameId}';
  }
}

/// generated route for
/// [RoundResultsScreen]
class RoundResultsRoute extends PageRouteInfo<RoundResultsRouteArgs> {
  RoundResultsRoute({
    Key? key,
    required String gameId,
    required int roundNumber,
    required int totalRounds,
    required List<RoundScoreResult> scoreResults,
    required List<PlayerRoleInfo> playerRoles,
    required String secretWord,
    required bool impostorsWon,
    required bool wordGuessed,
    List<PageRouteInfo>? children,
  }) : super(
          RoundResultsRoute.name,
          args: RoundResultsRouteArgs(
            key: key,
            gameId: gameId,
            roundNumber: roundNumber,
            totalRounds: totalRounds,
            scoreResults: scoreResults,
            playerRoles: playerRoles,
            secretWord: secretWord,
            impostorsWon: impostorsWon,
            wordGuessed: wordGuessed,
          ),
          initialChildren: children,
        );

  static const String name = 'RoundResultsRoute';

  static const PageInfo<RoundResultsRouteArgs> page =
      PageInfo<RoundResultsRouteArgs>(name);
}

class RoundResultsRouteArgs {
  const RoundResultsRouteArgs({
    this.key,
    required this.gameId,
    required this.roundNumber,
    required this.totalRounds,
    required this.scoreResults,
    required this.playerRoles,
    required this.secretWord,
    required this.impostorsWon,
    required this.wordGuessed,
  });

  final Key? key;

  final String gameId;

  final int roundNumber;

  final int totalRounds;

  final List<RoundScoreResult> scoreResults;

  final List<PlayerRoleInfo> playerRoles;

  final String secretWord;

  final bool impostorsWon;

  final bool wordGuessed;

  @override
  String toString() {
    return 'RoundResultsRouteArgs{key: $key, gameId: $gameId, roundNumber: $roundNumber, totalRounds: $totalRounds, scoreResults: $scoreResults, playerRoles: $playerRoles, secretWord: $secretWord, impostorsWon: $impostorsWon, wordGuessed: $wordGuessed}';
  }
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [VotingScreen]
class VotingRoute extends PageRouteInfo<VotingRouteArgs> {
  VotingRoute({
    Key? key,
    required String roundId,
    required String gameId,
    required RoundBloc roundBloc,
    List<PageRouteInfo>? children,
  }) : super(
          VotingRoute.name,
          args: VotingRouteArgs(
            key: key,
            roundId: roundId,
            gameId: gameId,
            roundBloc: roundBloc,
          ),
          initialChildren: children,
        );

  static const String name = 'VotingRoute';

  static const PageInfo<VotingRouteArgs> page = PageInfo<VotingRouteArgs>(name);
}

class VotingRouteArgs {
  const VotingRouteArgs({
    this.key,
    required this.roundId,
    required this.gameId,
    required this.roundBloc,
  });

  final Key? key;

  final String roundId;

  final String gameId;

  final RoundBloc roundBloc;

  @override
  String toString() {
    return 'VotingRouteArgs{key: $key, roundId: $roundId, gameId: $gameId, roundBloc: $roundBloc}';
  }
}
