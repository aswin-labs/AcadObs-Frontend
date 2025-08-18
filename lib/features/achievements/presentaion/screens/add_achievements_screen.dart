import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/achievements/provider/acheivement_provider.dart';
// import 'package:acadobs/features/achievements/models/student_section_model.dart';
import 'package:acadobs/features/achievements/widget/student_picker_manage.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
// import 'package:acadobs/shared/widgets/students_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AddAchievementsScreen extends StatefulWidget {
  const AddAchievementsScreen({super.key});

  @override
  State<AddAchievementsScreen> createState() => _AddAchievementsScreenState();
}

class _AddAchievementsScreenState extends State<AddAchievementsScreen> {
  late DropdownProvider dropdownProvider;
  late StudentProvider studentProvider;
  List<int> studentSections = [0];
  List<List<int>> selectedStudentsPerSection = [[]];
  List<int?> classIdsPerSection = [null];

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController awardingBodyController;
  List<TextEditingController> remarksControllers = [];

  @override
  void initState() {
    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    awardingBodyController = TextEditingController();
    remarksControllers = [TextEditingController()];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.clearSelectedItem("standard");
      dropdownProvider.clearSelectedItem("className");
      dropdownProvider.clearSelectedItem("category");
      dropdownProvider.clearSelectedItem("level");
      dropdownProvider.clearSelectedItem("status");

      studentProvider.deselectAllStudents();
    });
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    awardingBodyController.dispose();
    for (var controller in remarksControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: CommonAppBar(title: "Add Achievements", isBackButton: true),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Achievement Details:",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomTextfield(
                      iconData: Icon(LucideIcons.fileText),
                      controller: titleController,
                      hintText: 'Title',
                      label: "Title",
                      validator: FormValidator.validateNotEmpty,
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomTextfield(
                      iconData: Icon(LucideIcons.stickyNote),
                      controller: descriptionController,
                      hintText: 'Description',
                      label: "Description",
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomDropdown(
                      dropdownKey: 'category',
                      label: "Category",
                      icon: LucideIcons.clock,
                      items: AppConstants.achievementCategories,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please select a category'
                                  : null,
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomDropdown(
                      dropdownKey: 'level',
                      label: "Level",
                      icon: LucideIcons.receipt,
                      items: AppConstants.achievementLevels,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please select a level'
                                  : null,
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomDatePicker(
                      label: "Date*",
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
                    SizedBox(height: Responsive.height * 2),
                    CustomTextfield(
                      iconData: Icon(LucideIcons.type),
                      controller: awardingBodyController,
                      hintText: 'Awarding body',
                      label: "Awarding body",
                    ),
                    SizedBox(height: Responsive.height * 2),
                    Text(
                      "Add Students:",
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.height * 2),

                    // Dynamic student sections
                    Column(
                      children:
                          studentSections.map((sectionIndex) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // STANDARD
                                      CustomDropdown(
                                        dropdownKey: 'standard_$sectionIndex',
                                        label: 'Select Standard*',
                                        icon: LucideIcons.layers,
                                        items: AppConstants.classGrades,
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Please select a class standard'
                                                    : null,
                                        onChanged: (standard) {
                                          context
                                              .read<SharedProvider>()
                                              .getClassNameFromStandard(
                                                context: context,
                                                standard: int.parse(standard),
                                              );
                                        },
                                      ),

                                      // CLASS
                                      Consumer<SharedProvider>(
                                        builder: (context, provider, _) {
                                          List<Map<String, dynamic>>
                                          classMapList = provider.classNames;
                                          List<String> onlyClassNames =
                                              classMapList
                                                  .map(
                                                    (item) =>
                                                        item['classname']
                                                            .toString(),
                                                  )
                                                  .toList();

                                          if (provider.isLoading) {
                                            return CircularProgressIndicator();
                                          } else if (provider.isClassesEmpty) {
                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                "No Classes Available",
                                                style: context
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
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
                                                    dropdownKey:
                                                        'className_$sectionIndex',
                                                    label: 'Select Class*',
                                                    icon: LucideIcons.school,
                                                    items: onlyClassNames,
                                                    validator:
                                                        (value) =>
                                                            value == null ||
                                                                    value
                                                                        .isEmpty
                                                                ? 'Please select a class'
                                                                : null,
                                                    onChanged: (selectedClass) {
                                                      final selectedId =
                                                          classMapList.firstWhere(
                                                            (item) =>
                                                                item['classname'] ==
                                                                selectedClass,
                                                            orElse:
                                                                () => {
                                                                  'id': null,
                                                                },
                                                          )['id'];
                                                      provider.setClassId(
                                                        selectedId,
                                                      );
                                                    },
                                                  ),
                                                );
                                          }
                                        },
                                      ),
                                      SizedBox(height: Responsive.height * 2),

                                      // STUDENT PICKER
                                      Consumer<SharedProvider>(
                                        builder: (context, studentProvider, _) {
                                          final classId =
                                              context
                                                  .watch<SharedProvider>()
                                                  .classId;
                                          return StudentPickerManage(
                                            classId: classId ?? 0,
                                            selectAllNeeded: false,
                                            onStudentsSelected: (List<int> selectedIds){
                                                setState(() {
                                                  selectedStudentsPerSection[sectionIndex] = selectedIds;
                                                });
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(height: Responsive.height * 2),

                                      // STATUS
                                      CustomDropdown(
                                        dropdownKey: 'status_$sectionIndex',
                                        label: "Achievement Status",
                                        icon: LucideIcons.clock,
                                        items: AppConstants.achievementStatuses,
                                      ),
                                      SizedBox(height: Responsive.height * 2),

                                      // REMARK
                                      CustomTextfield(
                                        iconData: Icon(LucideIcons.type),
                                        controller:
                                            remarksControllers[sectionIndex],
                                        hintText: 'Remark',
                                        label: "Remark",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: Responsive.height * 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          studentSections.add(studentSections.length);
                          selectedStudentsPerSection.add(
                            <int>[],
                          ); // 👈 add empty selection list
                          classIdsPerSection.add(
                            null,
                          ); // 👈 add placeholder classId
                          remarksControllers.add(TextEditingController());
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("Add Student "), Icon(Icons.add)],
                        ),
                      ),
                    ),
                    SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, provider, _) {
          return CommonFloatingActionButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final dropdown = context.read<DropdownProvider>();
                final String category = dropdown.getSelectedItem('category');
                final String level = dropdown.getSelectedItem('level');

                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();
                final String date = dateController.text;
                final String awardngBody = awardingBodyController.text.trim();

                List<Map<String, dynamic>> studentsData = [];
                for (int i = 0; i < studentSections.length; i++) {
                  final String status = dropdown.getSelectedItem('status_$i');
                  final String remark = remarksControllers[i].text.trim();
                  final List<int> students = selectedStudentsPerSection[i];

                  if (students.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please select at least one student in section ${i + 1}',
                        ),
                      ),
                    );
                    return;
                  }
                  for (var studentId in students) {
                    studentsData.add({
                      "student_id": studentId,
                      "status": status,
                      "remark": remark,
                    });
                  }
                }
                if (studentsData.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add at least one student section')),
                  );
                  return;
                }
                final achievementProvider = context.read<AchievementProvider>();
                await achievementProvider.createAchievement(
                  context: context,
                  title: title,
                  description: description,
                  category: category,
                  level: level,
                  date: date,
                  awardingBody: awardngBody,
                  // studentSections: studentSectionsData,
                  students: studentsData,
                );
              }
            },
            text: "submit",
          );
        },
      ),
    );
  }
}
