import 'package:equatable/equatable.dart';
import '../../data/models/user_profile.dart';

abstract class AppAuthState extends Equatable {
  const AppAuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AppAuthState {}

class AuthLoading extends AppAuthState {}

class AuthAuthenticated extends AppAuthState {
  final String userId;
  final UserProfile? profile;

  const AuthAuthenticated({
    required this.userId,
    this.profile,
  });

  @override
  List<Object?> get props => [userId, profile];

  AuthAuthenticated copyWith({
    String? userId,
    UserProfile? profile,
  }) {
    return AuthAuthenticated(
      userId: userId ?? this.userId,
      profile: profile ?? this.profile,
    );
  }

  bool get hasProfile => profile != null;
  String get displayName => profile?.displayName ?? profile?.username ?? 'User';
}

class AuthUnauthenticated extends AppAuthState {}

class AuthError extends AppAuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class AuthNeedsProfileSetup extends AppAuthState {
  final String userId;
  final String? email;
  final String? name;

  const AuthNeedsProfileSetup({
    required this.userId,
    this.email,
    this.name,
  });

  @override
  List<Object?> get props => [userId, email, name];
}

class AuthUsernameCheckResult extends AppAuthState {
  final String username;
  final bool isAvailable;
  final String userId;
  final String? email;
  final String? name;

  const AuthUsernameCheckResult({
    required this.username,
    required this.isAvailable,
    required this.userId,
    this.email,
    this.name,
  });

  @override
  List<Object?> get props => [username, isAvailable, userId, email, name];
}