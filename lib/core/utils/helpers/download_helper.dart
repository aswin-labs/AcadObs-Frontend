import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadHelper {
  static Future<void> downloadAndOpenFile({
    required BuildContext context,
    required String fileUrl,
    String? fileName,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    // Request permission first
    final permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Download failed from server')),
        );
        return;
      }

      // Determine file name
      fileName ??= fileUrl.split('/').last;

      final directory = await _getDownloadDirectory();
      if (directory == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Unable to access download directory')),
        );
        return;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      messenger.showSnackBar(
        const SnackBar(content: Text('Download successful')),
      );

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  static Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    final result = await Permission.storage.request();
    if (result.isGranted) return true;

    // For Android 11+ (API 30+) where manageExternalStorage might be needed
    if (await Permission.manageExternalStorage.isGranted) return true;
    final manageResult = await Permission.manageExternalStorage.request();
    return manageResult.isGranted;
  }

  static Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final baseDir = await getExternalStorageDirectory();
      if (baseDir == null) return null;

      final downloadPath = "${baseDir.path.split("Android")[0]}Download";
      final downloadDir = Directory(downloadPath);

      if (!(await downloadDir.exists())) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getDownloadsDirectory();
    }
  }
}
