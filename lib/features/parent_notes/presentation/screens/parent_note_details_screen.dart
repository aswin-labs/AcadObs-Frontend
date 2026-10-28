import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/features/parent_notes/presentation/widgets/edit_parent_note_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class ParentNoteDetailsScreen extends StatefulWidget {
  final ParentNoteModel note;
  const ParentNoteDetailsScreen({super.key, required this.note});

  @override
  State<ParentNoteDetailsScreen> createState() =>
      _ParentNoteDetailsScreenState();
}

class _ParentNoteDetailsScreenState extends State<ParentNoteDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.note.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ParentNotesProvider>().fetchSingleParentNote(
            noteId: widget.note.id!,
          );
        }
      });
    }
  }

  Widget _buildStudentTile(ParentNoteStudentModel studentItem) {
    final student = studentItem.student;
    final isSeen = studentItem.isSeen ?? false;
    final fullName = student?.fullName?.trim() ?? "Unknown Student";
    final regNo = student?.regNo;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSeen ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : "S",
                style: TextStyle(
                  color: isSeen ? const Color(0xFF2EAF3B) : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and RegNo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),

          // Seen/Unseen Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSeen ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSeen
                        ? const Color(0xFF2EAF3B).withAlpha(80)
                        : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSeen ? LucideIcons.checkCheck : LucideIcons.check,
                  size: 13,
                  color:
                      isSeen ? const Color(0xFF2EAF3B) : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  isSeen ? "Seen" : "Unseen",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isSeen ? const Color(0xFF2EAF3B) : Colors.grey.shade600,
                  ),
                ),
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
        final note = provider.singleNote ?? widget.note;
        final isLoading =
            provider.isLoadingSingleNote && provider.singleNote == null;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: CommonAppBar(
            title: capitalizeEachWord(note.noteTitle ?? "Note Details"),
            isBackButton: true,
            actions: [
              if (note.id != null)
                CustomPopupMenu(
                  showEdit: true,
                  onEdit: () {
                    showEditParentNoteBottomSheet(context: context, note: note);
                  },
                  onDelete: () {
                    showConfirmationDialog(
                      context: context,
                      title: 'Delete Note',
                      content:
                          'Are you sure you want to delete this parent note?',
                      onConfirm: () async {
                        Navigator.of(context).pop();

                        final success = await context
                            .read<ParentNotesProvider>()
                            .deleteParentNote(
                              context: context,
                              noteId: note.id!,
                            );

                        if (!context.mounted) return;

                        if (success) {
                          CustomSnackbar.show(
                            context,
                            message: "Parent note deleted successfully",
                            type: SnackbarType.success,
                          );
                          Navigator.pop(context);
                        } else {
                          CustomErrorDialog.show(
                            context,
                            "Failed to delete note",
                          );
                        }
                      },
                    );
                  },
                ),
            ],
          ),
          body:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2EAF3B)),
                  )
                  : RefreshIndicator(
                    onRefresh: () async {
                      if (note.id != null) {
                        await provider.fetchSingleParentNote(noteId: note.id!);
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
                              Container(
                                padding: const EdgeInsets.all(16),
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
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCEFFD3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        LucideIcons.file,
                                        color: Color(0xFF2EAF3B),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.noteAttachment!
                                                .split('/')
                                                .last,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Attached Document",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Assigned Students Section
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Assigned Students",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (note.parentNoteStudents != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${note.seenCount}/${note.studentCount} Seen",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2EAF3B),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (note.parentNoteStudents == null ||
                                note.parentNoteStudents!.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "No students assigned to this note",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...note.parentNoteStudents!.map(
                                _buildStudentTile,
                              ),

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
