import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/features/parent_notes/presentation/screens/student_parent_note_details_screen.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentParentNotesScreenArgs {
  final int studentId;
  final String? studentName;

  const StudentParentNotesScreenArgs({
    required this.studentId,
    this.studentName,
  });
}

class StudentParentNotesListingScreen extends StatefulWidget {
  final int studentId;
  final String? studentName;

  const StudentParentNotesListingScreen({
    super.key,
    required this.studentId,
    this.studentName,
  });

  @override
  State<StudentParentNotesListingScreen> createState() =>
      _StudentParentNotesListingScreenState();
}

class _StudentParentNotesListingScreenState
    extends State<StudentParentNotesListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late ParentNotesProvider _provider;
  late int _activeStudentId;
  String? _activeStudentName;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ParentNotesProvider>();
    _activeStudentId = widget.studentId;
    _activeStudentName = widget.studentName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotesAndUnseenCounts();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_provider.isLoadingStudentNotes &&
        _provider.hasMoreStudentNotes) {
      _provider.fetchParentNotesByStudentId(
        studentId: _activeStudentId,
        loadMore: true,
      );
    }
  }

  Future<void> _loadNotesAndUnseenCounts() async {
    final parentProvider = context.read<ParentProvider>();
    final studentIds = parentProvider.students.map((s) => s.id).toList();
    if (!studentIds.contains(_activeStudentId)) {
      studentIds.add(_activeStudentId);
    }

    await Future.wait([
      _provider.fetchParentNotesByStudentId(
        studentId: _activeStudentId,
        forceRefresh: true,
      ),
      _provider.fetchUnseenCountsForStudents(studentIds),
    ]);
  }

  void _switchStudent(int newStudentId, String newStudentName) {
    if (_activeStudentId == newStudentId) return;
    setState(() {
      _activeStudentId = newStudentId;
      _activeStudentName = newStudentName;
    });
    _provider.fetchParentNotesByStudentId(
      studentId: _activeStudentId,
      forceRefresh: true,
      clearExisting: true,
    );
    _provider.getUnseenParentNoteCountByStudentId(studentId: _activeStudentId);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildStudentSelectorBanner() {
    return Consumer2<ParentProvider, ParentNotesProvider>(
      builder: (context, parentProvider, notesProvider, _) {
        final students = parentProvider.students;
        if (students.isEmpty) return const SizedBox.shrink();

        if (students.length == 1) {
          final student = students.first;
          final className = student.classGrade?.classname;
          final unseenCount = notesProvider.getUnseenNoteCount(student.id);

          return Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: Text(
                    student.fullName.isNotEmpty
                        ? student.fullName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Color(0xFF2EAF3B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(student.fullName),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (className != null && className.isNotEmpty)
                        Text(
                          "Class: $className",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (unseenCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Text(
                      "$unseenCount Unseen",
                      style: const TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        // Multiple students horizontal selector chips
        return Container(
          height: 54,
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final student = students[index];
              final isSelected = student.id == _activeStudentId;
              final unseenCount = notesProvider.getUnseenNoteCount(student.id);

              return GestureDetector(
                onTap: () => _switchStudent(student.id, student.fullName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2EAF3B) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF2EAF3B)
                              : const Color(0xFFE2E8F0),
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: const Color(0xFF2EAF3B).withAlpha(50),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                            : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            isSelected
                                ? Colors.white.withAlpha(55)
                                : const Color(0xFFE8F5E9),
                        child: Text(
                          student.fullName.isNotEmpty
                              ? student.fullName[0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF2EAF3B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        capitalizeEachWord(student.fullName),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                      if (unseenCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unseenCount.toString(),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? const Color(0xFF2EAF3B)
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoteCard(ParentNoteModel note) {
    final isSeen = note.isSeenByStudent;
    final hasAttachment =
        note.noteAttachment != null && note.noteAttachment!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await context.pushNamed(
              RouteConstants.studentParentNoteDetailsScreen,
              extra: StudentParentNoteDetailArgs(
                note: note,
                studentId: _activeStudentId,
              ),
            );
            if (mounted) {
              _provider.getUnseenParentNoteCountByStudentId(
                studentId: _activeStudentId,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSeen
                        ? Colors.grey.shade200
                        : const Color(0xFF2EAF3B).withAlpha(90),
                width: isSeen ? 1 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCEFFD3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.fileText,
                    color: Color(0xFF2EAF3B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              capitalizeEachWord(
                                note.noteTitle ?? "Parent Note",
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isSeen)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "New",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2EAF3B),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.noteContent ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (note.createdAt != null) ...[
                            Icon(
                              LucideIcons.clock,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.formatDateTime(note.createdAt!),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (hasAttachment) ...[
                            const Spacer(),
                            Icon(
                              LucideIcons.paperclip,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "Attachment",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonAppBar(title: "Parent Notes", isBackButton: true),
      body: Column(
        children: [
          _buildStudentSelectorBanner(),
          Expanded(
            child: Consumer<ParentNotesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingStudentNotes &&
                    provider.studentNotes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: commonShimmerList(),
                  );
                }

                if (provider.studentNotes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _loadNotesAndUnseenCounts,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // SizedBox(height: Responsive.height * 18),
                        emptyScreen(
                          message:
                              _activeStudentName != null &&
                                      _activeStudentName!.isNotEmpty
                                  ? "No Parent Notes for ${capitalizeEachWord(_activeStudentName!)}"
                                  : "No Parent Notes Available",
                        ),
                      ],
                    ),
                  );
                }

                final todayNotes = provider.todayStudentNotes;
                final yesterdayNotes = provider.yesterdayStudentNotes;
                final earlierNotes = provider.earlierStudentNotes;

                final hasGrouped =
                    todayNotes.isNotEmpty ||
                    yesterdayNotes.isNotEmpty ||
                    earlierNotes.isNotEmpty;

                return RefreshIndicator(
                  onRefresh: _loadNotesAndUnseenCounts,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 40, top: 8),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      if (hasGrouped) ...[
                        if (todayNotes.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              "Today",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...todayNotes.map(_buildNoteCard),
                        ],
                        if (yesterdayNotes.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              "Yesterday",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...yesterdayNotes.map(_buildNoteCard),
                        ],
                        if (earlierNotes.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              "Earlier",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...earlierNotes.map(_buildNoteCard),
                        ],
                      ] else ...[
                        ...provider.studentNotes.map(_buildNoteCard),
                      ],
                      if (provider.isLoadingStudentNotes)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
