import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/player.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayersLoaded extends PlayerState {
  final List<Player> players;

  const PlayersLoaded(this.players);

  @override
  List<Object> get props => [players];
}

class PlayersRegistered extends PlayerState {
  final List<Player> players;

  const PlayersRegistered(this.players);

  @override
  List<Object> get props => [players];
}

class PlayerAdded extends PlayerState {
  final Player player;
  final List<Player> allPlayers;

  const PlayerAdded({
    required this.player,
    required this.allPlayers,
  });

  @override
  List<Object> get props => [player, allPlayers];
}

class PlayerUpdated extends PlayerState {
  final Player player;
  final List<Player> allPlayers;

  const PlayerUpdated({
    required this.player,
    required this.allPlayers,
  });

  @override
  List<Object> get props => [player, allPlayers];
}

class PlayersSorted extends PlayerState {
  final List<Player> players;
  final String sortCriteria;

  const PlayersSorted({
    required this.players,
    required this.sortCriteria,
  });

  @override
  List<Object> get props => [players, sortCriteria];
}

class PlayerError extends PlayerState {
  final String message;

  const PlayerError(this.message);

  @override
  List<Object> get props => [message];
}
