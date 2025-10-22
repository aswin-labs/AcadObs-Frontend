import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDownloading;
  final double progress;

  const DownloadButton({
    super.key,
    required this.onTap,
    required this.isDownloading,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDownloading ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isDownloading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(progress * 100).toStringAsFixed(0)}%'),
              ],
            )
          : const Text('Download File'),
    );
  }
}
