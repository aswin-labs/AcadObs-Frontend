import 'package:acadobs/core/utils/download_popup.dart';
import 'package:flutter/material.dart';

class DownloadFileTile extends StatelessWidget {
  final String fileUrl;
  final String title;
  final String description;
  final String buttonText;
  final void Function()? onSuccess;

  const DownloadFileTile({
    super.key,
    required this.fileUrl,
    required this.title,
    required this.description,
    this.buttonText = 'Download',
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDownloadPopup(
        context: context,
        title: title,
        description: description,
        buttonText: buttonText,
        fileUrl: fileUrl,
        onSuccess: onSuccess,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.file_download, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
