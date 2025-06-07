import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class MultiplayerLobbyScreen extends StatefulWidget {
  final String roomId;

  const MultiplayerLobbyScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> with WidgetsBindingObserver {
  late MultiplayerGameBloc _gameBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameBloc = sl<MultiplayerGameBloc>();
    _gameBloc.add(LoadRoom(widget.roomId));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Send heartbeat when app becomes active
    if (state == AppLifecycleState.resumed) {
      _gameBloc.add(SendHeartbeat());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: BlocListener<MultiplayerGameBloc, MultiplayerGameState>(
        listener: (context, state) {
          if (state is GameStarted) {
            // Navigate to game when started
            context.router.navigate(MultiplayerGameRoute(roomId: widget.roomId));
          } else if (state is MultiplayerGameError) {
            // Show error and optionally go back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(AppSpacing.m),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                action: SnackBarAction(
                  label: 'Zurück',
                  textColor: Colors.white,
                  onPressed: () => context.router.pop(),
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
              icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
              onPressed: () => _showLeaveConfirmDialog(context),
            ),
            title: BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
              builder: (context, state) {
                if (state is InGameLobby) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Spielraum',
                        style: AppTypography.subtitle1.copyWith(
                          color: AppColors.onBackground,
                        ),
                      ),
                      Text(
                        state.room.roomCode,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.onBackground.withOpacity(0.7),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                return Text(
                  'Spielraum',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.onBackground,
                  ),
                );
              },
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
                builder: (context, state) {
                  if (state is InGameLobby) {
                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.onBackground),
                      onSelected: (value) {
                        switch (value) {
                          case 'copy_code':
                            _copyRoomCode(state.room.roomCode);
                            break;
                          case 'settings':
                            // TODO: Navigate to room settings
                            break;
                          case 'leave':
                            _showLeaveConfirmDialog(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'copy_code',
                          child: Row(
                            children: [
                              Icon(Icons.copy, color: AppColors.onSurface),
                              SizedBox(width: AppSpacing.s),
                              Text('Code kopieren'),
                            ],
                          ),
                        ),
                        if (state.isHost)
                          const PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(Icons.settings, color: AppColors.onSurface),
                                SizedBox(width: AppSpacing.s),
                                Text('Einstellungen'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'leave',
                          child: Row(
                            children: [
                              Icon(Icons.exit_to_app, color: AppColors.error),
                              SizedBox(width: AppSpacing.s),
                              Text('Raum verlassen'),
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
          body: BlocBuilder<MultiplayerGameBloc, MultiplayerGameState>(
            builder: (context, state) {
              if (state is MultiplayerGameLoading) {
                return _buildLoadingView();
              }

              if (state is InGameLobby) {
                return _buildLobbyView(context, state);
              }

              if (state is MultiplayerGameError) {
                return _buildErrorView(context, state);
              }

              return _buildLoadingView();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Lade Spielraum...',
            style: AppTypography.body1.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, MultiplayerGameError state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error.withOpacity(0.7),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Fehler beim Laden',
            style: AppTypography.headline3.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            state.message,
            style: AppTypography.body1.copyWith(
              color: AppColors.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.router.pop(),
                  child: const Text('Zurück'),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _gameBloc.add(LoadRoom(widget.roomId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: const Text('Erneut versuchen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyView(BuildContext context, InGameLobby state) {
    return SafeArea(
      child: Column(
        children: [
          // Room Info Header
          _buildRoomHeader(state),

          // Players List
          Expanded(
            child: _buildPlayersList(state),
          ),

          // Bottom Actions
          _buildBottomActions(context, state),
        ],
      ),
    );
  }

  Widget _buildRoomHeader(InGameLobby state) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Room Code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Raum-Code: ',
                style: AppTypography.body1.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.room.roomCode,
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.primary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(
                onPressed: () => _copyRoomCode(state.room.roomCode),
                icon: const Icon(Icons.copy, color: AppColors.primary),
                tooltip: 'Code kopieren',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Game Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(
                '${state.players.length}/${state.room.playerCount}',
                Icons.people,
                'Spieler',
              ),
              _buildInfoChip(
                '${state.room.impostorCount}',
                Icons.visibility_off,
                'Spione',
              ),
              _buildInfoChip(
                '${state.room.roundCount}',
                Icons.refresh,
                'Runden',
              ),
              _buildInfoChip(
                '${state.room.timerDuration ~/ 60}min',
                Icons.timer,
                'Zeit',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String value, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.body2.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersList(InGameLobby state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spieler (${state.players.length}/${state.room.playerCount})',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: ListView.separated(
              itemCount: state.players.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) {
                final player = state.players[index];
                final isCurrentPlayer = player.userId == state.currentPlayer.userId;
                final isHost = player.userId == state.room.hostId;

                return _buildPlayerCard(player, isCurrentPlayer, isHost);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(dynamic player, bool isCurrentPlayer, bool isHost) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? AppColors.primary.withOpacity(0.1) : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? AppColors.primary.withOpacity(0.3) : AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isCurrentPlayer ? AppColors.primary : AppColors.onSurface.withOpacity(0.1),
            child: Text(
              player.playerName.substring(0, 1).toUpperCase(),
              style: AppTypography.body1.copyWith(
                color: isCurrentPlayer ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.m),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.playerName,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentPlayer) ...[
                      const SizedBox(width: AppSpacing.s),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Du',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (isHost) ...[
                      const SizedBox(width: AppSpacing.s),
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      player.isConnected ? Icons.circle : Icons.circle_outlined,
                      color: player.isConnected ? AppColors.success : AppColors.error,
                      size: 8,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      player.isConnected ? 'Online' : 'Offline',
                      style: AppTypography.caption.copyWith(
                        color: player.isConnected ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ready Status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: player.isReady ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              player.isReady ? 'Bereit' : 'Wartend',
              style: AppTypography.caption.copyWith(
                color: player.isReady ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, InGameLobby state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ready Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _gameBloc.add(UpdatePlayerReadyStatus(!state.currentPlayer.isReady));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: state.currentPlayer.isReady ? AppColors.warning : AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: Text(
                state.currentPlayer.isReady ? 'Nicht mehr bereit' : 'Bereit',
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.m),

          // Start Game Button (Host only)
          if (state.isHost)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.canStartGame ? () => _gameBloc.add(StartGame()) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: Text(
                  state.canStartGame ? 'Spiel starten' : 'Warte auf alle Spieler...',
                ),
              ),
            ),

          // Game Status (Non-host)
          if (!state.isHost && !state.allPlayersReady)
            Text(
              'Warten auf Host...',
              style: AppTypography.body2.copyWith(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  void _copyRoomCode(String roomCode) {
    Clipboard.setData(ClipboardData(text: roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Raum-Code $roomCode kopiert!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.m),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLeaveConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Raum verlassen?'),
        content: const Text('Bist du sicher, dass du den Spielraum verlassen möchtest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Bleiben'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _gameBloc.add(LeaveGameRoom());
              context.router.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
  }
}
