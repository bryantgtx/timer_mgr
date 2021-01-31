abstract class WorkTimerTask {
  String get taskType;
  String get displayToken;

  void createTimecardEntry(double hours, DateTime spentDate, String notes);

  Map<String, dynamic> toMap();
}