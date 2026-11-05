import 'package:acadobs/features/exam_timetable/data/models/exam_timetable_model.dart';
import 'package:acadobs/features/exam_timetable/presentation/provider/exam_timetable_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentExamTimetableScreen extends StatefulWidget {
  final int studentId;

  const StudentExamTimetableScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentExamTimetableScreen> createState() =>
      _StudentExamTimetableScreenState();
}

class _StudentExamTimetableScreenState
    extends State<StudentExamTimetableScreen> {
  int? _selectedExamId;
  String? _selectedExamName;
  String? _selectedTitle;
  bool _isTableView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ExamTimetableProvider>();
      provider.resetStudentTimetable();
      provider.fetchExamTitles(forGuardian: true);
      provider.fetchGuardianExams();
    });
  }

  void _triggerFetchIfReady() {
    final examId = _selectedExamId;
    final title = _selectedTitle;
    if (examId != null && title != null && title.isNotEmpty) {
      context.read<ExamTimetableProvider>().fetchStudentExamTimetable(
        studentId: widget.studentId,
        examId: examId,
        title: title,
      );
    }
  }

  Future<void> _onRefresh() async {
    final provider = context.read<ExamTimetableProvider>();
    await Future.wait([
      provider.fetchExamTitles(forGuardian: true),
      provider.fetchGuardianExams(),
    ]);
    if (!mounted) return;
    _triggerFetchIfReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: CommonAppBar(
        title: 'Exam Timetable',
        isBackButton: true,
        actions: [
          Consumer<ExamTimetableProvider>(
            builder: (context, provider, _) {
              if (provider.studentTimetableItems.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: _isTableView ? 'Card View' : 'Table View',
                  onPressed: () {
                    setState(() {
                      _isTableView = !_isTableView;
                    });
                  },
                  icon: Icon(
                    _isTableView
                        ? LucideIcons.layoutList
                        : LucideIcons.table,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildFiltersCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<ExamTimetableProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingStudentTimetable) {
                    return _buildLoadingState();
                  }

                  if (!provider.hasSearchedStudentTimetable) {
                    return _buildInitialPromptState();
                  }

                  if (provider.studentErrorMessage != null) {
                    return _buildErrorState(provider.studentErrorMessage!);
                  }

                  if (provider.studentTimetableItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  final items = provider.studentTimetableItems;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScheduleHeaderBanner(items),
                        const SizedBox(height: 16),
                        if (_isTableView)
                          _buildClassicTableSchedule(items)
                        else
                          _buildTimelineScheduleList(items),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
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
                  color: const Color(0xFF35C2C1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.calendarClock,
                  size: 18,
                  color: Color(0xFF00897B),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Select Exam Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (_selectedExamId != null || _selectedTitle != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedExamId = null;
                      _selectedExamName = null;
                      _selectedTitle = null;
                    });
                    context
                        .read<ExamTimetableProvider>()
                        .resetStudentTimetable();
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.redAccent,
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text(
                    'Reset',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Select Term (exam_id)
          const Text(
            'Select Term *',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<ExamTimetableProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingGuardianExams &&
                  provider.guardianExams.isEmpty) {
                return Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading terms...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final exams = provider.guardianExams;
              final validSelectedId =
                  exams.any((e) => (e['id'] as int?) == _selectedExamId)
                      ? _selectedExamId
                      : null;

              return DropdownButtonFormField<int>(
                value: validSelectedId,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF475569),
                ),
                decoration: InputDecoration(
                  hintText: 'Select Term',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00897B),
                      width: 1.5,
                    ),
                  ),
                ),
                items: exams.map((exam) {
                  final id = exam['id'] as int;
                  final name = (exam['exam_name'] ?? '').toString();
                  final year = (exam['education_year'] ?? '').toString();
                  final label = year.isNotEmpty ? '$name ($year)' : name;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  final matched = exams.firstWhere(
                    (e) => e['id'] == val,
                    orElse: () => <String, dynamic>{},
                  );
                  final name = (matched['exam_name'] ?? '').toString();
                  final year = (matched['education_year'] ?? '').toString();
                  setState(() {
                    _selectedExamId = val;
                    _selectedExamName =
                        year.isNotEmpty ? '$name ($year)' : name;
                  });
                  _triggerFetchIfReady();
                },
              );
            },
          ),
          const SizedBox(height: 14),

          // 2. Exam Title Selection
          const Text(
            'Exam Title *',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<ExamTimetableProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingTitles && provider.examTitles.isEmpty) {
                return const SizedBox(
                  height: 38,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final titles = provider.examTitles;
              if (titles.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'No exam titles available',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            provider.fetchExamTitles(forGuardian: true),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00897B),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: titles.map((title) {
                  final isSelected = _selectedTitle == title;
                  return ChoiceChip(
                    label: Text(title),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFF00897B),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF00897B)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedTitle = title;
                      });
                      _triggerFetchIfReady();
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHeaderBanner(List<ExamTimetableItem> items) {
    final firstItem = items.first;
    final lastItem = items.last;
    final examTitle = firstItem.exam?.examName.isNotEmpty == true
        ? '${firstItem.exam!.examName}${firstItem.exam!.educationYear.isNotEmpty ? ' (${firstItem.exam!.educationYear})' : ''}'
        : (_selectedExamName ?? 'Exam Schedule');

    final dateRangeText = items.length == 1
        ? firstItem.formattedDate
        : '${firstItem.formattedDate} - ${lastItem.formattedDate}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  firstItem.standardDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF35C2C1).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedTitle ?? firstItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length} ${items.length == 1 ? 'Exam' : 'Exams'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            examTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                LucideIcons.calendarRange,
                size: 14,
                color: Color(0xFFCCFBF1),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateRangeText,
                  style: const TextStyle(
                    color: Color(0xFFCCFBF1),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isTableView = !_isTableView;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isTableView
                            ? LucideIcons.layoutList
                            : LucideIcons.table,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isTableView ? 'Cards' : 'Table',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineScheduleList(List<ExamTimetableItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildExamScheduleCard(item, index);
      },
    );
  }

  Widget _buildExamScheduleCard(ExamTimetableItem item, int index) {
    final subjectName = item.subject?.subjectName.isNotEmpty == true
        ? item.subject!.subjectName
        : 'Subject #${item.subjectId}';
    final statusText = item.status.isNotEmpty
        ? '${item.status[0].toUpperCase()}${item.status.substring(1)}'
        : 'Scheduled';
    final isScheduled = item.status.toLowerCase() == 'scheduled';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date column badge on the left
            Container(
              width: 74,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.weekdayShort.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.dayNumber,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF134E4A),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.monthShort,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: const Color(0xFFE2E8F0)),
            // Details column on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            subjectName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isScheduled
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isScheduled
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildInfoChip(
                          icon: LucideIcons.clock,
                          text: item.startTime.isNotEmpty
                              ? item.startTime
                              : 'TBA',
                        ),
                        _buildInfoChip(
                          icon: LucideIcons.hourglass,
                          text: item.formattedDuration,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.award,
                                  size: 14,
                                  color: Color(0xFF0284C7),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Max: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: item.cleanMaxMarks,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: const Color(0xFFE2E8F0),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.circleCheck,
                                  size: 14,
                                  color: Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Pass: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: item.cleanPassMarks,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.instructions != null &&
                        item.instructions!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              LucideIcons.info,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.instructions!.trim(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildClassicTableSchedule(List<ExamTimetableItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: const Color(0xFFF1F5F9),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Date & Day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Marks\n(Max/Pass)',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final subjectName = item.subject?.subjectName.isNotEmpty == true
                ? item.subject!.subjectName
                : 'Subject #${item.subjectId}';
            final isEven = index.isEven;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: isEven ? Colors.white : const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.formattedDate,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (item.weekdayFull.isNotEmpty)
                          Text(
                            item.weekdayFull,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        subjectName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.startTime.isNotEmpty ? item.startTime : 'TBA',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${item.durationMinutes} mins',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.cleanMaxMarks} / ${item.cleanPassMarks}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00897B)),
            SizedBox(height: 14),
            Text(
              'Loading exam timetable...',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialPromptState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.calendarSearch,
                size: 36,
                color: Color(0xFF00897B),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'View Exam Timetable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a Term and Exam Title above to view the student\'s exam schedule.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.calendarX2,
                size: 36,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Exam Timetable Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No exams are scheduled (${_selectedTitle ?? ''}) under the selected term.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _triggerFetchIfReady,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

