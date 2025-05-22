import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/player.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlayers extends PlayerEvent {
  final String gameId;

  const LoadPlayers({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

class AddPlayer extends PlayerEvent {
  final String gameId;
  final String name;

  const AddPlayer({
    required this.gameId,
    required this.name,
  });

  @override
  List<Object> get props => [gameId, name];
}

class RegisterPlayers extends PlayerEvent {
  final List<Player> players;

  const RegisterPlayers(this.players);

  @override
  List<Object> get props => [players];
}

class UpdatePlayerScore extends PlayerEvent {
  final String playerId;
  final int points;

  const UpdatePlayerScore({
    required this.playerId,
    required this.points,
  });

  @override
  List<Object> get props => [playerId, points];
}

class RemovePlayer extends PlayerEvent {
  final String playerId;

  const RemovePlayer({required this.playerId});

  @override
  List<Object> get props => [playerId];
}

class SortPlayers extends PlayerEvent {
  final List<Player> players;
  final String sortCriteria; // 'name', 'score', etc.

  const SortPlayers({
    required this.players,
    required this.sortCriteria,
  });

  @override
  List<Object> get props => [players, sortCriteria];
}

class ResetPlayerState extends PlayerEvent {
  const ResetPlayerState();
}
