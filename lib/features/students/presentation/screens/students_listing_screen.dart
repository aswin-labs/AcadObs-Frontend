import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class StudentsListingScreen extends StatefulWidget {
  const StudentsListingScreen({super.key});

  @override
  State<StudentsListingScreen> createState() => _StudentsListingScreenState();
}

class _StudentsListingScreenState extends State<StudentsListingScreen> {
  int? classId;
  String? className;

  final _formKey = GlobalKey<FormState>();
  String? _selectedStandard;

  late DropdownProvider dropdownProvider;
  late StudentProvider studentProvider;

  @override
  void initState() {
    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.clearSelectedItem("standard");
      dropdownProvider.clearSelectedItem("className");
      studentProvider.clearStudents();
      context.read<SharedProvider>().resetClassNames();

      setState(() => _selectedStandard = null);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Students", isBackButton: true),
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Responsive.width * 43,
                          child: CustomDropdown(
                            dropdownKey: 'standard',
                            label: 'Standard*',
                            icon: LucideIcons.layers,
                            items: AppConstants.classGrades,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please select a class standard'
                                        : null,
                            onChanged: (standard) {
                              setState(() => _selectedStandard = standard);
                              _formKey.currentState?.validate();

                              studentProvider.clearStudents();
                              dropdownProvider.clearSelectedItem("className");
                              classId = null;
                              className = null;

                              context
                                  .read<SharedProvider>()
                                  .getClassNameFromStandard(
                                    context: context,
                                    standard: int.parse(standard),
                                  );
                            },
                          ),
                        ),
                        Consumer<SharedProvider>(
                          builder: (context, provider, _) {
                            List<Map<String, dynamic>> classMapList =
                                provider.classNames;
                            List<String> onlyClassNames =
                                classMapList
                                    .map((item) => item['classname'].toString())
                                    .toList();

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: Responsive.width * 43,
                                child: Stack(
                                  children: [
                                    CustomDropdown(
                                      dropdownKey: 'className',
                                      label: 'Class*',
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
                                                  item['classname'] ==
                                                  selectedClass,
                                              orElse: () => {'id': null},
                                            )['id'];

                                        context
                                            .read<StudentProvider>()
                                            .fetchStudentsByClassId(
                                              context: context,
                                              classId: classId ?? 1,
                                            );
                                      },
                                    ),
                                    if (_selectedStandard == null)
                                      Positioned.fill(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _formKey.currentState?.validate();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                    "Please select standard",
                                                  ),
                                                  duration: Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<StudentProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return commonShimmerList();
                        }
                        if (provider.students.isEmpty) {
                          return emptyScreen(message: "No Students Found.");
                        }
                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.students.length,
                              itemBuilder: (context, index) {
                                final student = provider.students[index];
                                return ProfileTile(
                                  name: student.fullName,
                                  description:
                                      "Roll No: ${student.rollNumber.toString()}",
                                  onPressed:
                                      () => context.pushNamed(
                                        RouteConstants.studentDetails,
                                        extra: StudentDetailParameters(
                                          forParent: false,
                                          studentId: student.id,
                                        ),
                                      ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(16),
      //   // child: CommonFloatingButton(
      //   //   // onPressed: () => context.pushNamed(RouteConstants.addAchievements),
      //   //   onPressed: () => context.pushNamed(RouteConstants.getAchievement),
      //   // ),
      //   child: CommonFloatingButton2(
      //     onPressed: () => context.pushNamed(RouteConstants.getAchievement),
      //     icon: LucideIcons.file,
      //   ),
      //   // child: FloatingActionButton(
      //   //   backgroundColor: Colors.black,
      //   //   shape: CircleBorder(),

      //   //   onPressed: () => context.pushNamed(RouteConstants.getAchievement),
      //   //   child: Icon(LucideIcons.file, color: Colors.grey),
      //   // ),
      // ),
    );
  }
}
