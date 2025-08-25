import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/achievements/data/models/avhievement_section.dart';
import 'package:acadobs/features/achievements/presentaion/provider/acheivement_provider.dart';
import 'package:acadobs/features/achievements/presentaion/widgets/single_student_picker.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
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
  List<int?> selectedStudentsPerSection = []; // one student id per section
  List<int?> classIdsPerSection = []; // one class id per section
  List<TextEditingController> remarksControllers = [];
  List<String?> statusPerSection = []; // 👈 add this for status
  List<int> studentSections = [];

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController awardingBodyController;
  List<AchievementSection> achievementSections = [];
  // static const int maxSections = 5;

  @override
  void initState() {
    super.initState();

    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();

    titleController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    awardingBodyController = TextEditingController();

    // reset sections
    achievementSections = [];
    studentSections = [];
    classIdsPerSection = [];
    selectedStudentsPerSection = [];
    remarksControllers = [];
    statusPerSection = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // also reset providers
      dropdownProvider.clearSelectedItem("standard");
      dropdownProvider.clearSelectedItem("className");
      dropdownProvider.clearSelectedItem("category");
      dropdownProvider.clearSelectedItem("level");
      dropdownProvider.clearSelectedItem("status");
      studentProvider.deselectAllStudents();
    });
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

    // 👇 reset providers here
    dropdownProvider.clearAllDropdowns(); // we'll define this method
    studentProvider.deselectAllStudents();

    super.dispose();
  }

  List<Map<String, dynamic>> getStudentsAchievementList() {
    return achievementSections
        .where((s) => s.selectedStudent != null) // only valid
        .map((s) => s.toJson())
        .toList();
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

                    GestureDetector(
                      onTap: () {
                        if (achievementSections.length >= 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "You can only add up to 5 students",
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          final newIndex = studentSections.length;
                          studentSections.add(newIndex);
                          selectedStudentsPerSection.add(null);
                          classIdsPerSection.add(null);
                          remarksControllers.add(TextEditingController());
                          statusPerSection.add(null);
                          achievementSections.add(AchievementSection());
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Add Student",
                              style: context.textTheme.bodyLarge,
                            ),
                            SizedBox(width: Responsive.width * 2),
                            Icon(Icons.add),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.height * 3),
                    // Dynamic student sections
                    Column(
                      children:
                          achievementSections.asMap().entries.map((entry) {
                            final index = entry.key;
                            final section = entry.value;
                            final sid =
                                section.sectionId; // 👈 stable id for keys

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
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
                                            // STANDARD (use sid)
                                            CustomDropdown(
                                              dropdownKey: 'standard_$sid',
                                              label: 'Select Standard*',
                                              icon: LucideIcons.layers,
                                              items: AppConstants.classGrades,
                                              onChanged: (standard) {
                                                context
                                                    .read<SharedProvider>()
                                                    .getClassNameFromStandard(
                                                      context: context,
                                                      standard: int.parse(
                                                        standard,
                                                      ),
                                                    );
                                              },
                                            ),
                                            const SizedBox(height: 10),

                                            // CLASS (use sid)
                                            Consumer<SharedProvider>(
                                              builder: (context, provider, _) {
                                                final classMapList =
                                                    provider.classNames;
                                                final onlyClassNames =
                                                    classMapList
                                                        .map(
                                                          (item) =>
                                                              item['classname']
                                                                  .toString(),
                                                        )
                                                        .toList();

                                                return CustomDropdown(
                                                  dropdownKey: 'className_$sid',
                                                  label: 'Select Class*',
                                                  icon: LucideIcons.school,
                                                  items: onlyClassNames,
                                                  onChanged: (selectedClass) {
                                                    final selectedId =
                                                        classMapList.firstWhere(
                                                          (item) =>
                                                              item['classname'] ==
                                                              selectedClass,
                                                          orElse:
                                                              () => {
                                                                "id": null,
                                                              },
                                                        )['id'];

                                                    setState(() {
                                                      section.classId =
                                                          selectedId;
                                                      section.selectedStudent =
                                                          null; // reset student
                                                    });
                                                  },
                                                );
                                              },
                                            ),

                                            const SizedBox(height: 10),

                                            // STUDENT PICKER (unchanged)
                                            SingleStudentPicker(
                                              classId: section.classId ?? 0,
                                              selectedStudent:
                                                  section.selectedStudent,
                                              onStudentSelected: (student) {
                                                setState(() {
                                                  section.selectedStudent =
                                                      student;
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 10),

                                            // STATUS (use sid)
                                            CustomDropdown(
                                              dropdownKey: 'status_$sid',
                                              label: "Achievement Status",
                                              icon: LucideIcons.clock,
                                              items:
                                                  AppConstants
                                                      .achievementStatuses,
                                              onChanged: (value) {
                                                setState(() {
                                                  section.status = value;
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 10),

                                            // REMARK
                                            CustomTextfield(
                                              iconData: const Icon(
                                                LucideIcons.type,
                                              ),
                                              controller: TextEditingController(
                                                text: section.remark ?? "",
                                              ),
                                              hintText: 'Remark',
                                              label: "Remark",
                                              onChanged:
                                                  (value) =>
                                                      section.remark = value,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // const SizedBox(width: 8),

                                  // REMOVE button — clear provider keys tied to this sectionId before removing
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        // 👇 clear dropdown selections for this section
                                        dropdownProvider.clearSelectedItem(
                                          'standard_$sid',
                                        );
                                        dropdownProvider.clearSelectedItem(
                                          'className_$sid',
                                        );
                                        dropdownProvider.clearSelectedItem(
                                          'status_$sid',
                                        );

                                        // if you keep the parallel lists, also remove at index
                                        achievementSections.removeAt(index);
                                        if (index < studentSections.length) {
                                          studentSections.removeAt(index);
                                        }
                                        if (index < classIdsPerSection.length) {
                                          classIdsPerSection.removeAt(index);
                                        }
                                        if (index <
                                            selectedStudentsPerSection.length) {
                                          selectedStudentsPerSection.removeAt(
                                            index,
                                          );
                                        }
                                        if (index < statusPerSection.length) {
                                          statusPerSection.removeAt(index);
                                        }
                                        if (index < remarksControllers.length) {
                                          remarksControllers[index].dispose();
                                          remarksControllers.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: Responsive.height * 4),
                    Consumer<AchievementProvider>(
                      builder: (context, provider, _) {
                        return CommonButton(
                          onPressed: () {
                            // if (formKey.currentState?.validate() ?? false) {
                            final dropdown = context.read<DropdownProvider>();
                            final String category = dropdown.getSelectedItem(
                              'category',
                            );
                            final String level = dropdown.getSelectedItem(
                              'level',
                            );

                            final String title = titleController.text.trim();
                            final String description =
                                descriptionController.text.trim();
                            final String date = dateController.text;
                            final String awardngBody =
                                awardingBodyController.text.trim();

                            // }
                            final achievementProvider =
                                context.read<AchievementProvider>();
                            log(getStudentsAchievementList().toString());
                            achievementProvider.createAchievement(
                              context: context,
                              title: title,
                              description: description,
                              category: category,
                              level: level,
                              date: date,
                              awardingBody: awardngBody,
                              students: getStudentsAchievementList(),
                            );
                          },
                          widget:
                              provider.isLoadingTwo
                                  ? ButtonLoading()
                                  : Text("Submit"),
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
