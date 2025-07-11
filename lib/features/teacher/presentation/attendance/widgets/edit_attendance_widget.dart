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
  final List<String> options = ['Medical', 'Personal', 'Official'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final selectedStatus =
        provider.getEditedStatus(widget.studentAttendanceId) ??
        widget.currentStatus;

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
                Text(
                  "${widget.remarks}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF7C7C7C),
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
                onTap:
                    () => provider.setEditedAttendance(
                      widget.studentAttendanceId,
                      "present",
                      selectedValue ?? "Updated",
                    ),
              ),
              _attendanceButton(
                context: context,
                buttonStatus: "Late",
                bottomLeftRadius: 0,
                bottomRightRadius: 0,
                isSelected: selectedStatus == "late",
                onTap:
                    () => provider.setEditedAttendance(
                      widget.studentAttendanceId,
                      "late",
                      selectedValue ?? "Updated",
                    ),
              ),
              _attendanceButton(
                context: context,
                buttonStatus: "Absent",
                bottomLeftRadius: 0,
                bottomRightRadius: 8,
                isSelected: selectedStatus == "absent",
                onTap:
                    () => provider.setEditedAttendance(
                      widget.studentAttendanceId,
                      "absent",
                      selectedValue ?? "Updated",
                    ),
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
    "Present": Color(0xFF64F946),
    "Late": Color.fromARGB(255, 239, 180, 71),
    "Absent": Color(0xFFFF1C1C),
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
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
    ),
  );
}
