import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_upload_model.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

Future<void> showAttendancePeriodDialog({
  required int classId,
  required String className,
  required BuildContext context,
}) async {
  final formKey = GlobalKey<FormState>();

  context.read<DropdownProvider>().clearSelectedItem('period');

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      Future<List<String>> loadPeriods() async {
        final authService = AuthStorageService();
        final schoolData = await authService.getSchoolDetailsForTeacher();
        if (schoolData == null) return [];
        final attendanceCount = schoolData['attendance_count'];
        if (attendanceCount == null) return [];
        return List.generate(attendanceCount as int, (i) => '${i + 1}');
      }

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fact_check_outlined,
                          color: Colors.green,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Take Attendance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              capitalizeEachWord(className),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6F737A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<String>>(
                    future: loadPeriods(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Unable to load periods',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      final periods = snapshot.data ?? [];

                      if (periods.isEmpty) {
                        return const Text('No periods found');
                      }

                      return CustomDropdown(
                        dropdownKey: 'period',
                        label: 'Select Period*',
                        icon: LucideIcons.clock,
                        items: periods,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a period';
                          }

                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      final period = context
                          .read<DropdownProvider>()
                          .getSelectedItem('period');
                      final parsedPeriod = int.tryParse(period);

                      if (parsedPeriod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a valid period'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(dialogContext);

                      context.pushNamed(
                        RouteConstants.attendanceTaking,
                        extra: AttendanceUploadModel(
                          classId: classId,
                          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          className: className,
                          period: parsedPeriod,
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text(
                      'Continue to Attendance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
