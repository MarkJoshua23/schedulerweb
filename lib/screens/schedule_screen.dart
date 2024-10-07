import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_schedule/box/boxes.dart';
import 'package:my_schedule/model/schedule_model.dart';
import 'package:my_schedule/model/user_model.dart';
import 'package:my_schedule/screens/view_page.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:my_schedule/shared/schedule_list_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDay = DateTime.now().weekday % 7;
  final List<String> days = ["S", "M", "T", "W", "TH", "F", "SA"];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getCredentials();
    super.initState();
  }

  // So need ko gumawa dito ng query para makuha yung mga credential ng specific user na nag login, gagamitin ko yung user id na nilagay ko sa hive
  UserModel?
      userInfo; // Bali laman nito yung credentials nung user na ni query,
  void getCredentials() async {
    final userCredentials = await Supabase.instance.client
        .from('tbl_users')
        .select()
        .eq('auth_id', boxUserCredentials.get('userId'));
    print("USER CREDENTIALS ::: $userCredentials");

    for (var data in userCredentials) {
      userInfo = UserModel(
          firstName: data['first_name'],
          lastName: data['last_name'],
          section: data['section'],
          email: data['email'],
          birthday: data['birthday'],
          userType: data['user_type']);
    }

    await boxUserCredentials.put("section", userInfo!.section);
    print("SECTIONNNN :::: ${boxUserCredentials.get("section")}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAROON,
      appBar: AppBar(
        backgroundColor: MAROON,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/wally.jpg"),
            ),
          ),
        ],
      ),
      drawer: const DrawerClass(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userInfo != null
                    ? Text(
                        "${userInfo!.firstName} ${userInfo!.lastName}",
                        style: const TextStyle(
                            fontSize: 30,
                            color: WHITE,
                            fontWeight: FontWeight.bold),
                      )
                    : Shimmer(
                        child: Container(
                        height: 40,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(28, 158, 158, 158),
                            borderRadius: BorderRadius.circular(10)),
                      )),
                      SizedBox(height: 6,),
                userInfo != null
                    ? Text(
                        "${userInfo!.section}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: WHITE,
                        ),
                      )
                    : Shimmer(
                        child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(26, 158, 158, 158),
                            borderRadius: BorderRadius.circular(10)),
                      )),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: days.asMap().entries.map((entry) {
                        int index = entry.key;
                        String day = entry.value;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDay = index;
                            });
                          },
                          child: SizedBox(
                            width: 50,
                            height: 60,
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color:
                                    selectedDay == index ? MAROON : LIGHTGRAY,
                              ),
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: selectedDay == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 45),
                    child: Text(
                      "Time            Course",
                      style: TextStyle(color: GRAY),
                    ),
                  ),
                  Expanded(
                    child: ScheduleList(
                      selectedDay: selectedDay,
                      scrollController: _scrollController,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ScheduleList extends StatefulWidget {
  final int selectedDay;
  final ScrollController scrollController;

  const ScheduleList(
      {super.key, required this.selectedDay, required this.scrollController});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<SchedModel>> schedFuture;
  Map<int, bool> newAnnouncementsMap = {};
  late Box<String> announcementsBox;
  Map<int, String> latestAnnouncementTimes = {};
  late String section = boxUserCredentials.get("section");

  @override
  void initState() {
    super.initState();
    initHive();
    schedFuture = fetchSched();
  }

  void initHive() async {
    await Hive.initFlutter();
    announcementsBox = await Hive.openBox<String>('announcements');
    loadData();
  }

  Future<void> loadData() async {
    schedFuture = fetchSched();
    await checkForNewAnnouncements();
    setState(() {});
  }

  Future<List<SchedModel>> fetchSched() async {
    // If section is not provided, wait for it to be available in Hive
    await waitForSection();
    section = boxUserCredentials.get("section");

    try {
      final response =
          await supabase.from('tbl_schedule').select().eq('section', section);
      return SchedModel.jsonToList(response);
    } catch (e) {
      print('Error fetching schedules: $e');
      return [];
    }
  }

  Future<void> waitForSection() async {
    while (boxUserCredentials.get("section") == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> checkForNewAnnouncements() async {
    final response = await supabase
        .from('tbl_announcement')
        .select('schedule_id, created_at')
        .order('created_at', ascending: false);

    for (var announcement in response) {
      int schedId = announcement['schedule_id'];
      String createdAt = announcement['created_at'];

      // Store the latest created_at for each schedule
      if (!latestAnnouncementTimes.containsKey(schedId) ||
          createdAt.compareTo(latestAnnouncementTimes[schedId]!) > 0) {
        latestAnnouncementTimes[schedId] = createdAt;
      }

      String lastViewedKey = 'last_viewed_$schedId';
      String? lastViewedTime = announcementsBox.get(lastViewedKey);

      if (lastViewedTime == null || createdAt.compareTo(lastViewedTime) > 0) {
        newAnnouncementsMap[schedId] = true;
      }
    }
  }

  void updateLastViewedTime(int schedId) async {
    String? latestTime = latestAnnouncementTimes[schedId];
    if (latestTime != null) {
      await announcementsBox.put('last_viewed_$schedId', latestTime);
      setState(() {
        newAnnouncementsMap[schedId] = false;
      });
    }
  }

  bool checkIfCurrentTime(String startTime, String endTime) {
    DateTime now = DateTime.now();
    final scheduleStartTime = _parseTimeString(startTime, now);
    final scheduleEndTime = _parseTimeString(endTime, now);
    final lowerBound = scheduleStartTime.subtract(const Duration(minutes: 1));
    final upperBound = scheduleEndTime;
    return now.isAfter(lowerBound) && now.isBefore(upperBound);
  }

  DateTime _parseTimeString(String timeString, DateTime currentDate) {
    List<String> parts = timeString.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    if (parts[1].toLowerCase() == 'pm' && hours != 12) {
      hours += 12;
    }
    if (parts[1].toLowerCase() == 'am' && hours == 12) {
      hours = 0;
    }
    return DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      hours,
      minutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadData,
      child: FutureBuilder<List<SchedModel>>(
        future: schedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                const SizedBox(height: 50),
                Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: MAROON,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Just a moment, retrieving schedule...",
                  style: TextStyle(color: GRAY, fontSize: 15),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No schedules available'));
          }

          List<SchedModel> allSched = snapshot.data!;
          List<SchedModel> filteredSchedules = allSched
              .where((schedule) => schedule.dayIndex == widget.selectedDay)
              .toList();

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            itemCount: filteredSchedules.length,
            itemBuilder: (context, index) {
              var schedule = filteredSchedules[index];
              bool isCurrentTime = checkIfCurrentTime(
                schedule.startTime,
                schedule.endTime,
              );

              bool hasNewAnnouncement =
                  newAnnouncementsMap[schedule.schedId] ?? false;

              return ScheduleListItem(
                schedule: schedule,
                isCurrentTime: isCurrentTime,
                hasNewAnnouncement: hasNewAnnouncement,
                onTap: () {
                  updateLastViewedTime(schedule
                      .schedId); //only updates hive when sched is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPage(
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        profName: schedule.profName,
                        subjectName: schedule.subject,
                        schedId: schedule.schedId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
