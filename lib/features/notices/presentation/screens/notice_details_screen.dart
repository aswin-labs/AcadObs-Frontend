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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: const Color(0xFFCEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF378AA8),
                  size: 150,
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    capitalizeEachWord(notices.title.toString()),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Text(DateFormatter.formatDateString(notices.date)),
                ],
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                capitalizeEachWord(notices.content.toString()),
                style: TextStyle(color: Color(0xFF949494)),
              ),
            ),
            const SizedBox(height: 40),

            notices.file != null
                ? DownloadFileCard(
                  fileName: "${MediaEndpoints.notices}${notices.file}",
                )
                : const SizedBox(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
