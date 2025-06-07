import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_profile.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AppAuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<AuthSetupProfileRequested>(_onSetupProfileRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthCheckUsernameAvailability>(_onCheckUsernameAvailability);

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      add(AuthUserChanged(authState.session?.user.id));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAuthStarted(AuthStarted event, Emitter<AppAuthState> emit) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        final profile = await _authRepository.getUserProfile(user.id);
        emit(AuthAuthenticated(userId: user.id, profile: profile));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to initialize authentication: ${e.toString()}'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        await _handleSignInSuccess(user, emit);
      } else {
        emit(const AuthError(message: 'Google sign-in was cancelled'));
      }
    } on supabase.AuthException catch (e) {
      emit(AuthError(
        message: _getAuthErrorMessage(e.message),
        code: e.statusCode,
      ));
    } catch (e) {
      emit(AuthError(message: 'Google sign-in failed: ${e.toString()}'));
    }
  }

  Future<void> _onAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signInWithApple();
      if (user != null) {
        await _handleSignInSuccess(user, emit);
      } else {
        emit(const AuthError(message: 'Apple sign-in was cancelled'));
      }
    } on supabase.AuthException catch (e) {
      emit(AuthError(
        message: _getAuthErrorMessage(e.message),
        code: e.statusCode,
      ));
    } catch (e) {
      emit(AuthError(message: 'Apple sign-in failed: ${e.toString()}'));
    }
  }

  Future<void> _onSetupProfileRequested(
    AuthSetupProfileRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    print('DEBUG: AuthBloc received AuthSetupProfileRequested');
    print('DEBUG: Current state: ${state.runtimeType}');
    print('DEBUG: Username: ${event.username}');
    print('DEBUG: Display name: ${event.displayName}');
    
    String userId;
    String? email;
    String? name;
    
    if (state is AuthNeedsProfileSetup) {
      final currentState = state as AuthNeedsProfileSetup;
      userId = currentState.userId;
      email = currentState.email;
      name = currentState.name;
    } else if (state is AuthUsernameCheckResult) {
      final currentState = state as AuthUsernameCheckResult;
      userId = currentState.userId;
      email = currentState.email;
      name = currentState.name;
    } else {
      print('DEBUG: Invalid state for profile setup: ${state.runtimeType}');
      return;
    }

    print('DEBUG: Emitting AuthLoading');
    emit(AuthLoading());

    try {
      // Check username availability first
      print('DEBUG: Checking username availability');
      final isAvailable = await _authRepository.isUsernameAvailable(event.username);
      print('DEBUG: Username available: $isAvailable');
      
      if (!isAvailable) {
        print('DEBUG: Username not available, emitting error');
        emit(const AuthError(
          message: 'Username is already taken',
          code: 'username_taken',
        ));
        return;
      }

      // Create user profile
      print('DEBUG: Creating user profile');
      final profile = await _authRepository.createUserProfile(
        userId: userId,
        username: event.username,
        displayName: event.displayName ?? name,
      );

      print('DEBUG: Profile created successfully: ${profile.username}');
      emit(AuthAuthenticated(userId: userId, profile: profile));
    } catch (e) {
      print('DEBUG: Error creating profile: $e');
      emit(AuthError(message: 'Failed to setup profile: ${e.toString()}'));
      // Restore previous state - go back to profile setup
      emit(AuthNeedsProfileSetup(
        userId: userId,
        email: email,
        name: name,
      ));
    }
  }

  Future<void> _handleSignInSuccess(
    supabase.User user,
    Emitter<AppAuthState> emit,
  ) async {
    try {
      final profile = await _authRepository.getUserProfile(user.id);
      if (profile != null) {
        // User has a profile, sign them in
        emit(AuthAuthenticated(userId: user.id, profile: profile));
      } else {
        // New user needs to set up profile
        emit(AuthNeedsProfileSetup(
          userId: user.id,
          email: user.email,
          name: user.userMetadata?['full_name'] as String?,
        ));
      }
    } catch (e) {
      // Profile doesn't exist, user needs to set it up
      emit(AuthNeedsProfileSetup(
        userId: user.id,
        email: user.email,
        name: user.userMetadata?['full_name'] as String?,
      ));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to sign out: ${e.toString()}'));
    }
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AppAuthState> emit,
  ) async {
    if (event.userId != null) {
      try {
        final profile = await _authRepository.getUserProfile(event.userId!);
        if (profile != null) {
          emit(AuthAuthenticated(userId: event.userId!, profile: profile));
        } else {
          // User exists but no profile - redirect to profile setup
          final user = await _authRepository.getCurrentUser();
          emit(AuthNeedsProfileSetup(
            userId: event.userId!,
            email: user?.email,
            name: user?.userMetadata?['full_name'] as String?,
          ));
        }
      } catch (e) {
        // User exists but no profile - redirect to profile setup
        final user = await _authRepository.getCurrentUser();
        emit(AuthNeedsProfileSetup(
          userId: event.userId!,
          email: user?.email,
          name: user?.userMetadata?['full_name'] as String?,
        ));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AppAuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;
    emit(AuthLoading());

    try {
      final currentProfile = currentState.profile;
      if (currentProfile != null) {
        final updatedProfile = await _authRepository.updateUserProfile(
          currentProfile.copyWith(
            username: event.username,
            displayName: event.displayName,
            avatarUrl: event.avatarUrl,
          ),
        );

        emit(AuthAuthenticated(
          userId: currentState.userId,
          profile: updatedProfile,
        ));
      } else {
        emit(const AuthError(message: 'No profile found to update'));
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to update profile: ${e.toString()}'));
      // Restore previous state
      emit(currentState);
    }
  }

  Future<void> _onCheckUsernameAvailability(
    AuthCheckUsernameAvailability event,
    Emitter<AppAuthState> emit,
  ) async {
    print('DEBUG: AuthBloc checking username availability for: ${event.username}');
    
    // Get the current setup state
    if (state is! AuthNeedsProfileSetup) {
      print('DEBUG: Username check called from invalid state: ${state.runtimeType}');
      return;
    }
    
    final currentState = state as AuthNeedsProfileSetup;
    
    try {
      final isAvailable = await _authRepository.isUsernameAvailable(event.username);
      print('DEBUG: Username check result: ${event.username} -> $isAvailable');
      emit(AuthUsernameCheckResult(
        username: event.username,
        isAvailable: isAvailable,
        userId: currentState.userId,
        email: currentState.email,
        name: currentState.name,
      ));
    } catch (e) {
      print('DEBUG: Username check error: $e');
      emit(AuthError(message: 'Failed to check username availability: ${e.toString()}'));
    }
  }

  String _getAuthErrorMessage(String error) {
    switch (error.toLowerCase()) {
      case 'invalid login credentials':
        return 'Sign-in failed. Please try again.';
      case 'email address not confirmed':
        return 'Please verify your email address';
      case 'user already registered':
        return 'Account already exists';
      case 'signup disabled':
        return 'Sign-in is currently disabled';
      case 'provider not found':
        return 'This sign-in method is not available';
      default:
        return error;
    }
  }
}
