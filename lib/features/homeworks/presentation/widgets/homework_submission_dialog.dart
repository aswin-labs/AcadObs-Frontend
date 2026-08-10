import 'dart:ui';

import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeworkSubmissionDialog extends StatefulWidget {
  final String homeworkTitle;
  final int studentHomeworkId;
  final int homeworkId;
  final int studentId;

  const HomeworkSubmissionDialog({
    super.key,
    required this.homeworkTitle,
    required this.studentHomeworkId,
    required this.studentId,
    required this.homeworkId,
  });

  @override
  State<HomeworkSubmissionDialog> createState() =>
      _HomeworkSubmissionDialogState();
}

class _HomeworkSubmissionDialogState extends State<HomeworkSubmissionDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FilePickerProvider>().clearFile('assignmentFile');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final TextEditingController remarkController = TextEditingController();

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withAlpha(70)),
          ),
        ),

        AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 20,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.homeworkTitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  "Add file or remark",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Attachment",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),

                      const SizedBox(height: 6),

                      CustomFilePicker(
                        label: "Upload File (Max 5 mb):",
                        fieldName: "assignmentFile",
                        validator: (value) {
                          final error = context
                              .read<FilePickerProvider>()
                              .getError("assignmentFile");
                          return error;
                        },
                      ),
                      const SizedBox(height: 12),

                      // const Text(
                      //   "Remark",
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w600,
                      //     color: Color(0xFF374151),
                      //   ),
                      // ),

                      // const SizedBox(height: 6),

                      // TextFormField(
                      //   controller: remarkController,
                      //   minLines: 2,
                      //   maxLines: 2,
                      //   textCapitalization: TextCapitalization.sentences,
                      //   decoration: InputDecoration(
                      //     hintText: "Add a remark (optional)",
                      //     hintStyle: const TextStyle(
                      //       color: Color(0xFF9CA3AF),
                      //       fontSize: 13,
                      //     ),
                      //     filled: true,
                      //     fillColor: const Color(0xFFF9FAFB),
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: 12,
                      //       vertical: 10,
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //       borderSide: const BorderSide(
                      //         color: Color(0xFFE5E7EB),
                      //       ),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //       borderSide: const BorderSide(
                      //         color: Color(0xFF6366F1),
                      //         width: 1.5,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // const SizedBox(height: 14),
                      Consumer<HomeworksProvider>(
                        builder: (context, provider, _) {
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () {
                                      FocusScope.of(context).unfocus();

                                      // final remark =
                                      //     remarkController.text;

                                      provider.uploadFileAndRemarksByGuardian(
                                        context: context,
                                        studentId: widget.studentId,
                                        studentHomeworkId:
                                            widget.studentHomeworkId,
                                        homeworkId: widget.homeworkId,
                                        // remarks: remark,
                                      );
                                    },
                            icon:
                                provider.isLoading
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                      Icons.upload_rounded,
                                      size: 18,
                                    ),
                            label:
                                provider.isLoading
                                    ? const ButtonLoading()
                                    : const Text(
                                      "Submit",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
