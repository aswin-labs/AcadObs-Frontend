import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LeaveLetterScreen extends StatelessWidget {
  const LeaveLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ItemCard(
              title: 'leave letter 1',
              description: 'Fever',
              onTap: () {},
              icon: LucideIcons.clock,
              iconColor: Colors.orange,
              backgroundColor: Color(0xFFFFF3E0),
            ),
            ItemCard(
              title: 'leave letter 2',
              description: 'Fever',
              onTap: () {},
              icon: LucideIcons.clock,
              iconColor: Colors.orange,
              backgroundColor: Color(0xFFFFF3E0),
            ),
            ItemCard(
              title: 'leave letter 3',
              description: 'Fever',
              onTap: () {},
              icon: LucideIcons.clock,
              iconColor: Colors.orange,
              backgroundColor: Color(0xFFFFF3E0),
            ),
          ],
        ),
      ),
    );
  }
}
