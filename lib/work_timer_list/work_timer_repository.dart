import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';

class WorkTimerRepository {
  final JsonCodec codec;
  final Box _box;

  const WorkTimerRepository(this._box, [this.codec = json]);

  List<WorkTimer> loadWorkTimers() {
    return _box.values.map((value) => WorkTimer.fromMap(value)).toList();
  }

  Future<void> saveWorkTimer(WorkTimer timer) async {
    await _box.put(timer.id, timer.toMap());
  }

  Future<void> removeWorkTimer(String id) async {
    await _box.delete(id);
  }

  Future<void> removeAllWorkTimers() async {
    await _box.clear();
  }
}