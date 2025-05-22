import 'package:wortspion/data/models/player_group.dart';

abstract class PlayerGroupRepository {
  Future<List<PlayerGroup>> getAllPlayerGroups();
  Future<PlayerGroup> createPlayerGroup({
    required String groupName,
    required List<String> playerNames,
  });
  Future<PlayerGroup> updatePlayerGroup({
    required String groupId,
    required String newGroupName,
    required List<String> newPlayerNames,
  });
  Future<void> deletePlayerGroup({required String groupId});
}
