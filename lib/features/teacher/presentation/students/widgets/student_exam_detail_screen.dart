import 'package:acadobs/features/teacher/presentation/students/widgets/mark_card.dart';
import 'package:flutter/material.dart';

class StudentExamDetailScreen extends StatelessWidget {
  const StudentExamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            MarkCard(
              classname: "XII",
              examtitle: "1st semester",
              subject: "maths",
              mark: 86,
              total: 100,
            ),
            MarkCard(
              classname: "XII",
              examtitle: "1st semester",
              subject: "science",
              mark: 86,
              total: 100,
            ),
            MarkCard(
              classname: "XII",
              examtitle: "1st semester",
              subject: "english",
              mark: 86,
              total: 100,
            ),
          ],
        ),
      ),
    );
  }
}
