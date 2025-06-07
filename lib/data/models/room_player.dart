import 'package:equatable/equatable.dart';

class RoomPlayer extends Equatable {
  final String id;
  final String roomId;
  final String userId;
  final String playerName;
  final int playerOrder;
  final bool isReady;
  final bool isConnected;
  final DateTime lastHeartbeat;
  final int score;
  final DateTime joinedAt;
  final DateTime? leftAt;

  const RoomPlayer({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.playerName,
    required this.playerOrder,
    this.isReady = false,
    this.isConnected = true,
    required this.lastHeartbeat,
    this.score = 0,
    required this.joinedAt,
    this.leftAt,
  });

  factory RoomPlayer.fromJson(Map<String, dynamic> json) {
    return RoomPlayer(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      playerName: json['player_name'] as String,
      playerOrder: json['player_order'] as int,
      isReady: json['is_ready'] as bool? ?? false,
      isConnected: json['is_connected'] as bool? ?? true,
      lastHeartbeat: DateTime.parse(json['last_heartbeat'] as String),
      score: json['score'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'player_name': playerName,
      'player_order': playerOrder,
      'is_ready': isReady,
      'is_connected': isConnected,
      'last_heartbeat': lastHeartbeat.toIso8601String(),
      'score': score,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
    };
  }

  RoomPlayer copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? playerName,
    int? playerOrder,
    bool? isReady,
    bool? isConnected,
    DateTime? lastHeartbeat,
    int? score,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) {
    return RoomPlayer(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      playerName: playerName ?? this.playerName,
      playerOrder: playerOrder ?? this.playerOrder,
      isReady: isReady ?? this.isReady,
      isConnected: isConnected ?? this.isConnected,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      score: score ?? this.score,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
    );
  }

  bool get isActive => isConnected && leftAt == null;
  Duration get timeSinceLastHeartbeat => DateTime.now().difference(lastHeartbeat);
  bool get isOffline => timeSinceLastHeartbeat.inMinutes > 2;

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        playerName,
        playerOrder,
        isReady,
        isConnected,
        lastHeartbeat,
        score,
        joinedAt,
        leftAt,
      ];
}