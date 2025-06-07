import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../core/router/app_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

@RoutePage()
class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start authentication check
    context.read<AuthBloc>().add(AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AppAuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, navigate to home
          context.router.navigate(const HomeRoute());
        } else if (state is AuthNeedsProfileSetup) {
          // User needs to set up profile
          context.router.navigate(ProfileSetupRoute(
            userId: state.userId,
            email: state.email,
            name: state.name,
          ));
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated, navigate to login
          context.router.navigate(const LoginRoute());
        } else if (state is AuthError) {
          // Show error and navigate to login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          context.router.navigate(const LoginRoute());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 60,
                  color: AppColors.onPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              Text(
                'WortSpion',
                style: AppTypography.headline1.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Das soziale Deduktionsspiel',
                style: AppTypography.body1.copyWith(
                  color: AppColors.onBackground.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 48),

              // Loading Indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Wird geladen...',
                style: AppTypography.body2.copyWith(
                  color: AppColors.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
