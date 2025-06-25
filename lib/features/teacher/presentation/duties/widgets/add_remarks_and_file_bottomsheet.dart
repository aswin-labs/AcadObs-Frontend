import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/duties/provider/duty_provider.dart';
import 'package:acadobs/presentation/providers/file_picker_provider.dart';
import 'package:acadobs/presentation/widgets/common_button.dart';
import 'package:acadobs/presentation/widgets/custom_filepicker.dart';
import 'package:acadobs/presentation/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

Future<void> showAddRemarksAndFileBottomSheet(
  BuildContext context, {
  required int dutyId,
}) {
  final TextEditingController remarksController = TextEditingController();
  context.read<FilePickerProvider>().clearFile('solved_file');
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Remarks", style: context.textTheme.headlineSmall),
            SizedBox(height: Responsive.height * 2),
            CustomTextfield(
              iconData: Icon(LucideIcons.stickyNote),
              controller: remarksController,
              hintText: 'Enter Remarks',
            ),
            SizedBox(height: Responsive.height * 2),
            CustomFilePicker(
              label: "Upload File (Max 5 mb):",
              fieldName: "solved_file",
            ),
            SizedBox(height: Responsive.height * 4),
            Consumer<DutyProvider>(
              builder: (context, provider, child) {
                return CommonButton(
                  onPressed: () {
                    context.read<DutyProvider>().addDutyRemarksAndFile(
                      context: context,
                      dutyId: dutyId,
                      remarks: remarksController.text,
                    );
                  },
                  widget:
                      provider.isLoadingTwo
                          ? ButtonLoading()
                          : const Text('Save'),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
