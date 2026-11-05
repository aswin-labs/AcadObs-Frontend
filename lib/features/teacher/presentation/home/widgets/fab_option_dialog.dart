import 'dart:ui';

import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/option_tile.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class FabOptionsDialog extends StatelessWidget {
  const FabOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final maxPopupHeight = MediaQuery.of(context).size.height * 0.7;

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withAlpha(68)),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 24,
          left: 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxPopupHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(34),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Consumer<SubjectProvider>(
                builder: (context, subjectProv, _) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OptionTile(
                          icon: Icons.note_alt_outlined,
                          label: 'Leave Requests',
                          iconColor: const Color(0xFF26A69A),
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.staffLeaveRequestHome,
                            );
                            Navigator.pop(context);
                          },
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        OptionTile(
                          icon: Icons.menu_book_outlined,
                          label: 'Students',
                          iconColor: const Color(0xFF1E88E5),
                          onTap: () {
                            context.pushNamed(RouteConstants.studentListing);
                            Navigator.pop(context);
                          },
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        OptionTile(
                          icon: LucideIcons.badgeCheck,
                          label: 'Achievements',
                          iconColor: const Color(0xFFFF6B6B),
                          onTap: () {
                            context.pushNamed(RouteConstants.achievementList);
                            Navigator.pop(context);
                          },
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        OptionTile(
                          icon: LucideIcons.fileText,
                          label: 'Parent Notes',
                          iconColor: const Color(0xFF43A047),
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.parentNotesListingScreen,
                            );
                            Navigator.pop(context);
                          },
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        OptionTile(
                          icon: LucideIcons.calendarClock,
                          label: 'Exam Timetable',
                          iconColor: const Color(0xFF7E57C2),
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.examTimetableScreen,
                            );
                            Navigator.pop(context);
                          },
                        ),
                        if (subjectProv.hasPetSubject) ...[
                          Divider(height: 1, color: Colors.grey.shade200),
                          OptionTile(
                            icon: Icons.fitness_center_rounded,
                            label:
                                'Co-Scholastic Assessment\n(Health & Physical Education)',
                            iconColor: const Color(0xFF0077B6),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.physicalCoscholasticAssessment,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        if (subjectProv.hasMusicArtsRoboticsSubject) ...[
                          Divider(height: 1, color: Colors.grey.shade200),
                          OptionTile(
                            icon: Icons.palette_rounded,
                            label:
                                'Co-Scholastic Assessment\n(Music / Arts / Robotics)',
                            iconColor: const Color(0xFF7B2CBF),
                            onTap: () {
                              context.pushNamed(
                                RouteConstants
                                    .musicArtsRoboticsCoscholasticClassSelection,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
