import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<supabase.User?> signInWithGoogle();
  Future<supabase.User?> signInWithApple();
  Future<void> signOut();
  Future<supabase.User?> getCurrentUser();
  Stream<supabase.AuthState> get authStateChanges;

  Future<UserProfile> createUserProfile({
    required String userId,
    required String username,
    String? displayName,
    String? avatarUrl,
  });

  Future<UserProfile?> getUserProfile(String userId);
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<bool> isUsernameAvailable(String username);
}

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;
  late final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._client) {
    // Configure Google Sign-In for Android with Supabase
    // Note: Supabase requires the Web Client ID even for mobile apps
    _googleSignIn = GoogleSignIn(
      serverClientId: '683573802211-r1k2bfqgpdu21pe8qoic23on35orn5sl.apps.googleusercontent.com', // Replace this!
      scopes: ['email', 'profile'],
    );
  }

  @override
  Future<supabase.User?> signInWithGoogle() async {
    try {
      // Debug: Test network connectivity first
      print('Testing network connectivity...');

      // First, sign out any existing Google account to ensure clean state
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('User cancelled Google sign-in');
        return null;
      }

      print('Google user: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      print('Got Google auth tokens, sending to Supabase...');

      final response = await _client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      print('Supabase sign-in successful: ${response.user?.email}');
      
      // Ensure user profile exists
      if (response.user != null) {
        await _ensureUserProfile(response.user!);
      }
      
      return response.user;
    } catch (e) {
      print('Google sign-in error: $e');
      // Sign out on error to ensure clean state
      await _googleSignIn.signOut();
      throw Exception('Google sign-in failed: $e');
    }
  }

  @override
  Future<supabase.User?> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw Exception('Apple sign-in is only available on iOS and macOS');
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await _client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      return response.user;
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<supabase.User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  @override
  Stream<supabase.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<UserProfile> createUserProfile({
    required String userId,
    required String username,
    String? displayName,
    String? avatarUrl,
  }) async {
    final now = DateTime.now();
    final profileData = {
      'id': userId,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _client.from('user_profiles').insert(profileData).select().single();

    return UserProfile.fromJson(response);
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client.from('user_profiles').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final response = await _client
        .from('user_profiles')
        .update({
          'username': profile.username,
          'display_name': profile.displayName,
          'avatar_url': profile.avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', profile.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _client.from('user_profiles').select('id').eq('username', username).maybeSingle();

      return response == null;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to ensure user profile exists after authentication
  Future<void> _ensureUserProfile(supabase.User user) async {
    try {
      // Check if profile already exists
      final existingProfile = await getUserProfile(user.id);
      if (existingProfile != null) {
        print('User profile already exists: ${existingProfile.username}');
        return;
      }

      // Create profile if it doesn't exist
      final username = user.userMetadata?['name'] ?? 
                      user.email ?? 
                      'User_${user.id.substring(0, 8)}';
      
      final displayName = user.userMetadata?['full_name'] ?? 
                         user.userMetadata?['name'];
      
      final avatarUrl = user.userMetadata?['avatar_url'];

      await createUserProfile(
        userId: user.id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      
      print('Created user profile for: $username');
    } catch (e) {
      print('Error ensuring user profile: $e');
      // Don't throw - authentication can still succeed
    }
  }
}
