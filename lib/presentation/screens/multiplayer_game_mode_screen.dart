import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/multiplayer_game/multiplayer_game_bloc.dart';
import '../../blocs/multiplayer_game/multiplayer_game_event.dart';
import '../../blocs/multiplayer_game/multiplayer_game_state.dart';
import '../../core/router/app_router.dart';
import '../../di/injection_container.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import '../themes/app_spacing.dart';

@RoutePage()
class MultiplayerGameModeScreen extends StatefulWidget {
  const MultiplayerGameModeScreen({super.key});

  @override
  State<MultiplayerGameModeScreen> createState() => _MultiplayerGameModeScreenState();
}

class _MultiplayerGameModeScreenState extends State<MultiplayerGameModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _roomCodeController = TextEditingController();
  final _playerNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomCodeController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MultiplayerGameBloc>(),
      child: BlocListener<MultiplayerGameBloc, MultiplayerGameState>(
        listener: (context, state) {
          if (state is GameRoomCreated) {
            // Navigate to lobby after creating room
            context.router.push(MultiplayerLobbyRoute(roomId: state.room.id));
          } else if (state is GameRoomJoined) {
            // Navigate to lobby after joining room
            context.router.push(MultiplayerLobbyRoute(roomId: state.room.id));
          } else if (state is MultiplayerGameError) {
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.onBackground),
              onPressed: () => context.router.pop(),
            ),
            title: Text(
              'Online Spiel',
              style: AppTypography.headline3.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<AuthBloc, AppAuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return PopupMenuButton<String>(
                      icon: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          authState.displayName.substring(0, 1).toUpperCase(),
                          style: AppTypography.body2.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'logout') {
                          context.read<AuthBloc>().add(AuthSignOutRequested());
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person, color: AppColors.onSurface),
                              const SizedBox(width: AppSpacing.s),
                              Text(authState.displayName),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: AppColors.error),
                              const SizedBox(width: AppSpacing.s),
                              Text('Abmelden'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<AuthBloc, AppAuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return _buildNotAuthenticatedView(context);
              }

              return SafeArea(
                child: Column(
                  children: [
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: AppColors.onPrimary,
                        unselectedLabelColor: AppColors.onSurface.withOpacity(0.7),
                        labelStyle: AppTypography.button,
                        unselectedLabelStyle: AppTypography.button,
                        tabs: const [
                          Tab(text: 'Raum erstellen'),
                          Tab(text: 'Raum beitreten'),
                        ],
                      ),
                    ),
                    
                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCreateRoomTab(context, authState),
                          _buildJoinRoomTab(context, authState),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotAuthenticatedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: AppColors.onBackground.withOpacity(0.5),
          ),
          
          const SizedBox(height: AppSpacing.l),
          
          Text(
            'Anmeldung erforderlich',
            style: AppTypography.headline2.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.m),
          
          Text(
            'Melde dich an, um online mit Freunden zu spielen.',
            style: AppTypography.body1.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.router.navigate(const LoginRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text('Jetzt anmelden'),
            ),
          ),
          
          const SizedBox(height: AppSpacing.m),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.router.pop();
              },
              child: Text('Lokales Spiel spielen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRoomTab(BuildContext context, AuthAuthenticated authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Neuen Spielraum erstellen',
            style: AppTypography.headline3.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppSpacing.s),
          
          Text(
            'Erstelle einen Raum und lade deine Freunde ein.',
            style: AppTypography.body1.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Game Settings
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spiel-Einstellungen',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.l),
                
                // Player Count
                _buildSettingRow(
                  'Spieleranzahl',
                  '5 Spieler',
                  Icons.people,
                ),
                
                const SizedBox(height: AppSpacing.m),
                
                // Impostor Count
                _buildSettingRow(
                  'Spione',
                  '1 Spion',
                  Icons.visibility_off,
                ),
                
                const SizedBox(height: AppSpacing.m),
                
                // Rounds
                _buildSettingRow(
                  'Runden',
                  '3 Runden',
                  Icons.refresh,
                ),
                
                const SizedBox(height: AppSpacing.m),
                
                // Timer
                _buildSettingRow(
                  'Diskussionszeit',
                  '3 Minuten',
                  Icons.timer,
                ),
                
                const SizedBox(height: AppSpacing.l),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to game settings
                    },
                    child: Text('Einstellungen anpassen'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Create Room Button
          BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
            builder: (context, state) {
              final isLoading = state is MultiplayerGameLoading;
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    context.read<MultiplayerGameBloc>().add(CreateGameRoom(
                      playerCount: 5,
                      impostorCount: 1,
                      roundCount: 3,
                      timerDuration: 180,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: isLoading
                      ? Row(
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
                            const SizedBox(width: AppSpacing.s),
                            Text('Raum wird erstellt...'),
                          ],
                        )
                      : Text('Raum erstellen'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJoinRoomTab(BuildContext context, AuthAuthenticated authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Spielraum beitreten',
            style: AppTypography.headline3.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppSpacing.s),
          
          Text(
            'Gib den Raum-Code ein, den du von deinem Freund erhalten hast.',
            style: AppTypography.body1.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Room Code Input
          Text(
            'Raum-Code',
            style: AppTypography.body2.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppSpacing.s),
          
          TextFormField(
            controller: _roomCodeController,
            decoration: InputDecoration(
              hintText: 'z.B. ABC123',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.lock, color: AppColors.primary),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              // Format room code as uppercase
              if (value.length <= 6) {
                final formatted = value.toUpperCase();
                if (formatted != value) {
                  _roomCodeController.value = _roomCodeController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              }
            },
          ),
          
          const SizedBox(height: AppSpacing.l),
          
          // Player Name Input
          Text(
            'Dein Spielername',
            style: AppTypography.body2.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppSpacing.s),
          
          TextFormField(
            controller: _playerNameController,
            decoration: InputDecoration(
              hintText: authState.displayName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
          
          const SizedBox(height: AppSpacing.s),
          
          Text(
            'Falls leer, wird dein Profilname verwendet',
            style: AppTypography.caption.copyWith(
              color: AppColors.onBackground.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Join Room Button
          BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
            builder: (context, state) {
              final isLoading = state is MultiplayerGameLoading;
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || _roomCodeController.text.length < 6 
                      ? null 
                      : () {
                          final playerName = _playerNameController.text.trim().isEmpty
                              ? authState.displayName
                              : _playerNameController.text.trim();
                          
                          context.read<MultiplayerGameBloc>().add(JoinGameRoom(
                            roomCode: _roomCodeController.text.trim(),
                            playerName: playerName,
                          ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: isLoading
                      ? Row(
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
                            const SizedBox(width: AppSpacing.s),
                            Text('Raum wird beigetreten...'),
                          ],
                        )
                      : Text('Raum beitreten'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            title,
            style: AppTypography.body2.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.body2.copyWith(
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}