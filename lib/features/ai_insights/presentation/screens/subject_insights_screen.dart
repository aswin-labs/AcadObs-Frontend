import 'package:acadobs/features/ai_insights/presentation/widgets/subject_insight_widget.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class SubjectInsightsScreen extends StatelessWidget {
  const SubjectInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Subject Insights", isBackButton: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SubjectInsightsWidget(
              subject: 'Maths',
              icon: Icons.calculate_outlined,
              predictedScore: 64,
              status: SubjectStatus.needsSupport,
              recommendation: 'Focus on Algebra and Fraction logic.',
              onTap: () => {},
            ),
            SizedBox(height: 16),
            SubjectInsightsWidget(
              subject: 'Science',
              icon: Icons.science_outlined,
              predictedScore: 78,
              status: SubjectStatus.onTrack,
              recommendation: 'Review Physics concepts and practice more.',
              onTap: () => {},
            ),
            SizedBox(height: 16),
            SubjectInsightsWidget(
              subject: 'English',
              icon: Icons.menu_book_outlined,
              predictedScore: 92,
              status: SubjectStatus.excellent,
              recommendation:
                  'Keep up the great work! Try some advanced literature.',
              onTap: () => {},
            ),
          ],
        ),
      ),
    );
  }
}
