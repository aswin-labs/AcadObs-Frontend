import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/presentation/widgets/common_floating_action_button.dart';
import 'package:acadobs/presentation/widgets/select_class_bottomsheet.dart';
import 'package:flutter/material.dart';

class StudentsHomeScreen extends StatefulWidget {
  const StudentsHomeScreen({super.key});

  @override
  State<StudentsHomeScreen> createState() => _StudentsHomeScreenState();
}

class _StudentsHomeScreenState extends State<StudentsHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: context.paddingHorizontal,
          child: Column(children: []),
        ),
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () => selectClassBottomsheet(context),
        text: "Add New Student",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
