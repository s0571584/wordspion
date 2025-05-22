import 'dart:async';

class TimerState {
  final bool isRunning;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isCompleted;
  final TimerPhase phase;

  TimerState({
    required this.isRunning,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isCompleted = false,
    required this.phase,
  });

  double get progressPercentage => remainingSeconds / totalSeconds;

  bool get isWarningTime => remainingSeconds <= 10 && remainingSeconds > 0;
}

enum TimerPhase { discussion, voting, wordGuessing, none }

abstract class TimerService {
  Stream<TimerState> get timerStream;
  void startTimer(int durationInSeconds, TimerPhase phase);
  void pauseTimer();
  void resumeTimer();
  void stopTimer();
  void addExtraTime(int seconds);
  bool get isRunning;
  void dispose();
}

class TimerServiceImpl implements TimerService {
  Timer? _timer;
  final _timerController = StreamController<TimerState>.broadcast();
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  TimerPhase _currentPhase = TimerPhase.none;

  @override
  Stream<TimerState> get timerStream => _timerController.stream;

  @override
  void startTimer(int durationInSeconds, TimerPhase phase) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _totalSeconds = durationInSeconds;
    _remainingSeconds = durationInSeconds;
    _isRunning = true;
    _isPaused = false;
    _currentPhase = phase;

    _emitCurrentState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      _remainingSeconds--;
      _emitCurrentState();

      if (_remainingSeconds <= 0) {
        stopTimer();
      }
    });
  }

  @override
  void pauseTimer() {
    if (_isRunning && !_isPaused) {
      _isPaused = true;
      _emitCurrentState();
    }
  }

  @override
  void resumeTimer() {
    if (_isRunning && _isPaused) {
      _isPaused = false;
      _emitCurrentState();
    }
  }

  @override
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    _isRunning = false;
    _isPaused = false;

    // Emittiere einen finalen Zustand mit isCompleted = true
    _timerController.add(TimerState(
      isRunning: false,
      remainingSeconds: 0,
      totalSeconds: _totalSeconds,
      isCompleted: true,
      phase: _currentPhase,
    ));

    _currentPhase = TimerPhase.none;
  }

  @override
  void addExtraTime(int seconds) {
    if (_isRunning) {
      _remainingSeconds += seconds;
      _totalSeconds += seconds;
      _emitCurrentState();
    }
  }

  void _emitCurrentState() {
    _timerController.add(TimerState(
      isRunning: _isRunning && !_isPaused,
      remainingSeconds: _remainingSeconds,
      totalSeconds: _totalSeconds,
      isCompleted: false,
      phase: _currentPhase,
    ));
  }

  @override
  bool get isRunning => _isRunning && !_isPaused;

  @override
  void dispose() {
    stopTimer();
    _timerController.close();
  }
}
