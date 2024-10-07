import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_schedule/model/schedule_model.dart';
import 'package:my_schedule/screens/view_page.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int selectedDay = DateTime.now().weekday % 7;
  // Get current day of the week (0 = Sunday, 6 = Saturday)
  final List<String> days = ["S", "M", "T", "W", "TH", "F", "SA"];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAROON,
      appBar: AppBar(
        backgroundColor: MAROON,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Option 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Option 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Juan Dela Cruztzy",
                  style: TextStyle(
                      fontSize: 30, color: WHITE, fontWeight: FontWeight.bold),
                ),
                Text(
                  "BSCS-4",
                  style: TextStyle(
                    fontSize: 20,
                    color: WHITE,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: days.asMap().entries.map((entry) {
                        int index = entry.key;
                        String day = entry.value;
                        return InkWell(
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 10),
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                        fontSize: 19,
                                        color: selectedDay == index
                                            ? const Color.fromARGB(255, 255, 255, 255)
                                            : const Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.bold),
                                  ),
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

  const ScheduleList({super.key, required this.selectedDay, required this.scrollController});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<SchedModel>> schedFuture;

  @override
  void initState() {
    super.initState();
    schedFuture = fetchSched();
  }

  Future<List<SchedModel>> fetchSched() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_schedule')
          .select()
          .eq('section', 'BSHM-2B');

      return SchedModel.jsonToList(response);
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SchedModel>>(
      future: schedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: MAROON, size: 50)),
              const SizedBox(
                height: 10,
              ),
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

        int highlightedIndex = filteredSchedules.indexWhere((schedule) {
          return checkIfCurrentTime(schedule.startTime, schedule.endTime);
        });

        if (highlightedIndex != -1) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            widget.scrollController.animateTo(
              highlightedIndex * 105.0,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          });
        }

        return ListView.builder(
          controller: widget.scrollController,
          itemCount: filteredSchedules.length,
          itemBuilder: (context, index) {
            var schedule = filteredSchedules[index];
            bool isCurrentTime =
                checkIfCurrentTime(schedule.startTime, schedule.endTime);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Column
                    Container(
                      width: 80,
                      decoration: const BoxDecoration(
                          border:
                              Border(right: BorderSide(width: 2, color: GRAY))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  schedule.startTime,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  schedule.endTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 126, 126, 126),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Schedule Detail Container
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: const Color.fromARGB(29, 0, 0, 0),
                            borderRadius: BorderRadius.circular(8.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPage(startTime: schedule.startTime, endTime: schedule.endTime,profName: schedule.profName, subjectName: schedule.subject, schedId: schedule.schedId,)),
                              );
                            },
                            child: Ink(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isCurrentTime ? MAROON : LIGHTGRAY,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule.subject,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentTime
                                          ? const Color.fromARGB(
                                              255, 255, 255, 255)
                                          : const Color.fromARGB(255, 3, 3, 3),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    schedule.profName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentTime
                                          ? const Color.fromARGB(
                                              255, 255, 255, 255)
                                          : const Color.fromARGB(255, 3, 3, 3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool checkIfCurrentTime(String startTime, String endTime) {
    // Get today's date
    DateTime now = DateTime.now();

    // Parse the start_time and end_time string
    final scheduleStartTime = _parseTimeString(startTime, now);
    final scheduleEndTime = _parseTimeString(endTime, now);

    // Define a time range (1 minute before the start_time and up to the end_time)
    final lowerBound = scheduleStartTime.subtract(const Duration(minutes: 1));
    final upperBound = scheduleEndTime;

    // Check if the current time falls within the range
    return now.isAfter(lowerBound) && now.isBefore(upperBound);
  }

  DateTime _parseTimeString(String timeString, DateTime currentDate) {
    // Extract hours and minutes
    List<String> parts = timeString.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Adjust for PM
    if (parts[1].toLowerCase() == 'pm' && hours != 12) {
      hours += 12;
    }
    // Adjust for AM 12:00
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
}