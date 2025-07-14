import 'package:acadobs/core/utils/helpers/download_helper.dart';
import 'package:flutter/material.dart';

void showDownloadPopup({
  required BuildContext context,
  required String title,
  required String description,
  required String buttonText,
  required String fileUrl,
  void Function()? onSuccess,
}) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close popup
              await DownloadHelper.downloadAndOpenFile(
                context: context,
                fileUrl: fileUrl,
              );
              if (onSuccess != null) onSuccess();
            },
            child: Text(buttonText),
          ),
        ],
      );
    },
  );
}
