part of 'work_timer_bloc.dart';

@immutable
abstract class WorkTimerEvent extends Equatable {
  const WorkTimerEvent();
  
  @override
  List<Object> get props => [];
}

class WorkTimerStart extends WorkTimerEvent {}

class WorkTimerPause extends WorkTimerEvent {}

class WorkTimerStop extends WorkTimerEvent {}

class WorkTimerReset extends WorkTimerEvent {}

class WorkTimerTicked extends WorkTimerEvent {
  final int duration;

  const WorkTimerTicked({@required this.duration});
  @override
  List<Object> get props => [duration];
}

class WorkTimerTaskAdded extends WorkTimerEvent {
  final WorkTimerTask task;
  final BuildContext context;

  const WorkTimerTaskAdded(this.context, this.task);
  @override
  List<Object> get props => [task];
}
