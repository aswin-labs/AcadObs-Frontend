import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/data/models/co_scholastic_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/my_class_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentCoScholasticRatingScreen extends StatefulWidget {
  final StudentCoScholasticRatingArgs args;

  const StudentCoScholasticRatingScreen({
    super.key,
    required this.args,
  });

  @override
  State<StudentCoScholasticRatingScreen> createState() =>
      _StudentCoScholasticRatingScreenState();
}

class _StudentCoScholasticRatingScreenState
    extends State<StudentCoScholasticRatingScreen> {
  late int _currentIndex;
  bool _isEditing = false;
  final Map<int, TextEditingController> _scoreControllers = {};
  final Map<int, TextEditingController> _remarksControllers = {};
  final List<String> _gradeOptions = ['A+', 'A', 'B+', 'B', 'C', 'D'];

  StudentModel get _currentStudent => widget.args.students[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.args.initialStudentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentStudentData();
    });
  }

  @override
  void dispose() {
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    for (final c in _remarksControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCurrentStudentData() async {
    final provider = context.read<MyClassProvider>();

    // Fetch areas if needed
    if (provider.coScholasticAreas.isEmpty) {
      await provider.fetchCoScholasticAreas(
        studentId: _currentStudent.id,
      );
    }

    // Load existing assessment for current student and exam
    await provider.loadStudentCoScholasticAssessment(
      studentId: _currentStudent.id,
      examId: widget.args.examId,
    );

    // Sync controllers with loaded ratings
    for (final area in provider.coScholasticAreas) {
      final entry = provider.studentCoScholasticRatings[area.id];
      final scoreVal = entry?.score != null ? entry!.score.toString() : '';
      final remarksVal = entry?.remarks ?? '';

      if (_scoreControllers.containsKey(area.id)) {
        _scoreControllers[area.id]!.text = scoreVal;
      } else {
        _scoreControllers[area.id] = TextEditingController(text: scoreVal);
      }

      if (_remarksControllers.containsKey(area.id)) {
        _remarksControllers[area.id]!.text = remarksVal;
      } else {
        _remarksControllers[area.id] = TextEditingController(text: remarksVal);
      }
    }

    // If assessment already exists, show it in Showing/View Mode!
    // Otherwise, open in Adding/Editing Mode.
    if (mounted) {
      setState(() {
        _isEditing = !provider.hasExistingCoScholasticAssessment;
      });
    }
  }

  TextEditingController _getScoreController(int areaId) {
    if (!_scoreControllers.containsKey(areaId)) {
      _scoreControllers[areaId] = TextEditingController();
    }
    return _scoreControllers[areaId]!;
  }

  TextEditingController _getRemarksController(int areaId) {
    if (!_remarksControllers.containsKey(areaId)) {
      _remarksControllers[areaId] = TextEditingController();
    }
    return _remarksControllers[areaId]!;
  }

  void _goToStudent(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.args.students.length) return;
    setState(() {
      _currentIndex = newIndex;
    });
    _loadCurrentStudentData();
  }

  Future<bool> _saveCurrentAssessment({bool moveToNext = false}) async {
    final provider = context.read<MyClassProvider>();

    // Push controllers text into provider state before saving
    for (final area in provider.coScholasticAreas) {
      final scoreText = _scoreControllers[area.id]?.text.trim() ?? '';
      final scoreVal = double.tryParse(scoreText);
      provider.setCoScholasticScore(areaId: area.id, score: scoreVal);

      final remarksText = _remarksControllers[area.id]?.text.trim() ?? '';
      provider.setCoScholasticRemarks(areaId: area.id, remarks: remarksText);
    }

    final success = await provider.saveStudentCoScholasticAssessment(
      context: context,
      studentId: _currentStudent.id,
      examId: widget.args.examId,
    );

    if (success && mounted) {
      if (moveToNext) {
        if (_currentIndex < widget.args.students.length - 1) {
          _goToStudent(_currentIndex + 1);
        } else {
          Navigator.pop(context);
        }
      } else {
        await _loadCurrentStudentData();
        setState(() {
          _isEditing = false;
        });
      }
    }
    return success;
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
          "Are you sure you want to delete co-scholastic assessments for ${_currentStudent.fullName}?",
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
      final success = await context
          .read<MyClassProvider>()
          .deleteStudentCoScholasticAssessment(
            context: context,
            studentId: _currentStudent.id,
            examId: widget.args.examId,
          );
      if (success && mounted) {
        for (final c in _scoreControllers.values) {
          c.clear();
        }
        for (final c in _remarksControllers.values) {
          c.clear();
        }
        setState(() {
          _isEditing = true;
        });
      }
    }
  }

  String _formatDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return "${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}";
    } catch (_) {
      return rawDate;
    }
  }

  IconData _getAreaIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('physical') ||
        lower.contains('sport') ||
        lower.contains('pe') ||
        lower.contains('fitness') ||
        lower.contains('yoga')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('art') ||
        lower.contains('craft') ||
        lower.contains('drawing')) {
      return Icons.palette_outlined;
    }
    if (lower.contains('music') ||
        lower.contains('sing') ||
        lower.contains('dance')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('attendance') ||
        lower.contains('punctual') ||
        lower.contains('discipline')) {
      return Icons.event_available_rounded;
    }
    if (lower.contains('work') || lower.contains('experience')) {
      return Icons.handyman_outlined;
    }
    if (lower.contains('health')) {
      return Icons.favorite_outline_rounded;
    }
    return Icons.stars_rounded;
  }

  Color _getAreaColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('physical') || lower.contains('sport')) {
      return const Color(0xFF00B894);
    }
    if (lower.contains('art')) {
      return const Color(0xFFE17055);
    }
    if (lower.contains('music')) {
      return const Color(0xFF6C5CE7);
    }
    if (lower.contains('attendance')) {
      return const Color(0xFF0984E3);
    }
    return const Color(0xFF0077B6);
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return const Color(0xFF00B894);
      case 'A':
        return const Color(0xFF00CEC9);
      case 'B+':
        return const Color(0xFF0984E3);
      case 'B':
        return const Color(0xFF6C5CE7);
      case 'C':
        return const Color(0xFFF39C12);
      case 'D':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildStudentNavigatorBanner(MyClassProvider provider) {
    final bool hasPrev = _currentIndex > 0;
    final bool hasNext = _currentIndex < widget.args.students.length - 1;

    int gradedCount = 0;
    for (final area in provider.coScholasticAreas) {
      final entry = provider.studentCoScholasticRatings[area.id];
      if (entry != null && (entry.grade.isNotEmpty || entry.score != null)) {
        gradedCount++;
      }
    }
    final totalAreas = provider.coScholasticAreas.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                      hasPrev ? const Color(0xFFF1F5F9) : Colors.transparent,
                  foregroundColor:
                      hasPrev ? Colors.black87 : Colors.grey.shade300,
                  padding: const EdgeInsets.all(8),
                ),
                onPressed:
                    hasPrev ? () => _goToStudent(_currentIndex - 1) : null,
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
              ),

              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    const Color(0xFF0077B6).withValues(alpha: 0.15),
                backgroundImage: _currentStudent.image != null &&
                        _currentStudent.image!.isNotEmpty
                    ? NetworkImage(_currentStudent.image!)
                    : null,
                child: _currentStudent.image == null ||
                        _currentStudent.image!.isEmpty
                    ? Text(
                        _currentStudent.fullName.isNotEmpty
                            ? _currentStudent.fullName[0].toUpperCase()
                            : "S",
                        style: const TextStyle(
                          color: Color(0xFF0077B6),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (_currentStudent.rollNumber != null) ...[
                          Text(
                            "Roll: ${_currentStudent.rollNumber}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
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

              // Next Button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor:
                      hasNext ? const Color(0xFFF1F5F9) : Colors.transparent,
                  foregroundColor:
                      hasNext ? Colors.black87 : Colors.grey.shade300,
                  padding: const EdgeInsets.all(8),
                ),
                onPressed:
                    hasNext ? () => _goToStudent(_currentIndex + 1) : null,
                icon: const Icon(LucideIcons.chevronRight, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Exam tag & Graded status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: Color(0xFF0077B6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.args.examName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0077B6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: gradedCount > 0
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: gradedCount > 0
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Text(
                  totalAreas > 0
                      ? "$gradedCount of $totalAreas Graded"
                      : (provider.hasExistingCoScholasticAssessment
                          ? "Assessed"
                          : "Not Assessed"),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: gradedCount > 0
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SHOWING MODE (View Mode for already assessed records)
  // ---------------------------------------------------------------------------
  Widget _buildShowingView(MyClassProvider provider) {
    final bool hasNext = _currentIndex < widget.args.students.length - 1;

    return Column(
      children: [
        // Mode Header / Action bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    LucideIcons.award,
                    size: 16,
                    color: Color(0xFF0077B6),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Assessment Summary",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0077B6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF0077B6)),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(LucideIcons.pencil, size: 14),
                label: const Text(
                  "Edit Assessment",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // List of Showing Area Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: provider.coScholasticAreas.length,
            itemBuilder: (context, index) {
              final area = provider.coScholasticAreas[index];
              final entry = provider.studentCoScholasticRatings[area.id];
              return _buildShowingAreaCard(area, entry);
            },
          ),
        ),

        // Bottom Action Bar in Showing Mode
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Edit Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF0077B6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: const Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: Color(0xFF0077B6),
                    ),
                    label: const Text(
                      "Edit Assessment",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0077B6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Next Student Button
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
                    onPressed: hasNext
                        ? () => _goToStudent(_currentIndex + 1)
                        : () => Navigator.pop(context),
                    icon: Icon(
                      hasNext ? LucideIcons.arrowRight : LucideIcons.checkCheck,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      hasNext ? "Next Student" : "Finished",
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
        ),
      ],
    );
  }

  Widget _buildShowingAreaCard(
    CoScholasticAreaModel area,
    StudentCoScholasticAssessmentEntry? entry,
  ) {
    final areaColor = _getAreaColor(area.name);
    final areaIcon = _getAreaIcon(area.name);
    final isAttendance = area.name.toLowerCase().contains('attendance');

    final bool isGraded = entry != null &&
        (entry.grade.isNotEmpty ||
            entry.score != null ||
            entry.remarks.isNotEmpty);
    final grade = entry?.grade ?? '';
    final hasGrade = grade.isNotEmpty;
    final score = entry?.score;
    final remarks = entry?.remarks ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGraded
              ? areaColor.withValues(alpha: 0.35)
              : Colors.grey.shade200,
          width: isGraded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Area Info & Big Grade Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: areaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(areaIcon, size: 22, color: areaColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (area.classGroup != null &&
                          area.classGroup!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          "Class Group: ${area.classGroup}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Grade Badge or Not Graded Tag
                if (hasGrade)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(grade),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _getGradeColor(grade).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "Grade $grade",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Not Graded",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            // Row 2: Score / Attendance (if present)
            if (score != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAttendance
                              ? LucideIcons.calendarCheck
                              : LucideIcons.percent,
                          size: 13,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAttendance
                              ? "Attendance: $score%"
                              : "Score: $score",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Row 3: Remarks (if present)
            if (remarks.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remarks,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Row 4: Assessed At & Recorded By Info
            if (entry != null &&
                (entry.recorderName != null ||
                    (entry.assessedAt.isNotEmpty && entry.id != null))) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    LucideIcons.userCheck,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Recorded on ${_formatDate(entry.assessedAt)}${entry.recorderName != null && entry.recorderName!.isNotEmpty ? ' • by ${entry.recorderName}' : ''}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // If not graded, offer quick button to grade
            if (!isGraded) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    "Add Grade",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADDING / EDITING MODE (Input form for adding or updating grades & marks)
  // ---------------------------------------------------------------------------
  Widget _buildEditingView(MyClassProvider provider) {
    final bool hasNext = _currentIndex < widget.args.students.length - 1;

    return Column(
      children: [
        // Notice bar when editing an already assessed student
        if (provider.hasExistingCoScholasticAssessment)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.pencil,
                  size: 14,
                  color: Colors.amber.shade900,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Editing saved assessment. Tap Save to apply changes.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // List of Editable Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: provider.coScholasticAreas.length,
            itemBuilder: (context, index) {
              final area = provider.coScholasticAreas[index];
              return _buildEditableAreaCard(area, provider);
            },
          ),
        ),

        // Bottom Action Bar in Editing Mode
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                      side: const BorderSide(color: Color(0xFF0077B6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _saveCurrentAssessment(),
                    icon: const Icon(
                      LucideIcons.save,
                      size: 18,
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

                // Save & Next Button
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
                    onPressed: () => _saveCurrentAssessment(moveToNext: true),
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
        ),
      ],
    );
  }

  Widget _buildEditableAreaCard(
    CoScholasticAreaModel area,
    MyClassProvider provider,
  ) {
    final areaColor = _getAreaColor(area.name);
    final areaIcon = _getAreaIcon(area.name);
    final isAttendance = area.name.toLowerCase().contains('attendance');

    final currentEntry = provider.studentCoScholasticRatings[area.id];
    final selectedGrade = currentEntry?.grade ?? '';
    final hasGrade = selectedGrade.trim().isNotEmpty;
    final hasScore = currentEntry?.score != null;

    final scoreCtrl = _getScoreController(area.id);
    final remarksCtrl = _getRemarksController(area.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasGrade
              ? areaColor.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: hasGrade ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Area Icon & Title & Current Grade Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: areaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(areaIcon, size: 20, color: areaColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (area.classGroup != null &&
                          area.classGroup!.isNotEmpty)
                        Text(
                          "Class Group: ${area.classGroup}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),

                // Selected Grade Chip
                if (hasGrade)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getGradeColor(selectedGrade).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Grade: $selectedGrade",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(selectedGrade),
                          ),
                        ),
                        if (hasScore) ...[
                          const SizedBox(width: 4),
                          Text(
                            "(${currentEntry!.score}${isAttendance ? '%' : ''})",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getGradeColor(selectedGrade),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Not Graded",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Grade Selector Pills
            const Text(
              "Select Grade",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _gradeOptions.map((grade) {
                final isSelected = selectedGrade == grade;
                final gradeColor = _getGradeColor(grade);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (isSelected) {
                          provider.setCoScholasticGrade(
                            areaId: area.id,
                            grade: '',
                          );
                        } else {
                          provider.setCoScholasticGrade(
                            areaId: area.id,
                            grade: grade,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? gradeColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? gradeColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            grade,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Score / Attendance and Remarks Inputs
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score Input
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAttendance ? "Attendance %" : "Score (optional)",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: scoreCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val.trim());
                          provider.setCoScholasticScore(
                            areaId: area.id,
                            score: parsed,
                          );
                        },
                        decoration: InputDecoration(
                          hintText: isAttendance ? "e.g. 95" : "e.g. 85",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: areaColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Remarks Input
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Remarks",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: remarksCtrl,
                        onChanged: (val) {
                          provider.setCoScholasticRemarks(
                            areaId: area.id,
                            remarks: val.trim(),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: isAttendance
                              ? "Regular & punctual"
                              : "Good progress",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: areaColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: _isEditing ? "Rate Co-Scholastic" : "Co-Scholastic Rating",
        isBackButton: true,
        actions: [
          Consumer<MyClassProvider>(
            builder: (context, provider, _) {
              final hasExisting = provider.hasExistingCoScholasticAssessment;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle Button between Edit and View Mode (if existing assessment exists)
                  if (hasExisting)
                    IconButton(
                      icon: Icon(
                        _isEditing ? LucideIcons.eye : LucideIcons.pencil,
                        size: 20,
                        color: const Color(0xFF0077B6),
                      ),
                      tooltip: _isEditing ? "View Mode" : "Edit Mode",
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                    ),

                  // Menu for Quick Fill and Delete
                  PopupMenuButton<String>(
                    icon: const Icon(
                      LucideIcons.ellipsisVertical,
                      color: Colors.black,
                    ),
                    onSelected: (value) {
                      if (value.startsWith('quick_fill_')) {
                        final grade = value.replaceFirst('quick_fill_', '');
                        setState(() {
                          _isEditing = true;
                        });
                        provider.quickFillAllCoScholasticGrades(grade);
                      } else if (value == 'delete') {
                        _confirmDeleteAssessment();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'quick_fill_A+',
                        child: Row(
                          children: [
                            Icon(
                              Icons.grade_rounded,
                              color: Color(0xFF00B894),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text("Fill All with A+"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'quick_fill_A',
                        child: Row(
                          children: [
                            Icon(
                              Icons.grade_rounded,
                              color: Color(0xFF00CEC9),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text("Fill All with A"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'quick_fill_B+',
                        child: Row(
                          children: [
                            Icon(
                              Icons.grade_rounded,
                              color: Color(0xFF0984E3),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text("Fill All with B+"),
                          ],
                        ),
                      ),
                      if (hasExisting)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Delete Assessment",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<MyClassProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingCoScholasticAreas ||
              provider.isLoadingStudentCoScholastic) {
            return Column(
              children: [
                _buildStudentNavigatorBanner(provider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: commonShimmerList(itemCount: 4, height: 160),
                  ),
                ),
              ],
            );
          }

          if (provider.coScholasticAreas.isEmpty) {
            return Column(
              children: [
                _buildStudentNavigatorBanner(provider),
                const Expanded(
                  child: Center(
                    child: Text(
                      "No Co-Scholastic Areas found for this class.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildStudentNavigatorBanner(provider),
              Expanded(
                child: _isEditing
                    ? _buildEditingView(provider)
                    : _buildShowingView(provider),
              ),
            ],
          );
        },
      ),
    );
  }
}
