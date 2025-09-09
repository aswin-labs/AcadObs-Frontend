import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:acadobs/core/services/api_services.dart';

class FileDownloadProvider extends ChangeNotifier {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _downloadedFilePath;

  bool get isDownloading => _isDownloading;
  double get progress => _progress;
  String? get downloadedFilePath => _downloadedFilePath;

  Future<void> downloadNoticeFile(String url, String filename) async {
    _isDownloading = true;
    _progress = 0;
    notifyListeners();

    try {
      String saveDirpath;

      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        log("Storage permission status: $status");
        if (!status.isGranted) {
          throw Exception("Storage permission not granted");
        }

        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        saveDirpath = downloadsDir.path;
      } else {
        // on iOS
        final dir = await getApplicationDocumentsDirectory();
        saveDirpath = dir.path;
      }

      final savePath = '$saveDirpath/$filename';
      log("savePath: $savePath");

      await ApiServices.downloadFile(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _progress = received / total;
            notifyListeners();
          }
        },
      );

      log("Downloaded file size: ${File(savePath).lengthSync()} bytes");

      _downloadedFilePath = savePath;
      await OpenFile.open(savePath);
    } catch (e) {
      log("Download error: $e");
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}
