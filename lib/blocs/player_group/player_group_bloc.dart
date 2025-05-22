import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/player_group/player_group_event.dart';
import 'package:wortspion/blocs/player_group/player_group_state.dart';
import 'package:wortspion/data/repositories/player_group_repository.dart';

class PlayerGroupBloc extends Bloc<PlayerGroupEvent, PlayerGroupState> {
  final PlayerGroupRepository playerGroupRepository;

  PlayerGroupBloc({required this.playerGroupRepository}) : super(PlayerGroupsInitial()) {
    on<LoadPlayerGroups>(_onLoadPlayerGroups);
    on<AddPlayerGroup>(_onAddPlayerGroup);
    on<DeletePlayerGroup>(_onDeletePlayerGroup);
    on<UpdatePlayerGroup>(_onUpdatePlayerGroup);
  }

  Future<void> _onLoadPlayerGroups(
    LoadPlayerGroups event,
    Emitter<PlayerGroupState> emit,
  ) async {
    emit(PlayerGroupsLoading());
    try {
      final groups = await playerGroupRepository.getAllPlayerGroups();
      emit(PlayerGroupsLoaded(groups));
    } catch (e) {
      emit(PlayerGroupError('Fehler beim Laden der Spieler-Gruppen: ${e.toString()}'));
    }
  }

  Future<void> _onAddPlayerGroup(
    AddPlayerGroup event,
    Emitter<PlayerGroupState> emit,
  ) async {
    // Optionally emit a loading/in-progress state if it's a long operation
    // emit(PlayerGroupsLoading()); // Or a more specific PlayerGroupOperationInProgress state
    try {
      await playerGroupRepository.createPlayerGroup(
        groupName: event.groupName,
        playerNames: event.playerNames,
      );
      emit(PlayerGroupOperationSuccess());
      // After success, reload the groups to reflect the new addition
      add(LoadPlayerGroups());
    } catch (e) {
      emit(PlayerGroupError('Fehler beim Hinzufügen der Spieler-Gruppe: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePlayerGroup(
    UpdatePlayerGroup event,
    Emitter<PlayerGroupState> emit,
  ) async {
    // Optionally emit a loading/in-progress state
    // emit(PlayerGroupsLoading()); // Or a more specific PlayerGroupOperationInProgress state
    try {
      await playerGroupRepository.updatePlayerGroup(
        groupId: event.groupId,
        newGroupName: event.newGroupName,
        newPlayerNames: event.newPlayerNames,
      );
      emit(PlayerGroupOperationSuccess());
      // After success, reload the groups to reflect the update
      add(LoadPlayerGroups());
    } catch (e) {
      emit(PlayerGroupError('Fehler beim Aktualisieren der Spieler-Gruppe: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePlayerGroup(
    DeletePlayerGroup event,
    Emitter<PlayerGroupState> emit,
  ) async {
    try {
      await playerGroupRepository.deletePlayerGroup(groupId: event.groupId);
      emit(PlayerGroupOperationSuccess()); // Indicate success
      add(LoadPlayerGroups()); // Reload groups to reflect deletion
    } catch (e) {
      emit(PlayerGroupError('Fehler beim Löschen der Spieler-Gruppe: ${e.toString()}'));
    }
  }
}
