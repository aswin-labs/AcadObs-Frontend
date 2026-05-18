import 'package:acadobs/features/ai_insights/presentation/widgets/insights_widget.dart';
import 'package:acadobs/features/ai_insights/presentation/widgets/overall_performance_widget.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiInsightsHomescreen extends StatelessWidget {
  const AiInsightsHomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: "AI Insights", isBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              const Text(
                'Student Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "class and section",
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF111827).withAlpha(153),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'OVERALL PERFORMANCE',
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              // Content
              OverallPerformanceWidget(), const SizedBox(height: 16),
              Text(
                'KEY INSIGHTS',
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              InsightsWidget(
                icon: Icons.book_rounded,
                iconColor: const Color(0xFFDBEAFE),
                title: 'Subject Insights',
                description:
                    'Get detailed insights into the student\'s performance in each subject.',
                buttonLabel: 'View Subject Insights',
                onExplore: () {
                  context.pushNamed(RouteConstants.subjectInsights);
                },
              ),
              const SizedBox(height: 20),
              InsightsWidget(
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFFEE2E2),
                title: 'Career Guidance',
                description:
                    'Get personalized career advice based on the student\'s interests and strengths.',
                buttonLabel: 'Explore Career Guidance',
                onExplore: () {
                  // Navigate to risk analysis screen
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
