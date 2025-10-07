import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';

class MarkCard extends StatelessWidget {
  final String subject;
  final String examtitle;
  final double mark;
  final double total;

  const MarkCard({
    super.key,
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
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //title
                Row(
                  children: [
                    Text('>>', style: TextStyle(color: Colors.white)),
                    Flexible(
                      child: Text(
                        capitalizeEachWord(examtitle),
                        style: TextStyle(color: Color(0xFFE9FF42)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // header
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Subject",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // SizedBox(width: 165),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Mark",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Total",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        //bottom white section
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    capitalizeEachWord(subject),
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    mark.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    total.toString(),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
