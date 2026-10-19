import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/physical_coscholastic_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class PhysicalCoscholasticStudentRatingScreen extends StatefulWidget {
  final PhysicalCoscholasticRatingArgs args;

  const PhysicalCoscholasticStudentRatingScreen({
    super.key,
    required this.args,
  });

  @override
  State<PhysicalCoscholasticStudentRatingScreen> createState() =>
      _PhysicalCoscholasticStudentRatingScreenState();
}

class _PhysicalCoscholasticStudentRatingScreenState
    extends State<PhysicalCoscholasticStudentRatingScreen> {
  late int _currentIndex;
  late DateTime _assessedDate;

  final List<String> _gradeOptions = ['A', 'B', 'C', 'D'];

  StudentModel get _currentStudent => widget.args.students[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.args.initialStudentIndex;
    _assessedDate = widget.args.assessedAt;
  }

  void _goToStudent(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.args.students.length) return;
    setState(() {
      _currentIndex = newIndex;
    });
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return const Color(0xFF00CEC9);
      case 'B':
        return const Color(0xFF6C5CE7);
      case 'C':
        return const Color(0xFFF39C12);
      case 'D':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF0077B6);
    }
  }

  Future<void> _saveAssessment({bool moveToNext = false}) async {
    final provider = context.read<PhysicalCoscholasticProvider>();
    final entry = provider.getOrCreateRating(_currentStudent.id);

    if (entry.grade.trim().isEmpty) {
      CustomSnackbar.show(
        context,
        message: "Please select a grade for ${_currentStudent.fullName}",
        type: SnackbarType.warning,
      );
      return;
    }

    final success = await provider.savePhysicalAssessment(
      context: context,
      examId: widget.args.examId,
      assessedAt: _assessedDate,
      assessments: [entry],
      allStudents: widget.args.students,
      className: widget.args.className,
      standard: widget.args.standard,
      examName: widget.args.examName,
    );

    if (success && mounted) {
      if (moveToNext) {
        if (_currentIndex < widget.args.students.length - 1) {
          _goToStudent(_currentIndex + 1);
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPrev = _currentIndex > 0;
    final bool hasNext = _currentIndex < widget.args.students.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: "Health & Physical Education Grade",
        isBackButton: true,
        actions: [
          Consumer<PhysicalCoscholasticProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                onSelected: (grade) {
                  provider.setStudentGrade(_currentStudent.id, grade);
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'A',
                        child: Text("Set Grade A"),
                      ),
                      const PopupMenuItem(
                        value: 'B',
                        child: Text("Set Grade B"),
                      ),
                      const PopupMenuItem(
                        value: 'C',
                        child: Text("Set Grade C"),
                      ),
                      const PopupMenuItem(
                        value: 'D',
                        child: Text("Set Grade D"),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Consumer<PhysicalCoscholasticProvider>(
        builder: (context, provider, _) {
          final entry = provider.getOrCreateRating(_currentStudent.id);
          final selectedGrade = entry.grade;
          final isGraded = selectedGrade.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Top Student Navigation Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Prev Button
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                hasPrev
                                    ? const Color(0xFFF1F5F9)
                                    : Colors.transparent,
                            foregroundColor:
                                hasPrev ? Colors.black87 : Colors.grey.shade300,
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed:
                              hasPrev
                                  ? () => _goToStudent(_currentIndex - 1)
                                  : null,
                          icon: const Icon(LucideIcons.chevronLeft, size: 20),
                        ),
                        const SizedBox(width: 4),

                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(
                            0xFF0077B6,
                          ).withAlpha(35),
                          backgroundImage:
                              _currentStudent.image != null &&
                                      _currentStudent.image!.isNotEmpty
                                  ? NetworkImage(_currentStudent.image!)
                                  : null,
                          child:
                              _currentStudent.image == null ||
                                      _currentStudent.image!.isEmpty
                                  ? Text(
                                    _currentStudent.fullName.isNotEmpty
                                        ? _currentStudent.fullName[0]
                                            .toUpperCase()
                                        : "S",
                                    style: const TextStyle(
                                      color: Color(0xFF0077B6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),

                        // Student Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentStudent.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (_currentStudent.rollNumber != null)
                                    Text(
                                      "Roll: ${_currentStudent.rollNumber}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "${_currentIndex + 1} of ${widget.args.students.length}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Next Button
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                hasNext
                                    ? const Color(0xFFF1F5F9)
                                    : Colors.transparent,
                            foregroundColor:
                                hasNext ? Colors.black87 : Colors.grey.shade300,
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed:
                              hasNext
                                  ? () => _goToStudent(_currentIndex + 1)
                                  : null,
                          icon: const Icon(LucideIcons.chevronRight, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 10),

                    // Exam & Graded Status
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.calendar,
                                size: 14,
                                color: Color(0xFF0077B6),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "${widget.args.examName} • ${DateFormat('dd MMM').format(_assessedDate)}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0077B6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isGraded
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  isGraded
                                      ? Colors.green.shade300
                                      : Colors.orange.shade300,
                            ),
                          ),
                          child: Text(
                            isGraded ? "Grade: $selectedGrade" : "Not Graded",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  isGraded
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Grade Input Card (Only Grade Selector - Clean & Content-fitted)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isGraded
                            ? const Color(0xFF0077B6).withAlpha(100)
                            : Colors.grey.shade200,
                    width: isGraded ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0077B6).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 22,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Health & Physical Education Grade",
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Select grade for current assessment",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedGrade.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getGradeColor(
                                selectedGrade,
                              ).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getGradeColor(selectedGrade),
                              ),
                            ),
                            child: Text(
                              "Grade $selectedGrade",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(selectedGrade),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Select Grade*",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Grade Selector Pills (A, B, C, D)
                    Row(
                      children:
                          _gradeOptions.map((grade) {
                            final isSelected = selectedGrade == grade;
                            final gradeColor = _getGradeColor(grade);

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    if (isSelected) {
                                      provider.setStudentGrade(
                                        _currentStudent.id,
                                        '',
                                      );
                                    } else {
                                      provider.setStudentGrade(
                                        _currentStudent.id,
                                        grade,
                                      );
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 180,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? gradeColor
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? gradeColor
                                                : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: gradeColor.withAlpha(
                                                    80,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: const Offset(
                                                    0,
                                                    3,
                                                  ),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        grade,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    if (selectedGrade.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getGradeColor(selectedGrade).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getGradeColor(
                              selectedGrade,
                            ).withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.check,
                              size: 15,
                              color: _getGradeColor(selectedGrade),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Grade $selectedGrade assigned to ${_currentStudent.fullName.split(' ').first}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getGradeColor(selectedGrade),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Save
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF0077B6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _saveAssessment(moveToNext: false),
                  icon: const Icon(
                    LucideIcons.save,
                    size: 16,
                    color: Color(0xFF0077B6),
                  ),
                  label: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0077B6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save & Next
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _saveAssessment(moveToNext: true),
                  icon: Icon(
                    hasNext ? LucideIcons.arrowRight : LucideIcons.check,
                    size: 16,
                  ),
                  label: Text(
                    hasNext ? "Save & Next" : "Save & Finish",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
