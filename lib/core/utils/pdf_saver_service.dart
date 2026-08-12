import 'dart:typed_data';
import 'pdf_saver_mobile.dart'
    if (dart.library.html) 'pdf_saver_web.dart';

class PdfSaverService {
  static Future<void> saveAndOpenPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await PlatformPdfSaver.saveAndOpenPdf(bytes: bytes, fileName: fileName);
  }
}
