import 'file_download_mobile.dart'
    if (dart.library.html) 'file_download_web.dart';

class FileDownloadService {
  static Future<void> download({
    required String url,
    required void Function(double progress) onProgress,
  }) {
    return PlatformFileDownloader.download(
      url: url,
      onProgress: onProgress,
    );
  }
}