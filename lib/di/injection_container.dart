import 'package:get_it/get_it.dart';
import 'package:wortspion/core/services/score_calculator.dart';
import 'package:wortspion/core/services/timer_service.dart';
import 'package:wortspion/data/repositories/game_repository.dart';
import 'package:wortspion/data/repositories/game_repository_impl.dart';
import 'package:wortspion/data/repositories/word_repository.dart';
import 'package:wortspion/data/repositories/round_repository.dart';
import 'package:wortspion/data/repositories/player_group_repository.dart';
import 'package:wortspion/data/repositories/player_group_repository_impl.dart';
import 'package:wortspion/data/sources/local/database_helper.dart';
import 'package:wortspion/blocs/game/game_bloc.dart';
import 'package:wortspion/blocs/player/player_bloc.dart';
import 'package:wortspion/blocs/round/round_bloc.dart';
import 'package:wortspion/blocs/voting/voting_bloc.dart';
import 'package:wortspion/blocs/settings/settings_bloc.dart';
import 'package:wortspion/blocs/timer/timer_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Database
  final databaseHelper = await DatabaseHelper.instance;
  sl.registerLazySingleton<DatabaseHelper>(() => databaseHelper);

  // Repositories
  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(databaseHelper: sl()),
  );

  sl.registerLazySingleton<WordRepository>(
    () => WordRepositoryImpl(databaseHelper: sl()),
  );

  sl.registerLazySingleton<RoundRepository>(
    () => RoundRepositoryImpl(databaseHelper: sl()),
  );

  sl.registerLazySingleton<PlayerGroupRepository>(
    () => PlayerGroupRepositoryImpl(databaseHelper: sl()),
  );

  // Services
  sl.registerLazySingleton<TimerService>(
    () => TimerServiceImpl(),
  );
  
  sl.registerLazySingleton<ScoreCalculator>(
    () => ScoreCalculator(),
  );

  // BLoCs
  sl.registerFactory<GameBloc>(
    () => GameBloc(
      gameRepository: sl(),
      scoreCalculator: sl(),
    ),
  );

  sl.registerFactory<PlayerBloc>(
    () => PlayerBloc(gameRepository: sl()),
  );

  sl.registerFactory<RoundBloc>(
    () => RoundBloc(
      gameRepository: sl(),
      wordRepository: sl(),
      roundRepository: sl(),
      scoreCalculator: sl(),
    ),
  );

  sl.registerFactory<VotingBloc>(
    () => VotingBloc(
      gameRepository: sl(),
      roundRepository: sl(),
    ),
  );

  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(),
  );

  sl.registerFactory<TimerBloc>(
    () => TimerBloc(timerService: sl()),
  );

  sl.registerFactory<PlayerGroupBloc>(
    () => PlayerGroupBloc(playerGroupRepository: sl()),
  );
}
