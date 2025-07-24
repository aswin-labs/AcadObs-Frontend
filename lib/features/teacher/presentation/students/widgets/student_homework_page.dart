import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StudentHomeworkPage extends StatelessWidget {
  const StudentHomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ItemCard(
              title: 'Imposition',
              description: "Hindi",
              onTap: () {},
              icon: LucideIcons.clipboardList,
              iconColor: Color(0xFFB14F6F),
              backgroundColor: Color(0xFFFFCEDE),
            ),
            ItemCard(
              title: 'Imposition',
              description: "Hindi",
              onTap: () {},
              icon: LucideIcons.clipboardList,
              iconColor: Color(0xFFB14F6F),
              backgroundColor: Color(0xFFFFCEDE),
            ),
            ItemCard(
              title: 'Imposition',
              description: "Hindi",
              onTap: () {},
              icon: LucideIcons.clipboardList,
              iconColor: Color(0xFFB14F6F),
              backgroundColor: Color(0xFFFFCEDE),
            ),
            ItemCard(
              title: 'Imposition',
              description: "Hindi",
              onTap: () {},
              icon: LucideIcons.clipboardList,
              iconColor: Color(0xFFB14F6F),
              backgroundColor: Color(0xFFFFCEDE),
            ),
          ],
        ),
      ),
    );
  }
}
