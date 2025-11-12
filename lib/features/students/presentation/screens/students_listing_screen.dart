import 'package:acadobs/core/constants/app_constants.dart';
// import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
// import 'package:acadobs/core/utils/empty_screen.dart';
// import 'package:acadobs/core/utils/responsive.dart';
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
  String _searchQuery = '';

  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  String? _selectedStandard;

  late DropdownProvider dropdownProvider;
  late StudentProvider studentProvider;

  @override
  void initState() {
    super.initState();
    dropdownProvider = context.read<DropdownProvider>();
    studentProvider = context.read<StudentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.clearSelectedItem("standard");
      dropdownProvider.clearSelectedItem("className");
      studentProvider.clearStudents();
      context.read<SharedProvider>().resetClassNames();
      setState(() => _selectedStandard = null);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredStudents(List<dynamic> students) {
    if (_searchQuery.isEmpty) return students;

    return students.where((student) {
      final name = student.fullName?.toLowerCase() ?? '';
      final rollNo = student.rollNumber?.toString() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || rollNo.contains(query);
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedStandard = null;
      classId = null;
      className = null;
      _searchQuery = '';
      _searchController.clear();
    });

    dropdownProvider.clearSelectedItem("standard");
    dropdownProvider.clearSelectedItem("className");
    studentProvider.clearStudents();
    context.read<SharedProvider>().resetClassNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: "Students", isBackButton: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Filter Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF35C2C1).withAlpha(24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.filter,
                            size: 20,
                            color: Color(0xFF35C2C1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Filter Students",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedStandard != null ||
                            _searchQuery.isNotEmpty)
                          TextButton.icon(
                            onPressed: _clearFilters,

                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dropdowns Row
                    Row(
                      children: [
                        // Standard Dropdown
                        Expanded(
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
                        const SizedBox(width: 12),

                        // Class Dropdown
                        Expanded(
                          child: Consumer<SharedProvider>(
                            builder: (context, provider, _) {
                              List<Map<String, dynamic>> classMapList =
                                  provider.classNames;
                              List<String> onlyClassNames =
                                  classMapList
                                      .map(
                                        (item) => item['classname'].toString(),
                                      )
                                      .toList();

                              return Stack(
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
                                              const SnackBar(
                                                backgroundColor: Colors.orange,
                                                content: Text(
                                                  "Please select standard first",
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Consumer<StudentProvider>(
              builder: (context, provider, _) {
                if (provider.students.isEmpty && !provider.isLoading) {
                  return const SizedBox.shrink();
                }

                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or roll number',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Students List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return commonShimmerList();
                  }

                  if (provider.students.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(height: 80),
                        Icon(
                          LucideIcons.users,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Students Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select a class to view students",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }

                  final filteredStudents = _getFilteredStudents(
                    provider.students,
                  );

                  if (filteredStudents.isEmpty) {
                    return Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Results Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your search",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Results Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              "${filteredStudents.length} Student${filteredStudents.length != 1 ? 's' : ''}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF35C2C1).withAlpha(24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Filtered",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF35C2C1),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Students Cards
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(9),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) => const SizedBox(),
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
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
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:acadobs/core/constants/app_constants.dart';
// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/common_shimmer_list.dart';
// import 'package:acadobs/core/utils/empty_screen.dart';
// import 'package:acadobs/core/utils/responsive.dart';
// import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
// import 'package:acadobs/routes/modules/staff_routes.dart';
// import 'package:acadobs/routes/router_constants.dart';
// import 'package:acadobs/shared/providers/dropdown_provider.dart';
// import 'package:acadobs/shared/providers/shared_provider.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:acadobs/shared/widgets/custom_dropdown.dart';
// import 'package:acadobs/shared/widgets/profile_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:provider/provider.dart';

// class StudentsListingScreen extends StatefulWidget {
//   const StudentsListingScreen({super.key});

//   @override
//   State<StudentsListingScreen> createState() => _StudentsListingScreenState();
// }

// class _StudentsListingScreenState extends State<StudentsListingScreen> {
//   int? classId;
//   String? className;

//   final _formKey = GlobalKey<FormState>();
//   String? _selectedStandard;

//   late DropdownProvider dropdownProvider;
//   late StudentProvider studentProvider;

//   @override
//   void initState() {
//     dropdownProvider = context.read<DropdownProvider>();
//     studentProvider = context.read<StudentProvider>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       dropdownProvider.clearSelectedItem("standard");
//       dropdownProvider.clearSelectedItem("className");
//       studentProvider.clearStudents();
//       context.read<SharedProvider>().resetClassNames();

//       setState(() => _selectedStandard = null);
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(title: "Students", isBackButton: true),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(
//           parent: AlwaysScrollableScrollPhysics(),
//         ),
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: context.paddingHorizontal.add(
//                 EdgeInsets.only(top: Responsive.height * 2),
//               ),
//               child: Form(
//                 key: _formKey,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(
//                           width: Responsive.width * 43,
//                           child: CustomDropdown(
//                             dropdownKey: 'standard',
//                             label: 'Standard*',
//                             icon: LucideIcons.layers,
//                             items: AppConstants.classGrades,
//                             validator:
//                                 (value) =>
//                                     value == null || value.isEmpty
//                                         ? 'Please select a class standard'
//                                         : null,
//                             onChanged: (standard) {
//                               setState(() => _selectedStandard = standard);
//                               _formKey.currentState?.validate();

//                               studentProvider.clearStudents();
//                               dropdownProvider.clearSelectedItem("className");
//                               classId = null;
//                               className = null;

//                               context
//                                   .read<SharedProvider>()
//                                   .getClassNameFromStandard(
//                                     context: context,
//                                     standard: int.parse(standard),
//                                   );
//                             },
//                           ),
//                         ),
//                         Consumer<SharedProvider>(
//                           builder: (context, provider, _) {
//                             List<Map<String, dynamic>> classMapList =
//                                 provider.classNames;
//                             List<String> onlyClassNames =
//                                 classMapList
//                                     .map((item) => item['classname'].toString())
//                                     .toList();

//                             return Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: SizedBox(
//                                 width: Responsive.width * 43,
//                                 child: Stack(
//                                   children: [
//                                     CustomDropdown(
//                                       dropdownKey: 'className',
//                                       label: 'Class*',
//                                       icon: LucideIcons.school,
//                                       items: onlyClassNames,
//                                       validator:
//                                           (value) =>
//                                               value == null || value.isEmpty
//                                                   ? 'Please select a class'
//                                                   : null,
//                                       onChanged: (selectedClass) {
//                                         className = selectedClass;
//                                         classId =
//                                             classMapList.firstWhere(
//                                               (item) =>
//                                                   item['classname'] ==
//                                                   selectedClass,
//                                               orElse: () => {'id': null},
//                                             )['id'];

//                                         context
//                                             .read<StudentProvider>()
//                                             .fetchStudentsByClassId(
//                                               context: context,
//                                               classId: classId ?? 1,
//                                             );
//                                       },
//                                     ),
//                                     if (_selectedStandard == null)
//                                       Positioned.fill(
//                                         child: Material(
//                                           color: Colors.transparent,
//                                           child: InkWell(
//                                             onTap: () {
//                                               _formKey.currentState?.validate();
//                                               ScaffoldMessenger.of(
//                                                 context,
//                                               ).showSnackBar(
//                                                 SnackBar(
//                                                   backgroundColor: Colors.red,
//                                                   content: Text(
//                                                     "Please select standard",
//                                                   ),
//                                                   duration: Duration(
//                                                     seconds: 3,
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Consumer<StudentProvider>(
//                       builder: (context, provider, _) {
//                         if (provider.isLoading) {
//                           return commonShimmerList();
//                         }
//                         if (provider.students.isEmpty) {
//                           return emptyScreen(message: "No Students Found.");
//                         }
//                         return Column(
//                           children: [
//                             ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: provider.students.length,
//                               itemBuilder: (context, index) {
//                                 final student = provider.students[index];
//                                 return ProfileTile(
//                                   name: student.fullName,
//                                   description:
//                                       "Roll No: ${student.rollNumber.toString()}",
//                                   onPressed:
//                                       () => context.pushNamed(
//                                         RouteConstants.studentDetails,
//                                         extra: StudentDetailParameters(
//                                           forParent: false,
//                                           studentId: student.id,
//                                         ),
//                                       ),
//                                 );
//                               },
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                     SizedBox(height: Responsive.height * 10),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       // floatingActionButton: Padding(
//       //   padding: const EdgeInsets.all(16),
//       //   // child: CommonFloatingButton(
//       //   //   // onPressed: () => context.pushNamed(RouteConstants.addAchievements),
//       //   //   onPressed: () => context.pushNamed(RouteConstants.getAchievement),
//       //   // ),
//       //   child: CommonFloatingButton2(
//       //     onPressed: () => context.pushNamed(RouteConstants.getAchievement),
//       //     icon: LucideIcons.file,
//       //   ),
//       //   // child: FloatingActionButton(
//       //   //   backgroundColor: Colors.black,
//       //   //   shape: CircleBorder(),

//       //   //   onPressed: () => context.pushNamed(RouteConstants.getAchievement),
//       //   //   child: Icon(LucideIcons.file, color: Colors.grey),
//       //   // ),
//       // ),
//     );
//   }
// }
