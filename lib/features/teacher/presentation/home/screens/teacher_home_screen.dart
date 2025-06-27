import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: context.paddingHorizontal,
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: Responsive.height * 2),
                  CustomButtonContainer(
                    color: AppColors.black,
                    text: "Take Attendance",
                    ontap: () => showAttendanceBottomSheet(context),
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
