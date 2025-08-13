import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:acadobs/shared/widgets/students_picker.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();
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
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
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
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomDropdown(
                    dropdownKey: 'category',
                    label: "Category",
                    icon: LucideIcons.clock,
                    items: AppConstants.achievementCategories,
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomDropdown(
                    dropdownKey: 'level',
                    label: "Level",
                    icon: LucideIcons.receipt,
                    items: AppConstants.achievementLevels,
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Text(
                    "Add Students:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 3),
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
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "No Classes Available",
                                style: context.textTheme.bodySmall!.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
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
                                  // className = selectedClass;
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
                  SizedBox(height: Responsive.height * 2),
                  Consumer<StudentProvider>(
                    builder: (context, studentProvider, _) {
                      final classId = context.watch<SharedProvider>().classId;
                      return StudentsPicker(
                        classId: classId ?? 0,
                        selectAllNeeded: false,
                      );
                    },
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomDropdown(
                    dropdownKey: 'status',
                    label: "Achievement Status",
                    icon: LucideIcons.clock,
                    items: AppConstants.achievementStatuses,
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Container(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
