import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/notices/presentation/provider/file_download_provider.dart';
import 'package:acadobs/features/teacher/data/models/note_model.dart';
import 'package:acadobs/features/teacher/presentation/notes/provider/parent_note_provider.dart';
// import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note note;
  const NoteDetailsScreen({super.key, required this.note});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(widget.note.noteTitle ?? " "),
        isBackButton: true,
        actions: [
          Consumer<ParentNoteProvider>(
            builder: (context, provider, _) {
              return CustomPopupMenu(
                showEdit: false,
                onDelete: () {
                  showConfirmationDialog(
                    context: context,
                    title: 'Delete note',
                    content: 'Do you want to delete the note?',
                    onConfirm: () async {
                      Navigator.of(
                        context,
                      ).pop(); // close the confirmation dialog first

                      final ok = await context
                          .read<ParentNoteProvider>()
                          .deleteNote(widget.note.id!);

                      if (!mounted) return;

                      if (ok) {
                        if (!context.mounted) return;
                        CustomSnackbar.show(
                          context,
                          message: "Note deleted",
                          type: SnackbarType.success,
                        );
                        Navigator.pop(context); // close the NoteDetailsScreen
                      } else {
                        if (!context.mounted) return;
                        CustomErrorDialog.show(
                          context,
                          "Failed to delete note",
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: const Color(0xFFCEFFD3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.filePlus2,
                  color: Color(0xFF5DD168),
                  size: 150,
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    capitalizeEachWord(widget.note.noteTitle ?? ""),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  // Text(DateFormatter.formatDateString(note.createdAt)),
                ],
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                capitalizeEachWord(widget.note.noteContent.toString()),
                style: TextStyle(color: Color(0xFF949494)),
              ),
            ),
            const SizedBox(height: 40),

            widget.note.noteAttachment != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.note.noteAttachment!.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          final provider = context.read<FileDownloadProvider>();
                          final fileName =
                              widget.note.noteAttachment!.split('/').last;
                          provider.downloadNoticeFile(
                            widget.note.noteAttachment!,
                            fileName,
                          );
                        },

                        child: const Icon(Icons.file_download_outlined),
                      ),
                    ],
                  ),
                )
                : const SizedBox(),
            const SizedBox(height: 8),

            Consumer<FileDownloadProvider>(
              builder: (context, provider, _) {
                if (provider.isDownloading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: provider.progress),
                      const SizedBox(height: 4),
                      Text('${(provider.progress * 100).toStringAsFixed(0)}%'),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
