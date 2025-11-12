import 'package:acadobs/core/services/location_services.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckInWidget extends StatelessWidget {
  const CheckInWidget({super.key});

  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true, 
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onConfirm(); // Run confirmed action
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherAttendanceProvider>(
      builder: (context, provider, _) {
        final status = provider.todayAttendanceStatus;

        if (provider.isLoading || status.isEmpty) {
          return commonShimmerList(itemCount: 1);
        }

        final bool isNotMarked = status == 'Not Marked';
        final bool isCheckedIn = status == 'Checked In';
        final bool isCompleted = status == 'Checked Out';

        final String buttonText =
            isNotMarked
                ? 'Check In'
                : isCheckedIn
                ? 'Check Out'
                : 'Completed';

        final Color buttonColor =
            isNotMarked
                ? Colors.green
                : isCheckedIn
                ? Colors.orange
                : Colors.grey;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed:
                isCompleted
                    ? null
                    : () async {
                      final String action =
                          isNotMarked ? 'Check In' : 'Check Out';
                      final String message =
                          'Are you sure you want to $action now?';

                      await _showConfirmDialog(
                        context: context,
                        title: '$action Confirmation',
                        message: message,
                        onConfirm: () async {
                          final position = await getCurrentLocation();
                          if (position != null) {
                            if (isNotMarked) {
                              if (!context.mounted) return;
                              await context
                                  .read<TeacherAttendanceProvider>()
                                  .checkInAttendance(
                                    context: context,
                                    latitude: position.latitude.toString(),
                                    longitude: position.longitude.toString(),
                                  );
                            } else if (isCheckedIn) {
                              if (!context.mounted) return;
                              await context
                                  .read<TeacherAttendanceProvider>()
                                  .checkOutAttendance(
                                    context: context,
                                    latitude: position.latitude.toString(),
                                    longitude: position.longitude.toString(),
                                  );
                            }
                          }
                        },
                      );
                    },
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
