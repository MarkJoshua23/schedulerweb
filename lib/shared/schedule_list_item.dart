
import 'package:flutter/material.dart';
import 'package:my_schedule/model/schedule_model.dart';
import 'package:my_schedule/shared/constants.dart';
import 'package:badges/badges.dart' as badges;

class ScheduleListItem extends StatelessWidget {
  final SchedModel schedule;
  final bool isCurrentTime;
  final bool hasNewAnnouncement;
  final VoidCallback onTap;

  const ScheduleListItem({
    required this.schedule,
    required this.isCurrentTime,
    required this.hasNewAnnouncement,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(width: 2, color: GRAY)),
              ),
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: const Color.fromARGB(29, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: onTap,
                    child: Ink(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isCurrentTime ? MAROON : LIGHTGRAY,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: badges.Badge(
                        position: badges.BadgePosition.topEnd(),
                        showBadge: hasNewAnnouncement,
                        
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.transparent,
                        ),
                        badgeContent: const Icon(
                          Icons.circle,
                          size: 10,
                          color: Color.fromARGB(255, 51, 231, 57),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.subject,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCurrentTime ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              schedule.profName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrentTime ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
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
  }
}
