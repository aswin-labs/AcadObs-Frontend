import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/students/provider/student_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final provider = context.read<StudentProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoading &&
        provider.hasMore) {
      provider.fetchStudentsByClassId(classId: classId ?? 0, loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                              child: CustomDropdown(
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
                                            item['classname'] == selectedClass,
                                        orElse: () => {'id': null},
                                      )['id'];

                                  context
                                      .read<StudentProvider>()
                                      .fetchStudentsByClassId(
                                        classId: classId ?? 1,
                                        forceRefresh: true,
                                      );
                                },
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
                      if (provider.isLoading && provider.students.isEmpty) {
                        return commonShimmerList();
                      }

                      if (provider.students.isEmpty) {
                        return emptyScreen(message: "No Students Found.");
                      }

                      return Column(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
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
                                      extra: student.id,
                                    ),
                              );
                            },
                          ),
                          if (provider.isLoading && provider.hasMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
