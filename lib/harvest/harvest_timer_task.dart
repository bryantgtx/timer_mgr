import 'package:timer_mgr/harvest/harvest_api.dart';
import 'package:timer_mgr/work_timer/work_timer_task.dart';

class HarvestTimerTask implements WorkTimerTask {
  static const String harvestTaskType = 'harvestTimerTask';
  String get taskType => harvestTaskType;

  final int projectId;
  final int taskId;
  final String token;

  String get displayToken => token;
  
  HarvestTimerTask({this.projectId, this.taskId, this.token});

  factory HarvestTimerTask.fromMap(Map<dynamic, dynamic> rawMap) {
    return HarvestTimerTask(
      projectId: rawMap['projectId'],
      taskId: rawMap['taskId'],
      token: rawMap['token'],
    );
  }

  Map<String, dynamic> toMap() {
    var hiveMap = Map<String, dynamic>();
    hiveMap['projectId'] = projectId;
    hiveMap['taskId'] = taskId;
    hiveMap['token'] = token;

    return hiveMap;
  }

  @override
  void createTimecardEntry(double hours, DateTime spentDate, String description) {
    HarvestApi().submitTimeEntry(
      projectId: projectId,
      taskId: taskId,
      spentDate: spentDate,
      description: description,
      hours: hours,
    );
  }
}