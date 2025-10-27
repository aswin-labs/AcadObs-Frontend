import 'dart:developer';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/features/homework/presentation/widgets/ranking_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeworkRankingScreen extends StatefulWidget {
  final HomeworkModel homework;
  const HomeworkRankingScreen({super.key, required this.homework});

  @override
  State<HomeworkRankingScreen> createState() => _HomeworkRankingScreenState();
}

class _HomeworkRankingScreenState extends State<HomeworkRankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("studentHomeworkStatus: ${widget.homework.studentHomeworkStatus}");

      final provider = context.read<HomeworkProvider>();
      for (var status in widget.homework.studentHomeworkStatus ?? []) {
        final id = status.student?.id;
        if (id != null) {
          if (status.points != null) {
            provider.updatePoint(id, status.points!);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //button function
    void buttonFunction(BuildContext context) async {
      final provider = Provider.of<HomeworkProvider>(context, listen: false);
      final studentPoints = provider.studentRankingsList;

      log("Submitting rankings: $studentPoints");

      if (studentPoints.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please assign at least one point')),
        );
        return;
      }
      await provider.homeworkRanking(
        context: context,
        homeworkId: widget.homework.id ?? 0,
        assignments: studentPoints,
      );
      if (!context.mounted) return;

      Navigator.pop(context);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: CommonAppBar(title: 'Homework Ranking', isBackButton: true),
      body: Column(
        children: [
          // Header Section with Enhanced Design
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6366F1).withAlpha(77),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(widget.homework.dueDate!),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Students Count Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: Color(0xFF6366F1),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${widget.homework.studentHomeworkStatus?.length ?? 0} Students',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF6366F1).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 18,
                        color: Color(0xFF6366F1),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Rank Students',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Students List
          Expanded(
            child: Padding(
              padding: context.paddingHorizontal,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.homework.studentHomeworkStatus?.length ?? 0,
                itemBuilder: (context, index) {
                  return Consumer<HomeworkProvider>(
                    builder: (context, provider, _) {
                      final studentStatus =
                          provider
                              .singleHomework
                              ?.studentHomeworkStatus?[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RankingCard(
                          studentId: studentStatus?.student?.id ?? 0,
                          name: studentStatus?.student?.fullName ?? "",
                          number:
                              studentStatus?.student?.rollNumber?.toString() ??
                              "",
                          point: provider.getPoint(
                            studentStatus?.student?.id ?? 0,
                          ),
                          homeworkId: studentStatus?.id ?? 0,
                          remark: studentStatus?.remark ?? "",
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Bottom padding for FAB
          SizedBox(height: 80),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<HomeworkProvider>(
        builder: (context, provider, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6366F1).withAlpha(77),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: CommonButton(
              onPressed: () async {
                buttonFunction(context);
              },
              widget:
                  provider.isLoadingTwo
                      ? ButtonLoading()
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Submit Rankings",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}

// import 'dart:developer';

// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/button_loading.dart';
// import 'package:acadobs/core/utils/responsive.dart';
// import 'package:acadobs/features/homework/data/models/homework_model.dart';
// import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
// import 'package:acadobs/features/homework/presentation/widgets/ranking_card.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:acadobs/shared/widgets/common_button.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class HomeworkRankingScreen extends StatefulWidget {
//   final HomeworkModel homework;
//   const HomeworkRankingScreen({super.key, required this.homework});

//   @override
//   State<HomeworkRankingScreen> createState() => _HomeworkRankingScreenState();
// }

// class _HomeworkRankingScreenState extends State<HomeworkRankingScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       log("studentHomeworkStatus: ${widget.homework.studentHomeworkStatus}");

//       final provider = context.read<HomeworkProvider>();
//       for (var status in widget.homework.studentHomeworkStatus ?? []) {
//         final id = status.student?.id;
//         if (id != null) {
//           if (status.points != null) {
//             provider.updatePoint(id, status.points!);
//           }
//           // if (status.remark != null) {
//           //   provider.updateRemark(id, status.remark!);
//           // }
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     //button function
//     void buttonFunction(BuildContext context) async {
//       final provider = Provider.of<HomeworkProvider>(context, listen: false);
//       final studentPoints = provider.studentRankingsList;

//       log("Submitting rankings: $studentPoints");

//       if (studentPoints.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Please assign at least one point')),
//         );
//         return;
//       }
//       await provider.homeworkRanking(
//         context: context,
//         homeworkId: widget.homework.id ?? 0,
//         assignments: studentPoints,
//       );
//       if (!context.mounted) return;

//       Navigator.pop(context);
//       Navigator.pop(context);
//     }

//     return Scaffold(
//       appBar: CommonAppBar(title: 'Homework', isBackButton: true),
//       body: Padding(
//         padding: context.paddingHorizontal.add(
//           EdgeInsets.only(top: Responsive.height * 2),
//         ),
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 // '23/07/2025',
//                 // widget.homework.dueDate.toString(),
//                 DateFormat('dd MMM yyyy').format(widget.homework.dueDate!),
//                 style: TextStyle(fontSize: 24, color: Color(0xFF6F6F6F)),
//               ),
//               SizedBox(height: 10),

//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: widget.homework.studentHomeworkStatus?.length ?? 0,
//                 itemBuilder: (context, index) {
//                   // final studentHomeworks =
//                   //     widget.homework.studentHomeworkStatus?[index];
//                   return Consumer<HomeworkProvider>(
//                     builder: (context, provider, _) {
//                       final studentStatus =
//                           provider
//                               .singleHomework
//                               ?.studentHomeworkStatus?[index];

//                       return RankingCard(
//                         studentId: studentStatus?.student?.id ?? 0,
//                         name: studentStatus?.student?.fullName ?? "",
//                         number:
//                             studentStatus?.student?.rollNumber?.toString() ??
//                             "",
//                         point: provider.getPoint(
//                           studentStatus?.student?.id ?? 0,
//                         ),
//                         homeworkId: studentStatus?.id ?? 0,
//                         remark:
//                             studentStatus?.remark ??
//                             "", // ✅ from provider not widget
//                       );
//                     },
//                   );
//                 },
//               ),
//               SizedBox(height: Responsive.height * 20),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: Consumer<HomeworkProvider>(
//         builder: (context, provider, _) {
//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: CommonButton(
//               onPressed: () async {
//                 buttonFunction(context);
//               },
//               widget: provider.isLoadingTwo ? ButtonLoading() : Text("Submit"),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
