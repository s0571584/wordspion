import 'package:uuid/uuid.dart';
import 'package:wortspion/core/constants/database_constants.dart';
import 'package:wortspion/data/models/player_group.dart';
import 'package:wortspion/data/repositories/player_group_repository.dart';
import 'package:wortspion/data/sources/local/database_helper.dart';

class PlayerGroupRepositoryImpl implements PlayerGroupRepository {
  final DatabaseHelper databaseHelper;
  final Uuid _uuid = const Uuid();

  PlayerGroupRepositoryImpl({required this.databaseHelper});

  @override
  Future<PlayerGroup> createPlayerGroup({
    required String groupName,
    required List<String> playerNames,
  }) async {
    final db = await databaseHelper.database;
    final newGroupId = _uuid.v4();

    final playerGroup = PlayerGroup(
      id: newGroupId,
      groupName: groupName,
      createdAt: DateTime.now(),
      playerNames: playerNames, // Will be stored separately
    );

    await db.transaction((txn) async {
      // Insert into player_groups table
      await txn.insert(
        DatabaseConstants.tablePlayerGroups,
        playerGroup.toMap(), // .toMap() should only include group-specific fields
      );

      // Insert each player name into player_group_members table
      for (final playerName in playerNames) {
        await txn.insert(
          DatabaseConstants.tablePlayerGroupMembers,
          {
            'id': _uuid.v4(),
            'group_id': newGroupId,
            'player_name': playerName,
          },
        );
      }
    });

    // Return the created PlayerGroup object (which already has playerNames in its model)
    return playerGroup;
  }

  @override
  Future<List<PlayerGroup>> getAllPlayerGroups() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> groupMaps = await db.query(DatabaseConstants.tablePlayerGroups);

    final List<PlayerGroup> playerGroups = [];

    for (final groupMap in groupMaps) {
      final groupId = groupMap['id'] as String;
      final List<Map<String, dynamic>> memberMaps = await db.query(
        DatabaseConstants.tablePlayerGroupMembers,
        where: 'group_id = ?',
        whereArgs: [groupId],
      );

      final List<String> playerNames = memberMaps.map((memberMap) => memberMap['player_name'] as String).toList();

      playerGroups.add(PlayerGroup.fromMap(groupMap, playerNames));
    }

    return playerGroups;
  }

  @override
  Future<PlayerGroup> updatePlayerGroup({
    required String groupId,
    required String newGroupName,
    required List<String> newPlayerNames,
  }) async {
    final db = await databaseHelper.database;

    // Create the updated PlayerGroup object to return.
    // The createdAt timestamp should ideally be the original creation time.
    // We'll fetch the existing group to preserve its createdAt timestamp.
    // This is a bit inefficient but ensures data integrity if not passed in.
    // A more optimized approach might involve passing the original createdAt or
    // not updating it if the model is designed such that createdAt is immutable.

    // For now, let's assume we'll construct a new PlayerGroup with a potentially new
    // `createdAt` if we don't fetch the old one. Or, more simply, assume the consumer
    // of this update doesn't mind if `createdAt` is effectively `updatedAt` in this context
    // if we don't explicitly fetch and preserve it.
    // Given the current `PlayerGroup.toMap()` doesn't include `playerNames`,
    // and `PlayerGroup.fromMap()` requires `playerNames`, we'll build the return
    // object after the transaction.

    await db.transaction((txn) async {
      // 1. Update the group's name in the player_groups table
      await txn.update(
        DatabaseConstants.tablePlayerGroups,
        {'group_name': newGroupName}, // Only update the name for now
        where: 'id = ?',
        whereArgs: [groupId],
      );

      // 2. Clear out the old members from player_group_members for that group
      await txn.delete(
        DatabaseConstants.tablePlayerGroupMembers,
        where: 'group_id = ?',
        whereArgs: [groupId],
      );

      // 3. Insert the new list of player names into player_group_members
      for (final playerName in newPlayerNames) {
        await txn.insert(
          DatabaseConstants.tablePlayerGroupMembers,
          {
            'id': _uuid.v4(), // Generate new ID for each member entry
            'group_id': groupId,
            'player_name': playerName,
          },
        );
      }
    });

    // After the transaction, fetch the (potentially old) createdAt timestamp to reconstruct the object.
    // This is to ensure the returned object is as accurate as possible.
    final List<Map<String, dynamic>> groupData = await db.query(
      DatabaseConstants.tablePlayerGroups,
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );

    if (groupData.isEmpty) {
      // This should ideally not happen if the update was successful.
      // Handle error or throw exception.
      throw Exception("Failed to find group after update: $groupId");
    }

    final originalCreatedAt = DateTime.fromMillisecondsSinceEpoch(groupData.first['created_at'] as int);

    // Construct and return the updated PlayerGroup object
    return PlayerGroup(
      id: groupId,
      groupName: newGroupName,
      createdAt: originalCreatedAt, // Preserved original creation timestamp
      playerNames: newPlayerNames,
    );
  }

  @override
  Future<void> deletePlayerGroup({required String groupId}) async {
    final db = await databaseHelper.database;
    // The ON DELETE CASCADE constraint on player_group_members.group_id
    // should automatically delete members when the group is deleted.
    await db.delete(
      DatabaseConstants.tablePlayerGroups,
      where: 'id = ?',
      whereArgs: [groupId],
    );
    // No need to explicitly delete from player_group_members due to CASCADE
  }
}
