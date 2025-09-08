import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/teacher/presentation/notes/provider/parent_note_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
// import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:acadobs/shared/widgets/students_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AddTeacherNoteScreen extends StatelessWidget {
  const AddTeacherNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    context.read<DropdownProvider>().clearSelectedItem('standard');
    context.read<DropdownProvider>().clearSelectedItem('className');
    return Scaffold(
      appBar: CommonAppBar(title: "Add New Parent Note", isBackButton: true),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(LucideIcons.fileText),
                  controller: titleController,
                  hintText: 'Note Title*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 2),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: TextStyle(color: Colors.black54),

                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: 20),
                CustomFilePicker(
                  label: "Documents",
                  fieldName: "parentNoteFile",
                ),
                SizedBox(height: 10),
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
                    context.read<SharedProvider>().getClassNameFromStandard(
                      context: context,
                      standard: int.parse(standard),
                    );
                  },
                ),
                Consumer<SharedProvider>(
                  builder: (context, provider, _) {
                    List<Map<String, dynamic>> classMapList =
                        provider.classNames;
                    List<String> onlyClassNames =
                        classMapList
                            .map((item) => item['classname'].toString())
                            .toList();
                    if (provider.isLoading) {
                      return CircularProgressIndicator();
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
                          ? SizedBox.shrink()
                          : Padding(
                            padding: EdgeInsets.only(
                              top: Responsive.height * 1,
                            ),
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
                SizedBox(height: 10),
                Consumer2<StudentProvider, SharedProvider>(
                  builder: (context, studentProvider, sharedProvider, _) {
                    return StudentsPicker(classId: sharedProvider.classId ?? 0);
                  },
                ),

                SizedBox(height: 30),

                Consumer<ParentNoteProvider>(
                  builder: (context, provider, _) {
                    return CommonButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await provider.createParentNote(
                            context: context,
                            title: titleController.text.trim(),
                            content: descriptionController.text.trim(),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(" Submission failed"),
                            ),
                          );
                        }
                      },
                      widget: Text("Send Note"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
