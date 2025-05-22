import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/settings/settings_event.dart';
import 'package:wortspion/blocs/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<UpdateGameSettings>(_onUpdateGameSettings);
    on<ResetGameSettings>(_onResetGameSettings);
  }

  void _onUpdateGameSettings(
    UpdateGameSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsUpdated(
      playerCount: event.playerCount,
      impostorCount: event.impostorCount,
      roundCount: event.roundCount,
      timerDuration: event.timerDuration,
      impostorsKnowEachOther: event.impostorsKnowEachOther,
    ));
  }

  void _onResetGameSettings(
    ResetGameSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(const SettingsInitial());
  }
}
