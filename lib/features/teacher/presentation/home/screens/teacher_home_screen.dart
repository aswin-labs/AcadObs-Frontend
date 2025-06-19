import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/presentation/widgets/common_appbar.dart';
import 'package:acadobs/presentation/widgets/custom_button_container.dart';
import 'package:flutter/material.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "HomeScreen"),
      body: Column(
        children: [
          CustomButtonContainer(
            color: AppColors.black,
            text: "Take Attendance",
            ontap: () {},
          ),
        ],
      ),
    );
  }
}
