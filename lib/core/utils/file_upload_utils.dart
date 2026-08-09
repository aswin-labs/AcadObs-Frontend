import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadUtils {
  static Future<MultipartFile?> toMultipartFile(
    PlatformFile? file,
  ) async {
    if (file == null) return null;

    if (file.bytes != null) {
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      );
    }

    if (file.path != null) {
      return MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      );
    }

    return null;
  }
}