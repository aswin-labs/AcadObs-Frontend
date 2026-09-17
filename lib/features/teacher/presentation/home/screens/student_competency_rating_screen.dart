import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/data/models/competency_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/my_class_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/star_rating_widget.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentCompetencyRatingScreen extends StatefulWidget {
  final ClassGradeModel classGrade;
  final List<StudentModel> students;
  final int initialStudentIndex;
  final int examId;
  final String examName;

  const StudentCompetencyRatingScreen({
    super.key,
    required this.classGrade,
    required this.students,
    required this.initialStudentIndex,
    required this.examId,
    required this.examName,
  });

  @override
  State<StudentCompetencyRatingScreen> createState() =>
      _StudentCompetencyRatingScreenState();
}

class _StudentCompetencyRatingScreenState
    extends State<StudentCompetencyRatingScreen> {
  late int _currentIndex;
  final Map<int, TextEditingController> _remarksControllers = {};

  StudentModel get _currentStudent => widget.students[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialStudentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentStudentAssessment();
    });
  }

  @override
  void dispose() {
    for (final controller in _remarksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCurrentStudentAssessment() async {
    final provider = context.read<MyClassProvider>();
    await provider.loadStudentAssessment(
      studentId: _currentStudent.id,
      examId: widget.examId,
    );

    // Sync controllers with loaded remarks
    for (final entry in provider.studentRatings.entries) {
      if (!_remarksControllers.containsKey(entry.key)) {
        _remarksControllers[entry.key] = TextEditingController();
      }
      _remarksControllers[entry.key]!.text = entry.value.remarks;
    }
    if (mounted) setState(() {});
  }

  TextEditingController _getRemarksController(int indicatorId, String initialText) {
    if (!_remarksControllers.containsKey(indicatorId)) {
      _remarksControllers[indicatorId] = TextEditingController(text: initialText);
    }
    return _remarksControllers[indicatorId]!;
  }

  void _goToStudent(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.students.length) return;
    setState(() {
      _currentIndex = newIndex;
    });
    _loadCurrentStudentAssessment();
  }

  Future<bool> _saveCurrentAssessment() async {
    final provider = context.read<MyClassProvider>();
    return await provider.saveStudentAssessment(
      context: context,
      studentId: _currentStudent.id,
      examId: widget.examId,
    );
  }

  Future<void> _confirmDeleteAssessment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.triangleAlert, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Assessment", style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          "Are you sure you want to delete competency assessments for ${_currentStudent.fullName}?",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<MyClassProvider>().deleteStudentAssessment(
            context: context,
            studentId: _currentStudent.id,
            examId: widget.examId,
          );
      if (success && mounted) {
        for (final c in _remarksControllers.values) {
          c.clear();
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: "Student Assessment",
        isBackButton: true,
        actions: [
          Consumer<MyClassProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(LucideIcons.ellipsisVertical, color: Colors.black),
                onSelected: (value) {
                  if (value == 'quick_fill_3') {
                    provider.quickFillAllRatings(3);
                  } else if (value == 'quick_fill_4') {
                    provider.quickFillAllRatings(4);
                  } else if (value == 'delete') {
                    _confirmDeleteAssessment();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'quick_fill_3',
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                        SizedBox(width: 8),
                        Text("Fill All with 3 Stars (Proficient)"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'quick_fill_4',
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                        SizedBox(width: 8),
                        Text("Fill All with 4 Stars (Exemplary)"),
                      ],
                    ),
                  ),
                  if (provider.hasExistingAssessment)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text("Delete Assessment", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<MyClassProvider>(
        builder: (context, provider, _) {
          final student = _currentStudent;
          final totalStudents = widget.students.length;
          final hasPrevious = _currentIndex > 0;
          final hasNext = _currentIndex < totalStudents - 1;

          return Column(
            children: [
              // Student Navigator Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    // Previous Student Button
                    IconButton(
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: hasPrevious ? const Color(0xFF4834D4) : Colors.grey.shade300,
                      ),
                      onPressed: hasPrevious ? () => _goToStudent(_currentIndex - 1) : null,
                      tooltip: "Previous Student",
                    ),

                    // Student Info Card
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
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
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${widget.classGrade.classname} • Roll: ${student.rollNumber ?? 'N/A'} • (${_currentIndex + 1}/$totalStudents)",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Next Student Button
                    IconButton(
                      icon: Icon(
                        LucideIcons.chevronRight,
                        color: hasNext ? const Color(0xFF4834D4) : Colors.grey.shade300,
                      ),
                      onPressed: hasNext ? () => _goToStudent(_currentIndex + 1) : null,
                      tooltip: "Next Student",
                    ),
                  ],
                ),
              ),

              // Term Name Info Strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                color: const Color(0xFF4834D4).withAlpha(12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF4834D4)),
                    const SizedBox(width: 6),
                    Text(
                      "Term: ${widget.examName}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4834D4),
                      ),
                    ),
                    const Spacer(),
                    if (provider.hasExistingAssessment)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Existing Saved",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Rating Form Body
              Expanded(
                child: provider.isLoadingStudentAssessment || provider.isLoadingCompetencies
                    ? const Center(child: CircularProgressIndicator())
                    : provider.competencies.isEmpty
                        ? const Center(child: Text("No competencies available"))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            itemCount: provider.competencies.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, cIndex) {
                              final competency = provider.competencies[cIndex];
                              return _buildCompetencyCard(competency, provider);
                            },
                          ),
              ),

              // Sticky Bottom Action Bar
              _buildBottomActionBar(hasNext),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompetencyCard(CompetencyModel competency, MyClassProvider provider) {
    // Calculate how many indicators are rated
    int ratedCount = 0;
    for (final indicator in competency.indicators) {
      if ((provider.studentRatings[indicator.id]?.rating ?? 0) > 0) {
        ratedCount++;
      }
    }
    final totalCount = competency.indicators.length;
    final isAllRated = totalCount > 0 && ratedCount == totalCount;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isAllRated ? Colors.green.shade200 : Colors.grey.shade200,
            width: isAllRated ? 1.2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAllRated
                    ? Colors.green.withAlpha(20)
                    : const Color(0xFF4834D4).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAllRated ? LucideIcons.check : LucideIcons.sparkles,
                size: 16,
                color: isAllRated ? Colors.green : const Color(0xFF4834D4),
              ),
            ),
            title: Text(
              competency.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAllRated
                    ? Colors.green.withAlpha(20)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$ratedCount/$totalCount",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAllRated ? Colors.green.shade800 : Colors.grey.shade700,
                ),
              ),
            ),
            children: competency.indicators.map((indicator) {
              return _buildIndicatorTile(competency, indicator, provider);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorTile(
    CompetencyModel competency,
    CompetencyIndicatorModel indicator,
    MyClassProvider provider,
  ) {
    final entry = provider.studentRatings[indicator.id];
    final currentRating = entry?.rating ?? 0;
    final remarksController = _getRemarksController(indicator.id, entry?.remarks ?? '');

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator Title
          Text(
            indicator.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Star Rating Widget (1 to 4 Stars)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StarRatingWidget(
                rating: currentRating,
                starSize: 28,
                onRatingChanged: (newRating) {
                  provider.setIndicatorRating(
                    competencyId: competency.id,
                    indicatorId: indicator.id,
                    rating: newRating,
                    remarks: remarksController.text,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick Remarks Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              "Very Good",
              "Good progress",
              "Active participation",
              "Needs support",
            ].map((preset) {
              final isSelected = remarksController.text == preset;
              return InkWell(
                onTap: () {
                  remarksController.text = preset;
                  provider.setIndicatorRemarks(
                    competencyId: competency.id,
                    indicatorId: indicator.id,
                    remarks: preset,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4834D4).withAlpha(20)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4834D4)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    preset,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF4834D4)
                          : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Custom remarks field
          TextField(
            controller: remarksController,
            onChanged: (text) {
              provider.setIndicatorRemarks(
                competencyId: competency.id,
                indicatorId: indicator.id,
                remarks: text,
              );
            },
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: "Add remarks or observation (optional)...",
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool hasNext) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Save Assessment Button
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF4834D4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await _saveCurrentAssessment();
                },
                icon: const Icon(LucideIcons.save, size: 18, color: Color(0xFF4834D4)),
                label: const Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4834D4),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Save & Next Button
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4834D4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final success = await _saveCurrentAssessment();
                  if (success && mounted) {
                    if (hasNext) {
                      _goToStudent(_currentIndex + 1);
                    } else {
                      // Last student finished
                      Navigator.pop(context);
                    }
                  }
                },
                icon: Icon(
                  hasNext ? LucideIcons.arrowRight : LucideIcons.checkCheck,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  hasNext ? "Save & Next" : "Save & Finish",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
