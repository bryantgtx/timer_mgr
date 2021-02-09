abstract class WorkTimerTask {
  String get taskType;
  String get displayToken;

  Future<void> createTimecardEntry(double hours, DateTime spentDate, String notes) ;

  Map<String, dynamic> toMap();
}