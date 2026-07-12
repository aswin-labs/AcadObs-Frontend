import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PlatformFileDownloader {
  static Future<void> download({
    required String url,
    required void Function(double progress) onProgress,
  }) async {
    final uri = Uri.parse(url);

    if (uri.pathSegments.isEmpty) {
      throw Exception('Invalid file URL');
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = Uri.decodeComponent(uri.pathSegments.last);
    final savePath = '${directory.path}/$fileName';

    await Dio().download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    final result = await OpenFile.open(savePath);

    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}