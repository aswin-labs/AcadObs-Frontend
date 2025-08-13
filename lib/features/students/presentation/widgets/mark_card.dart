import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';

class MarkCard extends StatelessWidget {
  final String classname;
  final String subject;
  final String examtitle;
  final int mark;
  final int total;

  const MarkCard({
    super.key,
    required this.classname,
    required this.examtitle,
    required this.subject,
    required this.mark,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Text(classname, style: TextStyle(color: Colors.white)),
                    Text('>', style: TextStyle(color: Colors.white)),
                    Text(examtitle, style: TextStyle(color: Color(0xFFE9FF42))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Text("subject", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 150),
                    Text("Mark", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 20),
                    Text("Total", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Text(
                    capitalizeEachWord(subject),
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(width: 170),
                  Text(mark.toString(), style: TextStyle(color: Colors.black)),
                  SizedBox(width: 30),
                  Text(total.toString(), style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
