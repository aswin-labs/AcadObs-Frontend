import 'dart:html' as html;

class PlatformFileDownloader {
  static Future<void> download({
    required String url,
    required void Function(double progress) onProgress,
  }) async {
    final uri = Uri.parse(url);

    if (uri.pathSegments.isEmpty) {
      throw Exception('Invalid file URL');
    }

    final fileName = Uri.decodeComponent(uri.pathSegments.last);

    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..target = '_blank'
      ..style.display = 'none';

    html.document.body?.append(anchor);

    try {
      anchor.click();
      onProgress(1);
    } finally {
      anchor.remove();
    }
  }
}