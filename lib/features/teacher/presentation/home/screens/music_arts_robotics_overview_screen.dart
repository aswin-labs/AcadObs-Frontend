import 'dart:async';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/teacher/data/models/physical_coscholastic_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/music_arts_robotics_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MusicArtsRoboticsOverviewScreen extends StatefulWidget {
  const MusicArtsRoboticsOverviewScreen({super.key});

  @override
  State<MusicArtsRoboticsOverviewScreen> createState() =>
      _MusicArtsRoboticsOverviewScreenState();
}

class _MusicArtsRoboticsOverviewScreenState
    extends State<MusicArtsRoboticsOverviewScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  static const Color _primaryThemeColor = Color(0xFF7B2CBF);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MusicArtsRoboticsProvider>();
      _searchController.text = provider.filterSearchQuery;
      provider.fetchRecordedAssessments(isRefresh: true);
      context.read<TermExamProvider>().fetchTermExams();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MusicArtsRoboticsProvider>().loadMoreRecordedAssessments();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<MusicArtsRoboticsProvider>().setFilterSearchQuery(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    context.read<MusicArtsRoboticsProvider>().setFilterSearchQuery('');
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
      return const Color(0xFF6C5CE7);
    } else if (clean.startsWith('C')) {
      return const Color(0xFFF39C12);
    } else if (clean.startsWith('D')) {
      return const Color(0xFFE74C3C);
    }
    return _primaryThemeColor;
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

  void _showFilterModal(BuildContext context) {
    final provider = context.read<MusicArtsRoboticsProvider>();
    final termExamProv = context.read<TermExamProvider>();

    int? tempExamId = provider.filterExamId;
    String? tempExamName = provider.filterExamName;
    int? tempClassId = provider.filterClassId;
    String? tempClassName = provider.filterClassName;

    final Map<int, String> availableClasses = {};
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
          builder: (modalContext, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Assessments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempExamId = null;
                            tempExamName = null;
                            tempClassId = null;
                            tempClassName = null;
                          });
                        },
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Exam Filter
                  const Text(
                    "Exam",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: tempExamId,
                        hint: const Text("All Exams"),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("All Exams"),
                          ),
                          ...termExamProv.termExams.map((e) {
                            final id =
                                e['id'] is int
                                    ? e['id'] as int
                                    : int.tryParse(e['id'].toString());
                            final name =
                                e['exam_name']?.toString() ?? 'Exam #$id';
                            return DropdownMenuItem<int?>(
                              value: id,
                              child: Text(name),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            tempExamId = val;
                            if (val == null) {
                              tempExamName = null;
                            } else {
                              final ex = termExamProv.termExams.firstWhere(
                                (e) => e['id'] == val,
                                orElse: () => {},
                              );
                              tempExamName = ex['exam_name']?.toString();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Class Filter
                  if (availableClasses.isNotEmpty) ...[
                    const Text(
                      "Class",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: tempClassId,
                          hint: const Text("All Classes"),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("All Classes"),
                            ),
                            ...availableClasses.entries.map((entry) {
                              return DropdownMenuItem<int?>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setModalState(() {
                              tempClassId = val;
                              tempClassName =
                                  val != null ? availableClasses[val] : null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryThemeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      provider.setFilterExam(tempExamId, tempExamName);
                      provider.setFilterClass(tempClassId, tempClassName);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditGradeModal(BuildContext context, RecordedCoScholasticItem item) {
    String selectedGrade = item.grade ?? 'A';
    final provider = context.read<MusicArtsRoboticsProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Update Grade for ${item.studentName}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.areaName} • ${item.examName}",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grade Options (A, B, C, D)
                  Row(
                    children:
                        ['A', 'B', 'C', 'D'].map((grade) {
                          final isSelected = selectedGrade == grade;
                          final color = _getGradeColor(grade);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setModalState(() {
                                    selectedGrade = grade;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? color
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? color
                                              : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
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
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryThemeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await provider.updateAssessmentGrade(
                        context: context,
                        assessmentId: item.id,
                        grade: selectedGrade,
                        assessedAt: item.assessedAt,
                        score: item.score,
                        remarks: item.remarks,
                        showLoader: true,
                      );
                    },
                    child: const Text(
                      "Update Grade",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
      appBar: const CommonAppBar(
        title: "Music, Arts & Robotics Assessment",
        isBackButton: true,
      ),
      body: Consumer<MusicArtsRoboticsProvider>(
        builder: (context, provider, _) {
          final assessments = provider.recordedAssessments;
          final isLoading = provider.isLoadingRecorded;
          final error = provider.recordedError;

          return RefreshIndicator(
            color: _primaryThemeColor,
            onRefresh: () async {
              await provider.fetchRecordedAssessments(isRefresh: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Top Banner Card with "Add Grades" Action
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7B2CBF),
                          Color(0xFF9D4EDD),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryThemeColor.withAlpha(80),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
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
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.palette_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Music / Arts / Robotics Grading",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Evaluate and record co-scholastic grades",
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _primaryThemeColor,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.pushNamed(
                              RouteConstants
                                  .musicArtsRoboticsCoscholasticClassSelection,
                            );
                          },
                          icon: const Icon(
                            LucideIcons.plus,
                            size: 18,
                            color: _primaryThemeColor,
                          ),
                          label: const Text(
                            "Add Co-Scholastic Grades",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search & Filter Bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: "Search recorded assessments...",
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
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: _primaryThemeColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showFilterModal(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  provider.activeFilterCount > 0
                                      ? _primaryThemeColor.withAlpha(24)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    provider.activeFilterCount > 0
                                        ? _primaryThemeColor
                                        : Colors.grey.shade300,
                              ),
                            ),
                            child: Badge(
                              isLabelVisible: provider.activeFilterCount > 0,
                              label: Text(
                                provider.activeFilterCount.toString(),
                              ),
                              child: Icon(
                                LucideIcons.filter,
                                size: 20,
                                color:
                                    provider.activeFilterCount > 0
                                        ? _primaryThemeColor
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Filters Chips Row
                if (provider.activeFilterCount > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (provider.filterExamName != null)
                            Chip(
                              label: Text(
                                "Exam: ${provider.filterExamName}",
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              onDeleted:
                                  () => provider.setFilterExam(null, null),
                            ),
                          if (provider.filterClassName != null)
                            Chip(
                              label: Text(
                                "Class: ${provider.filterClassName}",
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              onDeleted:
                                  () => provider.setFilterClass(null, null),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Recorded List
                if (isLoading && assessments.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: commonShimmerList(itemCount: 5, height: 85),
                    ),
                  )
                else if (error != null && assessments.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
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
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Failed to load assessments",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryThemeColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              provider.fetchRecordedAssessments(isRefresh: true);
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (assessments.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
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
                            Icons.palette_outlined,
                            size: 56,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No Recorded Assessments Found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tap 'Add Co-Scholastic Grades' to record new assessments.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryThemeColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              context.pushNamed(
                                RouteConstants
                                    .musicArtsRoboticsCoscholasticClassSelection,
                              );
                            },
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text("Add Grades"),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == assessments.length) {
                          if (provider.isLoadingMoreRecorded) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                        _primaryThemeColor,
                                      ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final item = assessments[index];
                        final grade = item.grade ?? '-';
                        final gradeColor = _getGradeColor(grade);
                        final areaIcon = _getAreaIcon(item.areaName);
                        final areaColor = _getAreaAccentColor(item.areaName);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Student Name & Grade Pill
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: areaColor.withAlpha(24),
                                    child: Icon(
                                      areaIcon,
                                      size: 18,
                                      color: areaColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        const SizedBox(height: 2),
                                        Text(
                                          "${item.className} • Roll: ${item.rollNumber.isNotEmpty ? item.rollNumber : '-'}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Grade badge with edit button
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap:
                                        () => _showEditGradeModal(
                                          context,
                                          item,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: gradeColor.withAlpha(24),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: gradeColor),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Grade $grade",
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: gradeColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            LucideIcons.pencil,
                                            size: 12,
                                            color: gradeColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEEEEEE),
                              ),
                              const SizedBox(height: 10),

                              // Bottom details: Area Name, Exam, Date
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: areaColor.withAlpha(16),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.areaName.isNotEmpty
                                          ? item.areaName
                                          : "Co-Scholastic",
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: areaColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.examName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  if (item.assessedAt.isNotEmpty)
                                    Text(
                                      item.assessedAt.contains('T')
                                          ? item.assessedAt.split('T').first
                                          : item.assessedAt.split(' ').first,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }, childCount: assessments.length + 1),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
