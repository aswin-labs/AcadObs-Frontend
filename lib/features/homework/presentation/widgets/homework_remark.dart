import 'dart:ui';

import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeworkRemark extends StatelessWidget {
  final String name;
  final int homeworkId;
  const HomeworkRemark({
    super.key,
    required this.name,
    required this.homeworkId,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController remarkController = TextEditingController();
    return Stack(
      children: [
        // Blurred background
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withAlpha(50)),
          ),
        ),

        // Floating card at bottom right
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              height: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      hintText: "Enter remarks",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    maxLines: 4, // more space for remarks
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      context.read<HomeworkProvider>().homeworkRemarks(
                        context: context,
                        studentHomeworkId: homeworkId,
                        remarks: remarkController.text,
                      );
                      context.pop();
                    },
                    child: Text("Send", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
