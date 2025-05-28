import 'package:equatable/equatable.dart';

enum PlayerRoleType { impostor, detective, civilian, saboteur }

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
      case PlayerRoleType.saboteur:
        return 'Saboteur';
      default:
        return 'Unknown';
    }
  }

  // Convert to database string representation
  String get databaseValue {
    switch (this) {
      case PlayerRoleType.impostor:
        return 'impostor';
      case PlayerRoleType.detective:
        return 'detective';
      case PlayerRoleType.civilian:
        return 'civilian';
      case PlayerRoleType.saboteur:
        return 'saboteur';
      default:
        return 'civilian';
    }
  }

  // Convert from database string representation
  static PlayerRoleType fromDatabaseValue(String value) {
    switch (value.toLowerCase()) {
      case 'impostor':
        return PlayerRoleType.impostor;
      case 'detective':
        return PlayerRoleType.detective;
      case 'civilian':
        return PlayerRoleType.civilian;
      case 'saboteur':
        return PlayerRoleType.saboteur;
      default:
        return PlayerRoleType.civilian;
    }
  }

  bool get isImpostor => this == PlayerRoleType.impostor;

  bool get isDetective => this == PlayerRoleType.detective;

  bool get isCivilian => this == PlayerRoleType.civilian;

  bool get isSaboteur => this == PlayerRoleType.saboteur;
}

class PlayerRole extends Equatable {
  final String id;
  final String roundId;
  final String playerId;
  final bool isImpostor; // 🔄 BACKWARD COMPATIBILITY: Keep existing field
  final PlayerRoleType roleType; // 🆕 NEW: Enhanced role type system
  final DateTime createdAt;

  const PlayerRole({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.isImpostor,
    this.roleType = PlayerRoleType.civilian, // 🆕 NEW: Default to civilian
    required this.createdAt,
  });

  // 🆕 NEW: Convenience getters for role checking
  bool get isSaboteur => roleType.isSaboteur;
  bool get isDetective => roleType.isDetective;
  bool get isCivilian => roleType.isCivilian && !isImpostor; // Civilian but not impostor

  @override
  List<Object> get props => [
        id,
        roundId,
        playerId,
        isImpostor,
        roleType, // 🆕 NEW: Include in equality check
        createdAt,
      ];

  // Factory method for creating from database
  factory PlayerRole.fromMap(Map<String, dynamic> map) {
    // 🔄 BACKWARD COMPATIBILITY: Handle both old and new schema
    final roleTypeStr = map['role_type'] as String?;
    final isImpostorFlag = (map['is_impostor'] as int) == 1;
    
    // Determine role type from database
    PlayerRoleType roleType;
    if (roleTypeStr != null && roleTypeStr.isNotEmpty) {
      // New schema: use role_type column
      roleType = PlayerRoleTypeExtension.fromDatabaseValue(roleTypeStr);
    } else {
      // Old schema: derive from is_impostor
      roleType = isImpostorFlag ? PlayerRoleType.impostor : PlayerRoleType.civilian;
    }

    return PlayerRole(
      id: map['id'] as String,
      roundId: map['round_id'] as String,
      playerId: map['player_id'] as String,
      isImpostor: isImpostorFlag,
      roleType: roleType,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // Method for converting to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_id': roundId,
      'player_id': playerId,
      'is_impostor': isImpostor ? 1 : 0, // 🔄 BACKWARD COMPATIBILITY: Keep existing field
      'role_type': roleType.databaseValue, // 🆕 NEW: Store role type
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Copy with new values
  PlayerRole copyWith({
    String? id,
    String? roundId,
    String? playerId,
    bool? isImpostor,
    PlayerRoleType? roleType, // 🆕 NEW: Add role type parameter
    DateTime? createdAt,
  }) {
    return PlayerRole(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      playerId: playerId ?? this.playerId,
      isImpostor: isImpostor ?? this.isImpostor,
      roleType: roleType ?? this.roleType, // 🆕 NEW: Use provided or current value
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PlayerRole(id: $id, roundId: $roundId, playerId: $playerId, '
        'isImpostor: $isImpostor, roleType: $roleType, createdAt: $createdAt)';
  }
}
