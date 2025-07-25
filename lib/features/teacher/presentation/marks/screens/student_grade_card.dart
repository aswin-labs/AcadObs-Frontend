import 'dart:developer';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/features/teacher/presentation/marks/widgets/grade_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';

class StudentGradeCard extends StatelessWidget {
  const StudentGradeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'grade card', isBackButton: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: context.paddingHorizontal,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '24-07-2025',
                            style: TextStyle(
                              color: Color(0xFF6F6F6F),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 90),
                          Text(
                            'Mark 100',
                            style: TextStyle(color: Color(0xFF6F6F6F)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      GradeCard(
                        name: "Theodore T.C. Calvin",
                        grade: "A",
                        mark: '80',
                        serialnumber: 01,
                      ),
                      GradeCard(
                        name: "Theodore T.C. Calvin",
                        grade: "A",
                        mark: '80',
                        serialnumber: 02,
                      ),
                      GradeCard(
                        name: "Theodore T.C. Calvin",
                        grade: "A",
                        mark: '80',
                        serialnumber: 03,
                      ),
                      GradeCard(
                        name: "Theodore T.C. Calvin",
                        grade: "A",
                        mark: '80',
                        serialnumber: 04,
                      ),
                      GradeCard(
                        name: "Theodore T.C. Calvin",
                        grade: "A",
                        mark: '80',
                        serialnumber: 05,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: CommonButton(
                onPressed: () {
                  log('submit');
                },
                widget: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
