import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class EditableGradeCard extends StatelessWidget {
  final int studentId;
  final String name;
  final int rollNumber;
  final TextEditingController marksController;
  final String status;
  final double totalMarks;
  final ValueChanged<String> onStatusChanged;

  const EditableGradeCard({
    super.key,
    required this.studentId,
    required this.name,
    required this.rollNumber,
    required this.marksController,
    required this.status,
    required this.totalMarks,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isAbsent = status == "absent";

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 1,
              color: Colors.grey.withAlpha(80),
            ),
          ],
        ),
        child: Row(
          children: [
            // Roll Number
            Container(
              width: 50,
              height: 60,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF4F4F4),
                child: Text(
                  rollNumber.toString(),
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Name
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 60,
                child: Text(
                  capitalizeEachWord(name),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            Container(color: Colors.grey[200], width: 2, height: 60),

            // Marks
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: AbsorbPointer(
                absorbing: isAbsent,
                child: TextField(
                  controller: marksController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "0",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (value) {
                    final marks = int.tryParse(value) ?? 0;
                    if (marks > totalMarks) {
                      marksController.text = "0";
                      marksController.selection = TextSelection.fromPosition(
                        TextPosition(offset: marksController.text.length),
                      );
                      CustomSnackbar.show(
                        context,
                        message: "Marks cannot exceed $totalMarks",
                        type: SnackbarType.warning,
                        bottomPadding: Responsive.height * 10,
                      );
                    }
                  },
                ),
              ),
            ),

            // Status
            GestureDetector(
              onTap: () {
                final newStatus = isAbsent ? "present" : "absent";
                onStatusChanged(newStatus);
              },
              child: Container(
                width: 40,
                height: 60,
                alignment: Alignment.center,
                color: isAbsent ? Colors.red : Colors.grey[200],
                child: Text(
                  isAbsent ? "A" : "P",
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
