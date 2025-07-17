import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class NoticeDetailsScreen extends StatelessWidget {
  final Notices notices;
  const NoticeDetailsScreen({super.key, required this.notices});

  @override
  Widget build(BuildContext context) {
    // print("File URL is: ${notices.file}");
    return Scaffold(
      appBar: CommonAppBar(
        // title: capitalizeEachWord('title'),
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
              child: Text(
                // '12th Class Notices',
                capitalizeEachWord(notices.title.toString()),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // 'you have to complete the registration of 12th class students before 2022',
                capitalizeEachWord(notices.content.toString(),),
                style: TextStyle(
                  color: Color(0xFF949494),
                ),
              ),
            ),
            const SizedBox(height: 40),

            notices.file != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          notices.file!.split('/').last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {},
                        child: const Icon(Icons.file_download_outlined),
                      ),
                    ],
                  ),
                )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
