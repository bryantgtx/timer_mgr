part of 'work_timer_bloc.dart';

class WorkTimerReadyState extends Equatable {
  final WorkTimer timer;
  const WorkTimerReadyState(this.timer);

  @override
  String toString() => "WorkTimerReady state";

  @override
  List<Object> get props => [timer];
}

class WorkTimerRunningState extends WorkTimerReadyState {
  const WorkTimerRunningState(WorkTimer timer) : super(timer);

  @override
  String toString() => "WorkTimerRunning state";
}

class WorkTimerPausedState extends WorkTimerReadyState {
  const WorkTimerPausedState(WorkTimer timer) : super(timer);

  @override
  String toString() => "WorkTimerPaused state";
}

class WorkTimerStoppedState extends WorkTimerReadyState {
  const WorkTimerStoppedState(WorkTimer timer) : super(timer);

  @override
  String toString() => "WorkTimerStopped state";
}
