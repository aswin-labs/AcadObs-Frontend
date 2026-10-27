import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/teacher/data/models/music_arts_robotics_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/music_arts_robotics_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MusicArtsRoboticsClassSelectionScreen extends StatefulWidget {
  const MusicArtsRoboticsClassSelectionScreen({super.key});

  @override
  State<MusicArtsRoboticsClassSelectionScreen> createState() =>
      _MusicArtsRoboticsClassSelectionScreenState();
}

class _MusicArtsRoboticsClassSelectionScreenState
    extends State<MusicArtsRoboticsClassSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedStandard;
  String? _selectedClassName;
  int? _selectedClassId;

  int? _selectedExamId;
  String? _selectedExamName;
  DateTime _assessedDate = DateTime.now();
  String _searchQuery = '';
  int? _selectedAreaId;

  late DropdownProvider dropdownProvider;
  late StudentProvider studentProvider;
  late TermExamProvider termExamProvider;

  static const Color _primaryThemeColor = Color(0xFF7B2CBF);

  MusicArtsRoboticsAreaItem? _getSelectedArea(
    List<MusicArtsRoboticsAreaItem> areas,
  ) {
    if (areas.isEmpty) return null;
    if (_selectedAreaId != null) {
      final match = areas.where((a) => a.id == _selectedAreaId).firstOrNull;
      if (match != null) return match;
    }
    return areas.first;
  }


  @override
  void initState() {
    super.initState();
    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();
    termExamProvider = context.read<TermExamProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.clearSelectedItem("standard");
      dropdownProvider.clearSelectedItem("className");
      studentProvider.clearStudents();
      context.read<SharedProvider>().resetClassNames();
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (termExamProvider.termExams.isEmpty) {
      await termExamProvider.fetchTermExams();
    }

    if (mounted && termExamProvider.termExams.isNotEmpty) {
      final firstExam = termExamProvider.termExams.first;
      setState(() {
        _selectedExamId = firstExam['id'] as int? ?? 5;
        final name = firstExam['exam_name']?.toString() ?? 'Term 1 Exam';
        final year = firstExam['education_year']?.toString() ?? '';
        _selectedExamName = year.isNotEmpty ? '$name - $year' : name;
      });
    } else if (mounted) {
      setState(() {
        _selectedExamId = 5;
        _selectedExamName = "Term 1 Examination";
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Color _getGradeColor(String grade) {
    return switch (grade.toUpperCase().trim()) {
      'A' => const Color(0xFF2E7D32),
      'B' => const Color(0xFF1565C0),
      'C' => const Color(0xFFE65100),
      'D' => const Color(0xFFC62828),
      _ => _primaryThemeColor,
    };
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

  Future<void> _pickAssessedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assessedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryThemeColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _assessedDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStandard = null;
      _selectedClassId = null;
      _selectedClassName = null;
      _searchQuery = '';
      _selectedAreaId = null;
      _searchController.clear();
    });

    dropdownProvider.clearSelectedItem("standard");
    dropdownProvider.clearSelectedItem("className");
    studentProvider.clearStudents();
    context.read<SharedProvider>().resetClassNames();
  }

  void _openGradePopup(List<StudentModel> students, int initialIndex) {
    if (_selectedExamId == null) {
      CustomSnackbar.show(
        context,
        message: "Please select an Exam first",
        type: SnackbarType.warning,
      );
      return;
    }

    final musicProvider = context.read<MusicArtsRoboticsProvider>();
    final activeArea = _getSelectedArea(musicProvider.areas);
    if (activeArea == null) {
      CustomSnackbar.show(
        context,
        message: "No co-scholastic area available for this class",
        type: SnackbarType.warning,
      );
      return;
    }

    musicProvider.setSelectedExam(
      _selectedExamId!,
      _selectedExamName ?? "Term Exam",
    );
    musicProvider.setAssessedDate(_assessedDate);
    if (_selectedClassId != null &&
        _selectedStandard != null &&
        _selectedClassName != null) {
      musicProvider.setSelectedClass(
        standard: _selectedStandard!,
        classId: _selectedClassId!,
        className: _selectedClassName!,
      );
    }

    int currentIndex = initialIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentStudent = students[currentIndex];
            final bool hasPrev = currentIndex > 0;
            final bool hasNext = currentIndex < students.length - 1;

            return Consumer<MusicArtsRoboticsProvider>(
              builder: (context, provider, _) {
                final currentArea =
                    _getSelectedArea(provider.areas) ?? activeArea;
                final entry = provider.getOrCreateRating(currentStudent.id);
                final selectedGrade = entry.getGrade(currentArea.id);
                final isGraded = selectedGrade.isNotEmpty;
                final areaAccent = _getAreaAccentColor(currentArea.name);

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(bottomSheetContext).padding.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: areaAccent.withAlpha(24),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getAreaIcon(currentArea.name),
                              size: 20,
                              color: areaAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${currentArea.name} Grade",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Student ${currentIndex + 1} of ${students.length}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              padding: const EdgeInsets.all(6),
                            ),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Student Info Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: _primaryThemeColor.withAlpha(28),
                              backgroundImage:
                                  currentStudent.image != null &&
                                          currentStudent.image!.isNotEmpty
                                      ? NetworkImage(currentStudent.image!)
                                      : null,
                              child:
                                  currentStudent.image == null ||
                                          currentStudent.image!.isEmpty
                                      ? Text(
                                        currentStudent.fullName.isNotEmpty
                                            ? currentStudent.fullName[0]
                                                .toUpperCase()
                                            : "S",
                                        style: const TextStyle(
                                          color: _primaryThemeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentStudent.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Roll: ${currentStudent.rollNumber ?? '-'} • ${_selectedStandard ?? ''} ${_selectedClassName ?? ''}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isGraded
                                        ? _getGradeColor(
                                          selectedGrade,
                                        ).withAlpha(24)
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      isGraded
                                          ? _getGradeColor(selectedGrade)
                                          : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                isGraded
                                    ? "Grade $selectedGrade"
                                    : "Not Graded",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isGraded
                                          ? _getGradeColor(selectedGrade)
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Section Title
                      Text(
                        "Assign ${currentArea.name} Grade",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Grade Selection Buttons (A, B, C, D)
                      Row(
                        children:
                            ['A', 'B', 'C', 'D'].map((grade) {
                              final isSelected = selectedGrade == grade;
                              final gradeColor = _getGradeColor(grade);

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      if (isSelected) {
                                        provider.setStudentAreaGrade(
                                          currentStudent.id,
                                          currentArea.id,
                                          '',
                                        );
                                      } else {
                                        provider.setStudentAreaGrade(
                                          currentStudent.id,
                                          currentArea.id,
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
                                                : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(14),
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
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            grade,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            switch (grade) {
                                              'A' => 'Excellent',
                                              'B' => 'Good',
                                              'C' => 'Satisfactory',
                                              'D' => 'Needs Work',
                                              _ => '',
                                            },
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isSelected
                                                      ? Colors.white.withAlpha(
                                                        230,
                                                      )
                                                      : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Navigation Bar (Previous, Clear, Next / Done)
                      Row(
                        children: [
                          // Previous Button
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  hasPrev
                                      ? Colors.grey.shade100
                                      : Colors.grey.shade50,
                              foregroundColor:
                                  hasPrev
                                      ? Colors.black87
                                      : Colors.grey.shade300,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      hasPrev
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade200,
                                ),
                              ),
                            ),
                            onPressed:
                                hasPrev
                                    ? () {
                                      setModalState(() {
                                        currentIndex--;
                                      });
                                    }
                                    : null,
                            icon: const Icon(LucideIcons.chevronLeft, size: 20),
                          ),
                          const SizedBox(width: 8),

                          // Clear button if graded
                          if (isGraded) ...[
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade600,
                                side: BorderSide(color: Colors.red.shade200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                provider.setStudentAreaGrade(
                                  currentStudent.id,
                                  currentArea.id,
                                  '',
                                );
                              },
                              child: const Text("Clear"),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Next / Done Button
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryThemeColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (hasNext) {
                                  setModalState(() {
                                    currentIndex++;
                                  });
                                } else {
                                  Navigator.pop(bottomSheetContext);
                                }
                              },
                              icon: Icon(
                                hasNext
                                    ? LucideIcons.chevronRight
                                    : LucideIcons.checkCheck,
                                size: 18,
                              ),
                              label: Text(
                                hasNext ? "Next Student" : "Done",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submitAllAssessments(List<StudentModel> allStudents) async {
    final provider = context.read<MusicArtsRoboticsProvider>();
    final activeArea = _getSelectedArea(provider.areas);
    final targetAreas = activeArea != null ? [activeArea] : provider.areas;
    final gradedCount = provider.getGradedStudentsCount(
      allStudents,
      targetAreas: targetAreas,
    );

    if (gradedCount == 0) {
      CustomSnackbar.show(
        context,
        message: "Please enter grades for at least one student before saving",
        type: SnackbarType.warning,
      );
      return;
    }

    if (_selectedExamId == null) {
      CustomSnackbar.show(
        context,
        message: "Please select an Exam",
        type: SnackbarType.warning,
      );
      return;
    }

    final success = await provider.saveClassAssessments(
      context: context,
      examId: _selectedExamId!,
      assessedAt: _assessedDate,
      allStudents: allStudents,
      className: _selectedClassName,
      standard: _selectedStandard,
      examName: _selectedExamName,
    );

    if (success && mounted) {
      // Stay or provide feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: "Music / Arts / Robotics Grading",
        isBackButton: true,
        actions: [
          IconButton(
            tooltip: "Recorded History",
            icon: const Icon(LucideIcons.history, size: 20),
            onPressed: () {
              context.pushNamed(
                RouteConstants.musicArtsRoboticsCoscholasticAssessment,
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Filter Section (Standard & Class dropdowns)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryThemeColor.withAlpha(24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.filter,
                            size: 18,
                            color: _primaryThemeColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Select Class & Division",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (_selectedStandard != null ||
                            _searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: _clearFilters,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Standard & Class Dropdowns Row
                    Row(
                      children: [
                        // Standard Dropdown
                        Expanded(
                          child: CustomDropdown(
                            dropdownKey: 'standard',
                            label: 'Standard*',
                            icon: LucideIcons.layers,
                            items: AppConstants.classGrades,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Select standard'
                                        : null,
                            onChanged: (standard) {
                              setState(() {
                                _selectedStandard = standard;
                                _selectedAreaId = null;
                              });
                              _formKey.currentState?.validate();

                              studentProvider.clearStudents();
                              dropdownProvider.clearSelectedItem("className");
                              _selectedClassId = null;
                              _selectedClassName = null;

                              final parsedYear = switch (standard) {
                                'LKG' => -2,
                                'UKG' => -1,
                                _ => int.tryParse(standard) ?? 0,
                              };

                              context
                                  .read<SharedProvider>()
                                  .getClassNameFromStandard(
                                    context: context,
                                    standard: parsedYear,
                                  );

                              // Fetch Co-Scholastic Music/Arts/Robotics areas for this standard/year!
                              final queryYear =
                                  parsedYear > 0 ? parsedYear : standard;
                              context
                                  .read<MusicArtsRoboticsProvider>()
                                  .fetchAreasForYear(queryYear);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Class Dropdown
                        Expanded(
                          child: Consumer<SharedProvider>(
                            builder: (context, provider, _) {
                              List<Map<String, dynamic>> classMapList =
                                  provider.classNames;
                              List<String> onlyClassNames =
                                  classMapList
                                      .map(
                                        (item) => item['classname'].toString(),
                                      )
                                      .toList();

                              return Stack(
                                children: [
                                  CustomDropdown(
                                    dropdownKey: 'className',
                                    label: 'Class*',
                                    icon: LucideIcons.school,
                                    items: onlyClassNames,
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Select class'
                                                : null,
                                    onChanged: (selectedClass) {
                                      _selectedClassName = selectedClass;
                                      _selectedClassId =
                                          classMapList.firstWhere(
                                            (item) =>
                                                item['classname'] ==
                                                selectedClass,
                                            orElse: () => {'id': null},
                                          )['id'];

                                      if (_selectedClassId != null) {
                                        context
                                            .read<StudentProvider>()
                                            .fetchStudentsByClassId(
                                              context: context,
                                              classId: _selectedClassId!,
                                            );
                                      }
                                    },
                                  ),
                                  if (_selectedStandard == null)
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            _formKey.currentState?.validate();
                                            CustomSnackbar.show(
                                              context,
                                              message:
                                                  "Please select standard first",
                                              type: SnackbarType.warning,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Term Exam & Assessed Date Selector Row
                    Row(
                      children: [
                        // Term Exam Selector
                        Expanded(
                          child: Consumer<TermExamProvider>(
                            builder: (context, termProv, _) {
                              final exams = termProv.termExams;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: _selectedExamId,
                                    hint: const Text(
                                      "Select Exam",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 18,
                                      color: _primaryThemeColor,
                                    ),
                                    items:
                                        exams.isEmpty
                                            ? [
                                              const DropdownMenuItem<int>(
                                                value: 5,
                                                child: Text(
                                                  "Term 1 Exam",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ]
                                            : exams.map((e) {
                                              final id =
                                                  e['id'] is int
                                                      ? e['id'] as int
                                                      : int.tryParse(
                                                            e['id'].toString(),
                                                          ) ??
                                                          5;
                                              final name =
                                                  e['exam_name']?.toString() ??
                                                  'Exam';
                                              return DropdownMenuItem<int>(
                                                value: id,
                                                child: Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                    onChanged: (val) {
                                      if (val == null) return;
                                      final selected = exams.firstWhere(
                                        (e) => e['id'] == val,
                                        orElse:
                                            () => {
                                              'exam_name': 'Term Examination',
                                            },
                                      );
                                      setState(() {
                                        _selectedExamId = val;
                                        _selectedExamName =
                                            selected['exam_name']?.toString() ??
                                            'Term Examination';
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Assessed Date Picker Pill
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _pickAssessedDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.calendar,
                                    size: 16,
                                    color: _primaryThemeColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(_assessedDate),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Active Areas display badge
                    Consumer<MusicArtsRoboticsProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingAreas) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _primaryThemeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Loading Co-Scholastic areas...",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (provider.areas.isNotEmpty) {
                          final activeArea = _getSelectedArea(provider.areas);

                          return Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.sparkles,
                                      size: 13,
                                      color: _primaryThemeColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        provider.areas.length > 1
                                            ? "Select Assessment Area:"
                                            : "Assessment Area for Class ${_selectedStandard ?? ''}:",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (activeArea != null &&
                                        provider.areas.length > 1) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getAreaAccentColor(
                                            activeArea.name,
                                          ).withAlpha(20),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          activeArea.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _getAreaAccentColor(
                                              activeArea.name,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Area selection chips (Single select: Music OR Arts, not both)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      provider.areas.map((area) {
                                        final isSelected =
                                            activeArea?.id == area.id;
                                        final areaColor = _getAreaAccentColor(
                                          area.name,
                                        );

                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedAreaId = area.id;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? areaColor
                                                      : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? areaColor
                                                        : Colors.grey.shade300,
                                                width: isSelected ? 1.5 : 1,
                                              ),
                                              boxShadow:
                                                  isSelected
                                                      ? [
                                                        BoxShadow(
                                                          color: areaColor
                                                              .withAlpha(50),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ]
                                                      : null,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isSelected
                                                      ? LucideIcons.check
                                                      : _getAreaIcon(area.name),
                                                  size: 15,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : Colors
                                                              .grey
                                                              .shade700,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  area.name,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          );
                        }

                        if (_selectedStandard != null &&
                            !provider.isLoadingAreas &&
                            provider.areas.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "No co-scholastic areas configured for Class $_selectedStandard",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar & Progress Header (when students are available)
          SliverToBoxAdapter(
            child: Consumer<StudentProvider>(
              builder: (context, studentProv, _) {
                if (studentProv.students.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Consumer<MusicArtsRoboticsProvider>(
                  builder: (context, provider, _) {
                    final allStudents = studentProv.students;
                    final activeArea = _getSelectedArea(provider.areas);
                    final targetAreas =
                        activeArea != null ? [activeArea] : provider.areas;
                    final gradedCount = provider.getGradedStudentsCount(
                      allStudents,
                      targetAreas: targetAreas,
                    );
                    final total = allStudents.length;

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // Header with Graded count & Quick Fill Menu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _primaryThemeColor.withAlpha(24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    activeArea != null
                                        ? "$gradedCount of $total Graded (${activeArea.name})"
                                        : "$gradedCount of $total Students Graded",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryThemeColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Quick Fill Menu
                              PopupMenuButton<String>(
                                tooltip: "Quick Fill",
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.sparkles,
                                        size: 14,
                                        color: _primaryThemeColor,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Quick Fill",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onSelected: (grade) {
                                  if (activeArea == null) {
                                    CustomSnackbar.show(
                                      context,
                                      message: "No area selected",
                                      type: SnackbarType.warning,
                                    );
                                    return;
                                  }
                                  final ids =
                                      allStudents.map((s) => s.id).toList();
                                  provider.quickFillAreaGrades(
                                    ids,
                                    activeArea.id,
                                    grade,
                                  );
                                  CustomSnackbar.show(
                                    context,
                                    message:
                                        "Applied Grade $grade for ${activeArea.name} to all students",
                                    type: SnackbarType.success,
                                  );
                                },
                                itemBuilder:
                                    (ctx) => [
                                      const PopupMenuItem(
                                        value: 'A',
                                        child: Text("Fill All with Grade A"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'B',
                                        child: Text("Fill All with Grade B"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'C',
                                        child: Text("Fill All with Grade C"),
                                      ),
                                      const PopupMenuItem(
                                        value: 'D',
                                        child: Text("Fill All with Grade D"),
                                      ),
                                    ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Search TextField
                          TextField(
                            controller: _searchController,
                            onChanged:
                                (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: "Search student by name or roll no...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.search,
                                size: 18,
                                color: Colors.grey,
                              ),
                              suffixIcon:
                                  _searchQuery.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          setState(() => _searchQuery = '');
                                          _searchController.clear();
                                        },
                                      )
                                      : null,
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: _primaryThemeColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Students List Section
          SliverToBoxAdapter(
            child: Consumer<StudentProvider>(
              builder: (context, studentProv, _) {
                if (studentProv.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: commonShimmerList(itemCount: 5, height: 75),
                  );
                }

                if (studentProv.students.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 30,
                    ),
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.users,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStandard == null ||
                                  _selectedClassName == null
                              ? "Select Standard & Class"
                              : "No Students Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedStandard == null ||
                                  _selectedClassName == null
                              ? "Choose standard and class to load students list"
                              : "No students registered in this class",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allStudents = studentProv.students;
                final filteredStudents = _getFilteredStudents(allStudents);

                if (filteredStudents.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No students match \"$_searchQuery\"",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Consumer<MusicArtsRoboticsProvider>(
                  builder: (context, provider, _) {
                    final activeArea = _getSelectedArea(provider.areas);

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final student = filteredStudents[idx];
                        final originalIndex = allStudents.indexWhere(
                          (s) => s.id == student.id,
                        );
                        final entry = provider.studentRatings[student.id];
                        final studentGrade =
                            activeArea != null
                                ? (entry?.getGrade(activeArea.id) ?? '')
                                : '';
                        final isGraded = studentGrade.isNotEmpty;

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          elevation: 0.6,
                          shadowColor: Colors.black12,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap:
                                () => _openGradePopup(
                                  allStudents,
                                  originalIndex >= 0 ? originalIndex : 0,
                                ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: _primaryThemeColor
                                        .withAlpha(24),
                                    backgroundImage:
                                        student.image != null &&
                                                student.image!.isNotEmpty
                                            ? NetworkImage(student.image!)
                                            : null,
                                    child:
                                        student.image == null ||
                                                student.image!.isEmpty
                                            ? Text(
                                              student.fullName.isNotEmpty
                                                  ? student.fullName[0]
                                                      .toUpperCase()
                                                  : 'S',
                                              style: const TextStyle(
                                                color: _primaryThemeColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 12),

                                  // Student Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 6,
                                          runSpacing: 2,
                                          children: [
                                            Text(
                                              "Roll: ${student.rollNumber ?? '-'}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            if (activeArea != null)
                                              Text(
                                                "• ${activeArea.name}",
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Grade Status Pill
                                  if (isGraded)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getGradeColor(
                                          studentGrade,
                                        ).withAlpha(24),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getGradeColor(studentGrade),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.checkCheck,
                                            size: 13,
                                            color: _getGradeColor(studentGrade),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Grade $studentGrade",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _getGradeColor(
                                                studentGrade,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.plus,
                                            size: 13,
                                            color: _primaryThemeColor,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Add Grade",
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: _primaryThemeColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Consumer<StudentProvider>(
        builder: (context, studentProv, _) {
          if (studentProv.students.isEmpty) {
            return const SizedBox.shrink();
          }

          return Consumer<MusicArtsRoboticsProvider>(
            builder: (context, provider, _) {
              final allStudents = studentProv.students;
              final activeArea = _getSelectedArea(provider.areas);
              final targetAreas =
                  activeArea != null ? [activeArea] : provider.areas;
              final gradedCount = provider.getGradedStudentsCount(
                allStudents,
                targetAreas: targetAreas,
              );

              if (gradedCount == 0) return const SizedBox.shrink();

              return Container(
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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryThemeColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _submitAllAssessments(allStudents),
                    icon: const Icon(LucideIcons.checkCheck, size: 18),
                    label: Text(
                      activeArea != null
                          ? "Submit ${activeArea.name} Assessments ($gradedCount Graded)"
                          : "Submit Assessments ($gradedCount Graded)",
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
