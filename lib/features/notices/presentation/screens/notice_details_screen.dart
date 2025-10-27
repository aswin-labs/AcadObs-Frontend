import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:flutter/material.dart';

class NoticeDetailsScreen extends StatelessWidget {
  final Notices notices;
  const NoticeDetailsScreen({super.key, required this.notices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(notices.title.toString()),
        isBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Hero Image with Gradient and Shadow
              Container(
                width: double.infinity,
                height: 226,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCEF2FF), Color(0xFFB3E5FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCEF2FF).withAlpha(128),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(77),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF2C8BA8),
                      size: 80,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Date Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF378AA8).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF378AA8).withAlpha(51),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF378AA8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatDateString(notices.date),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF378AA8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Title with better styling
              Text(
                capitalizeEachWord(notices.title.toString()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 20),

              // Decorative Divider
              Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF378AA8), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Content with enhanced styling
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Text(
                  capitalizeEachWord(notices.content.toString()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // File download card with conditional rendering
              if (notices.file != null) ...[
                DownloadFileCard(
                  fileName: "${MediaEndpoints.notices}${notices.file}",
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
