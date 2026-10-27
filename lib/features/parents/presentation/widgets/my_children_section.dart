import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyChildrenSection extends StatefulWidget {
  const MyChildrenSection({super.key});

  @override
  State<MyChildrenSection> createState() => _MyChildrenSectionState();
}

class _MyChildrenSectionState extends State<MyChildrenSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUnseenHomeworkCounts();
    });
  }

  void _fetchUnseenHomeworkCounts() {
    final parentProvider = context.read<ParentProvider>();
    final homeworksProvider = context.read<HomeworksProvider>();
    for (final student in parentProvider.students) {
      homeworksProvider.getUnseenHomeworkCountByStudentId(
        studentId: student.id,
      );
    }
  }

  String _buildImageUrl(String? image) {
    if (image == null || image.trim().isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return "${BaseUrls.media}${MediaEndpoints.studentDp}$image";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                CupertinoIcons.person_2_fill,
                color: Color(0xFF00AEF0),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "My Children",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer2<ParentProvider, HomeworksProvider>(
            builder: (context, parentProvider, homeworksProvider, _) {
              if (parentProvider.students.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "No students found",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parentProvider.students.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = parentProvider.students[index];
                  final unseenCount =
                      homeworksProvider.getUnseenHomeworkCount(student.id);

                  return _buildStudentCard(
                    context,
                    student,
                    unseenCount,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    StudentModel student,
    int unseenCount,
  ) {
    final imageUrl = _buildImageUrl(student.image);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await context.pushNamed(
              RouteConstants.studentDetails,
              extra: StudentDetailParameters(
                forStaff: false,
                studentId: student.id,
              ),
            );
            if (context.mounted) {
              context
                  .read<HomeworksProvider>()
                  .getUnseenHomeworkCountByStudentId(
                    studentId: student.id,
                  );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  CupertinoIcons.person_fill,
                                  color: Colors.white,
                                  size: 24,
                                );
                              },
                            )
                            : const Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.white,
                              size: 24,
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.classGrade?.classname ?? "No Class",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (unseenCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFECDD3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 13,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$unseenCount new",
                          style: const TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
