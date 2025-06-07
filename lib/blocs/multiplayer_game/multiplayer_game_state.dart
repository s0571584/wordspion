import 'package:equatable/equatable.dart';
import '../../data/models/game_room.dart';
import '../../data/models/room_player.dart';
import '../../data/models/multiplayer_round.dart';
import '../../data/models/multiplayer_player_role.dart';
import '../../data/models/game_event.dart';

abstract class MultiplayerGameState extends Equatable {
  const MultiplayerGameState();

  @override
  List<Object?> get props => [];
}

class MultiplayerGameInitial extends MultiplayerGameState {}

class MultiplayerGameLoading extends MultiplayerGameState {}

class MultiplayerGameError extends MultiplayerGameState {
  final String message;
  final String? code;

  const MultiplayerGameError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// Room States
class GameRoomCreated extends MultiplayerGameState {
  final GameRoom room;

  const GameRoomCreated(this.room);

  @override
  List<Object> get props => [room];
}

class GameRoomJoined extends MultiplayerGameState {
  final GameRoom room;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;

  const GameRoomJoined({
    required this.room,
    required this.players,
    required this.currentPlayer,
  });

  @override
  List<Object> get props => [room, players, currentPlayer];
}

class InGameLobby extends MultiplayerGameState {
  final GameRoom room;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;
  final List<GameEvent> recentEvents;

  const InGameLobby({
    required this.room,
    required this.players,
    required this.currentPlayer,
    this.recentEvents = const [],
  });

  @override
  List<Object> get props => [room, players, currentPlayer, recentEvents];

  InGameLobby copyWith({
    GameRoom? room,
    List<RoomPlayer>? players,
    RoomPlayer? currentPlayer,
    List<GameEvent>? recentEvents,
  }) {
    return InGameLobby(
      room: room ?? this.room,
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      recentEvents: recentEvents ?? this.recentEvents,
    );
  }

  bool get allPlayersReady => 
      players.length >= 3 && 
      players.every((player) => player.isReady);
  
  bool get isHost => currentPlayer.userId == room.hostId;
  bool get canStartGame => isHost && allPlayersReady && room.canStart;
}

// Game States
class GameStarted extends MultiplayerGameState {
  final GameRoom room;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;

  const GameStarted({
    required this.room,
    required this.players,
    required this.currentPlayer,
  });

  @override
  List<Object> get props => [room, players, currentPlayer];
}

class RoleAssignmentPhase extends MultiplayerGameState {
  final GameRoom room;
  final MultiplayerRound currentRound;
  final MultiplayerPlayerRole? playerRole;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;

  const RoleAssignmentPhase({
    required this.room,
    required this.currentRound,
    this.playerRole,
    required this.players,
    required this.currentPlayer,
  });

  @override
  List<Object?> get props => [room, currentRound, playerRole, players, currentPlayer];

  bool get hasViewedRole => playerRole?.hasViewedRole ?? false;
  bool get isImpostor => playerRole?.isImpostor ?? false;
}

class RoleRevealPhase extends MultiplayerGameState {
  final GameRoom room;
  final MultiplayerRound currentRound;
  final MultiplayerPlayerRole playerRole;
  final String assignedWord;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;

  const RoleRevealPhase({
    required this.room,
    required this.currentRound,
    required this.playerRole,
    required this.assignedWord,
    required this.players,
    required this.currentPlayer,
  });

  @override
  List<Object> get props => [
        room,
        currentRound,
        playerRole,
        assignedWord,
        players,
        currentPlayer,
      ];

  bool get isImpostor => playerRole.isImpostor;
}

class DiscussionPhase extends MultiplayerGameState {
  final GameRoom room;
  final MultiplayerRound currentRound;
  final MultiplayerPlayerRole playerRole;
  final String assignedWord;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;
  final Duration? remainingTime;

  const DiscussionPhase({
    required this.room,
    required this.currentRound,
    required this.playerRole,
    required this.assignedWord,
    required this.players,
    required this.currentPlayer,
    this.remainingTime,
  });

  @override
  List<Object?> get props => [
        room,
        currentRound,
        playerRole,
        assignedWord,
        players,
        currentPlayer,
        remainingTime,
      ];

  bool get isImpostor => playerRole.isImpostor;
}

class VotingPhase extends MultiplayerGameState {
  final GameRoom room;
  final MultiplayerRound currentRound;
  final MultiplayerPlayerRole playerRole;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;
  final String? votedPlayerId;
  final Map<String, int> voteCount;

  const VotingPhase({
    required this.room,
    required this.currentRound,
    required this.playerRole,
    required this.players,
    required this.currentPlayer,
    this.votedPlayerId,
    this.voteCount = const {},
  });

  @override
  List<Object?> get props => [
        room,
        currentRound,
        playerRole,
        players,
        currentPlayer,
        votedPlayerId,
        voteCount,
      ];

  bool get hasVoted => votedPlayerId != null;
  bool get isImpostor => playerRole.isImpostor;

  VotingPhase copyWith({
    GameRoom? room,
    MultiplayerRound? currentRound,
    MultiplayerPlayerRole? playerRole,
    List<RoomPlayer>? players,
    RoomPlayer? currentPlayer,
    String? votedPlayerId,
    Map<String, int>? voteCount,
  }) {
    return VotingPhase(
      room: room ?? this.room,
      currentRound: currentRound ?? this.currentRound,
      playerRole: playerRole ?? this.playerRole,
      players: players ?? this.players,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      votedPlayerId: votedPlayerId ?? this.votedPlayerId,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}

class RoundCompleted extends MultiplayerGameState {
  final GameRoom room;
  final MultiplayerRound completedRound;
  final List<RoomPlayer> players;
  final RoomPlayer currentPlayer;
  final bool impostorsWon;
  final Map<String, int> finalVotes;
  final List<String> eliminatedPlayers;

  const RoundCompleted({
    required this.room,
    required this.completedRound,
    required this.players,
    required this.currentPlayer,
    required this.impostorsWon,
    required this.finalVotes,
    required this.eliminatedPlayers,
  });

  @override
  List<Object> get props => [
        room,
        completedRound,
        players,
        currentPlayer,
        impostorsWon,
        finalVotes,
        eliminatedPlayers,
      ];
}

class GameCompleted extends MultiplayerGameState {
  final GameRoom room;
  final List<RoomPlayer> finalPlayers;
  final RoomPlayer currentPlayer;
  final bool impostorsWon;
  final Map<String, int> finalScores;
  final List<MultiplayerRound> allRounds;

  const GameCompleted({
    required this.room,
    required this.finalPlayers,
    required this.currentPlayer,
    required this.impostorsWon,
    required this.finalScores,
    required this.allRounds,
  });

  @override
  List<Object> get props => [
        room,
        finalPlayers,
        currentPlayer,
        impostorsWon,
        finalScores,
        allRounds,
      ];
}