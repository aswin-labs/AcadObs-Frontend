import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/homework/widgets/ranking_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class HomeworkRankingScreen extends StatelessWidget {
  const HomeworkRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Homework', isBackButton: true),
      body: Padding(
        padding: context.paddingHorizontal.add(
          EdgeInsets.only(top: Responsive.height * 2),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '23/07/2025',
                style: TextStyle(fontSize: 24, color: Color(0xFF6F6F6F)),
              ),
              SizedBox(height: 10),
              RankingCard(name: "Theodore T.C. Calvin", number: '01'),
              RankingCard(name: 'Jonathan Higgins', number: '02'),
              RankingCard(name: "Templeton Peck", number: '03'),
              RankingCard(name: 'Kate Tanner', number: '04'),
            ],
          ),
        ),
      ),
    );
  }
}
