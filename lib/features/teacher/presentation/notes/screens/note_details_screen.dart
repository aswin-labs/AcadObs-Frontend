// import 'package:acadobs/core/utils/custom_error_dialog.dart';
// import 'package:acadobs/core/utils/custom_popup_menu.dart';
// import 'package:acadobs/core/utils/custom_snackbar.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
// import 'package:acadobs/features/teacher/data/models/note_model.dart';
// import 'package:acadobs/features/teacher/presentation/notes/provider/parent_note_provider.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:provider/provider.dart';

// class NoteDetailsScreen extends StatefulWidget {
//   final Note note;
//   const NoteDetailsScreen({super.key, required this.note});

//   @override
//   State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
// }

// class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         title: capitalizeEachWord(widget.note.noteTitle ?? " "),
//         isBackButton: true,
//         actions: [
//           Consumer<ParentNoteProvider>(
//             builder: (context, provider, _) {
//               return CustomPopupMenu(
//                 showEdit: false,
//                 onDelete: () {
//                   showConfirmationDialog(
//                     context: context,
//                     title: 'Delete note',
//                     content: 'Do you want to delete the note?',
//                     onConfirm: () async {
//                       Navigator.of(
//                         context,
//                       ).pop(); // close the confirmation dialog first

//                       final ok = await context
//                           .read<ParentNoteProvider>()
//                           .deleteNote(widget.note.id!);

//                       if (!mounted) return;

//                       if (ok) {
//                         if (!context.mounted) return;
//                         CustomSnackbar.show(
//                           context,
//                           message: "Note deleted",
//                           type: SnackbarType.success,
//                         );
//                         Navigator.pop(context); // close the NoteDetailsScreen
//                       } else {
//                         if (!context.mounted) return;
//                         CustomErrorDialog.show(
//                           context,
//                           "Failed to delete note",
//                         );
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: double.infinity,
//               height: 226,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFCEFFD3),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Center(
//                 child: Icon(
//                   LucideIcons.filePlus2,
//                   color: Color(0xFF5DD168),
//                   size: 150,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Row(
//                 children: [
//                   Text(
//                     capitalizeEachWord(widget.note.noteTitle ?? ""),
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                   ),
//                   Spacer(),
//                   // Text(DateFormatter.formatDateString(note.createdAt)),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 capitalizeEachWord(widget.note.noteContent.toString()),
//                 style: TextStyle(color: Color(0xFF949494)),
//               ),
//             ),
//             const SizedBox(height: 40),

//             widget.note.noteAttachment != null
//                 ? Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black26),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.picture_as_pdf_outlined,
//                         color: Colors.black87,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           widget.note.noteAttachment!.split('/').last,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       // InkWell(
//                       //   onTap: () async {
//                       //     final provider = context.read<FileDownloadProvider>();
//                       //     final fileName =
//                       //         widget.note.noteAttachment!.split('/').last;
//                       //     provider.downloadNoticeFile(
//                       //       widget.note.noteAttachment!,
//                       //       fileName,
//                       //     );
//                       //   },

//                       //   child: const Icon(Icons.file_download_outlined),
//                       // ),
//                     ],
//                   ),
//                 )
//                 : const SizedBox(),
//             const SizedBox(height: 8),

//             // Consumer<FileDownloadProvider>(
//             //   builder: (context, provider, _) {
//             //     if (provider.isDownloading) {
//             //       return Column(
//             //         crossAxisAlignment: CrossAxisAlignment.start,
//             //         children: [
//             //           LinearProgressIndicator(value: provider.progress),
//             //           const SizedBox(height: 4),
//             //           Text('${(provider.progress * 100).toStringAsFixed(0)}%'),
//             //         ],
//             //       );
//             //     }
//             //     return const SizedBox();
//             //   },
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/teacher/data/models/note_model.dart';
import 'package:acadobs/features/teacher/presentation/notes/provider/parent_note_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Colors.grey.shade50,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Card
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFCEFFD3), const Color(0xFFB8F5BE)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5DD168).withAlpha(45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(68),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.fileText,
                      color: const Color(0xFF2EAF3B),
                      size: 80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      capitalizeEachWord(widget.note.noteTitle ?? ""),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        letterSpacing: -0.5,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                  // Uncomment when date is available
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade200,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Text(
                  //     DateFormatter.formatDateString(widget.note.createdAt),
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.grey.shade700,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
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
                "Description",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Content Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(7),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  capitalizeEachWord(widget.note.noteContent.toString()),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Attachment Section
              if (widget.note.noteAttachment != null) ...[
                const SizedBox(height: 28),
                Text(
                  "Attachment",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
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
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.note.noteAttachment!.split('/').last,
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
                              "PDF Document",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.download,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
