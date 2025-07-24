import 'package:flutter/material.dart';

class GradeCard extends StatelessWidget {
  final String name;
  final String grade;
  final String mark;
  final int serialnumber;
  const GradeCard({
    super.key,
    required this.name,
    required this.grade,
    required this.mark,
    required this.serialnumber,
  });

  @override
  Widget build(BuildContext context) {
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
            // Number Circle
            Container(
              width: 50,
              height: 60,
              color: Colors.white,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFF4F4F4),
                child: Text(
                  serialnumber.toString(),
                  style: TextStyle(
                    color: Color(0xFF7C7C7C),
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
                color: Colors.white,
                height: 60,
                child: Text(
                  name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(color: Colors.grey[200], width: 2, height: 60),
            // Marks TextField
            Container(
              width: 60,
              height: 60,
              color: Colors.white,
              alignment: Alignment.center,
              child: TextField(
                controller: TextEditingController(text: mark),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
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

            // Grade box
            Container(
              width: 40,
              height: 60,
              alignment: Alignment.center,
              color: Colors.grey[100],
              child: Text(
                grade,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
