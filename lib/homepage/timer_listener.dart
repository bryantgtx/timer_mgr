// WorkTimerListener should listen to start events from work timers, and stop any other running timers.
import 'dart:async';

import 'package:timer_mgr/work_timer/work_timer_bloc.dart';

class WorkTimerListener {
  static final WorkTimerListener _workTimerListener =
      WorkTimerListener._constructor();
  var timerBlocs = Map<int, WorkTimerBloc>();
  List<StreamSubscription> subscriptions = [];

  factory WorkTimerListener() {
    return _workTimerListener;
  }
  WorkTimerListener._constructor();

  Future _pauseRunning(int hashCode) async {
    timerBlocs.forEach((key, value) {
      if (key != hashCode) {
        value.add(WorkTimerPause());
      }
    });
  }

  void addBloc(WorkTimerBloc timerBloc) {
    timerBlocs[timerBloc.hashCode] = timerBloc;
    subscriptions.add(timerBloc.listen((state) {
      if (state is WorkTimerRunningState) {
        _pauseRunning(timerBloc.hashCode);
      }
    }));
  }

  void clear() {
    subscriptions = [];
    for (var bloc in timerBlocs.values) {
      bloc.close();
    }
    timerBlocs.clear();
  }
}
