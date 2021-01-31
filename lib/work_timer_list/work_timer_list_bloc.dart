import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';
import 'package:timer_mgr/work_timer_list/work_timer_repository.dart';

part 'work_timer_list_event.dart';
part 'work_timer_list_state.dart';

class WorkTimerListBloc extends Bloc<WorkTimerListEvent, WorkTimerListState> {
  final WorkTimerRepository repo;

  WorkTimerListBloc({@required this.repo}) : 
    assert(repo != null),
    super(WorkTimerListInitial());
   
  @override
  Stream<WorkTimerListState> mapEventToState(WorkTimerListEvent event) async* {
    if (event is WorkTimerListLoad) {
      yield* _mapWorkTimersLoad(event);
    }
    else if (event is WorkTimerListAdd) {
      yield* _mapWorkTimerListAdd(event);
    }
    else if (event is WorkTimerListRemove) {
      yield* _mapWorkTimerListRemove(event);
    }
    else if (event is WorkTimerListUpdate) {
      yield* _mapWorkTimerListUpdate(event);
    }
  }

  Stream<WorkTimerListState> _mapWorkTimersLoad(WorkTimerListLoad event) async* {
    yield WorkTimerListReady(repo.loadWorkTimers());
  }

  Stream<WorkTimerListState> _mapWorkTimerListAdd(WorkTimerListAdd event) async* {
    if (state is WorkTimerListReady) {
      final List<WorkTimer> timers = List.from((state as WorkTimerListReady).timers)
        ..add(event.timer);
      await repo.saveWorkTimer(event.timer);
      yield WorkTimerListReady(timers);
    }
  }

  Stream<WorkTimerListState> _mapWorkTimerListRemove(WorkTimerListRemove event) async* {
    if (state is WorkTimerListReady) {
      final List<WorkTimer> timers = List.from((state as WorkTimerListReady).timers)
        ..removeWhere((timer) => timer.id == event.id);
      await repo.removeWorkTimer(event.id);
      yield WorkTimerListReady(timers);
    } 
  }

  Stream<WorkTimerListState> _mapWorkTimerListUpdate(WorkTimerListUpdate event) async* {
    if (state is WorkTimerListReady) {
      final List<WorkTimer> timers = List.from((state as WorkTimerListReady).timers);
      final int idx = timers.indexWhere((element) => element.id == event.timer.id);
      if (idx >= 0) {
        timers[idx] = event.timer;
        await repo.saveWorkTimer(event.timer);
      }
      yield WorkTimerListReady(timers);
    }
  }
}
