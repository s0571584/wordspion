# Phase 2: Authentication Setup

This document covers the implementation of user authentication using Supabase Auth and integration with the Flutter app.

## Prerequisites

- [ ] Database tables created (Phase 1 completed)
- [ ] Supabase project URL and anon key available
- [ ] Flutter app configured with Supabase SDK

## 1. Supabase Auth Configuration

### 1.1 Enable Auth Providers

In Supabase Dashboard → Authentication → Providers:

- [ ] Enable Email/Password authentication
- [ ] Enable Magic Link (optional)
- [ ] Configure email templates (German language)
- [ ] Set redirect URLs for the app

### 1.2 Auth Settings

```yaml
# Supabase Dashboard → Authentication → Settings
Site URL: https://your-app.com
Redirect URLs:
  - wortspion://auth-callback
  - http://localhost:3000/auth-callback (for development)

# Email Settings
Enable email confirmations: false (for MVP)
Enable double opt-in: false

# Security
Enable captcha: true (for production)
```

## 2. Database Triggers for User Management

```sql
-- Automatically create user profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, username, display_name)
  VALUES (
    NEW.id,
    LOWER(SPLIT_PART(NEW.email, '@', 1) || '_' || SUBSTRING(NEW.id::TEXT, 1, 4)),
    SPLIT_PART(NEW.email, '@', 1)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to check username availability
CREATE OR REPLACE FUNCTION check_username_available(desired_username TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM user_profiles 
    WHERE username = LOWER(desired_username)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## 3. Flutter Authentication Implementation

### 3.1 Dependencies

```yaml
# pubspec.yaml additions
dependencies:
  supabase_flutter: ^2.3.0
  flutter_secure_storage: ^9.0.0
