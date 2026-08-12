import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/student_feature_card.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/show_attendance_dialog_class_teacher.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/show_marks_report_dialog.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MyClassScreen extends StatefulWidget {
  final ClassGradeModel classGrade;
  const MyClassScreen({super.key, required this.classGrade});

  @override
  State<MyClassScreen> createState() => _MyClassScreenState();
}

class _MyClassScreenState extends State<MyClassScreen> {
  String _searchQuery = '';

  final _searchController = TextEditingController();

  late StudentProvider studentProvider;

  @override
  void initState() {
    super.initState();

    studentProvider = context.read<StudentProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStudents();
    });
  }

  Future<void> _fetchStudents() async {
    _clearFilters();

    await studentProvider.fetchStudentsByClassId(
      context: context,
      classId: widget.classGrade.id,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredStudents(List<dynamic> students) {
    if (_searchQuery.isEmpty) return students;

    return students.where((student) {
      final name = student.fullName?.toLowerCase() ?? '';
      final rollNo = student.rollNumber?.toString() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || rollNo.contains(query);
    }).toList();
  }

  void _clearFilters() {
    _searchQuery = '';
    _searchController.clear();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'My Class', isBackButton: true),
      body: RefreshIndicator(
        onRefresh: _fetchStudents,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B61FF), Color(0xFF5B42F3)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B42F3).withAlpha(45),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          LucideIcons.school,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Class Teacher Of',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.classGrade.classname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: StudentFeatureCard(
                        icon: Icons.check_circle_outline,
                        title: 'Class Attendance',
                        color: Colors.green,
                        onTap: () {
                          showAttendancePeriodDialog(
                            context: context,
                            classId: widget.classGrade.id,
                            className: widget.classGrade.classname,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StudentFeatureCard(
                        icon: Icons.edit_note,
                        title: 'Student Marks',
                        color: Colors.brown,
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.myClassMarksScreen,
                            extra: widget.classGrade,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StudentFeatureCard(
                        icon: Icons.picture_as_pdf_outlined,
                        title: 'Marks Report',
                        color: Colors.teal,
                        onTap: () {
                          showMarksReportDialog(
                            context: context,
                            classId: widget.classGrade.id,
                            className: widget.classGrade.classname,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: StudentFeatureCard(
                        title: 'Homeworks',
                        icon: Icons.assignment_outlined,
                        color: Colors.orange,
                        onTap: () {
                          final params = HomeworkParameters(
                            viewerType: HomeworkViewerType.myClassView,
                          );
                          context.pushNamed(
                            RouteConstants.homeworkLisitingScreen,
                            extra: params,
                            queryParameters: params.toQueryParameters(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StudentFeatureCard(
                        title: 'Time Table',
                        icon: Icons.calendar_month_outlined,
                        color: Colors.indigo,
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.todayTimetableScreen,
                            extra: TodayTimetableParameters(
                              timetableType: TimetableType.myClass,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Consumer<StudentLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        return Expanded(
                          child: StudentFeatureCard(
                            icon: Icons.description_outlined,
                            title: 'Student Leaves',
                            color: Colors.redAccent,
                            notificationCount: provider.leaveNotificationCount,
                            onTap:
                                () => context.pushNamed(
                                  RouteConstants.studentLeaveLetter,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Students',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (!provider.isLoading && provider.students.isNotEmpty)
                          Text(
                            '${provider.students.length} students',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Search Bar
            SliverToBoxAdapter(
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  if (provider.students.isEmpty && !provider.isLoading) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or roll number',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Students List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return commonShimmerList();
                    }

                    if (provider.students.isEmpty) {
                      return Column(
                        children: [
                          SizedBox(height: 80),
                          Icon(
                            LucideIcons.users,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Students Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      );
                    }

                    final filteredStudents = _getFilteredStudents(
                      provider.students,
                    );

                    if (filteredStudents.isEmpty) {
                      return Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Results Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try adjusting your search",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Text(
                                "${filteredStudents.length} Student${filteredStudents.length != 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              if (_searchQuery.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF35C2C1,
                                    ).withAlpha(24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Filtered",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF35C2C1),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Students Cards
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) => const SizedBox(),
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final studentName =
                                student.fullName?.toString().trim() ?? '';

                            final rollNumber =
                                student.rollNumber?.toString().trim() ?? '';

                            return ProfileTile(
                              name:
                                  studentName.isEmpty
                                      ? 'Unnamed Student'
                                      : studentName,
                              description:
                                  rollNumber.isEmpty
                                      ? 'Roll number not available'
                                      : 'Roll No: $rollNumber',
                              onPressed:
                                  () => context.pushNamed(
                                    RouteConstants.studentDetails,
                                    extra: StudentDetailParameters(
                                      forStaff: true,
                                      studentId: student.id,
                                    ),
                                  ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
