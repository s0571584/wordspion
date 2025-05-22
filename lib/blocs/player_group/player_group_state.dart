import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/player_group.dart';

abstract class PlayerGroupState extends Equatable {
  const PlayerGroupState();
  @override
  List<Object> get props => [];
}

class PlayerGroupsInitial extends PlayerGroupState {}

class PlayerGroupsLoading extends PlayerGroupState {}

class PlayerGroupsLoaded extends PlayerGroupState {
  final List<PlayerGroup> groups;
  const PlayerGroupsLoaded(this.groups);

  @override
  List<Object> get props => [groups];
}

// Emitted after a successful CUD operation, might trigger a reload or UI feedback
class PlayerGroupOperationSuccess extends PlayerGroupState {
  // Optionally, include a message for SnackBar feedback
  // final String? message;
  // const PlayerGroupOperationSuccess({this.message});

  // @override
  // List<Object> get props => [message ?? ''];
}

class PlayerGroupError extends PlayerGroupState {
  final String message;
  const PlayerGroupError(this.message);

  @override
  List<Object> get props => [message];
}
