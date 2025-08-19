import 'dart:developer';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/features/homework/presentation/widgets/ranking_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
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
        if (status.student?.id != null && status.points != null) {
          provider.updatePoint(status.student!.id!, status.points!);
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
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Homework ranking submitted')));
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: CommonAppBar(title: 'Homework', isBackButton: true),
      body: Padding(
        padding: context.paddingHorizontal.add(
          EdgeInsets.only(top: Responsive.height * 2),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                // '23/07/2025',
                // widget.homework.dueDate.toString(),
                DateFormat('dd MMM yyyy').format(widget.homework.dueDate!),
                style: TextStyle(fontSize: 24, color: Color(0xFF6F6F6F)),
              ),
              SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.homework.studentHomeworkStatus?.length ?? 0,
                itemBuilder: (context, index) {
                  final studentHomeworks =
                      widget.homework.studentHomeworkStatus?[index];
                  return Consumer<HomeworkProvider>(
                    builder: (context, provider, _) {
                      final studentId = studentHomeworks?.student?.id ?? 0;
                      final points = provider.getPoint(studentId);
                      return RankingCard(
                        studentId: studentHomeworks?.student?.id ?? 0,
                        name: studentHomeworks?.student?.fullName ?? "",
                        number:
                            studentHomeworks?.student?.rollNumber?.toString() ??
                            "",
                        point: points,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: Responsive.height * 20),
            ],
          ),
        ),
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () async {
          buttonFunction(context);
        },
        text: "Submit",
      ),
    );
  }
}
