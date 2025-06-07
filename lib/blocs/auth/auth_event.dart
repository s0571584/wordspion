import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthAppleSignInRequested extends AuthEvent {}

class AuthSetupProfileRequested extends AuthEvent {
  final String username;
  final String? displayName;

  const AuthSetupProfileRequested({
    required this.username,
    this.displayName,
  });

  @override
  List<Object?> get props => [username, displayName];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final String? userId;

  const AuthUserChanged(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String username;
  final String? displayName;
  final String? avatarUrl;

  const AuthProfileUpdateRequested({
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [username, displayName, avatarUrl];
}

class AuthCheckUsernameAvailability extends AuthEvent {
  final String username;

  const AuthCheckUsernameAvailability(this.username);

  @override
  List<Object> get props => [username];
}