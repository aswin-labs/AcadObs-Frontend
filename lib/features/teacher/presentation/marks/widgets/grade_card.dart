import 'package:acadobs/features/teacher/presentation/marks/provider/marks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GradeCard extends StatelessWidget {
  final int studentId;
  final String name;
  final int rollNumber;

  const GradeCard({
    super.key,
    required this.studentId,
    required this.name,
    required this.rollNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Use context.watch<MarksProvider>() to get the provider instance and
    // ensure this widget rebuilds when the provider's data changes.
    final marksProvider = context.watch<MarksProvider>();

    // Find the specific data for this student from the provider's list.
    // This will throw an error if the studentId is not found, so ensure
    // the provider is initialized before this widget is built.
    final studentMark = marksProvider.marksList.firstWhere(
      (m) => m.studentId == studentId,
      // You can add an orElse clause for safety if needed
    );

    // Determine the color for the attendance box based on the status
    final Color attendanceColor = studentMark.attendanceStatus == "absent"
        ? Colors.red.shade100
        : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 1,
              color: Colors.grey.withAlpha(80),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- Roll Number Circle ---
            Container(
              width: 50,
              height: 60,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF4F4F4),
                child: Text(
                  // Use the 'rollNumber' property passed to the widget
                  rollNumber.toString(),
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- Student Name ---
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
                height: 60,
                child: Text(
                  // Use the 'name' property passed to the widget
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(color: Colors.grey[200], width: 2, height: 60),

            // --- Marks TextField ---
            Container(
              width: 60,
              height: 60,
              color: Colors.white,
              alignment: Alignment.center,
              child: TextField(
                // The controller gets its text from the provider's data
                controller: TextEditingController(text: studentMark.marksObtained),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                // On change, call the provider's update method
                onChanged: (value) {
                  // Use 'context.read' in callbacks as it doesn't listen for changes
                  context.read<MarksProvider>().updateMark(studentId, value);
                },
                decoration: const InputDecoration(
                  hintText: "0",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),

            // --- Attendance Toggle ---
            GestureDetector(
              onTap: () {
                // On tap, call the provider's toggle method
                context.read<MarksProvider>().toggleAttendance(studentId);
              },
              child: Container(
                width: 40,
                height: 60,
                alignment: Alignment.center,
                color: attendanceColor,
                child: Text(
                  // Text is based on the provider's data
                  studentMark.attendanceStatus == "absent" ? "A" : "P",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}