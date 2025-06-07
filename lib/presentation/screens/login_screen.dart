import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:io';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../core/router/app_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import '../themes/app_spacing.dart';
import '../widgets/app_button.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        } else if (state is AuthError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 50,
                          color: AppColors.onPrimary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Welcome Text
                      Text(
                        'Willkommen bei',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.onBackground.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        'WortSpion',
                        style: AppTypography.headline1.copyWith(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.m),

                      Text(
                        'Spiele mit Freunden online oder lokal und entdecke, wer der Spion ist!',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.onBackground.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<AuthBloc, AppAuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return Column(
                            children: [
                              // Google Sign In Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                                        },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isLoading)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                          ),
                                        )
                                      else
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          width: 20,
                                          height: 20,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.account_circle,
                                              size: 20,
                                              color: AppColors.primary,
                                            );
                                          },
                                        ),
                                      const SizedBox(width: AppSpacing.s),
                                      Text(
                                        'Mit Google anmelden',
                                        style: AppTypography.button.copyWith(
                                          color: AppColors.onBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.m),

                              // Apple Sign In Button (iOS/macOS only)
                              if (Platform.isIOS || Platform.isMacOS)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<AuthBloc>().add(AuthAppleSignInRequested());
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (isLoading)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.apple,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        const SizedBox(width: AppSpacing.s),
                                        Text(
                                          'Mit Apple anmelden',
                                          style: AppTypography.button.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Skip to local game option
                      TextButton(
                        onPressed: () {
                          context.router.navigate(const HomeRoute());
                        },
                        child: Text(
                          'Lokales Spiel starten',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Terms and Privacy
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Text(
                    'Durch die Anmeldung stimmst du unseren Nutzungsbedingungen und Datenschutzrichtlinien zu.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onBackground.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
