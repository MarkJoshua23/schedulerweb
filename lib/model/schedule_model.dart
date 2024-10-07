
import 'package:intl/intl.dart';

class SchedModel {
  late final int schedId;
  late final String profName;
  late final String subject;
  late final String startTime;
  late final String endTime;
  late final String dayOfWeek;
  late final int dayIndex;

  SchedModel({
    required this.schedId,
    required this.profName,
    required this.subject,
    required String rawStartTime,
    required String rawEndTime,
    required this.dayOfWeek,
  }) {
    startTime = _formatTime(rawStartTime);
    endTime = _formatTime(rawEndTime);
    dayIndex = _mapDayToIndex(dayOfWeek);
  }

  static List<SchedModel> jsonToList(List<dynamic> jsonList) {
    List<SchedModel> schedules = [];
    for (var json in jsonList) {
      var schedule = SchedModel(
        schedId: json['schedule_id'],
        profName: json['professor_name'],
        subject: json['subject'],
        rawStartTime: json['start_time'],
        rawEndTime: json['end_time'],
        dayOfWeek: json['day_of_week'],
      );
      schedules.add(schedule);
    }
    return schedules;
  }

  static String _formatTime(String time) {
    // Extract hours and minutes
    List<String> parts = time.split(':');
    String hours = parts[0].padLeft(2, '0');
    String minutes = parts[1].padLeft(2, '0');

    // Create a DateTime object to use DateFormat
    DateTime dateTime = DateTime(2022, 1, 1, int.parse(hours), int.parse(minutes));

    // Format the time to 12-hour format
    return DateFormat("h:mm a").format(dateTime);
  }

  int _mapDayToIndex(String day) {
    final Map<String, int> dayMap = {
      'sunday': 0,
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
    };
    return dayMap[day.toLowerCase()] ?? -1;
  }

}
