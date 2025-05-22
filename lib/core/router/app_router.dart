import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wortspion/blocs/round/round_bloc.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/blocs/voting/voting_state.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/data/models/player.dart';
import 'package:wortspion/data/models/round_score_result.dart';
import 'package:wortspion/presentation/screens/home_screen.dart';
import 'package:wortspion/presentation/screens/game_setup_screen.dart';
import 'package:wortspion/presentation/screens/player_registration_screen.dart';
import 'package:wortspion/presentation/screens/role_reveal_screen.dart';
import 'package:wortspion/presentation/screens/voting_screen.dart';
import 'package:wortspion/presentation/screens/results_screen.dart';
import 'package:wortspion/presentation/screens/splash_screen.dart';
import 'package:wortspion/presentation/screens/game_play_screen.dart';
import 'package:wortspion/presentation/screens/round_results_screen.dart';
import 'package:wortspion/presentation/screens/final_results_screen.dart';
import 'package:wortspion/presentation/screens/player_groups_screen.dart';
import 'package:wortspion/presentation/screens/create_edit_player_group_screen.dart';
import 'package:wortspion/core/utils/round_results_state.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page, path: '/home'),
        AutoRoute(page: GameSetupRoute.page, path: '/game-setup'),
        AutoRoute(page: PlayerRegistrationRoute.page, path: '/player-registration'),
        AutoRoute(page: RoleRevealRoute.page, path: '/role-reveal'),
        AutoRoute(page: GamePlayRoute.page, path: '/game-play'),
        AutoRoute(page: VotingRoute.page, path: '/voting'),
        AutoRoute(page: ResultsRoute.page, path: '/results'),
        // New round scoring routes
        AutoRoute(
          page: RoundResultsRoute.page,
          path: '/round-results',
        ),
        AutoRoute(
          page: FinalResultsRoute.page,
          path: '/final-results',
        ),
        // Player Groups routes
        AutoRoute(page: PlayerGroupsRoute.page, path: '/player-groups'),
        AutoRoute(page: CreateEditPlayerGroupRoute.page, path: '/create-edit-player-group'),
      ];
}
