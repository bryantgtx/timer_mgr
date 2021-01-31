import 'package:equatable/equatable.dart';
import 'package:timer_mgr/harvest/harvest_timer_task.dart';
import 'package:timer_mgr/work_timer/work_timer_task.dart';
import 'package:uuid/uuid.dart';

class WorkTimer extends Equatable {
  final String id;
  final String name;
  final String description;

  final List<WorkTimerTask> tasks;

  final int elapsed;

  WorkTimer({id, this.name, this.description, tasks, this.elapsed=0})
    : this.id = id ?? Uuid().v4(),
      this.tasks = tasks ?? [];

  WorkTimer addTicks(int duration) {
    return WorkTimer(
      id: this.id,
      name: this.name,
      description: this.description,
      tasks: List<WorkTimerTask>.from(this.tasks),
      elapsed: this.elapsed + duration,
    );
  }

  WorkTimer resetElapsed() {
    return WorkTimer(
      id: this.id,
      name: this.name,
      description: this.description,
      tasks: List<WorkTimerTask>.from(this.tasks),
      elapsed: 0,
    );
  }

  void addTask(WorkTimerTask task) {
    tasks.add(task);
  }

  void removeTask(String displayToken) {
    tasks.removeWhere((task) => task.displayToken == displayToken);
  }

  WorkTimer copyWith({name, description, id, tasks, elapsed}) {
    return WorkTimer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tasks: List<WorkTimerTask>.from(tasks ?? this.tasks),
      elapsed: elapsed ?? this.elapsed,
    );
  }

  factory WorkTimer.fromMap(Map<dynamic, dynamic> rawTimer) {
    List<dynamic> rawTasks = rawTimer['tasks'];
    List<WorkTimerTask> tasks = rawTasks.map((e) {
      switch (e['taskType'] as String) {
        case HarvestTimerTask.harvestTaskType:
          return HarvestTimerTask.fromMap(e);
        default:
          throw 'Unknown taskType: ${e['taskType']}';
      }
    }).toList();
    return WorkTimer(
      id: rawTimer['id'],
      name: rawTimer['name'],
      description: rawTimer['description'],
      tasks: tasks,
    );
  }

  
  Map<String, dynamic> toMap() {
    var hiveMap = Map<String, dynamic>();
    hiveMap['id'] = id;
    hiveMap['name'] = name;
    hiveMap['description'] = description;
    hiveMap['tasks'] = tasks.map((task) {
      var mapTask = task.toMap();
      mapTask['taskType'] = task.taskType;
      return mapTask;
    }).toList();

    return hiveMap;
  }

  @override
  List<Object> get props => [id, name, elapsed, tasks];
}