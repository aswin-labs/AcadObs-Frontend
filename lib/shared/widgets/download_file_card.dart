import 'package:acadobs/core/services/file_download_service.dart';
import 'package:flutter/material.dart';

class DownloadFileCard extends StatefulWidget {
  final String fileName;

  const DownloadFileCard({super.key, required this.fileName});

  @override
  State<DownloadFileCard> createState() => _DownloadFileCardState();
}

class _DownloadFileCardState extends State<DownloadFileCard> {
  bool _isDownloading = false;
  double _progress = 0.0;

  Future<void> _downloadFile() async {
    if (_isDownloading) return;

    try {
      setState(() {
        _isDownloading = true;
        _progress = 0;
      });

      await FileDownloadService.download(
        url: widget.fileName,
        onProgress: (progress) {
          if (!mounted) return;

          setState(() {
            _progress = progress;
          });
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Download error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to download the file.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(80),
        ),
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insert_drive_file_rounded,
              size: 36,
              color: Colors.red,
            ),
          ),

          const SizedBox(width: 16),

          // File name + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName.split('/').last,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (_isDownloading)
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(4),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Download icon or spinner
          GestureDetector(
            onTap: _isDownloading ? null : _downloadFile,
            child:
                _isDownloading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.blue,
                      ),
                    )
                    : const Icon(
                      Icons.download_rounded,
                      size: 30,
                      color: Colors.black,
                    ),
          ),
        ],
      ),
    );
  }
}
