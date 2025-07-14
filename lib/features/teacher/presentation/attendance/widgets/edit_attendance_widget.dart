import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/scrollable_name.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditAttendanceWidget extends StatefulWidget {
  final int studentAttendanceId;
  final int rollNo;
  final String studentName;
  final String currentStatus;
  final String? remarks;

  const EditAttendanceWidget({
    super.key,
    required this.studentAttendanceId,
    required this.rollNo,
    required this.studentName,
    required this.currentStatus,
    this.remarks,
  });

  @override
  State<EditAttendanceWidget> createState() => _EditAttendanceWidgetState();
}

class _EditAttendanceWidgetState extends State<EditAttendanceWidget> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AttendanceProvider>();

    // Load initial remarks
    final stored = provider.getEditedRemarks(widget.studentAttendanceId);
    selectedValue = stored ?? widget.remarks;

    // Save initial remarks to map if not already stored
    if (stored == null && widget.remarks != null) {
      provider.setEditedRemarks(widget.studentAttendanceId, widget.remarks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final selectedStatus =
        provider.getEditedStatus(widget.studentAttendanceId) ??
        widget.currentStatus.toLowerCase();

    final showDropdown = selectedStatus == "late" || selectedStatus == "absent";
    final showValueInDropdown =
        selectedValue != null &&
        AppConstants.attendanceRemarks.contains(selectedValue);

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFCCCCCC)),
          left: BorderSide(color: Color(0xFFCCCCCC)),
          right: BorderSide(color: Color(0xFFCCCCCC)),
        ),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
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
                if (showDropdown)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButton<String>(
                      value: showValueInDropdown ? selectedValue : null,
                      hint: Text(
                        'Remarks',
                        style: context.textTheme.bodySmall!.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      items:
                          AppConstants.attendanceRemarks.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      style: context.textTheme.bodySmall,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                        provider.setEditedRemarks(
                          widget.studentAttendanceId,
                          newValue,
                        );
                        provider.setEditedAttendance(
                          widget.studentAttendanceId,
                          selectedStatus,
                          newValue,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              _attendanceButton(
                context: context,
                buttonStatus: "Present",
                bottomLeftRadius: 8,
                bottomRightRadius: 0,
                isSelected: selectedStatus == "present",
                onTap: () {
                  setState(() {
                    selectedValue = null;
                  });
                  provider.setEditedAttendance(
                    widget.studentAttendanceId,
                    "present",
                    "Updated",
                  );
                },
              ),
              _attendanceButton(
                context: context,
                buttonStatus: "Late",
                bottomLeftRadius: 0,
                bottomRightRadius: 0,
                isSelected: selectedStatus == "late",
                onTap: () {
                  provider.setEditedAttendance(
                    widget.studentAttendanceId,
                    "late",
                    selectedValue,
                  );
                },
              ),
              _attendanceButton(
                context: context,
                buttonStatus: "Absent",
                bottomLeftRadius: 0,
                bottomRightRadius: 8,
                isSelected: selectedStatus == "absent",
                onTap: () {
                  provider.setEditedAttendance(
                    widget.studentAttendanceId,
                    "absent",
                    selectedValue,
                  );
                },
              ),
            ],
          ),
        ],
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
            isSelected ? statusColors[buttonStatus] : Color(0xFFF4F4F4),
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
