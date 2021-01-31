part of 'work_timer_list_bloc.dart';

@immutable
abstract class WorkTimerListState extends Equatable {
  const WorkTimerListState();

  @override
  List<Object> get props => [];
}

class WorkTimerListInitial extends WorkTimerListState {}

class WorkTimerListReady extends WorkTimerListState {
  final List<WorkTimer> timers;
  const WorkTimerListReady([this.timers = const[]]);

  @override
  List<Object> get props => [timers];

  @override
  String toString() => "WorkTimerListReady";
}
