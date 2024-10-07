import 'package:intl/intl.dart';

class AnnouncementModel {
  late final int id;
  late final int sched_id;
  late final String title;
  late final String content;
  late final String _createdAt;

  AnnouncementModel({
    required this.id,
    required this.sched_id,
    required this.title,
    required this.content,
    required String createdAt,
  }) : _createdAt = createdAt;

  String get createdAt {
    final dateTime = DateTime.parse(_createdAt);
    return DateFormat('MMMM d, yyyy h:mm a').format(dateTime);
  }

  static List<AnnouncementModel> jsonToList(List<dynamic> jsonList) {
    List<AnnouncementModel> announcements = [];
    for (var json in jsonList) {
      var announcement = AnnouncementModel(
        id: json['id'],
        sched_id: json['schedule_id'],
        title: json['title'],
        content: json['content'],
        createdAt: json['created_at'],
      );
      announcements.add(announcement);
    }
    return announcements;
  }
}