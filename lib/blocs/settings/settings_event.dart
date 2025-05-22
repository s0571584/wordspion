import 'package:equatable/equatable.dart';
import 'package:wortspion/data/models/game_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdatePlayerCount extends SettingsEvent {
  final int playerCount;

  const UpdatePlayerCount(this.playerCount);

  @override
  List<Object> get props => [playerCount];
}

class UpdateImpostorCount extends SettingsEvent {
  final int impostorCount;

  const UpdateImpostorCount(this.impostorCount);

  @override
  List<Object> get props => [impostorCount];
}

class UpdateRoundCount extends SettingsEvent {
  final int roundCount;

  const UpdateRoundCount(this.roundCount);

  @override
  List<Object> get props => [roundCount];
}

class UpdateTimerDuration extends SettingsEvent {
  final int timerDuration;

  const UpdateTimerDuration(this.timerDuration);

  @override
  List<Object> get props => [timerDuration];
}

class UpdateImpostorsKnowEachOther extends SettingsEvent {
  final bool impostorsKnowEachOther;

  const UpdateImpostorsKnowEachOther(this.impostorsKnowEachOther);

  @override
  List<Object> get props => [impostorsKnowEachOther];
}

class UpdateSelectedCategories extends SettingsEvent {
  final List<String> selectedCategoryIds;

  const UpdateSelectedCategories(this.selectedCategoryIds);

  @override
  List<Object> get props => [selectedCategoryIds];
}

class ValidateSettings extends SettingsEvent {
  final GameSettings settings;

  const ValidateSettings(this.settings);

  @override
  List<Object> get props => [settings];
}

class UpdateGameSettings extends SettingsEvent {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;

  const UpdateGameSettings({
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
  });

  @override
  List<Object?> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
      ];
}

class ResetGameSettings extends SettingsEvent {
  const ResetGameSettings();
}