```

### 3.2 Supabase Initialization

```dart
// lib/core/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}
```

### 3.3 Auth Repository

```dart
// lib/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<AuthResponse> signUp({required String email, required String password});
  Future<AuthResponse> signIn({required String email, required String password});
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile profile);
  Future<bool> checkUsernameAvailable(String username);
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;
  
  SupabaseAuthRepository(this._supabase);
  
  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  @override
  Future<AuthResponse> signUp({
    required String email, 
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Signup failed');
      }
      
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Invalid credentials');
      }
      
      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }
  
  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
          
      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _supabase
        .from('user_profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }
  
  @override
  Future<bool> checkUsernameAvailable(String username) async {
    final response = await _supabase
        .rpc('check_username_available', params: {
          'desired_username': username,
        });
    
    return response as bool;
  }
  
  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return Exception('Invalid email or password');
        case '422':
          return Exception('Email already registered');
        default:
          return Exception(error.message);
      }
    }
    return Exception('Authentication failed');
  }
}
```

### 3.4 Auth BLoC

```dart
// lib/blocs/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  
  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.username,
  });
  
  @override
  List<Object?> get props => [email, password, username];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  
  AuthSignInRequested({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final UserProfile profile;
  
  AuthAuthenticated({required this.user, required this.profile});
  
  @override
  List<Object?> get props => [user, profile];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authSubscription;
  
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    
    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        add(AuthCheckRequested());
      } else if (authState.event == AuthChangeEvent.signedOut) {
        emit(AuthUnauthenticated());
      }
    });
  }
  
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      final profile = await _authRepository.getUserProfile(user.id);
      if (profile != null) {
        emit(AuthAuthenticated(user: user, profile: profile));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Check username availability
      final isAvailable = await _authRepository.checkUsernameAvailable(event.username);
      if (!isAvailable) {
        emit(AuthError('Username already taken'));
        return;
      }
      
      // Sign up
      final response = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      
      if (response.user != null) {
        // Update username
        await _authRepository.updateUserProfile(
          UserProfile(
            id: response.user!.id,
            username: event.username,
            displayName: event.username,
          ),
        );
        
        final profile = await _authRepository.getUserProfile(response.user!.id);
        emit(AuthAuthenticated(user: response.user!, profile: profile!));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
```

## 4. UI Implementation

### 4.1 Sign In Screen

```dart
// lib/presentation/screens/auth/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anmelden')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bitte E-Mail eingeben';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Passwort',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bitte Passwort eingeben';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: Text('Anmelden'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign-up');
                    },
                    child: Text('Noch kein Konto? Registrieren'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }
}
```

### 4.2 Sign Up Screen

```dart
// lib/presentation/screens/auth/sign_up_screen.dart
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrieren')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Benutzername',
                      prefixIcon: Icon(Icons.person),
                      suffixIcon: _isCheckingUsername
                          ? CircularProgressIndicator()
                          : _isUsernameAvailable
                              ? Icon(Icons.check, color: Colors.green)
                              : Icon(Icons.close, color: Colors.red),
                    ),
                    onChanged: _checkUsername,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Bitte Benutzername eingeben';
                      }
                      if (!_isUsernameAvailable) {
                        return 'Benutzername bereits vergeben';
                      }
                      return null;
                    },
                  ),
                  // Email and password fields...
                  ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Registrieren'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _checkUsername(String username) async {
    if (username.length < 3) return;
    
    setState(() => _isCheckingUsername = true);
    
    final isAvailable = await context
        .read<AuthRepository>()
        .checkUsernameAvailable(username);
        
    setState(() {
      _isCheckingUsername = false;
      _isUsernameAvailable = isAvailable;
    });
  }
  
  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
        ),
      );
    }
  }
}
```

## 5. Profile Management

### 5.1 Profile Screen

```dart
// lib/presentation/screens/profile/profile_screen.dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return SizedBox();
        }
        
        final profile = state.profile;
        
        return Scaffold(
          appBar: AppBar(title: Text('Profil')),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(profile.displayName[0].toUpperCase()),
                ),
                SizedBox(height: 16),
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '@${profile.username}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 32),
                _StatCard(
                  title: 'Spiele gespielt',
                  value: profile.gamesPlayed.toString(),
                ),
                _StatCard(
                  title: 'Spiele gewonnen',
                  value: profile.gamesWon.toString(),
                ),
                _StatCard(
                  title: 'Gesamtpunkte',
                  value: profile.totalScore.toString(),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                  child: Text('Abmelden'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## 6. Auth Guard / Navigation

### 6.1 Auth Guard Widget

```dart
// lib/presentation/widgets/auth_guard.dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  
  const AuthGuard({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return child;
        } else if (state is AuthUnauthenticated) {
          // Navigate to sign in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/sign-in');
          });
          return SizedBox();
        } else {
          // Loading state
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
```

### 6.2 App Router Update

```dart
// lib/core/navigation/app_router.dart
@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashScreen, initial: true),
    AutoRoute(page: SignInScreen),
    AutoRoute(page: SignUpScreen),
    AutoRoute(
      page: AuthGuard,
      children: [
        AutoRoute(page: HomeScreen),
        AutoRoute(page: ProfileScreen),
        AutoRoute(page: CreateRoomScreen),
        AutoRoute(page: JoinRoomScreen),
        // ... other authenticated routes
      ],
    ),
  ],
)
class $AppRouter {}
```

## 7. Session Management

### 7.1 Auto-refresh Token

```dart
// lib/core/services/session_service.dart
class SessionService {
  final SupabaseClient _supabase;
  Timer? _refreshTimer;
  
  SessionService(this._supabase) {
    _setupAutoRefresh();
  }
  
  void _setupAutoRefresh() {
    // Check session every 5 minutes
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final expiresAt = session.expiresAt;
        if (expiresAt != null) {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          // Refresh if expires in less than 10 minutes
          if (expiresAt - now < 600) {
            await _supabase.auth.refreshSession();
          }
        }
      }
    });
  }
  
  void dispose() {
    _refreshTimer?.cancel();
  }
}
```

## 8. Error Handling

### 8.1 Auth Error Messages (German)

```dart
// lib/core/constants/auth_messages.dart
class AuthMessages {
  static const Map<String, String> errorMessages = {
    'Invalid login credentials': 'Ungültige Anmeldedaten',
    'Email already registered': 'E-Mail bereits registriert',
    'Password should be at least 6 characters': 'Passwort muss mindestens 6 Zeichen lang sein',
    'Invalid email': 'Ungültige E-Mail-Adresse',
    'User not found': 'Benutzer nicht gefunden',
    'Network error': 'Netzwerkfehler',
  };
  
  static String getErrorMessage(String error) {
    for (final entry in errorMessages.entries) {
      if (error.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Ein Fehler ist aufgetreten';
  }
}
```

## 9. Testing

### 9.1 Auth Repository Tests

```dart
// test/data/repositories/auth_repository_test.dart
void main() {
  group('AuthRepository', () {
    late MockSupabaseClient mockSupabase;
    late AuthRepository repository;
    
    setUp(() {
      mockSupabase = MockSupabaseClient();
      repository = SupabaseAuthRepository(mockSupabase);
    });
    
    test('signUp creates user and profile', () async {
      // Arrange
      when(mockSupabase.auth.signUp(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(user: testUser));
      
      // Act
      final response = await repository.signUp(
        email: 'test@example.com',
        password: 'password123',
      );
      
      // Assert
      expect(response.user, isNotNull);
    });
    
    test('checkUsernameAvailable returns correct value', () async {
      // Test implementation...
    });
  });
}
```

## Verification Checklist

- [ ] Supabase Auth configured with email/password
- [ ] Database trigger for user profile creation working
- [ ] Flutter app initialized with Supabase
- [ ] Auth repository implemented and tested
- [ ] Auth BLoC working correctly
- [ ] Sign in/up screens functional
- [ ] Username availability check working
- [ ] Profile screen displays user data
- [ ] Auth guard protecting routes
- [ ] Session auto-refresh functioning
- [ ] Error messages in German
- [ ] All auth flows tested

## Common Issues & Solutions

### Issue: User profile not created on signup
**Solution**: Check the database trigger is active and has proper permissions

### Issue: Username check fails
**Solution**: Ensure the RPC function has SECURITY DEFINER

### Issue: Auth state not persisting
**Solution**: Check SecureStorage is properly configured

## Next Steps

1. Complete all auth implementation
2. Test with real Supabase instance
3. Add social auth providers (optional)
4. Proceed to [Backend Functions](./03-backend-functions.md)
