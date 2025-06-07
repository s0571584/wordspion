import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../core/router/app_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import '../themes/app_spacing.dart';

@RoutePage()
class ProfileSetupScreen extends StatefulWidget {
  final String userId;
  final String? email;
  final String? name;

  const ProfileSetupScreen({
    super.key,
    required this.userId,
    this.email,
    this.name,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = false;
  String? _usernameError;
  bool _hasCheckedUsername = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill display name if available
    if (widget.name != null && widget.name!.isNotEmpty) {
      _displayNameController.text = widget.name!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _checkUsernameAvailability(String username) {
    print('DEBUG: Checking username availability for: "$username"');
    if (username.length >= 3) {
      setState(() {
        _isCheckingUsername = true;
        _hasCheckedUsername = false;
        _usernameError = null;
      });

      print('DEBUG: Sending AuthCheckUsernameAvailability event');
      context.read<AuthBloc>().add(AuthCheckUsernameAvailability(username));
    } else {
      print('DEBUG: Username too short: ${username.length}');
      setState(() {
        _isUsernameAvailable = false;
        _hasCheckedUsername = false;
        _usernameError = 'Benutzername muss mindestens 3 Zeichen lang sein';
      });
    }
  }

  void _setupProfile() {
    print('DEBUG: _setupProfile called');
    print('DEBUG: _hasCheckedUsername: $_hasCheckedUsername');
    print('DEBUG: _isUsernameAvailable: $_isUsernameAvailable');
    print('DEBUG: username length: ${_usernameController.text.length}');
    print('DEBUG: username: "${_usernameController.text.trim()}"');

    // Force username check if not checked yet
    if (!_hasCheckedUsername && _usernameController.text.length >= 3) {
      print('DEBUG: Triggering username check first');
      _checkUsernameAvailability(_usernameController.text.trim());
      return;
    }

    final isValid = _formKey.currentState!.validate();
    print('DEBUG: Form is valid: $isValid');

    if (isValid && _isUsernameAvailable) {
      print('DEBUG: Sending AuthSetupProfileRequested event');
      context.read<AuthBloc>().add(AuthSetupProfileRequested(
            username: _usernameController.text.trim(),
            displayName: _displayNameController.text.trim().isEmpty ? null : _displayNameController.text.trim(),
          ));
    } else {
      print('DEBUG: Validation failed or username not available');
      print('DEBUG: Form valid: $isValid, Username available: $_isUsernameAvailable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AppAuthState>(
      listener: (context, state) {
        print('DEBUG: AuthBloc state changed: ${state.runtimeType}');
        if (state is AuthAuthenticated) {
          print('DEBUG: Authentication successful, navigating to home');
          // Profile setup complete, navigate to home
          context.router.navigate(const HomeRoute());
        } else if (state is AuthUsernameCheckResult) {
          print('DEBUG: Username check result: ${state.username} -> ${state.isAvailable}');
          setState(() {
            _isCheckingUsername = false;
            _isUsernameAvailable = state.isAvailable;
            _hasCheckedUsername = true;
            _usernameError = state.isAvailable ? null : 'Benutzername ist bereits vergeben';
          });
        } else if (state is AuthError) {
          print('DEBUG: Auth error: ${state.message}');
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Profil einrichten',
            style: AppTypography.headline3.copyWith(
              color: AppColors.onBackground,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Willkommen!',
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s),

                  Text(
                    'Erstelle dein Profil, um mit dem Spielen zu beginnen.',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.onBackground.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Username field
                  Text(
                    'Benutzername *',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s),

                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Dein einzigartiger Benutzername',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.error, width: 2),
                      ),
                      suffixIcon: _isCheckingUsername
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _usernameController.text.length >= 3
                              ? Icon(
                                  _isUsernameAvailable ? Icons.check_circle : Icons.error,
                                  color: _isUsernameAvailable ? AppColors.success : AppColors.error,
                                )
                              : null,
                      errorText: _usernameError,
                    ),
                    onChanged: (value) {
                      // Reset availability when user types
                      setState(() {
                        _hasCheckedUsername = false;
                        _isUsernameAvailable = false;
                      });

                      if (value.length >= 3) {
                        // Debounce username check
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_usernameController.text == value) {
                            _checkUsernameAvailability(value);
                          }
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Benutzername ist erforderlich';
                      }
                      if (value.trim().length < 3) {
                        return 'Benutzername muss mindestens 3 Zeichen lang sein';
                      }
                      if (value.trim().length > 20) {
                        return 'Benutzername darf maximal 20 Zeichen lang sein';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                        return 'Nur Buchstaben, Zahlen und Unterstriche erlaubt';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.l),

                  // Display name field
                  Text(
                    'Anzeigename (optional)',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s),

                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      hintText: 'Wie sollen andere dich sehen?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 30) {
                        return 'Anzeigename darf maximal 30 Zeichen lang sein';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.s),

                  Text(
                    'Falls leer, wird dein Benutzername angezeigt',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onBackground.withOpacity(0.6),
                    ),
                  ),

                  const Spacer(),

                  // Setup button
                  BlocBuilder<AuthBloc, AppAuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _setupProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                          child: isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.onPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.s),
                                    Text('Profil wird erstellt...'),
                                  ],
                                )
                              : const Text('Profil erstellen'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.m),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
