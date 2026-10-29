import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentParentNoteDetailArgs {
  final ParentNoteModel note;
  final int studentId;

  const StudentParentNoteDetailArgs({
    required this.note,
    required this.studentId,
  });
}

class StudentParentNoteDetailsScreen extends StatefulWidget {
  final ParentNoteModel note;
  final int studentId;

  const StudentParentNoteDetailsScreen({
    super.key,
    required this.note,
    required this.studentId,
  });

  @override
  State<StudentParentNoteDetailsScreen> createState() =>
      _StudentParentNoteDetailsScreenState();
}

class _StudentParentNoteDetailsScreenState
    extends State<StudentParentNoteDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.note.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ParentNotesProvider>().fetchSingleParentNoteByStudentId(
            noteId: widget.note.id!,
            studentId: widget.studentId,
          );
        }
      });
    }
  }

  Widget _buildStudentInfoCard(ParentNoteStudentModel studentItem) {
    final student = studentItem.student;
    if (student == null ||
        (student.fullName == null || student.fullName!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final fullName = student.fullName!.trim();
    final regNo = student.regNo;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : "S",
                style: const TextStyle(
                  color: Color(0xFF2EAF3B),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeEachWord(fullName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (regNo != null && regNo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    "Reg No: $regNo",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentNotesProvider>(
      builder: (context, provider, _) {
        final note = provider.singleStudentNote ?? widget.note;
        final isLoading =
            provider.isLoadingSingleStudentNote &&
            provider.singleStudentNote == null;

        final studentNoteEntry =
            (note.parentNoteStudents != null &&
                    note.parentNoteStudents!.isNotEmpty)
                ? note.parentNoteStudents!.first
                : null;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: CommonAppBar(
            title: capitalizeEachWord(note.noteTitle ?? "Note Details"),
            isBackButton: true,
          ),
          body:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2EAF3B)),
                  )
                  : RefreshIndicator(
                    onRefresh: () async {
                      if (note.id != null) {
                        await provider.fetchSingleParentNoteByStudentId(
                          noteId: note.id!,
                          studentId: widget.studentId,
                        );
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero Image / Icon Card
                            Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFCEFFD3),
                                    Color(0xFFB8F5BE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF5DD168,
                                    ).withAlpha(45),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(80),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.fileText,
                                    color: Color(0xFF2EAF3B),
                                    size: 56,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Student Info Card (if Student details present from detail API)
                            if (studentNoteEntry != null &&
                                studentNoteEntry.student != null)
                              _buildStudentInfoCard(studentNoteEntry),

                            // Title Section
                            Text(
                              capitalizeEachWord(note.noteTitle ?? ""),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                letterSpacing: -0.4,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),

                            // Date & Time
                            if (note.createdAt != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.clock,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormatter.formatDateTime(
                                      note.createdAt!,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.grey.shade100,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Content Label
                            Text(
                              "Content",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Content Section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(7),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                note.noteContent ?? "",
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            // Attachment Section
                            if (note.noteAttachment != null &&
                                note.noteAttachment!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                "Attachment",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DownloadFileCard(fileName: note.noteAttachment!),
                            ],

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }
}

