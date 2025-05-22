import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class PlayerGroup extends Equatable {
  final String id;
  final String groupName;
  final DateTime createdAt;
  final List<String> playerNames;

  const PlayerGroup({
    required this.id,
    required this.groupName,
    required this.createdAt,
    required this.playerNames,
  });

  @override
  List<Object?> get props => [id, groupName, createdAt, playerNames];

  // Factory for creating a new PlayerGroup instance with a generated ID
  factory PlayerGroup.create({
    required String groupName,
    required List<String> playerNames,
  }) {
    return PlayerGroup(
      id: const Uuid().v4(),
      groupName: groupName,
      createdAt: DateTime.now(),
      playerNames: List<String>.from(playerNames), // Ensure a mutable copy
    );
  }

  // Factory for creating a PlayerGroup from a map (database row) and a list of names
  factory PlayerGroup.fromMap(Map<String, dynamic> map, List<String> names) {
    return PlayerGroup(
      id: map['id'] as String,
      groupName: map['group_name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      playerNames: names,
    );
  }

  // Method to convert PlayerGroup to a map for database insertion (player_groups table)
  // This map does NOT include playerNames, as they are stored in a separate table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_name': groupName,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // CopyWith method for creating a new instance with updated fields
  PlayerGroup copyWith({
    String? id,
    String? groupName,
    DateTime? createdAt,
    List<String>? playerNames,
  }) {
    return PlayerGroup(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      playerNames: playerNames ?? this.playerNames,
    );
  }

  @override
  String toString() {
    return 'PlayerGroup(id: $id, groupName: $groupName, createdAt: $createdAt, playerCount: ${playerNames.length})';
  }
}
