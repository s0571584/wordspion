import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wortspion/core/services/timer_service.dart';

// Events
abstract class TimerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartTimer extends TimerEvent {
  final int durationInSeconds;
  final TimerPhase phase;

  StartTimer({
    required this.durationInSeconds,
    required this.phase,
  });

  @override
  List<Object> get props => [durationInSeconds, phase];
}

class PauseTimer extends TimerEvent {}

class ResumeTimer extends TimerEvent {}

class StopTimer extends TimerEvent {}

class AddExtraTime extends TimerEvent {
  final int seconds;

  AddExtraTime(this.seconds);

  @override
  List<Object> get props => [seconds];
}

class TimerTick extends TimerEvent {
  final TimerState timerState;

  TimerTick(this.timerState);

  @override
  List<Object> get props => [timerState];
}

// States
abstract class TimerStateBloc extends Equatable {
  @override
  List<Object?> get props => [];
}

class TimerInitial extends TimerStateBloc {}

class TimerRunInProgress extends TimerStateBloc {
  final TimerState timerState;

  TimerRunInProgress(this.timerState);

  @override
  List<Object> get props => [timerState];
}

class TimerRunPaused extends TimerStateBloc {
  final TimerState timerState;

  TimerRunPaused(this.timerState);

  @override
  List<Object> get props => [timerState];
}

class TimerRunComplete extends TimerStateBloc {
  final TimerPhase completedPhase;

  TimerRunComplete(this.completedPhase);

  @override
  List<Object> get props => [completedPhase];
}

// Bloc
class TimerBloc extends Bloc<TimerEvent, TimerStateBloc> {
  final TimerService timerService;
  StreamSubscription<TimerState>? _timerSubscription;

  TimerBloc({required this.timerService}) : super(TimerInitial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<StopTimer>(_onStopTimer);
    on<AddExtraTime>(_onAddExtraTime);
    on<TimerTick>(_onTimerTick);

    // Subscription zum Timer-Stream
    _timerSubscription = timerService.timerStream.listen((timerState) {
      if (timerState.isCompleted) {
        add(StopTimer());
      } else {
        add(TimerTick(timerState));
      }
    });
  }

  void _onStartTimer(StartTimer event, Emitter<TimerStateBloc> emit) {
    timerService.startTimer(event.durationInSeconds, event.phase);
    // Der aktuelle TimerState wird durch den Subscription-Handler gesendet
  }

  void _onPauseTimer(PauseTimer event, Emitter<TimerStateBloc> emit) {
    if (state is TimerRunInProgress) {
      timerService.pauseTimer();
      final currentState = (state as TimerRunInProgress).timerState;
      emit(TimerRunPaused(currentState));
    }
  }

  void _onResumeTimer(ResumeTimer event, Emitter<TimerStateBloc> emit) {
    if (state is TimerRunPaused) {
      timerService.resumeTimer();
      // Der aktualisierte TimerState wird durch den Subscription-Handler gesendet
    }
  }

  void _onStopTimer(StopTimer event, Emitter<TimerStateBloc> emit) {
    TimerPhase completedPhase = TimerPhase.none;

    if (state is TimerRunInProgress) {
      completedPhase = (state as TimerRunInProgress).timerState.phase;
    } else if (state is TimerRunPaused) {
      completedPhase = (state as TimerRunPaused).timerState.phase;
    }

    timerService.stopTimer();
    emit(TimerRunComplete(completedPhase));
  }

  void _onAddExtraTime(AddExtraTime event, Emitter<TimerStateBloc> emit) {
    timerService.addExtraTime(event.seconds);
    // Der aktualisierte TimerState wird durch den Subscription-Handler gesendet
  }

  void _onTimerTick(TimerTick event, Emitter<TimerStateBloc> emit) {
    emit(TimerRunInProgress(event.timerState));
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    timerService.dispose();
    return super.close();
  }
}
