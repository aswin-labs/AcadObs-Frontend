// import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StudentAcheivementTab extends StatelessWidget {
  const StudentAcheivementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ItemCard(
              title: '2nd place',
              description: "independence day quiz",
              onTap: () {},
              icon: LucideIcons.trophy,
            ),
            ItemCard(
              title: '1st place',
              description: "Quiz competition",
              onTap: () {},
              icon: LucideIcons.trophy,
            ),
            ItemCard(
              title: '1st place',
              description: "Quiz competition",
              onTap: () {},
              icon: LucideIcons.trophy,
            ),
            ItemCard(
              title: '2nd place',
              description: "Quiz competition",
              onTap: () {},
              icon: LucideIcons.trophy,
            ),
          ],
        ),
      ),
      // floatingActionButton: CommonFloatingButton(onPressed: () {

      // },),
    );
  }
}
