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
    AuthSplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AuthSplashScreen(),
      );
    },
    CategorySelectionRoute.name: (routeData) {
      final args = routeData.argsAs<CategorySelectionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CategorySelectionScreen(
          key: args.key,
          playerCount: args.playerCount,
          impostorCount: args.impostorCount,
          saboteurCount: args.saboteurCount,
          roundCount: args.roundCount,
          timerDuration: args.timerDuration,
          impostorsKnowEachOther: args.impostorsKnowEachOther,
          groupPlayerNames: args.groupPlayerNames,
        ),
      );
    },
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
          fromGroup: args.fromGroup,
          groupPlayerNames: args.groupPlayerNames,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MultiplayerGameModeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MultiplayerGameModeScreen(),
      );
    },
    MultiplayerGameRoute.name: (routeData) {
      final args = routeData.argsAs<MultiplayerGameRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MultiplayerGameScreen(
          key: args.key,
          roomId: args.roomId,
        ),
      );
    },
    MultiplayerLobbyRoute.name: (routeData) {
      final args = routeData.argsAs<MultiplayerLobbyRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MultiplayerLobbyScreen(
          key: args.key,
          roomId: args.roomId,
        ),
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
    ProfileSetupRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileSetupRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProfileSetupScreen(
          key: args.key,
          userId: args.userId,
          email: args.email,
          name: args.name,
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
          gameId: args.gameId,
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
/// [AuthSplashScreen]
class AuthSplashRoute extends PageRouteInfo<void> {
  const AuthSplashRoute({List<PageRouteInfo>? children})
      : super(
          AuthSplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthSplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CategorySelectionScreen]
class CategorySelectionRoute extends PageRouteInfo<CategorySelectionRouteArgs> {
  CategorySelectionRoute({
    Key? key,
    required int playerCount,
    required int impostorCount,
    int saboteurCount = 0,
    required int roundCount,
    required int timerDuration,
    required bool impostorsKnowEachOther,
    List<String>? groupPlayerNames,
    List<PageRouteInfo>? children,
  }) : super(
          CategorySelectionRoute.name,
          args: CategorySelectionRouteArgs(
            key: key,
            playerCount: playerCount,
            impostorCount: impostorCount,
            saboteurCount: saboteurCount,
            roundCount: roundCount,
            timerDuration: timerDuration,
            impostorsKnowEachOther: impostorsKnowEachOther,
            groupPlayerNames: groupPlayerNames,
          ),
          initialChildren: children,
        );

  static const String name = 'CategorySelectionRoute';

  static const PageInfo<CategorySelectionRouteArgs> page =
      PageInfo<CategorySelectionRouteArgs>(name);
}

class CategorySelectionRouteArgs {
  const CategorySelectionRouteArgs({
    this.key,
    required this.playerCount,
    required this.impostorCount,
    this.saboteurCount = 0,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
    this.groupPlayerNames,
  });

  final Key? key;

  final int playerCount;

  final int impostorCount;

  final int saboteurCount;

  final int roundCount;

  final int timerDuration;

  final bool impostorsKnowEachOther;

  final List<String>? groupPlayerNames;

  @override
  String toString() {
    return 'CategorySelectionRouteArgs{key: $key, playerCount: $playerCount, impostorCount: $impostorCount, saboteurCount: $saboteurCount, roundCount: $roundCount, timerDuration: $timerDuration, impostorsKnowEachOther: $impostorsKnowEachOther, groupPlayerNames: $groupPlayerNames}';
  }
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
    bool fromGroup = false,
    List<String>? groupPlayerNames,
    List<PageRouteInfo>? children,
  }) : super(
          GameSetupRoute.name,
          args: GameSetupRouteArgs(
            key: key,
            isSettingsOnly: isSettingsOnly,
            fromGroup: fromGroup,
            groupPlayerNames: groupPlayerNames,
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
    this.fromGroup = false,
    this.groupPlayerNames,
  });

  final Key? key;

  final bool isSettingsOnly;

  final bool fromGroup;

  final List<String>? groupPlayerNames;

  @override
  String toString() {
    return 'GameSetupRouteArgs{key: $key, isSettingsOnly: $isSettingsOnly, fromGroup: $fromGroup, groupPlayerNames: $groupPlayerNames}';
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
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MultiplayerGameModeScreen]
class MultiplayerGameModeRoute extends PageRouteInfo<void> {
  const MultiplayerGameModeRoute({List<PageRouteInfo>? children})
      : super(
          MultiplayerGameModeRoute.name,
          initialChildren: children,
        );

  static const String name = 'MultiplayerGameModeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MultiplayerGameScreen]
class MultiplayerGameRoute extends PageRouteInfo<MultiplayerGameRouteArgs> {
  MultiplayerGameRoute({
    Key? key,
    required String roomId,
    List<PageRouteInfo>? children,
  }) : super(
          MultiplayerGameRoute.name,
          args: MultiplayerGameRouteArgs(
            key: key,
            roomId: roomId,
          ),
          initialChildren: children,
        );

  static const String name = 'MultiplayerGameRoute';

  static const PageInfo<MultiplayerGameRouteArgs> page =
      PageInfo<MultiplayerGameRouteArgs>(name);
}

class MultiplayerGameRouteArgs {
  const MultiplayerGameRouteArgs({
    this.key,
    required this.roomId,
  });

  final Key? key;

  final String roomId;

  @override
  String toString() {
    return 'MultiplayerGameRouteArgs{key: $key, roomId: $roomId}';
  }
}

/// generated route for
/// [MultiplayerLobbyScreen]
class MultiplayerLobbyRoute extends PageRouteInfo<MultiplayerLobbyRouteArgs> {
  MultiplayerLobbyRoute({
    Key? key,
    required String roomId,
    List<PageRouteInfo>? children,
  }) : super(
          MultiplayerLobbyRoute.name,
          args: MultiplayerLobbyRouteArgs(
            key: key,
            roomId: roomId,
          ),
          initialChildren: children,
        );

  static const String name = 'MultiplayerLobbyRoute';

  static const PageInfo<MultiplayerLobbyRouteArgs> page =
      PageInfo<MultiplayerLobbyRouteArgs>(name);
}

class MultiplayerLobbyRouteArgs {
  const MultiplayerLobbyRouteArgs({
    this.key,
    required this.roomId,
  });

  final Key? key;

  final String roomId;

  @override
  String toString() {
    return 'MultiplayerLobbyRouteArgs{key: $key, roomId: $roomId}';
  }
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
/// [ProfileSetupScreen]
class ProfileSetupRoute extends PageRouteInfo<ProfileSetupRouteArgs> {
  ProfileSetupRoute({
    Key? key,
    required String userId,
    String? email,
    String? name,
    List<PageRouteInfo>? children,
  }) : super(
          ProfileSetupRoute.name,
          args: ProfileSetupRouteArgs(
            key: key,
            userId: userId,
            email: email,
            name: name,
          ),
          initialChildren: children,
        );

  static const String name = 'ProfileSetupRoute';

  static const PageInfo<ProfileSetupRouteArgs> page =
      PageInfo<ProfileSetupRouteArgs>(name);
}

class ProfileSetupRouteArgs {
  const ProfileSetupRouteArgs({
    this.key,
    required this.userId,
    this.email,
    this.name,
  });

  final Key? key;

  final String userId;

  final String? email;

  final String? name;

  @override
  String toString() {
    return 'ProfileSetupRouteArgs{key: $key, userId: $userId, email: $email, name: $name}';
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
    required String gameId,
    List<PageRouteInfo>? children,
  }) : super(
          ResultsRoute.name,
          args: ResultsRouteArgs(
            key: key,
            votingResults: votingResults,
            mostVotedPlayer: mostVotedPlayer,
            playerRoles: playerRoles,
            secretWord: secretWord,
            gameId: gameId,
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
    required this.gameId,
  });

  final Key? key;

  final List<VotingResult> votingResults;

  final Player? mostVotedPlayer;

  final List<PlayerRoleInfo> playerRoles;

  final String secretWord;

  final String gameId;

  @override
  String toString() {
    return 'ResultsRouteArgs{key: $key, votingResults: $votingResults, mostVotedPlayer: $mostVotedPlayer, playerRoles: $playerRoles, secretWord: $secretWord, gameId: $gameId}';
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
