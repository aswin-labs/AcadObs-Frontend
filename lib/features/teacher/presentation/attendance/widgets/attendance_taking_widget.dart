import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/scrollable_name.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceTakingWidget extends StatefulWidget {
  final int studentId;
  final int rollNo;
  final String studentName;
  final bool alreadyTaken;
  final String currentStatus;
  final String? remarks;
  final bool? isLeaveApproved;

  const AttendanceTakingWidget({
    super.key,
    required this.studentId,
    required this.rollNo,
    required this.studentName,
    this.alreadyTaken = false,
    this.currentStatus = '',
    this.remarks,
    this.isLeaveApproved = false,
  });

  @override
  State<AttendanceTakingWidget> createState() => _AttendanceTakingWidgetState();
}

class _AttendanceTakingWidgetState extends State<AttendanceTakingWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final selectedStatus = provider.getStatus(widget.studentId);
    final selectedRemarks = provider.getRemarks(widget.studentId);

    final shouldShowRemarks =
        selectedStatus == "Late" || selectedStatus == "Absent";

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFCCCCCC)),
            left: BorderSide(color: Color(0xFFCCCCCC)),
            right: BorderSide(color: Color(0xFFCCCCCC)),
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    widget.isLeaveApproved == true
                        ? const Color.fromARGB(255, 234, 142, 142)
                        : Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF4F4F4),
                    child: Text(
                      widget.rollNo.toString(),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C7C7C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ScrollableName(
                    studentName: capitalizeEachWord(widget.studentName),
                  ),
                  const Spacer(),

                  // Show remarks if already taken
                  widget.alreadyTaken
                      ? Text(
                        widget.remarks != null ? " ${widget.remarks}" : "",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color:
                              widget.isLeaveApproved == true
                                  ? Colors.white
                                  : const Color(0xFF7C7C7C),
                        ),
                      )
                      : shouldShowRemarks
                      ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: DropdownButton<String>(
                          value:
                              AppConstants.attendanceRemarks.contains(
                                    selectedRemarks,
                                  )
                                  ? selectedRemarks
                                  : null,
                          hint: Text(
                            'Remarks',
                            style: context.textTheme.bodySmall!.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          items:
                              AppConstants.attendanceRemarks.map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          style: context.textTheme.bodySmall,
                          onChanged: (newValue) {
                            provider.setRemarks(widget.studentId, newValue);
                            provider.setAttendance(
                              widget.studentId,
                              selectedStatus!,
                              newValue,
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            /// Attendance Buttons
            Row(
              children: [
                _attendanceButton(
                  context: context,
                  buttonStatus: "Present",
                  bottomLeftRadius: 8,
                  bottomRightRadius: 0,
                  isSelected:
                      widget.alreadyTaken
                          ? widget.currentStatus == "present"
                          : selectedStatus == "Present",
                  onTap:
                      widget.alreadyTaken
                          ? () {}
                          : () {
                            provider.setAttendance(
                              widget.studentId,
                              "Present",
                              null,
                            );
                            provider.setRemarks(
                              widget.studentId,
                              null,
                            ); // optional
                          },
                ),
                _attendanceButton(
                  context: context,
                  buttonStatus: "Late",
                  bottomLeftRadius: 0,
                  bottomRightRadius: 0,
                  isSelected:
                      widget.alreadyTaken
                          ? widget.currentStatus == "late"
                          : selectedStatus == "Late",
                  onTap:
                      widget.alreadyTaken
                          ? () {}
                          : () {
                            final remarks = provider.getRemarks(
                              widget.studentId,
                            );
                            provider.setAttendance(
                              widget.studentId,
                              "Late",
                              remarks,
                            );
                          },
                ),
                _attendanceButton(
                  context: context,
                  buttonStatus: "Absent",
                  bottomLeftRadius: 0,
                  bottomRightRadius: 8,
                  isSelected:
                      widget.alreadyTaken
                          ? widget.currentStatus == "absent"
                          : selectedStatus == "Absent",
                  onTap:
                      widget.alreadyTaken
                          ? () {}
                          : () {
                            final remarks = provider.getRemarks(
                              widget.studentId,
                            );
                            provider.setAttendance(
                              widget.studentId,
                              "Absent",
                              remarks,
                            );
                          },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _attendanceButton({
  required BuildContext context,
  required String buttonStatus,
  required double bottomLeftRadius,
  required double bottomRightRadius,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final Map<String, Color> statusColors = {
    "Present": AppColors.attendancePresent,
    "Late": AppColors.attendanceLate,
    "Absent": AppColors.attendanceAbsent,
  };
  return Expanded(
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 25),
        backgroundColor:
            isSelected ? statusColors[buttonStatus] : const Color(0xFFF4F4F4),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0, color: Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(bottomLeftRadius),
            bottomRight: Radius.circular(bottomRightRadius),
          ),
        ),
      ),
      child: Text(
        buttonStatus,
        style:
            isSelected
                ? context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
                : context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
      ),
    ),
  );
}
