import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:timer_mgr/harvest/harvest_timer_task.dart';
import 'package:timer_mgr/resources/settings.dart';
import 'package:timer_mgr/services/ticker.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';
import 'package:timer_mgr/work_timer/work_timer_task.dart';
import 'package:timer_mgr/work_timer_list/work_timer_list_bloc.dart';

part 'work_timer_event.dart';
part 'work_timer_state.dart';

class WorkTimerBloc extends Bloc<WorkTimerEvent, WorkTimerReadyState> {
  final Ticker ticker;

  StreamSubscription<int> _tickerSubscription;

  WorkTimerBloc({@required this.ticker, workTimer: WorkTimer}) : 
    assert(ticker != null),
    super(WorkTimerReadyState(workTimer));
   
  @override
  Stream<WorkTimerReadyState> mapEventToState(WorkTimerEvent event) async* {
    if (event is WorkTimerStart) {
      yield* _mapWorkTimerStart(event);
    }
    else if (event is WorkTimerTicked) {
      yield* _mapWorkTimerTicked(event);
    }
    else if (event is WorkTimerPause) {
      yield* _mapWorkTimerPause(event);
    }
    else if (event is WorkTimerStop) {
      yield* _mapWorkTimerStop(event);
    }
    else if (event is WorkTimerReset) {
      yield* _mapWorkTimerReset(event);
    }
    else if (event is WorkTimerTaskAdded) {
      yield* _mapWorkTimerTaskAdded(event);
    }
    // todo: clear (i.e. stop without sending)?
  }

  Stream<WorkTimerReadyState> _mapWorkTimerStart(WorkTimerStart event) async* {
    yield WorkTimerRunningState(state.timer);
    if (state is WorkTimerPausedState) {
      _tickerSubscription.resume();
    } 
    else {
      _tickerSubscription?.cancel();
      _tickerSubscription = ticker
          .startTicking()
          .listen((duration) => add(WorkTimerTicked(duration: duration)));
    }
  }

  Stream<WorkTimerReadyState> _mapWorkTimerTicked(WorkTimerTicked event) async* {
    yield WorkTimerRunningState(state.timer.addTicks(event.duration));
  }

  Stream<WorkTimerReadyState> _mapWorkTimerPause(WorkTimerPause event) async* {
    if (state is WorkTimerRunningState) {
      _tickerSubscription.pause();
      yield WorkTimerPausedState(state.timer);
    }
  }

  Stream<WorkTimerReadyState> _mapWorkTimerStop(WorkTimerStop event) async* {
    if (_tickerSubscription != null) _tickerSubscription.cancel();
    yield WorkTimerStoppedState(state.timer);
    await sendTimeEntries(state.timer);
    yield WorkTimerReadyState(state.timer.resetElapsed());
  }

  Stream<WorkTimerReadyState> _mapWorkTimerReset(WorkTimerReset event) async* {
    _tickerSubscription?.cancel();
    yield WorkTimerReadyState(state.timer.resetElapsed());
  }

  Stream<WorkTimerReadyState> _mapWorkTimerTaskAdded(WorkTimerTaskAdded event) async* {
    state.timer.addTask(event.task);
    BlocProvider.of<WorkTimerListBloc>(event.context).add(WorkTimerListUpdate(timer: state.timer));
  }

  Future sendTimeEntries(WorkTimer timer) async {
    print('Should send off ${timer.elapsed} seconds');
    int taskCount = timer.tasks.length;
    await Future.forEach(timer.tasks, (task) async { 
      switch (task.taskType) {
        case HarvestTimerTask.harvestTaskType:
          double splitDuration = (timer.elapsed / taskCount) / 3600.0;
          if (splitDuration >= Settings.minimumTimeCardDuration) {
            await task.createTimecardEntry(splitDuration, DateTime.now(), timer.description);
          }
          break;
        default:
          throw Exception('Unable to create timecard for ${task.taskType}');
      }
    });
  }

}