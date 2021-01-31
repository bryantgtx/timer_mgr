part of 'work_timer_list_bloc.dart';

@immutable
abstract class WorkTimerListEvent extends Equatable {
  const WorkTimerListEvent();
  
  @override
  List<Object> get props => [];
}

class WorkTimerListLoad extends WorkTimerListEvent {}

class WorkTimerListAdd extends WorkTimerListEvent {
  final WorkTimer timer;
  const WorkTimerListAdd({@required this.timer});
  
  @override
  List<Object> get props => [timer];
}

class WorkTimerListRemove extends WorkTimerListEvent {
  final String id;
  const WorkTimerListRemove({@required this.id});
  
  @override
  List<Object> get props => [id];
}

class WorkTimerListUpdate extends WorkTimerListEvent {
  final WorkTimer timer;
  const WorkTimerListUpdate({@required this.timer});
  
  @override
  List<Object> get props => [timer];
}
