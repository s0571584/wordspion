import 'package:equatable/equatable.dart';

class MultiplayerPlayerRole extends Equatable {
  final String id;
  final String roundId;
  final String playerId;
  final bool isImpostor;
  final String assignedWordId;
  final DateTime? roleViewedAt;

  const MultiplayerPlayerRole({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.isImpostor,
    required this.assignedWordId,
    this.roleViewedAt,
  });

  factory MultiplayerPlayerRole.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayerRole(
      id: json['id'] as String,
      roundId: json['round_id'] as String,
      playerId: json['player_id'] as String,
      isImpostor: json['is_impostor'] as bool,
      assignedWordId: json['assigned_word_id'] as String,
      roleViewedAt: json['role_viewed_at'] != null
          ? DateTime.parse(json['role_viewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'round_id': roundId,
      'player_id': playerId,
      'is_impostor': isImpostor,
      'assigned_word_id': assignedWordId,
      'role_viewed_at': roleViewedAt?.toIso8601String(),
    };
  }

  MultiplayerPlayerRole copyWith({
    String? id,
    String? roundId,
    String? playerId,
    bool? isImpostor,
    String? assignedWordId,
    DateTime? roleViewedAt,
  }) {
    return MultiplayerPlayerRole(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      playerId: playerId ?? this.playerId,
      isImpostor: isImpostor ?? this.isImpostor,
      assignedWordId: assignedWordId ?? this.assignedWordId,
      roleViewedAt: roleViewedAt ?? this.roleViewedAt,
    );
  }

  MultiplayerPlayerRole markAsViewed() {
    return copyWith(roleViewedAt: DateTime.now());
  }

  bool get hasViewedRole => roleViewedAt != null;
  bool get isRegularPlayer => !isImpostor;

  @override
  List<Object?> get props => [
        id,
        roundId,
        playerId,
        isImpostor,
        assignedWordId,
        roleViewedAt,
      ];
}