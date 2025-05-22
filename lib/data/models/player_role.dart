import 'package:equatable/equatable.dart';

enum PlayerRoleType { impostor, detective, civilian }

// Extension to get string representation of the role
extension PlayerRoleTypeExtension on PlayerRoleType {
  String get displayName {
    switch (this) {
      case PlayerRoleType.impostor:
        return 'Impostor';
      case PlayerRoleType.detective:
        return 'Detective';
      case PlayerRoleType.civilian:
        return 'Civilian';
      default:
        return 'Unknown';
    }
  }

  bool get isImpostor => this == PlayerRoleType.impostor;

  bool get isDetective => this == PlayerRoleType.detective;

  bool get isCivilian => this == PlayerRoleType.civilian;
}

class PlayerRole extends Equatable {
  final String id;
  final String roundId;
  final String playerId;
  final bool isImpostor;
  final DateTime createdAt;

  const PlayerRole({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.isImpostor,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        roundId,
        playerId,
        isImpostor,
        createdAt,
      ];

  // Factory method for creating from database
  factory PlayerRole.fromMap(Map<String, dynamic> map) {
    return PlayerRole(
      id: map['id'] as String,
      roundId: map['round_id'] as String,
      playerId: map['player_id'] as String,
      isImpostor: (map['is_impostor'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Method for converting to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_id': roundId,
      'player_id': playerId,
      'is_impostor': isImpostor ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Copy with new values
  PlayerRole copyWith({
    String? id,
    String? roundId,
    String? playerId,
    bool? isImpostor,
    DateTime? createdAt,
  }) {
    return PlayerRole(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      playerId: playerId ?? this.playerId,
      isImpostor: isImpostor ?? this.isImpostor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PlayerRole(id: $id, roundId: $roundId, playerId: $playerId, '
        'isImpostor: $isImpostor, createdAt: $createdAt)';
  }
}
