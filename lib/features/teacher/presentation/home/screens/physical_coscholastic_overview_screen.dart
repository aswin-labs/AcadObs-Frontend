import 'dart:async';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/teacher/data/models/physical_coscholastic_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/physical_coscholastic_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class PhysicalCoscholasticOverviewScreen extends StatefulWidget {
  final int? initialClassId;
  final String? initialClassName;
  final int? initialExamId;
  final String? initialExamName;
  final String? title;
  final bool isGeneralCoScholastic;

  const PhysicalCoscholasticOverviewScreen({
    super.key,
    this.initialClassId,
    this.initialClassName,
    this.initialExamId,
    this.initialExamName,
    this.title,
    this.isGeneralCoScholastic = false,
  });

  @override
  State<PhysicalCoscholasticOverviewScreen> createState() =>
      _PhysicalCoscholasticOverviewScreenState();
}

class _PhysicalCoscholasticOverviewScreenState
    extends State<PhysicalCoscholasticOverviewScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  bool _isAttendanceArea(String name) {
    final lower = name.toLowerCase();
    return lower.contains('attendance') ||
        lower.contains('presence') ||
        lower.contains('present days') ||
        lower.contains('working days');
  }

  String _getAttendanceHelperText(String text) {
    if (text.contains('/')) {
      final parts = text.split('/');
      final present = double.tryParse(parts[0].trim());
      final total = double.tryParse(parts.length > 1 ? parts[1].trim() : '');
      if (present != null && total != null && total > 0) {
        final pct = ((present / total) * 100).toStringAsFixed(1);
        final pInt =
            present == present.roundToDouble() ? present.toInt() : present;
        final tInt = total == total.roundToDouble() ? total.toInt() : total;
        return "$pInt days present out of $tInt total days ($pct%)";
      }
    }
    return "Enter present and total days (e.g. 90/110)";
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PhysicalCoscholasticProvider>();
      _searchController.text = provider.filterSearchQuery;
      if (widget.initialClassId != null || widget.initialExamId != null) {
        provider.setInitialFilters(
          classId: widget.initialClassId,
          className: widget.initialClassName,
          examId: widget.initialExamId,
          examName: widget.initialExamName,
        );
      } else {
        provider.fetchRecordedAssessments(isRefresh: true);
      }
      context.read<TermExamProvider>().fetchTermExams();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PhysicalCoscholasticProvider>().loadMoreRecordedAssessments();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<PhysicalCoscholasticProvider>().setFilterSearchQuery(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    context.read<PhysicalCoscholasticProvider>().setFilterSearchQuery('');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getGradeColor(String grade) {
    final clean = grade.toUpperCase().trim();
    if (clean.startsWith('A')) {
      return const Color(0xFF00B894);
    } else if (clean.startsWith('B')) {
      return const Color(0xFF0984E3);
    } else if (clean.startsWith('C')) {
      return const Color(0xFFF39C12);
    } else if (clean.startsWith('D')) {
      return const Color(0xFFE74C3C);
    }
    return const Color(0xFF0077B6);
  }

  void _showFilterModal(BuildContext context) {
    final provider = context.read<PhysicalCoscholasticProvider>();
    final termExamProv = context.read<TermExamProvider>();

    int? tempExamId = provider.filterExamId;
    String? tempExamName = provider.filterExamName;
    int? tempClassId = provider.filterClassId;
    String? tempClassName = provider.filterClassName;

    // Extract available classes from recorded assessments for quick filtering
    final Map<int, String> availableClasses = {};
    if (widget.initialClassId != null && widget.initialClassName != null) {
      availableClasses[widget.initialClassId!] = widget.initialClassName!;
    }
    if (provider.filterClassId != null && provider.filterClassName != null) {
      availableClasses[provider.filterClassId!] = provider.filterClassName!;
    }
    for (final item in provider.recordedAssessments) {
      if (item.classId != null && item.className.isNotEmpty) {
        availableClasses[item.classId!] = item.className;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final exams = termExamProv.termExams;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              LucideIcons.slidersHorizontal,
                              size: 18,
                              color: Color(0xFF0077B6),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Filter Assessments",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (tempExamId != null || tempClassId != null)
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempExamId = null;
                                tempExamName = null;
                                tempClassId = null;
                                tempClassName = null;
                              });
                            },
                            child: const Text(
                              "Reset",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Exam Filter Section
                    const Text(
                      "Term Examination",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("All Exams"),
                          selected: tempExamId == null,
                          selectedColor: const Color(0xFF0077B6).withAlpha(35),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color:
                                tempExamId == null
                                    ? const Color(0xFF0077B6)
                                    : Colors.black87,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempExamId = null;
                                tempExamName = null;
                              });
                            }
                          },
                        ),
                        ...exams.map((e) {
                          final eId =
                              e['id'] is int
                                  ? e['id'] as int
                                  : int.tryParse(e['id'].toString()) ?? 0;
                          final eName = e['exam_name']?.toString() ?? 'Exam';
                          final isSelected = tempExamId == eId;

                          return ChoiceChip(
                            label: Text(eName),
                            selected: isSelected,
                            selectedColor: const Color(
                              0xFF0077B6,
                            ).withAlpha(35),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? const Color(0xFF0077B6)
                                      : Colors.black87,
                            ),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  tempExamId = eId;
                                  tempExamName = eName;
                                } else {
                                  tempExamId = null;
                                  tempExamName = null;
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Class Filter Section
                    const Text(
                      "Class / Division",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("All Classes"),
                          selected: tempClassId == null,
                          selectedColor: const Color(0xFF0077B6).withAlpha(35),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color:
                                tempClassId == null
                                    ? const Color(0xFF0077B6)
                                    : Colors.black87,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempClassId = null;
                                tempClassName = null;
                              });
                            }
                          },
                        ),
                        ...availableClasses.entries.map((entry) {
                          final cId = entry.key;
                          final cName = entry.value;
                          final isSelected = tempClassId == cId;

                          return ChoiceChip(
                            label: Text("Class $cName"),
                            selected: isSelected,
                            selectedColor: const Color(
                              0xFF0077B6,
                            ).withAlpha(35),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? const Color(0xFF0077B6)
                                      : Colors.black87,
                            ),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  tempClassId = cId;
                                  tempClassName = cName;
                                } else {
                                  tempClassId = null;
                                  tempClassName = null;
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Apply Button
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF0077B6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0077B6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              provider.setFilterExam(tempExamId, tempExamName);
                              provider.setFilterClass(
                                tempClassId,
                                tempClassName,
                              );
                            },
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getGradeLabel(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return 'Excellent';
      case 'B+':
      case 'B':
        return 'Good';
      case 'C':
        return 'Satisfactory';
      case 'D':
        return 'Needs Work';
      default:
        return 'Grade';
    }
  }

  void _showEditGradeModal(
    BuildContext context,
    RecordedCoScholasticItem item,
  ) {
    final provider = context.read<PhysicalCoscholasticProvider>();
    final isAttendance = _isAttendanceArea(item.areaName);
    final attendanceController = TextEditingController(
      text: item.grade?.trim() ?? (item.score != null ? item.score.toString() : ''),
    );

    final defaultOptions = ['A', 'B', 'C', 'D'];
    final gradeOptions = List<String>.from(defaultOptions);
    final initialGrade = item.grade?.trim().toUpperCase() ?? 'A';
    if (initialGrade.isNotEmpty && !gradeOptions.contains(initialGrade)) {
      gradeOptions.insert(0, initialGrade);
    }

    String selectedGrade = initialGrade.isNotEmpty ? initialGrade : 'A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24 + MediaQuery.of(bottomSheetContext).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: (isAttendance
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFF0077B6))
                                      .withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isAttendance
                                      ? Icons.calendar_month_rounded
                                      : LucideIcons.pencil,
                                  size: 17,
                                  color: isAttendance
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF0077B6),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isAttendance
                                    ? "Edit Attendance Record"
                                    : "Edit Assessment Grade",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed:
                                isUpdating
                                    ? null
                                    : () => Navigator.pop(bottomSheetContext),
                            visualDensity: VisualDensity.compact,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Student Info Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  const Color(0xFF0077B6).withAlpha(25),
                              child: Text(
                                item.studentName.isNotEmpty
                                    ? item.studentName[0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(
                                  color: Color(0xFF0077B6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.studentName.isNotEmpty
                                        ? item.studentName
                                        : "Student #${item.studentId}",
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (item.rollNumber.isNotEmpty)
                                        Text(
                                          "Roll: ${item.rollNumber}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      if (item.className.isNotEmpty)
                                        Text(
                                          "Class: ${item.className}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isAttendance) ...[
                              if (item.grade != null && item.grade!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7).withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF0284C7),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Current",
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.calendar_month_rounded,
                                            size: 11,
                                            color: Color(0xFF0284C7),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            item.grade!.contains('/')
                                                ? "${item.grade!} Days"
                                                : "${item.grade!} Days",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ] else if (item.grade != null &&
                                item.grade!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getGradeColor(item.grade!).withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getGradeColor(item.grade!),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Current",
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      item.grade!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _getGradeColor(item.grade!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      if (isAttendance) ...[
                        const SizedBox(height: 18),
                        const Text(
                          "Attendance (Present/Total)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: attendanceController,
                          keyboardType: TextInputType.text,
                          onChanged: (val) {
                            setModalState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: "e.g. 90/110",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: Color(0xFF0284C7),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF0284C7),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (attendanceController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              _getAttendanceHelperText(
                                attendanceController.text.trim(),
                              ),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ] else ...[
                        const SizedBox(height: 18),

                        // Grade Selection Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select Grade",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (selectedGrade.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getGradeColor(selectedGrade)
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Selected: $selectedGrade",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getGradeColor(selectedGrade),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Grade Options Grid/Row
                        Row(
                          children:
                              gradeOptions.map((grade) {
                                final isSelected = selectedGrade == grade;
                                final color = _getGradeColor(grade);

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap:
                                          isUpdating
                                              ? null
                                              : () {
                                                setModalState(() {
                                                  selectedGrade = grade;
                                                });
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
                                              isSelected ? color : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? color
                                                    : Colors.grey.shade300,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow:
                                              isSelected
                                                  ? [
                                                    BoxShadow(
                                                      color: color.withAlpha(80),
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
                                            const SizedBox(height: 3),
                                            Text(
                                              _getGradeLabel(grade),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isSelected
                                                        ? Colors.white70
                                                        : Colors.grey.shade500,
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
                      ],

                      const SizedBox(height: 24),

                      // Action Buttons (Cancel & Update)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  isUpdating
                                      ? null
                                      : () => Navigator.pop(bottomSheetContext),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isUpdating
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAttendance
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF0077B6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed:
                                  isUpdating
                                      ? null
                                      : () async {
                                        setModalState(() {
                                          isUpdating = true;
                                        });

                                        bool success;
                                        if (isAttendance) {
                                          final attendanceText =
                                              attendanceController.text.trim();
                                          String? scoreVal;
                                          if (attendanceText.contains('/')) {
                                            final parts =
                                                attendanceText.split('/');
                                            final present = double.tryParse(
                                              parts[0].trim(),
                                            );
                                            final total = double.tryParse(
                                              parts.length > 1
                                                  ? parts[1].trim()
                                                  : '',
                                            );
                                            if (present != null &&
                                                total != null &&
                                                total > 0) {
                                              final pct = double.parse(
                                                ((present / total) * 100)
                                                    .toStringAsFixed(1),
                                              );
                                              scoreVal = pct.toString();
                                            } else if (present != null) {
                                              scoreVal = present.toString();
                                            }
                                          } else if (attendanceText.isNotEmpty) {
                                            final numVal = double.tryParse(
                                              attendanceText,
                                            );
                                            if (numVal != null) {
                                              scoreVal = numVal.toString();
                                            }
                                          }

                                          success = await provider
                                              .updateCoScholasticAssessmentGrade(
                                                context: this.context,
                                                assessmentId: item.id,
                                                grade: attendanceText,
                                                assessedAt: item.assessedAt,
                                                score: scoreVal,
                                                remarks: item.remarks,
                                                showLoader: false,
                                              );
                                        } else {
                                          success = await provider
                                              .updateCoScholasticAssessmentGrade(
                                                context: this.context,
                                                assessmentId: item.id,
                                                grade: selectedGrade,
                                                assessedAt: item.assessedAt,
                                                score: item.score,
                                                remarks: item.remarks,
                                                showLoader: false,
                                              );
                                        }

                                        if (bottomSheetContext.mounted) {
                                          if (success) {
                                            Navigator.pop(bottomSheetContext);
                                          } else {
                                            setModalState(() {
                                              isUpdating = false;
                                            });
                                          }
                                        }
                                      },
                              child:
                                  isUpdating
                                      ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Updating...",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        isAttendance
                                            ? "Update Attendance"
                                            : "Update Grade",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                            ),
                          ),
                        ],
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: widget.title ??
            (widget.isGeneralCoScholastic
                ? "Co-Scholastic History"
                : "Physical Co-Scholastic"),
        isBackButton: true,
      ),
      body: Consumer<PhysicalCoscholasticProvider>(
        builder: (context, provider, _) {
          final assessments = provider.recordedAssessments;
          final totalCount = provider.recordedTotalContent;
          final activeFilters = provider.activeFilterCount;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchRecordedAssessments(isRefresh: true);
            },
            color: const Color(0xFF0077B6),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Top Action Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isGeneralCoScholastic
                              ? const [Color(0xFF00B4D8), Color(0xFF0077B6)]
                              : const [Color(0xFF0077B6), Color(0xFF0096C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0077B6).withAlpha(60),
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.isGeneralCoScholastic
                                      ? LucideIcons.history
                                      : Icons.fitness_center_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.isGeneralCoScholastic
                                          ? (widget.initialClassName != null
                                              ? "Class ${widget.initialClassName} Assessment History"
                                              : "Co-Scholastic Assessment History")
                                          : "Health & Physical Education Assessment",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.isGeneralCoScholastic
                                          ? "Review and update recorded ratings, areas & attendance"
                                          : "Add or update grades for students",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (widget.isGeneralCoScholastic) ...[
                            if (widget.initialClassName != null) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0077B6),
                                  minimumSize: const Size(double.infinity, 42),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  size: 16,
                                  color: Color(0xFF0077B6),
                                ),
                                label: Text(
                                  "Back to Class ${widget.initialClassName} Grading",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0077B6),
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                context.pushNamed(
                                  RouteConstants
                                      .physicalCoscholasticClassSelection,
                                );
                              },
                              icon: const Icon(
                                LucideIcons.plus,
                                size: 18,
                                color: Color(0xFF0077B6),
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Add Health & Physical Education Grades",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Search Bar & Filter Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        // Search Box
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: "Search student name or roll...",
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
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: _clearSearch,
                                      )
                                      : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0077B6),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Filter Button with Badge
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showFilterModal(context),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color:
                                  activeFilters > 0
                                      ? const Color(0xFF0077B6)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    activeFilters > 0
                                        ? const Color(0xFF0077B6)
                                        : Colors.grey.shade200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(6),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.slidersHorizontal,
                                  size: 17,
                                  color:
                                      activeFilters > 0
                                          ? Colors.white
                                          : const Color(0xFF0077B6),
                                ),
                                if (activeFilters > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "$activeFilters",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0077B6),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Filter Chips (if any)
                if (provider.filterExamId != null ||
                    provider.filterClassId != null ||
                    provider.filterStudentId != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (provider.filterExamName != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text(provider.filterExamName!),
                                  labelStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0077B6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: const Color(
                                    0xFF0077B6,
                                  ).withAlpha(25),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFF0077B6),
                                  ),
                                  onDeleted:
                                      () => provider.setFilterExam(null, null),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            if (provider.filterClassName != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text(
                                    "Class ${provider.filterClassName!}",
                                  ),
                                  labelStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0077B6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: const Color(
                                    0xFF0077B6,
                                  ).withAlpha(25),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFF0077B6),
                                  ),
                                  onDeleted:
                                      () => provider.setFilterClass(null, null),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            if (provider.filterStudentName != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text(provider.filterStudentName!),
                                  labelStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0077B6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: const Color(
                                    0xFF0077B6,
                                  ).withAlpha(25),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFF0077B6),
                                  ),
                                  onDeleted:
                                      () =>
                                          provider.setFilterStudent(null, null),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            TextButton(
                              onPressed: provider.clearAllFilters,
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: const Text(
                                "Clear All",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Section Header with Total Count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recorded Assessments",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (totalCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0077B6).withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$totalCount Recorded",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0077B6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Body: Shimmer / Error / Empty / List
                if (provider.isLoadingRecorded && assessments.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: commonShimmerList(itemCount: 6, height: 95),
                    ),
                  )
                else if (provider.recordedError != null && assessments.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 50,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              LucideIcons.alertCircle,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Failed to Load Assessments",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.recordedError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077B6),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                provider.fetchRecordedAssessments(
                                  isRefresh: true,
                                );
                              },
                              child: const Text("Try Again"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (assessments.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 50,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.clipboardList,
                              size: 52,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              activeFilters > 0 ||
                                      provider.filterSearchQuery.isNotEmpty
                                  ? "No assessments match your filters"
                                  : "No Co-Scholastic Assessments Recorded Yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeFilters > 0 ||
                                      provider.filterSearchQuery.isNotEmpty
                                  ? "Try clearing search or filters to see all recorded assessments."
                                  : "Tap 'Add Health & Physical Education Grades' above to start assessing students.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (activeFilters > 0 ||
                                provider.filterSearchQuery.isNotEmpty)
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF0077B6),
                                  ),
                                ),
                                onPressed: () {
                                  _clearSearch();
                                  provider.clearAllFilters();
                                },
                                icon: const Icon(
                                  LucideIcons.rotateCcw,
                                  size: 15,
                                  color: Color(0xFF0077B6),
                                ),
                                label: const Text(
                                  "Clear Filters",
                                  style: TextStyle(color: Color(0xFF0077B6)),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0077B6),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  context.pushNamed(
                                    RouteConstants
                                        .physicalCoscholasticClassSelection,
                                  );
                                },
                                icon: const Icon(LucideIcons.plus, size: 16),
                                label: const Text("Add Grades"),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == assessments.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0077B6),
                                ),
                              ),
                            ),
                          );
                        }

                        final item = assessments[index];
                        return _buildAssessmentCard(context, item);
                      }, childCount: assessments.length + (provider.hasMoreRecorded ? 1 : 0)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssessmentCard(BuildContext context, RecordedCoScholasticItem item) {
    final gradeText = item.grade?.trim() ?? '';
    final hasGrade = gradeText.isNotEmpty;
    final scoreText = item.score?.trim() ?? '';
    final hasScore = scoreText.isNotEmpty && scoreText != 'null';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Student info & Grade badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0077B6).withAlpha(25),
                  child: Text(
                    item.studentName.isNotEmpty
                        ? item.studentName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Color(0xFF0077B6),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Roll
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName.isNotEmpty
                            ? item.studentName
                            : "Student #${item.studentId}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (item.rollNumber.isNotEmpty)
                            Text(
                              "Roll: ${item.rollNumber}",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (item.className.isNotEmpty)
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
                                "Class ${item.className}",
                                style: TextStyle(
                                  fontSize: 10.5,
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
                const SizedBox(width: 8),

                // Grade Badge & Edit Action
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAttendanceArea(item.areaName))
                      GestureDetector(
                        onTap: () => _showEditGradeModal(context, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF0284C7).withAlpha(120),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                size: 13,
                                color: Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                gradeText.isNotEmpty
                                    ? (gradeText.contains('/')
                                        ? "$gradeText Days"
                                        : (gradeText.toLowerCase().contains('day')
                                            ? gradeText
                                            : "$gradeText Days"))
                                    : (hasScore
                                        ? "$scoreText Days"
                                        : "Attendance Recorded"),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (hasGrade)
                      GestureDetector(
                        onTap: () => _showEditGradeModal(context, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getGradeColor(gradeText).withAlpha(28),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getGradeColor(gradeText),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            gradeText.contains('/') || gradeText.length > 3
                                ? gradeText
                                : "Grade $gradeText",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(gradeText),
                            ),
                          ),
                        ),
                      )
                    else if (hasScore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Text(
                          "Score $scoreText",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Graded",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showEditGradeModal(context, item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0077B6).withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF0077B6).withAlpha(45),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.pencil,
                                size: 12,
                                color: Color(0xFF0077B6),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0077B6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Bottom metadata: Area tag & Exam • Date
            Row(
              children: [
                // Area tag
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _getAreaIcon(item.areaName),
                        size: 13,
                        color: _getAreaColor(item.areaName),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.areaName.isNotEmpty
                              ? item.areaName
                              : "Health & Physical Education",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _getAreaColor(item.areaName),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Exam & Date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.examName.isNotEmpty) ...[
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.35,
                        ),
                        child: Text(
                          item.examName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text("•", style: TextStyle(color: Colors.grey.shade400)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      item.assessedAt,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAreaIcon(String name) {
    if (_isAttendanceArea(name)) {
      return Icons.calendar_month_rounded;
    }
    final lower = name.toLowerCase();
    if (lower.contains('physical') ||
        lower.contains('health') ||
        lower.contains('sport') ||
        lower.contains('fitness') ||
        lower.contains('pe')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('art') || lower.contains('drawing')) {
      return Icons.palette_outlined;
    }
    if (lower.contains('music') || lower.contains('dance')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('attend')) {
      return Icons.calendar_month_rounded;
    }
    return Icons.star_rounded;
  }

  Color _getAreaColor(String name) {
    if (_isAttendanceArea(name)) {
      return const Color(0xFF0284C7);
    }
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
    return const Color(0xFF0077B6);
  }
}
