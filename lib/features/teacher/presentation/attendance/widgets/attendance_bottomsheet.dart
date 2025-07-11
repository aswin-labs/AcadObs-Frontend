import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_upload_model.dart';
import 'package:acadobs/features/teacher/presentation/subjects/provider/subject_provider.dart';
import 'package:acadobs/features/teacher/presentation/subjects/widgets/subject_selection_dialog.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

void showAttendanceBottomSheet(BuildContext context) {
  final TextEditingController dateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final subjectProvider = context.read<SubjectProvider>();
  subjectProvider.clearSelection();
  dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  context.read<DropdownProvider>().clearSelectedItem('standard');
  context.read<DropdownProvider>().clearSelectedItem('className');
  context.read<DropdownProvider>().clearSelectedItem('period');
  context.read<SharedProvider>().resetClassNames();
  int? classId;
  String? className;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Mark Attendance",
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.height * 2),
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
                // SizedBox(height: Responsive.height * 1),
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
                                className = selectedClass;
                                classId =
                                    classMapList.firstWhere(
                                      (item) =>
                                          item['classname'] == selectedClass,
                                      orElse: () => {'id': null},
                                    )['id'];
                              },
                            ),
                          );
                    }
                  },
                ),

                SizedBox(height: Responsive.height * 1),
                CustomDropdown(
                  dropdownKey: 'period',
                  label: 'Select Period*',
                  icon: LucideIcons.clock,
                  items: AppConstants.periods,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select a period'
                              : null,
                ),
                SizedBox(height: Responsive.height * 1),
                Consumer<SubjectProvider>(
                  builder: (context, subjectProvider, _) {
                    return GestureDetector(
                      onTap: () => showSubjectSelectionDialog(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            color:
                                subjectProvider.selectedSubject?.subjectName ==
                                        null
                                    ? Colors.grey
                                    : Colors.black87,
                            fontSize: 14.0,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Subject*',
                            labelStyle: context.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.book),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                subjectProvider.selectedSubject?.subjectName ??
                                'Select Subject',
                          ),
                          validator:
                              (value) =>
                                  subjectProvider.selectedSubject == null
                                      ? 'Please select a subject'
                                      : null,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDatePicker(
                  label: "Date*",
                  dateController: dateController,
                  onDateSelected: (selectedDate) {
                    dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(selectedDate);
                  },
                ),
                SizedBox(height: Responsive.height * 3),
                CommonButton(
                  onPressed: () {
                    final period = context
                        .read<DropdownProvider>()
                        .getSelectedItem('period');
                    final subject =
                        context.read<SubjectProvider>().selectedSubject;
                    if (formKey.currentState?.validate() ?? false) {
                      if (className == null) {
                        ScaffoldMessenger.of(
                          Navigator.of(context, rootNavigator: true).context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text("Please select a class"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        context.pushNamed(
                          RouteConstants.attendanceTaking,
                          extra: AttendanceUploadModel(
                            classId: classId!,
                            date: dateController.text,
                            className: className!,
                            period: int.parse(period),
                            subjectId: subject?.id,
                            subjectName: subject?.subjectName,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  widget: Text("Take Attendance"),
                ),
                SizedBox(height: Responsive.height * 3),
              ],
            ),
          ),
        ),
      );
    },
  );
}
