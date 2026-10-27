import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/services/shared_services.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

typedef TermMarksFilterCallback = void Function({
  int? examId,
  String? examName,
  String? standard,
  int? classId,
  String? className,
  int? subjectId,
  String? subjectName,
});

Future<void> showTermMarksFilterBottomSheet({
  required BuildContext context,
  bool showClassFilter = true,
  int? initialExamId,
  String? initialExamName,
  String? initialStandard,
  int? initialClassId,
  String? initialClassName,
  int? initialSubjectId,
  String? initialSubjectName,
  TermMarksFilterCallback? onApply,
}) async {
  final termExamProvider = context.read<TermExamProvider>();
  final subjectProvider = context.read<SubjectProvider>();

  // Ensure exams & subjects are available
  if (termExamProvider.termExams.isEmpty) {
    termExamProvider.fetchTermExams();
  }
  if (subjectProvider.subjectsAll.isEmpty) {
    subjectProvider.fetchAllSubjects();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return _TermMarksFilterModal(
        showClassFilter: showClassFilter,
        initialExamId: initialExamId,
        initialExamName: initialExamName,
        initialStandard: initialStandard,
        initialClassId: initialClassId,
        initialClassName: initialClassName,
        initialSubjectId: initialSubjectId,
        initialSubjectName: initialSubjectName,
        onApply: onApply,
      );
    },
  );
}

class _TermMarksFilterModal extends StatefulWidget {
  final bool showClassFilter;
  final int? initialExamId;
  final String? initialExamName;
  final String? initialStandard;
  final int? initialClassId;
  final String? initialClassName;
  final int? initialSubjectId;
  final String? initialSubjectName;
  final TermMarksFilterCallback? onApply;

  const _TermMarksFilterModal({
    this.showClassFilter = true,
    this.initialExamId,
    this.initialExamName,
    this.initialStandard,
    this.initialClassId,
    this.initialClassName,
    this.initialSubjectId,
    this.initialSubjectName,
    this.onApply,
  });

  @override
  State<_TermMarksFilterModal> createState() => _TermMarksFilterModalState();
}

class _TermMarksFilterModalState extends State<_TermMarksFilterModal> {
  int? _selectedExamId;
  String? _selectedExamName;

  String? _selectedStandard;
  int? _selectedClassId;
  String? _selectedClassName;

  int? _selectedSubjectId;
  String? _selectedSubjectName;

  List<Map<String, dynamic>> _classList = [];
  bool _isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TermExamProvider>();

    _selectedExamId =
        widget.initialExamId ??
        (widget.onApply == null ? provider.filterExamId : null);
    _selectedExamName =
        widget.initialExamName ??
        (widget.onApply == null ? provider.filterExamName : null);

    if (widget.showClassFilter) {
      _selectedStandard =
          widget.initialStandard ??
          (widget.onApply == null ? provider.filterStandard : null);
      _selectedClassId =
          widget.initialClassId ??
          (widget.onApply == null ? provider.filterClassId : null);
      _selectedClassName =
          widget.initialClassName ??
          (widget.onApply == null ? provider.filterClassName : null);

      if (_selectedStandard != null) {
        _loadClassesForStandard(_selectedStandard!, retainSelectedClass: true);
      }
    }

