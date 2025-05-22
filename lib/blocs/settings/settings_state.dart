import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;

  const SettingsInitial({
    this.playerCount = 5,
    this.impostorCount = 1,
    this.roundCount = 3,
    this.timerDuration = 60,
    this.impostorsKnowEachOther = false,
  });

  @override
  List<Object> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
      ];
}

class SettingsLoading extends SettingsState {}

class SettingsUpdated extends SettingsState {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;

  const SettingsUpdated({
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
  });

  @override
  List<Object> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
      ];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}
