import 'package:flutter/material.dart';

class ProgressCardDesign extends StatelessWidget {
  const ProgressCardDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 170,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E5E5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    "SCHOLASTIC AREAS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: 390,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E5E5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    "TERM 1",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // Table
            Table(
              border: TableBorder.all(color: Colors.grey),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(170),
                1: FixedColumnWidth(70),
                2: FixedColumnWidth(80),
                3: FixedColumnWidth(80),
                4: FixedColumnWidth(90),
                5: FixedColumnWidth(70),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xffF5F5F5)),
                  children: [
                    _header("SUBJECTS"),
                    _header("PT 1\n(20)"),
                    _header("TERM 1\n(40)"),
                    _header("INT\n(10)"),
                    _header("TOTAL\n(50)"),
                    _header("GRADE"),
                  ],
                ),
                _row("MALAYALAM", "20", "29", "9", "38", "B1"),
                _row("HINDI", "20", "39", "10", "49", "A1"),
                _row("V E", "20", "31", "9.5", "40.5", "A2"),
                _row("MATHS", "17", "34", "9", "43", "A2"),
                _row("EVS", "14", "27", "9", "36", "B1"),
                _row("COMPUTER", "14", "-", "Absent", "Absent", "E"),
                _row("ELGA 2", "15.5", "28.5", "9", "37.5", "B1"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _header(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  static TableRow _row(
    String subject,
    String pt1,
    String term1,
    String internal,
    String total,
    String grade,
  ) {
    return TableRow(
      children: [
        _cell(subject, left: true),
        _cell(pt1),
        _cell(term1),
        _cell(internal),
        _cell(total),
        _cell(grade),
      ],
    );
  }

  static Widget _cell(String text, {bool left = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: left ? TextAlign.left : TextAlign.center,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
