import 'package:equatable/equatable.dart';

class GameEvent extends Equatable {
  final String id;
  final String roomId;
  final String eventType;
  final Map<String, dynamic> eventData;
  final String? createdBy;
  final DateTime createdAt;

  const GameEvent({
    required this.id,
    required this.roomId,
    required this.eventType,
    this.eventData = const {},
    this.createdBy,
    required this.createdAt,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      eventType: json['event_type'] as String,
      eventData: Map<String, dynamic>.from(json['event_data'] as Map? ?? {}),
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'event_type': eventType,
      'event_data': eventData,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  GameEvent copyWith({
    String? id,
    String? roomId,
    String? eventType,
    Map<String, dynamic>? eventData,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return GameEvent(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      eventType: eventType ?? this.eventType,
      eventData: eventData ?? this.eventData,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        eventType,
        eventData,
        createdBy,
        createdAt,
      ];
}

class GameEventTypes {
  static const String playerJoined = 'player_joined';
  static const String playerLeft = 'player_left';
  static const String playerReady = 'player_ready';
  static const String gameStarted = 'game_started';
  static const String roundStarted = 'round_started';
  static const String discussionStarted = 'discussion_started';
  static const String votingStarted = 'voting_started';
  static const String roundCompleted = 'round_completed';
  static const String gameCompleted = 'game_completed';
  static const String playerVoted = 'player_voted';
  static const String wordGuessed = 'word_guessed';
  static const String heartbeat = 'heartbeat';
}