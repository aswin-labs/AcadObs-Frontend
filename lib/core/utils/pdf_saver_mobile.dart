import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PlatformPdfSaver {
  static Future<void> saveAndOpenPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}
