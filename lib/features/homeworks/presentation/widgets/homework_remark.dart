import 'dart:ui';

import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeworkRemark extends StatelessWidget {
  final String name;
  final int homeworkId;

  const HomeworkRemark({
    super.key,
    required this.name,
    required this.homeworkId,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController remarkController = TextEditingController();

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withAlpha(70)),
          ),
        ),

        AnimatedPadding(
          duration: const Duration(milliseconds: 220),
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
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.rate_review_outlined,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Remark",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Write a remark for this student",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 20,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Remark",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: remarkController,
                      maxLines: 4,
                      minLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Enter your remark here...",
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Consumer<HomeworksProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                provider.isLoadingRemarks
                                    ? null
                                    : () {
                                      FocusScope.of(context).unfocus();

                                      provider.addHomeworkRemarks(
                                        context: context,
                                        studentHomeworkId: homeworkId,
                                        remarks: remarkController.text,
                                      );
                                    },
                            icon:
                                provider.isLoadingRemarks
                                    ? const SizedBox.shrink()
                                    : const Icon(Icons.send_rounded, size: 18),
                            label:
                                provider.isLoadingRemarks
                                    ? const ButtonLoading()
                                    : const Text(
                                      "Send Remark",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
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
      ],
    );
  }
}
