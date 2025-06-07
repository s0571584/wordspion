import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/presentation/themes/app_theme.dart';
import 'package:wortspion/blocs/auth/auth_bloc.dart';
import 'package:wortspion/di/injection_container.dart' as di;

class WortSpionApp extends StatelessWidget {
  const WortSpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'WortSpion',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerDelegate: AutoRouterDelegate(_appRouter),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }

  static final _appRouter = AppRouter();
}
