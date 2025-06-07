import 'package:equatable/equatable.dart';

enum GameRoomState { waiting, starting, playing, finished, cancelled }

class GameRoom extends Equatable {
  final String id;
  final String roomCode;
  final String hostId;
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final List<String> selectedCategories;
  final GameRoomState gameState;
  final int currentRound;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime expiresAt;

  const GameRoom({
    required this.id,
    required this.roomCode,
    required this.hostId,
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    this.impostorsKnowEachOther = false,
    this.selectedCategories = const ['entertainment', 'sports', 'animals', 'food'],
    this.gameState = GameRoomState.waiting,
    this.currentRound = 0,
    this.isActive = true,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    required this.expiresAt,
  });

  factory GameRoom.fromJson(Map<String, dynamic> json) {
    return GameRoom(
      id: json['id'] as String,
      roomCode: json['room_code'] as String,
      hostId: json['host_id'] as String,
      playerCount: json['player_count'] as int,
      impostorCount: json['impostor_count'] as int,
      roundCount: json['round_count'] as int,
      timerDuration: json['timer_duration'] as int,
      impostorsKnowEachOther: json['impostors_know_each_other'] as bool? ?? false,
      selectedCategories: List<String>.from(json['selected_categories'] as List? ?? []),
      gameState: _parseGameState(json['game_state'] as String?),
      currentRound: json['current_round'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at'] as String) : null,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  static GameRoomState _parseGameState(String? state) {
    switch (state) {
      case 'waiting':
        return GameRoomState.waiting;
      case 'starting':
        return GameRoomState.starting;
      case 'playing':
        return GameRoomState.playing;
      case 'finished':
        return GameRoomState.finished;
      case 'cancelled':
        return GameRoomState.cancelled;
      default:
        return GameRoomState.waiting;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_code': roomCode,
      'host_id': hostId,
      'player_count': playerCount,
      'impostor_count': impostorCount,
      'round_count': roundCount,
      'timer_duration': timerDuration,
      'impostors_know_each_other': impostorsKnowEachOther,
      'selected_categories': selectedCategories,
      'game_state': gameState.name,
      'current_round': currentRound,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  GameRoom copyWith({
    String? id,
    String? roomCode,
    String? hostId,
    int? playerCount,
    int? impostorCount,
    int? roundCount,
    int? timerDuration,
    bool? impostorsKnowEachOther,
    List<String>? selectedCategories,
    GameRoomState? gameState,
    int? currentRound,
    bool? isActive,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    DateTime? expiresAt,
  }) {
    return GameRoom(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      hostId: hostId ?? this.hostId,
      playerCount: playerCount ?? this.playerCount,
      impostorCount: impostorCount ?? this.impostorCount,
      roundCount: roundCount ?? this.roundCount,
      timerDuration: timerDuration ?? this.timerDuration,
      impostorsKnowEachOther: impostorsKnowEachOther ?? this.impostorsKnowEachOther,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      gameState: gameState ?? this.gameState,
      currentRound: currentRound ?? this.currentRound,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canStart => gameState == GameRoomState.waiting && playerCount >= 3;
  bool get isInProgress => gameState == GameRoomState.playing;

  @override
  List<Object?> get props => [
        id,
        roomCode,
        hostId,
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
        selectedCategories,
        gameState,
        currentRound,
        isActive,
        createdAt,
        startedAt,
        finishedAt,
        expiresAt,
      ];
}