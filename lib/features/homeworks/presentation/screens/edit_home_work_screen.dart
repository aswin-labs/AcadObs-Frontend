import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/homeworks/data/models/homework_model.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/features/subjects/presentation/widgets/subject_picker.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class EditHomeWorkScreen extends StatefulWidget {
  final HomeworkModel homework;
  const EditHomeWorkScreen({super.key, required this.homework});

  @override
  State<EditHomeWorkScreen> createState() => _EditHomeWorkScreenState();
}

class _EditHomeWorkScreenState extends State<EditHomeWorkScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  TextEditingController dateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.homework.title);
    descriptionController = TextEditingController(
      text: widget.homework.description,
    );
    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.homework.dueDate ?? DateTime.now());
    final existingHomeworkType = widget.homework.type;
    log("existing type:$existingHomeworkType");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppConstants.homeworkTypes.contains(existingHomeworkType)) {
        context.read<DropdownProvider>().setSelectedItem(
          'homeworkType',
          existingHomeworkType ?? 'offline',
        );
      }
      context.read<FilePickerProvider>().clearFile('homeworkFile');
      context.read<SubjectProvider>().clearSelection();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacer = SizedBox(height: Responsive.height * 2);

    return Scaffold(
      appBar: CommonAppBar(title: 'Edit Homework', isBackButton: true),
      body: Form(
        key: formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit Details:",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    spacer,

                    CustomTextfield(
                      label: "title",
                      iconData: Icon(Icons.title),
                      controller: titleController,
                      validator: FormValidator.validateNotEmpty,
                    ),
                    spacer,
                    CustomTextfield(
                      label: 'description',
                      iconData: Icon(Icons.description),
                      controller: descriptionController,
                      validator: FormValidator.validateNotEmpty,
                    ),
                    spacer,
                    SubjectPicker(
                      initialSubject: widget.homework.subject,
                      isSubjectRequired: false,
                    ),
                    spacer,
                    CustomDropdown(
                      dropdownKey: "homeworkType",
                      label: "Homework Type*",
                      icon: LucideIcons.clipboardList,
                      items: AppConstants.homeworkTypes,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please select type'
                                  : null,
                      onChanged: (homeworkType) {
                        context.read<DropdownProvider>().setSelectedItem(
                          "homeworkType",
                          homeworkType,
                        );
                      },
                    ),
                    spacer,
                    CustomDatePicker(
                      label: "Due Date*",
                      dateController: dateController,
                      onDateSelected: (selectedDate) {
                        dateController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(selectedDate);
                      },
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                      validator: (value) {
                        return FormValidator.validateNotEmpty(value);
                      },
                    ),
                    spacer,
                    CustomFilePicker(
                      label: "Upload File (Max 5 mb):",
                      fieldName: "homeworkFile",
                      validator: (value) {
                        final error = context
                            .read<FilePickerProvider>()
                            .getError("homeworkFile");
                        return error;
                      },
                    ),
                    spacer,
                    spacer,
                    SizedBox(
                      height: Responsive.height * 7,
                      width: Responsive.width * 50,
                      child: Consumer2<HomeworksProvider, SubjectProvider>(
                        builder: (
                          context,
                          homeworkProvider,
                          subjectProvider,
                          _,
                        ) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(2),
                            ),
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                final homeworkType = context
                                    .read<DropdownProvider>()
                                    .getSelectedItem('homeworkType');
                                homeworkProvider.edithomeWork(
                                  context: context,
                                  subjectId:
                                      subjectProvider.selectedSubject?.id ?? 0,
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  duedate: dateController.text,

                                  homeworkId: widget.homework.id ?? 0,
                                  homeworkType: homeworkType,
                                );
                              }
                            },
                            child:
                                homeworkProvider.isLoading
                                    ? ButtonLoading()
                                    : Text("Update"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
