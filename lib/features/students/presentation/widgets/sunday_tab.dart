import 'package:acadobs/features/students/presentation/widgets/time_table_list_card.dart';
import 'package:flutter/material.dart';

class SundayTab extends StatelessWidget {
  const SundayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 33),
            Text('Sunday', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('September,2025'),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return TimeTableListCard(
                 
                    subject: "english",
                    teacher: "mr. Smith",
                    classname: "class 09",
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