    _selectedSubjectId =
        widget.initialSubjectId ??
        (widget.onApply == null ? provider.filterSubjectId : null);
    _selectedSubjectName =
        widget.initialSubjectName ??
        (widget.onApply == null ? provider.filterSubjectName : null);
  }

  int _parseStandardValue(String standard) {
    return switch (standard) {
      'LKG' => -2,
      'UKG' => -1,
      _ => int.tryParse(standard) ?? 1,
    };
  }

  Future<void> _loadClassesForStandard(
    String standard, {
    bool retainSelectedClass = false,
  }) async {
    setState(() {
      _isLoadingClasses = true;
      if (!retainSelectedClass) {
        _selectedClassId = null;
        _selectedClassName = null;
      }
    });

    try {
      final standardValue = _parseStandardValue(standard);
      final response = await SharedServices().getClassNameFromStandard(
        standard: standardValue,
      );

      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data;
        if (mounted) {
          setState(() {
            _classList =
                list
                    .map(
                      (item) => {
                        'id': item['id'] as int?,
                        'classname': item['classname']?.toString() ?? '',
                      },
                    )
                    .toList();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _classList = [];
          });
        }
      }
    } catch (e) {
      log('Error loading classes for standard: $e');
      if (mounted) {
        setState(() {
          _classList = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingClasses = false;
        });
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedExamId = null;
      _selectedExamName = null;
      _selectedStandard = null;
      _selectedClassId = null;
      _selectedClassName = null;
      _selectedSubjectId = null;
      _selectedSubjectName = null;
      _classList = [];
      _isLoadingClasses = false;
    });
  }

  bool get _hasAnySelection =>
      _selectedExamId != null ||
      (widget.showClassFilter &&
          (_selectedStandard != null || _selectedClassId != null)) ||
      _selectedSubjectId != null;

  @override
  Widget build(BuildContext context) {
    final termExamProvider = context.watch<TermExamProvider>();
    final subjectProvider = context.watch<SubjectProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.slidersHorizontal,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Filter Term Marks",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                if (_hasAnySelection)
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
                    label: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // 1. Term Exam Dropdown
            Text(
              "Term Examination",
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: _selectedExamId,
              isExpanded: true,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Select Term Exam',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(LucideIcons.notebookTabs),
                ),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text("All Exams"),
                ),
                ...termExamProvider.termExams.map((exam) {
                  final id =
                      exam['id'] is int
                          ? exam['id'] as int
                          : int.tryParse(exam['id'].toString()) ?? 0;
                  final examName = exam['exam_name']?.toString() ?? '';
                  final eduYear = exam['education_year']?.toString() ?? '';
                  final label =
                      eduYear.isNotEmpty ? '$examName - $eduYear' : examName;

                  return DropdownMenuItem<int?>(
                    value: id,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedExamId = val;
                  if (val == null) {
                    _selectedExamName = null;
                  } else {
                    final found = termExamProvider.termExams.firstWhere(
                      (e) => e['id'] == val,
                      orElse: () => {},
                    );
                    _selectedExamName = found['exam_name']?.toString();
                  }
                });
              },
            ),

            if (widget.showClassFilter) ...[
              const SizedBox(height: 16),

              // 2. Class Standard Dropdown
              Text(
                "Standard & Class",
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
            Row(
              children: [
                // Standard selector
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedStandard,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Standard',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(LucideIcons.layers),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text("All Standards"),
                      ),
                      ...AppConstants.classGrades.map((grade) {
                        return DropdownMenuItem<String?>(
                          value: grade,
                          child: Text(grade),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedStandard = val;
                      });
                      if (val != null) {
                        _loadClassesForStandard(val);
                      } else {
                        setState(() {
                          _selectedClassId = null;
                          _selectedClassName = null;
                          _classList = [];
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Class selector
                Expanded(
                  child:
                      _isLoadingClasses
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                          : DropdownButtonFormField<int?>(
                            initialValue: _selectedClassId,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: 'Class',
                              enabled:
                                  _selectedStandard != null &&
                                  _classList.isNotEmpty,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(LucideIcons.school),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text("All Classes"),
                              ),
                              ..._classList.map((c) {
                                final id = c['id'] as int?;
                                final name = c['classname']?.toString() ?? '';
                                return DropdownMenuItem<int?>(
                                  value: id,
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged:
                                (_selectedStandard != null &&
                                        _classList.isNotEmpty)
                                    ? (val) {
                                      setState(() {
                                        _selectedClassId = val;
                                        if (val == null) {
                                          _selectedClassName = null;
                                        } else {
                                          final found = _classList.firstWhere(
                                            (c) => c['id'] == val,
                                            orElse: () => {},
                                          );
                                          _selectedClassName =
                                              found['classname']?.toString();
                                        }
                                      });
                                    }
                                    : null,
                          ),
                ),
              ],
            ),
          ],

            const SizedBox(height: 16),

            // 3. Subject Dropdown
            Text(
              "Subject",
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: _selectedSubjectId,
              isExpanded: true,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(LucideIcons.bookOpen),
                ),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text("All Subjects"),
                ),
                ...subjectProvider.subjectsAll.map((SubjectModel subject) {
                  return DropdownMenuItem<int?>(
                    value: subject.id,
                    child: Text(
                      subject.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedSubjectId = val;
                  if (val == null) {
                    _selectedSubjectName = null;
                  } else {
                    final found = subjectProvider.subjectsAll.firstWhere(
                      (s) => s.id == val,
                      orElse:
                          () => SubjectModel(
                            id: val,
                            subjectName: 'Subject #$val',
                          ),
                    );
                    _selectedSubjectName = found.subjectName;
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            // Apply Button
            CommonButton(
              onPressed: () {
                if (widget.onApply != null) {
                  widget.onApply!(
                    examId: _selectedExamId,
                    examName: _selectedExamName,
                    standard: widget.showClassFilter ? _selectedStandard : null,
                    classId: widget.showClassFilter ? _selectedClassId : null,
                    className:
                        widget.showClassFilter ? _selectedClassName : null,
                    subjectId: _selectedSubjectId,
                    subjectName: _selectedSubjectName,
                  );
                } else {
                  context.read<TermExamProvider>().applyTermExamFilters(
                    examId: _selectedExamId,
                    examName: _selectedExamName,
                    standard: _selectedStandard,
                    classId: _selectedClassId,
                    className: _selectedClassName,
                    subjectId: _selectedSubjectId,
                    subjectName: _selectedSubjectName,
                  );
                }
                Navigator.pop(context);
              },
              widget: const Text(
                "Apply Filters",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
