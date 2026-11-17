import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/achievements/data/models/avhievement_section.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/features/achievements/presentaion/widgets/single_student_picker.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/services/shared_services.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class AddAchievementsScreen extends StatefulWidget {
  const AddAchievementsScreen({super.key});

  @override
  State<AddAchievementsScreen> createState() => _AddAchievementsScreenState();
}

class _AddAchievementsScreenState extends State<AddAchievementsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DropdownProvider dropdownProvider;
  late StudentProvider studentProvider;

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController awardingBodyController;

  List<AchievementSection> achievementSections = [];
  final Map<String, TextEditingController> _remarkControllersBySection = {};
  final Map<String, List<Map<String, dynamic>>> _classesBySection = {};
  final Map<String, bool> _loadingClassesBySection = {};

  static const int maxStudents = 5;

  @override
  void initState() {
    super.initState();

    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();

    titleController = TextEditingController();
    descriptionController = TextEditingController();
    dateController = TextEditingController();
    awardingBodyController = TextEditingController();

    // Start with 1 required student section by default
    final initialSection = AchievementSection(
      sectionId: '${DateTime.now().microsecondsSinceEpoch}_0',
    );
    achievementSections = [initialSection];
    _remarkControllersBySection[initialSection.sectionId] =
        TextEditingController();
    _classesBySection[initialSection.sectionId] = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    for (final controller in _remarkControllersBySection.values) {
      controller.dispose();
    }

    Future.microtask(() {
      dropdownProvider.clearAllDropdowns();
      studentProvider.deselectAllStudents();
    });

    super.dispose();
  }

  void _addStudentSection() {
    if (achievementSections.length >= maxStudents) {
      CustomSnackbar.show(
        context,
        message: "You can only add up to $maxStudents students.",
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() {
      final section = AchievementSection(
        sectionId:
            '${DateTime.now().microsecondsSinceEpoch}_${achievementSections.length}',
      );
      achievementSections.add(section);
      _remarkControllersBySection[section.sectionId] = TextEditingController();
      _classesBySection[section.sectionId] = [];
    });
  }

  void _removeStudentSection(int index) {
    if (achievementSections.length <= 1) {
      CustomSnackbar.show(
        context,
        message: "At least one student is required for an achievement.",
        type: SnackbarType.warning,
      );
      return;
    }

    final section = achievementSections[index];
    final sid = section.sectionId;

    setState(() {
      dropdownProvider.clearSelectedItem('standard_$sid');
      dropdownProvider.clearSelectedItem('className_$sid');
      dropdownProvider.clearSelectedItem('status_$sid');

      _remarkControllersBySection[sid]?.dispose();
      _remarkControllersBySection.remove(sid);
      _classesBySection.remove(sid);
      _loadingClassesBySection.remove(sid);

      achievementSections.removeAt(index);
    });
  }

  Future<void> _fetchClassesForSection(
    AchievementSection section,
    String standard,
  ) async {
    final sid = section.sectionId;
    final standardValue = switch (standard) {
      'LKG' => -2,
      'UKG' => -1,
      _ => int.tryParse(standard) ?? 0,
    };

    setState(() {
      _loadingClassesBySection[sid] = true;
      _classesBySection[sid] = [];
      section.classId = null;
      section.selectedStudent = null;
    });
    dropdownProvider.clearSelectedItem('className_$sid');

    try {
      final response = await SharedServices().getClassNameFromStandard(
        standard: standardValue,
      );
      if (!mounted) return;
      if (response.statusCode == 200 && response.data is List) {
        final list =
            (response.data as List)
                .map(
                  (result) => {
                    'id': result['id'],
                    'classname': result['classname']?.toString() ?? '',
                  },
                )
                .where((m) => (m['classname'] as String).isNotEmpty)
                .toList();
        setState(() {
          _classesBySection[sid] = list;
        });
      }
    } catch (e) {
      log("Error fetching classes for standard $standard: $e");
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: "Unable to load classes for Standard $standard.",
          type: SnackbarType.failure,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingClassesBySection[sid] = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> getStudentsAchievementList() {
    return achievementSections
        .where((s) => s.selectedStudent != null)
        .map((s) => s.toJson())
        .toList();
  }

  void _handleSubmit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      CustomSnackbar.show(
        context,
        message: "Please fill in all required fields.",
        type: SnackbarType.warning,
      );
      return;
    }

    if (achievementSections.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "Please add at least one student for this achievement.",
        type: SnackbarType.warning,
      );
      return;
    }

    // Validate each student section thoroughly
    final seenStudentIds = <int>{};
    for (int i = 0; i < achievementSections.length; i++) {
      final section = achievementSections[i];
      final studentNum = i + 1;

      if (section.classId == null || section.classId! <= 0) {
        CustomSnackbar.show(
          context,
          message: "Please select Standard and Class for Student #$studentNum.",
          type: SnackbarType.warning,
        );
        return;
      }

      if (section.selectedStudent == null) {
        CustomSnackbar.show(
          context,
          message: "Please select a student for Student #$studentNum.",
          type: SnackbarType.warning,
        );
        return;
      }

      if (section.status == null || section.status!.trim().isEmpty) {
        CustomSnackbar.show(
          context,
          message:
              "Please select an Achievement Status for ${section.selectedStudent!.fullName}.",
          type: SnackbarType.warning,
        );
        return;
      }

      final studentId = section.selectedStudent!.id;
      if (seenStudentIds.contains(studentId)) {
        CustomSnackbar.show(
          context,
          message:
              "${section.selectedStudent!.fullName} has been added more than once. Please select unique students.",
          type: SnackbarType.warning,
        );
        return;
      }
      seenStudentIds.add(studentId);
    }

    final dropdown = context.read<DropdownProvider>();
    final String category = dropdown.getSelectedItem('category').trim();
    final String level = dropdown.getSelectedItem('level').trim();
    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();
    final String date = dateController.text.trim();
    final String awardingBody = awardingBodyController.text.trim();

    final studentsPayload = getStudentsAchievementList();
    log("Submitting achievement students: $studentsPayload");

    context.read<AchievementProvider>().createAchievement(
      context: context,
      title: title,
      description: description,
      category: category,
      level: level,
      date: date,
      awardingBody: awardingBody,
      students: studentsPayload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: "Add Achievements",
        isBackButton: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Form(
                key: _formKey,
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
                      iconData: const Icon(LucideIcons.fileText),
                      controller: titleController,
                      hintText: 'Title*',
                      label: "Title*",
                      validator: FormValidator.validateNotEmpty,
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomTextfield(
                      iconData: const Icon(LucideIcons.stickyNote),
                      controller: descriptionController,
                      hintText: 'Description',
                      label: "Description",
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomDropdown(
                      dropdownKey: 'category',
                      label: "Category*",
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
                      label: "Level*",
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
                          'yyyy-MM-dd',
                        ).format(selectedDate);
                      },
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                      validator: FormValidator.validateNotEmpty,
                    ),
                    SizedBox(height: Responsive.height * 2),
                    CustomTextfield(
                      iconData: const Icon(LucideIcons.type),
                      controller: awardingBodyController,
                      hintText: 'Awarding body',
                      label: "Awarding body",
                    ),
                    SizedBox(height: Responsive.height * 2.5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Students* (${achievementSections.length}/$maxStudents):",
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (achievementSections.length < maxStudents)
                          TextButton.icon(
                            onPressed: _addStudentSection,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              "Add Another",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Dynamic student sections
                    Column(
                      children:
                          achievementSections.asMap().entries.map((entry) {
                            final index = entry.key;
                            final section = entry.value;
                            final sid = section.sectionId;
                            final classMapList = _classesBySection[sid] ?? [];
                            final onlyClassNames =
                                classMapList
                                    .map((item) => item['classname'].toString())
                                    .toList();
                            final isLoadingClasses =
                                _loadingClassesBySection[sid] == true;
                            final remarkCtrl = _remarkControllersBySection
                                .putIfAbsent(
                                  sid,
                                  () => TextEditingController(
                                    text: section.remark ?? '',
                                  ),
                                );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.grey.shade200,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Student #${index + 1}",
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (achievementSections.length > 1)
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            onTap:
                                                () => _removeStudentSection(
                                                  index,
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // STANDARD
                                    CustomDropdown(
                                      dropdownKey: 'standard_$sid',
                                      label: 'Select Standard*',
                                      icon: LucideIcons.layers,
                                      items: AppConstants.classGrades,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Please select a standard'
                                                  : null,
                                      onChanged: (standard) {
                                        _fetchClassesForSection(
                                          section,
                                          standard,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    // CLASS
                                    CustomDropdown(
                                      dropdownKey: 'className_$sid',
                                      label:
                                          isLoadingClasses
                                              ? 'Loading Classes...'
                                              : 'Select Class*',
                                      icon: LucideIcons.school,
                                      items: onlyClassNames,
                                      enabled: !isLoadingClasses,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Please select a class'
                                                  : null,
                                      onChanged: (selectedClass) {
                                        final selectedId =
                                            classMapList.firstWhere(
                                              (item) =>
                                                  item['classname'] ==
                                                  selectedClass,
                                              orElse: () => {"id": null},
                                            )['id'];

                                        setState(() {
                                          section.classId = selectedId as int?;
                                          section.selectedStudent = null;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    // STUDENT PICKER
                                    SingleStudentPicker(
                                      classId: section.classId ?? 0,
                                      selectedStudent: section.selectedStudent,
                                      validator:
                                          (student) =>
                                              student == null
                                                  ? 'Please select a student'
                                                  : null,
                                      onStudentSelected: (student) {
                                        setState(() {
                                          section.selectedStudent = student;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    // STATUS
                                    CustomDropdown(
                                      dropdownKey: 'status_$sid',
                                      label: "Achievement Status*",
                                      icon: LucideIcons.clock,
                                      items: AppConstants.achievementStatuses,
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Please select an achievement status'
                                                  : null,
                                      onChanged: (value) {
                                        setState(() {
                                          section.status = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    // REMARK
                                    CustomTextfield(
                                      iconData: const Icon(LucideIcons.type),
                                      controller: remarkCtrl,
                                      hintText: 'Remark',
                                      label: "Remark",
                                      onChanged:
                                          (value) => section.remark = value,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    if (achievementSections.length < maxStudents)
                      GestureDetector(
                        onTap: _addStudentSection,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
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
                              const Icon(Icons.add),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: Responsive.height * 4),
                    Consumer<AchievementProvider>(
                      builder: (context, provider, _) {
                        return CommonButton(
                          onPressed:
                              provider.isLoadingSecondary
                                  ? null
                                  : _handleSubmit,
                          widget:
                              provider.isLoadingSecondary
                                  ? const ButtonLoading()
                                  : const Text("Submit"),
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
