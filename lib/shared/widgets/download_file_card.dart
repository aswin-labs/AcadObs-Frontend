import 'package:acadobs/core/services/file_download_service.dart';
import 'package:flutter/material.dart';

class DownloadFileCard extends StatefulWidget {
  final String fileName;
  final bool small;
  final bool iconOnly;

  const DownloadFileCard({
    super.key,
    required this.fileName,
    this.small = false,
    this.iconOnly = false
  });

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
    if (widget.iconOnly) {
    return InkWell(
      onTap: _isDownloading ? null : _downloadFile,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: _isDownloading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(
                Icons.download_rounded,
                size: 24,
                color: Colors.black,
              ),
      ),
    );
  }

    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.small ? 220 : double.infinity,
      ),
      margin: EdgeInsets.symmetric(vertical: widget.small ? 4 : 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.small ? 10 : 16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(80),
        ),
      ),
      child: Row(
        mainAxisSize: widget.small ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            width: widget.small ? 32 : 60,
            height: widget.small ? 32 : 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(widget.small ? 7 : 12),
            ),
            child: Icon(
              Icons.insert_drive_file_rounded,
              size: widget.small ? 20 : 36,
              color: Colors.red,
            ),
          ),

          SizedBox(width: widget.small ? 8 : 16),

          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName.split('/').last,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.small ? 12 : null,
                  ),
                ),
                if (_isDownloading) ...[
                  SizedBox(height: widget.small ? 3 : 6),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: widget.small ? 3 : 5,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: widget.small ? 8 : 12),

          GestureDetector(
            onTap: _isDownloading ? null : _downloadFile,
            child:
                _isDownloading
                    ? SizedBox(
                      width: widget.small ? 18 : 24,
                      height: widget.small ? 18 : 24,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.blue,
                      ),
                    )
                    : Icon(
                      Icons.download_rounded,
                      size: widget.small ? 20 : 30,
                      color: Colors.black,
                    ),
          ),
        ],
      ),
    );
  }
}
