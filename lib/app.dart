import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:wortspion/core/router/app_router.dart';
import 'package:wortspion/presentation/themes/app_theme.dart';

class WortSpionApp extends StatelessWidget {
  const WortSpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WortSpion',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerDelegate: AutoRouterDelegate(_appRouter),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }

  static final _appRouter = AppRouter();
}
