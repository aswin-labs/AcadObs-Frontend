import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/profile_container_shimmer.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/students/provider/student_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/profile_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentProvider studentProvider;
  @override
  void initState() {
    studentProvider = context.read<StudentProvider>();
    studentProvider.fetchStudentDetails(studentId: widget.studentId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Students", isBackButton: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                children: [
                  Consumer<StudentProvider>(
                    builder: (context, provider, _) {
                      final student = provider.individualStudent;
                      if (provider.isLoading) {
                        return ProfileContainerShimmer();
                      }
                      return ProfileContainer(
                        imagePath: student?.image ?? "",
                        name: student?.fullName ?? "",
                        present: "1",
                        absent: "2",
                        late: "3",
                        description: "class name",
                      );
                    },
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
