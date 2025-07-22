// import 'dart:io';

import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class NoticeDetailsScreen extends StatelessWidget {
  final Notices notices;
  const NoticeDetailsScreen({super.key, required this.notices});

//   Future<void> downloadFile(String url, String fileName) async {
//   try {
//     // Request storage permissions
//     if (Platform.isAndroid) {
//       var status = await Permission.storage.request();
//       if (!status.isGranted) {
//         print('Storage permission denied');
//         return;
//       }
//     }

//     // Get the directory
//     final Directory dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
//     final String filePath = '${dir.path}/$fileName';

//     // Download the file
//     Dio dio = Dio();
//     await dio.download(url, filePath);

//     print('File downloaded to $filePath');
//   } catch (e) {
//     print('Download failed: $e');
//   }
// }

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
                capitalizeEachWord(notices.content.toString()),
                style: TextStyle(color: Color(0xFF949494)),
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
                          // (notices.file?.length ?? 0) > 10
                          //     ? notices.file!.substring(notices.file!.length - 25)
                          //     : notices.file ?? "No documents found",
                          // style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {},
  //                       onTap: () async {
  //   final String fileUrl = notices.file!;
  //   final String fileName = fileUrl.split('/').last;
  //   await downloadFile(fileUrl, fileName);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Download started for $fileName')),
  //   );
  // },
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
