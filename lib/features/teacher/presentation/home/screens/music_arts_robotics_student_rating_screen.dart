import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/music_arts_robotics_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MusicArtsRoboticsStudentRatingScreen extends StatefulWidget {
  final MusicArtsRoboticsRatingArgs args;

  const MusicArtsRoboticsStudentRatingScreen({
    super.key,
    required this.args,
  });

  @override
  State<MusicArtsRoboticsStudentRatingScreen> createState() =>
      _MusicArtsRoboticsStudentRatingScreenState();
}

class _MusicArtsRoboticsStudentRatingScreenState
    extends State<MusicArtsRoboticsStudentRatingScreen> {
  late int _currentIndex;
  late DateTime _assessedDate;

  final List<String> _gradeOptions = ['A', 'B', 'C', 'D'];
  static const Color _primaryThemeColor = Color(0xFF7B2CBF);

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
    switch (grade.toUpperCase().trim()) {
      case 'A':
        return const Color(0xFF00CEC9);
      case 'B':
        return const Color(0xFF6C5CE7);
      case 'C':
        return const Color(0xFFF39C12);
      case 'D':
        return const Color(0xFFE74C3C);
      default:
        return _primaryThemeColor;
    }
  }

  IconData _getAreaIcon(String areaName) {
    final lower = areaName.toLowerCase();
    if (lower.contains('art')) {
      return Icons.palette_rounded;
    } else if (lower.contains('music')) {
      return Icons.music_note_rounded;
    } else if (lower.contains('robot')) {
      return Icons.smart_toy_rounded;
    }
    return LucideIcons.sparkles;
  }

  Color _getAreaAccentColor(String areaName) {
    final lower = areaName.toLowerCase();
    if (lower.contains('art')) {
      return const Color(0xFFE84393);
    } else if (lower.contains('music')) {
      return const Color(0xFF0984E3);
    } else if (lower.contains('robot')) {
      return const Color(0xFF00B894);
    }
    return _primaryThemeColor;
  }

  Future<void> _saveAssessment({bool moveToNext = false}) async {
    final provider = context.read<MusicArtsRoboticsProvider>();
    final entry = provider.getOrCreateRating(_currentStudent.id);

    if (!entry.hasAnyGrade) {
      CustomSnackbar.show(
        context,
        message: "Please select a grade for ${_currentStudent.fullName}",
        type: SnackbarType.warning,
      );
      return;
    }

    final success = await provider.saveStudentAssessment(
      context: context,
      examId: widget.args.examId,
      assessedAt: _assessedDate,
      studentId: _currentStudent.id,
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
        title: "Co-Scholastic Grade",
        isBackButton: true,
        actions: [
          Consumer<MusicArtsRoboticsProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                tooltip: "Set All Areas",
                onSelected: (grade) {
                  for (final area in provider.areas) {
                    provider.setStudentAreaGrade(
                      _currentStudent.id,
                      area.id,
                      grade,
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'A',
                        child: Text("Set All Areas to Grade A"),
                      ),
                      const PopupMenuItem(
                        value: 'B',
                        child: Text("Set All Areas to Grade B"),
                      ),
                      const PopupMenuItem(
                        value: 'C',
                        child: Text("Set All Areas to Grade C"),
                      ),
                      const PopupMenuItem(
                        value: 'D',
                        child: Text("Set All Areas to Grade D"),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Consumer<MusicArtsRoboticsProvider>(
        builder: (context, provider, _) {
          final entry = provider.getOrCreateRating(_currentStudent.id);
          final areas =
              provider.areas.isNotEmpty ? provider.areas : widget.args.areas;
          final gradedCount = entry.gradedCount;
          final isAllGraded = areas.isNotEmpty && entry.isComplete(areas);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
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
                                  hasPrev
                                      ? Colors.black87
                                      : Colors.grey.shade300,
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
                            backgroundColor: _primaryThemeColor.withAlpha(35),
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
                                        color: _primaryThemeColor,
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
                                        color: _primaryThemeColor.withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "${_currentIndex + 1} of ${widget.args.students.length}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _primaryThemeColor,
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
                                  hasNext
                                      ? Colors.black87
                                      : Colors.grey.shade300,
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
                                  color: _primaryThemeColor,
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
                                      color: _primaryThemeColor,
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
                                  isAllGraded
                                      ? Colors.green.shade50
                                      : gradedCount > 0
                                      ? Colors.orange.shade50
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isAllGraded
                                        ? Colors.green.shade300
                                        : gradedCount > 0
                                        ? Colors.orange.shade300
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              isAllGraded
                                  ? "All Areas Graded"
                                  : gradedCount > 0
                                  ? "$gradedCount/${areas.length} Graded"
                                  : "Not Graded",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color:
                                    isAllGraded
                                        ? Colors.green.shade800
                                        : gradedCount > 0
                                        ? Colors.orange.shade800
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Area Grading Cards
                if (areas.isEmpty)
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.alertCircle,
                          size: 40,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No Co-Scholastic Areas Found",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Please check if areas are configured for Class ${widget.args.standard}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...areas.map((area) {
                    final selectedGrade = entry.getGrade(area.id);
                    final isGraded = selectedGrade.isNotEmpty;
                    final accentColor = _getAreaAccentColor(area.name);
                    final areaIcon = _getAreaIcon(area.name);

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isGraded
                                  ? accentColor.withAlpha(120)
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
                                  color: accentColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  areaIcon,
                                  size: 22,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${area.name} Grade",
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Select grade for ${area.name}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isGraded)
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
                                            provider.setStudentAreaGrade(
                                              _currentStudent.id,
                                              area.id,
                                              '',
                                            );
                                          } else {
                                            provider.setStudentAreaGrade(
                                              _currentStudent.id,
                                              area.id,
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
                                                        color: gradeColor
                                                            .withAlpha(80),
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

                          if (isGraded) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getGradeColor(
                                  selectedGrade,
                                ).withAlpha(20),
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
                                    "Grade $selectedGrade assigned for ${area.name}",
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
                    );
                  }),
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
                    side: const BorderSide(color: _primaryThemeColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _saveAssessment(moveToNext: false),
                  icon: const Icon(
                    LucideIcons.save,
                    size: 16,
                    color: _primaryThemeColor,
                  ),
                  label: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryThemeColor,
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
                    backgroundColor: _primaryThemeColor,
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
