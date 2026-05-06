import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/edit_attendance_widget.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class EditAttendanceScreen extends StatefulWidget {
  final AttendanceModel attendance;
  const EditAttendanceScreen({super.key, required this.attendance});

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  late DropdownProvider dropdownProvider;
  late SubjectProvider subjectProvider;
  TextEditingController dateController = TextEditingController();

  // Load periods
  Future<List<String>> loadPeriods() async {
    final authService = AuthStorageService();
    final schoolData = await authService.getSchoolDetailsForTeacher();
    if (schoolData == null) return [];
    final periodCount = schoolData['period_count'];
    if (periodCount == null) return [];
    return List.generate(periodCount as int, (i) => '${i + 1}');
  }

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.attendance.date);
    dropdownProvider = Provider.of<DropdownProvider>(context, listen: false);
    subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dropdownProvider.setSelectedItem(
        'period',
        widget.attendance.period.toString(),
      );
      subjectProvider.setSubjectSelected(widget.attendance.subject?.id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit Attendance", isBackButton: true),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Details:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 2),
                  FutureBuilder<List<String>>(
                    future: loadPeriods(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final periods = snapshot.data ?? [];

                      if (periods.isEmpty) {
                        return const Text('No periods found');
                      }

                      return CustomDropdown(
                        dropdownKey: 'period',
                        label: "Period",
                        icon: LucideIcons.clock,
                        items: periods,
                      );
                    },
                  ),
                  SizedBox(height: Responsive.height * 3),
                  Consumer2<DropdownProvider, SubjectProvider>(
                    builder: (context, dropdownProvider, subjectProvider, _) {
                      final selectedPeriod = dropdownProvider.getSelectedItem(
                        'period',
                      );
                      final selectedSubject = subjectProvider.selectedSubject;
                      return SizedBox(
                        height: Responsive.height * 6,
                        width: Responsive.width * 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(2),
                          ),
                          onPressed: () {
                            context
                                .read<AttendanceProvider>()
                                .editAttendanceDetails(
                                  context: context,
                                  attendanceId: widget.attendance.id,
                                  date: dateController.text,
                                  subjectId: selectedSubject?.id ?? 0,
                                  period: int.parse(selectedPeriod),
                                );
                          },
                          child:
                              context.watch<AttendanceProvider>().isLoadingTwo
                                  ? ButtonLoading()
                                  : Text("Save"),
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.height * 2,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 198, 200, 201),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Text(
                    "Edit Students Attendance:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 2),

                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.attendance.studentRecords?.length,
                    itemBuilder: (context, index) {
                      final studentDetails =
                          widget.attendance.studentRecords?[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: EditAttendanceWidget(
                          currentStatus: studentDetails?.status ?? "",
                          studentAttendanceId: studentDetails?.id ?? 0,
                          rollNo: studentDetails?.student?.rollNumber ?? 0,
                          studentName: studentDetails?.student?.fullName ?? "",
                          remarks: studentDetails?.remarks ?? "",
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Consumer<AttendanceProvider>(
                    builder: (context, value, child) {
                      return CommonButton(
                        buttonHeight: 60,
                        onPressed: () {
                          context.read<AttendanceProvider>().editBulkAttendance(
                            attendanceId: widget.attendance.id,
                            context: context,
                          );
                        },
                        widget:
                            value.isLoadingTwo
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
        ],
      ),
    );
  }
}
