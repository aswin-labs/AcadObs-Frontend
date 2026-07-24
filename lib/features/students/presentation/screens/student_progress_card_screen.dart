import 'package:acadobs/features/students/presentation/widgets/progress_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class StudentProgressCardScreen extends StatelessWidget {
  const StudentProgressCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Progress Card', isBackButton: true),
      body: Column(children: [ProgressCardDesign()]),
    );
  }
}
