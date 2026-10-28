import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parent_notes/presentation/provider/parent_notes_provider.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:acadobs/shared/widgets/students_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

void showCreateParentNoteBottomSheet({required BuildContext context}) {
  context.read<SharedProvider>().clearSelectedClassId();
  context.read<DropdownProvider>().clearSelectedItem('standard');
  context.read<DropdownProvider>().clearSelectedItem('className');
  context.read<FilePickerProvider>().clearFile('parentNoteFile');
  context.read<StudentProvider>().deselectAllStudents();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => const _CreateParentNoteBottomSheetContent(),
  );
}

class _CreateParentNoteBottomSheetContent extends StatefulWidget {
  const _CreateParentNoteBottomSheetContent();

  @override
  State<_CreateParentNoteBottomSheetContent> createState() =>
      _CreateParentNoteBottomSheetContentState();
}

class _CreateParentNoteBottomSheetContentState
    extends State<_CreateParentNoteBottomSheetContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Parent Note",
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: Responsive.height * 2),

              // Note Title
              CustomTextfield(
                iconData: const Icon(LucideIcons.fileText),
                controller: _titleController,
                hintText: 'Note Title*',
                validator: (value) {
                  return FormValidator.validateNotEmpty(value);
                },
              ),
              SizedBox(height: Responsive.height * 1),

              // Note Content
              CustomTextfield(
                iconData: const Icon(LucideIcons.fileText),
                maxLines: 4,
                controller: _contentController,
                hintText: 'Note Content*',
                validator: (value) {
                  return FormValidator.validateNotEmpty(value);
                },
              ),
              SizedBox(height: Responsive.height * 1),

              // Standard Dropdown
              CustomDropdown(
                dropdownKey: 'standard',
                label: 'Select Standard*',
                icon: LucideIcons.layers,
                items: AppConstants.classGrades,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a class standard'
                            : null,
                onChanged: (standard) {
                  final standardValue = switch (standard) {
                    'LKG' => -2,
                    'UKG' => -1,
                    _ => int.parse(standard),
                  };

                  context.read<SharedProvider>().getClassNameFromStandard(
                    context: context,
                    standard: standardValue,
                  );
                },
              ),

              // Class Name Dropdown
              Consumer<SharedProvider>(
                builder: (context, provider, _) {
                  List<Map<String, dynamic>> classMapList = provider.classNames;
                  List<String> onlyClassNames =
                      classMapList
                          .map((item) => item['classname'].toString())
                          .toList();
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  } else if (provider.isClassesEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No Classes Available",
                        style: context.textTheme.bodySmall!.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else {
                    return onlyClassNames.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                          padding: EdgeInsets.only(top: Responsive.height * 1),
                          child: CustomDropdown(
                            dropdownKey: 'className',
                            label: 'Select Class*',
                            icon: LucideIcons.school,
                            items: onlyClassNames,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please select a class'
                                        : null,
                            onChanged: (selectedClass) {
                              final selectedId =
                                  classMapList.firstWhere(
                                    (item) =>
                                        item['classname'] == selectedClass,
                                    orElse: () => {'id': null},
                                  )['id'];
                              provider.setClassId(selectedId);
                            },
                          ),
                        );
                  }
                },
              ),
              SizedBox(height: Responsive.height * 1),

              // Student Picker
              Consumer2<StudentProvider, SharedProvider>(
                builder: (context, studentProvider, sharedProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StudentsPicker(classId: sharedProvider.classId ?? 0),
                      if (studentProvider.selectedStudentIds.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            "${studentProvider.selectedStudentIds.length} student${studentProvider.selectedStudentIds.length > 1 ? 's' : ''} selected",
                            style: const TextStyle(
                              color: Color(0xFF2EAF3B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: Responsive.height * 2),

              // Attachment File Picker
              CustomFilePicker(
                label: "Upload Attachment (Max 5 mb):",
                fieldName: "parentNoteFile",
                validator: (value) {
                  final error = context.read<FilePickerProvider>().getError(
                    "parentNoteFile",
                  );
                  return error;
                },
              ),
              SizedBox(height: Responsive.height * 4),

              // Submit Button
              Consumer<ParentNotesProvider>(
                builder: (context, provider, _) {
                  return CommonButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<ParentNotesProvider>().createParentNote(
                          context: context,
                          title: _titleController.text.trim(),
                          content: _contentController.text.trim(),
                        );
                      }
                    },
                    widget:
                        provider.isLoading
                            ? const ButtonLoading()
                            : const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
