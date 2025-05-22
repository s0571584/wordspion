import 'package:equatable/equatable.dart';

class Vote extends Equatable {
  final String id;
  final String voterId;
  final String targetId;
  final String roundId;
  final DateTime createdAt;

  const Vote({
    required this.id,
    required this.voterId,
    required this.targetId,
    required this.roundId,
    required this.createdAt,
  });

  // Factory constructor for creating a new vote
  factory Vote.create({
    required String voterId,
    required String targetId,
    required String roundId,
  }) {
    return Vote(
      id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
      voterId: voterId,
      targetId: targetId,
      roundId: roundId,
      createdAt: DateTime.now(),
    );
  }

  // Convert the vote to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voter_id': voterId,
      'target_id': targetId,
      'round_id': roundId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create a vote from a map
  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      id: map['id'] as String,
      voterId: map['voter_id'] as String,
      targetId: map['target_id'] as String,
      roundId: map['round_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  List<Object> get props => [id, voterId, targetId, roundId, createdAt];

  // Create a copy with new values
  Vote copyWith({
    String? id,
    String? voterId,
    String? targetId,
    String? roundId,
    DateTime? createdAt,
  }) {
    return Vote(
      id: id ?? this.id,
      voterId: voterId ?? this.voterId,
      targetId: targetId ?? this.targetId,
      roundId: roundId ?? this.roundId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Vote(id: $id, roundId: $roundId, voterId: $voterId, '
        'targetId: $targetId, createdAt: $createdAt)';
  }
}
