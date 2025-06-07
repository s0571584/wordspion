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
import 'package:wortspion/presentation/screens/category_selection_screen.dart';
import 'package:wortspion/presentation/screens/auth_splash_screen.dart';
import 'package:wortspion/presentation/screens/login_screen.dart';
import 'package:wortspion/presentation/screens/profile_setup_screen.dart';
import 'package:wortspion/presentation/screens/multiplayer_game_mode_screen.dart';
import 'package:wortspion/presentation/screens/multiplayer_lobby_screen.dart';
import 'package:wortspion/presentation/screens/multiplayer_game_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        // Auth routes
        AutoRoute(page: AuthSplashRoute.page, path: '/auth-splash', initial: true),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: ProfileSetupRoute.page, path: '/profile-setup'),

        // Multiplayer routes
        AutoRoute(page: MultiplayerGameModeRoute.page, path: '/multiplayer'),
        AutoRoute(page: MultiplayerLobbyRoute.page, path: '/multiplayer/lobby'),
        AutoRoute(page: MultiplayerGameRoute.page, path: '/multiplayer/game'),

        // Local game routes (keep existing)
        AutoRoute(page: SplashRoute.page, path: '/splash'),
        AutoRoute(page: HomeRoute.page, path: '/home'),
        AutoRoute(page: GameSetupRoute.page, path: '/game-setup'),
        AutoRoute(page: CategorySelectionRoute.page, path: '/category-selection'),
        AutoRoute(page: PlayerRegistrationRoute.page, path: '/player-registration'),
        AutoRoute(page: RoleRevealRoute.page, path: '/role-reveal'),
        AutoRoute(page: GamePlayRoute.page, path: '/game-play'),
        AutoRoute(page: VotingRoute.page, path: '/voting'),
        AutoRoute(page: ResultsRoute.page, path: '/results'),
        AutoRoute(page: RoundResultsRoute.page, path: '/round-results'),
        AutoRoute(page: FinalResultsRoute.page, path: '/final-results'),
        AutoRoute(page: PlayerGroupsRoute.page, path: '/player-groups'),
        AutoRoute(page: CreateEditPlayerGroupRoute.page, path: '/create-edit-player-group'),
      ];
}
