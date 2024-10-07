import 'package:flutter/material.dart';
import 'package:my_schedule/model/announcement_model.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ViewPage extends StatefulWidget {
  final String startTime;
  final String endTime;
  final String profName;
  final String subjectName;
  final int schedId;

  const ViewPage({
    required this.startTime,
    required this.endTime,
    required this.profName,
    required this.subjectName,
    required this.schedId,
    super.key,
  });

  @override
  ViewPageState createState() => ViewPageState();
}

class ViewPageState extends State<ViewPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAROON,
      appBar: AppBar(
        backgroundColor: MAROON,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.subjectName,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: WHITE),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(23),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 8),

                    Text(
                      'Time',
                      style: TextStyle(fontWeight: FontWeight.bold, color: WHITE),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Teacher',
                      style: TextStyle(fontWeight: FontWeight.bold, color: WHITE),
                    ),

                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    const SizedBox(height: 8),

                    Text(
                      "${widget.startTime}-${widget.endTime}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: WHITE),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.profName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: WHITE),
                    ),

                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25)
                ),
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Column(
                children: [
                  
                  const SizedBox(height: 10),

                  const Text(
                    'ANNOUNCEMENTS',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnnouncementCard(schedId: widget.schedId),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatefulWidget {
  final int schedId;

  const AnnouncementCard({required this.schedId, super.key});

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<AnnouncementModel>> announcementFuture;

  @override
  void initState() {
    super.initState();
    announcementFuture = fetchAnnouncement();
  }

  Future<List<AnnouncementModel>> fetchAnnouncement() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_announcement')
          .select()
          .eq('schedule_id', widget.schedId)
          .order('id',ascending: false);

          

      return AnnouncementModel.jsonToList(response);
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AnnouncementModel>>(
      future: announcementFuture,
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
                "Looking for announcements...",
                style: TextStyle(color: GRAY, fontSize: 15),
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No announcements available.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final announcement = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: LIGHTGRAY,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        announcement.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        announcement.content,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Created at: ${announcement.createdAt}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}