// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

class PlatformPdfSaver {
  static Future<void> saveAndOpenPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..target = '_blank'
      ..style.display = 'none';

    html.document.body?.append(anchor);
    try {
      anchor.click();
    } finally {
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    }
  }
}
