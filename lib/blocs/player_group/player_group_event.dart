import 'package:equatable/equatable.dart';

abstract class PlayerGroupEvent extends Equatable {
  const PlayerGroupEvent();
  @override
  List<Object> get props => [];
}

class LoadPlayerGroups extends PlayerGroupEvent {}

class AddPlayerGroup extends PlayerGroupEvent {
  final String groupName;
  final List<String> playerNames;

  const AddPlayerGroup({required this.groupName, required this.playerNames});

  @override
  List<Object> get props => [groupName, playerNames];
}

class UpdatePlayerGroup extends PlayerGroupEvent {
  final String groupId;
  final String newGroupName;
  final List<String> newPlayerNames;

  const UpdatePlayerGroup({
    required this.groupId,
    required this.newGroupName,
    required this.newPlayerNames,
  });

  @override
  List<Object> get props => [groupId, newGroupName, newPlayerNames];
}

class DeletePlayerGroup extends PlayerGroupEvent {
  final String groupId;

  const DeletePlayerGroup({required this.groupId});

  @override
  List<Object> get props => [groupId];
}
