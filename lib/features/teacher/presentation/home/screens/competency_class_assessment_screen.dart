import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/my_class_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class CompetencyClassAssessmentScreen extends StatefulWidget {
  final ClassGradeModel classGrade;

  const CompetencyClassAssessmentScreen({
    super.key,
    required this.classGrade,
  });

  @override
  State<CompetencyClassAssessmentScreen> createState() =>
      _CompetencyClassAssessmentScreenState();
}

class _CompetencyClassAssessmentScreenState
    extends State<CompetencyClassAssessmentScreen> {
  int? _selectedExamId;
  String? _selectedExamName;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final termExamProvider = context.read<TermExamProvider>();
    final myClassProvider = context.read<MyClassProvider>();
    final studentProvider = context.read<StudentProvider>();

    if (termExamProvider.termExams.isEmpty) {
      await termExamProvider.fetchTermExams();
    }

    if (myClassProvider.competencies.isEmpty) {
      await myClassProvider.fetchCompetencies();
    }

    if (studentProvider.students.isEmpty) {
      if (!mounted) return;
      await studentProvider.fetchStudentsByClassId(
        context: context,
        classId: widget.classGrade.id,
      );
    }

    if (mounted && termExamProvider.termExams.isNotEmpty) {
      setState(() {
        _selectedExamId = termExamProvider.termExams.first['id'] as int?;
        final name = termExamProvider.termExams.first['exam_name']?.toString() ?? '';
        final year = termExamProvider.termExams.first['education_year']?.toString() ?? '';
        _selectedExamName = year.isNotEmpty ? '$name - $year' : name;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentModel> _getFilteredStudents(List<StudentModel> students) {
    if (_searchQuery.trim().isEmpty) return students;
    final query = _searchQuery.toLowerCase().trim();
    return students.where((student) {
      final name = student.fullName.toLowerCase();
      final rollNo = student.rollNumber?.toString() ?? '';
      return name.contains(query) || rollNo.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: "Competency Assessment",
        isBackButton: true,
      ),
      body: Consumer<TermExamProvider>(
        builder: (context, termExamProvider, _) {
          return Consumer<StudentProvider>(
            builder: (context, studentProvider, _) {
              if (termExamProvider.isLoadingExams ||
                  (studentProvider.isLoading && studentProvider.students.isEmpty)) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: commonShimmerList(),
                );
              }

              final allStudents = studentProvider.students;
              final filteredStudents = _getFilteredStudents(allStudents);

              return Column(
                children: [
                  // Term Exam Selector & Header Banner
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4834D4).withAlpha(40),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.award,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Class ${widget.classGrade.classname}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Text(
                                    "CBSE Holistic Progress & Competency",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Term Exam Dropdown inside banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedExamId,
                              hint: const Text(
                                "Select Term Exam",
                                style: TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                              icon: const Icon(LucideIcons.chevronDown, size: 20, color: Color(0xFF4834D4)),
                              items: termExamProvider.termExams.map((exam) {
                                final id = exam['id'] as int;
                                final name = exam['exam_name']?.toString() ?? '';
                                final year = exam['education_year']?.toString() ?? '';
                                final label = year.isNotEmpty ? '$name - $year' : name;
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newExamId) {
                                if (newExamId == null) return;
                                final selected = termExamProvider.termExams.firstWhere(
                                  (e) => e['id'] == newExamId,
                                  orElse: () => {},
                                );
                                final name = selected['exam_name']?.toString() ?? '';
                                final year = selected['education_year']?.toString() ?? '';
                                setState(() {
                                  _selectedExamId = newExamId;
                                  _selectedExamName = year.isNotEmpty ? '$name - $year' : name;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search student by name or roll number...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(LucideIcons.search, size: 20, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4834D4), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),

                  // List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Students (${filteredStudents.length})",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "Tap student to grade 1–4 ★",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Student Roster
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.users, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty ? "No students found" : "No students in this class",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filteredStudents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              final originalIndex = allStudents.indexWhere((s) => s.id == student.id);

                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                elevation: 0.8,
                                shadowColor: Colors.black12,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    if (_selectedExamId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please select a Term Exam first")),
                                      );
                                      return;
                                    }

                                    context.pushNamed(
                                      RouteConstants.studentCompetencyRatingScreen,
                                      extra: StudentCompetencyRatingArgs(
                                        classGrade: widget.classGrade,
                                        students: allStudents,
                                        initialStudentIndex: originalIndex >= 0 ? originalIndex : 0,
                                        examId: _selectedExamId!,
                                        examName: _selectedExamName ?? "Term Exam",
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: const Color(0xFF4834D4).withAlpha(20),
                                          backgroundImage: student.image != null && student.image!.isNotEmpty
                                              ? NetworkImage(student.image!)
                                              : null,
                                          child: student.image == null || student.image!.isEmpty
                                              ? Text(
                                                  student.fullName.isNotEmpty
                                                      ? student.fullName[0].toUpperCase()
                                                      : "S",
                                                  style: const TextStyle(
                                                    color: Color(0xFF4834D4),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 14),

                                        // Name and Roll
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.fullName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                student.rollNumber != null
                                                    ? "Roll No: ${student.rollNumber}"
                                                    : "Roll No: N/A",
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Action Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4834D4).withAlpha(15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                                              SizedBox(width: 4),
                                              Text(
                                                "Rate",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4834D4),
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF4834D4)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
