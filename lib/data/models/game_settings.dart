import 'package:equatable/equatable.dart';

class GameSettings extends Equatable {
  final int playerCount;
  final int impostorCount;
  final int roundCount;
  final int timerDuration;
  final bool impostorsKnowEachOther;
  final List<String> selectedCategoryIds;

  const GameSettings({
    required this.playerCount,
    required this.impostorCount,
    required this.roundCount,
    required this.timerDuration,
    required this.impostorsKnowEachOther,
    required this.selectedCategoryIds,
  });

  @override
  List<Object> get props => [
        playerCount,
        impostorCount,
        roundCount,
        timerDuration,
        impostorsKnowEachOther,
        selectedCategoryIds,
      ];

  // Fabrikmethode für Standardeinstellungen
  factory GameSettings.defaultSettings() {
    return const GameSettings(
      playerCount: 5,
      impostorCount: 1,
      roundCount: 3,
      timerDuration: 120, // 2 Minuten
      impostorsKnowEachOther: false,
      selectedCategoryIds: [],
    );
  }

  // Kopieren mit neuen Werten
  GameSettings copyWith({
    int? playerCount,
    int? impostorCount,
    int? roundCount,
    int? timerDuration,
    bool? impostorsKnowEachOther,
    List<String>? selectedCategoryIds,
  }) {
    return GameSettings(
      playerCount: playerCount ?? this.playerCount,
      impostorCount: impostorCount ?? this.impostorCount,
      roundCount: roundCount ?? this.roundCount,
      timerDuration: timerDuration ?? this.timerDuration,
      impostorsKnowEachOther: impostorsKnowEachOther ?? this.impostorsKnowEachOther,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
    );
  }

  // Validierung der Einstellungen
  bool isValid() {
    // Prüfen, ob die Anzahl der Impostoren gültig ist
    if (impostorCount >= playerCount || impostorCount < 1) {
      return false;
    }

    // Prüfen, ob mindestens 3 Spieler teilnehmen
    if (playerCount < 3) {
      return false;
    }

    // Prüfen, ob mindestens eine Runde gespielt wird
    if (roundCount < 1) {
      return false;
    }

    // Prüfen, ob der Timer mindestens 30 Sekunden beträgt
    if (timerDuration < 30) {
      return false;
    }

    // Prüfen, ob mindestens eine Kategorie ausgewählt ist
    if (selectedCategoryIds.isEmpty) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'GameSettings(playerCount: $playerCount, impostorCount: $impostorCount, '
        'roundCount: $roundCount, timerDuration: $timerDuration, '
        'impostorsKnowEachOther: $impostorsKnowEachOther, '
        'selectedCategoryIds: $selectedCategoryIds)';
  }
}
