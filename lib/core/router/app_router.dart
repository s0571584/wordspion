import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wortspion/blocs/round/round_bloc.dart';
import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/blocs/voting/voting_state.dart';
import 'package:wortspion/data/models/game.dart';
import 'package:wortspion/data/models/player.dart';
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

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: GameSetupRoute.page),
        AutoRoute(page: PlayerRegistrationRoute.page),
        AutoRoute(page: RoleRevealRoute.page),
        AutoRoute(page: GamePlayRoute.page),
        AutoRoute(page: VotingRoute.page),
        AutoRoute(page: ResultsRoute.page),
        // New round scoring routes
        AutoRoute(page: RoundResultsRoute.page),
        AutoRoute(page: FinalResultsRoute.page),
        // Player Groups routes
        AutoRoute(page: PlayerGroupsRoute.page),
        AutoRoute(page: CreateEditPlayerGroupRoute.page),
      ];
}
