import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimerStatus { initial, running, paused }

class TimerState {
  final Duration duration;
  final Duration remainingTime;
  final TimerStatus status;

  const TimerState({
    required this.duration,
    required this.remainingTime,
    required this.status,
  });

  TimerState copyWith({
    Duration? duration,
    Duration? remainingTime,
    TimerStatus? status,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      remainingTime: remainingTime ?? this.remainingTime,
      status: status ?? this.status,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  TimerNotifier() : super(const TimerState(duration: Duration(), remainingTime: Duration(), status: TimerStatus.initial));

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration, remainingTime: duration);
  }

  void startTimer() {
    if (state.duration.inSeconds > 0) {
      _timer?.cancel();
      state = state.copyWith(status: TimerStatus.running);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.remainingTime.inSeconds > 0) {
          state = state.copyWith(remainingTime: state.remainingTime - const Duration(seconds: 1));
        } else {
          _timer?.cancel();
          state = state.copyWith(status: TimerStatus.initial);
        }
      });
    }
  }

  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resetTimer() {
    _timer?.cancel();
    state = const TimerState(duration: Duration(), remainingTime: Duration(), status: TimerStatus.initial);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
