import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadProvider with ChangeNotifier {
  bool _isDownloading = false;
  double _progress = 0;

  bool get isDownloading => _isDownloading;
  double get progress => _progress;

  Future<void> downloadFile({required String fileName}) async {
    try {
      _isDownloading = true;
      _progress = 0;
      notifyListeners();

      final dio = Dio();
      final url = "${BaseUrls.media}$fileName";

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _progress = received / total;
            notifyListeners();
          }
        },
      );

      _isDownloading = false;
      notifyListeners();

      // Open the downloaded file
      await OpenFile.open(savePath);
    } catch (e) {
      _isDownloading = false;
      notifyListeners();
      debugPrint('Download error: $e');
    }
  }
}
