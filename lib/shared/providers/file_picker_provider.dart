import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FilePickerProvider with ChangeNotifier {
  static const int _maxSize = 5 * 1024 * 1024; // 5 MB

  final Map<String, PlatformFile?> _files = {};
  final Map<String, String?> _errors = {};

  PlatformFile? getFile(String fieldName) => _files[fieldName];

  String? getError(String fieldName) => _errors[fieldName];

  Future<void> pickFile(String fieldName, {bool imagesOnly = false}) async {
    try {
      _errors.remove(fieldName);

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: imagesOnly ? FileType.image : FileType.any,

        // Important for Web.
        // It gives us Uint8List bytes instead of depending on file.path.
        withData: true,

        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile selectedFile = result.files.first;

      // Validate original file size
      if (!_validateSize(selectedFile, fieldName)) {
        return;
      }

      PlatformFile finalFile = selectedFile;

      // Compress images
      if (_isImage(selectedFile.name)) {
        final PlatformFile? compressedFile = await _compressImage(selectedFile);

        if (compressedFile != null) {
          if (!_validateSize(compressedFile, fieldName)) {
            return;
          }

          finalFile = compressedFile;
        }
      }

      _storeFile(fieldName, finalFile);

      notifyListeners();
    } catch (e, stackTrace) {
      log('Error picking file', error: e, stackTrace: stackTrace);

      _errors[fieldName] = 'Unable to select file';
      notifyListeners();
    }
  }

  void clearFile(String fieldName) {
    _files.remove(fieldName);
    _errors.remove(fieldName);
    notifyListeners();
  }

  void clearAllFiles() {
    _files.clear();
    _errors.clear();
    notifyListeners();
  }

  bool _validateSize(PlatformFile file, String fieldName) {
    if (file.size > _maxSize) {
      _files.remove(fieldName);
      _errors[fieldName] = 'File must be smaller than 5 MB';
      notifyListeners();

      return false;
    }

    _errors.remove(fieldName);

    return true;
  }

  void _storeFile(String fieldName, PlatformFile file) {
    _files[fieldName] = file;
    _errors.remove(fieldName);
  }

  bool _isImage(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
    ].contains(extension);
  }

  Future<PlatformFile?> _compressImage(PlatformFile file) async {
    try {
      final Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        return file;
      }

      // GIF should normally not be compressed because
      // compression removes animation.
      if (file.name.toLowerCase().endsWith('.gif')) {
        return file;
      }

      final Uint8List compressedBytes =
          await FlutterImageCompress.compressWithList(
            bytes,
            quality: 85,
            format: CompressFormat.jpeg,
          );

      // Don't use compressed file if compression makes it larger.
      if (compressedBytes.length >= bytes.length) {
        return file;
      }

      final String compressedName = _getCompressedFileName(file.name);

      return PlatformFile(
        name: compressedName,
        size: compressedBytes.length,
        bytes: compressedBytes,

        // Keep original path for mobile if available.
        // Web path will normally be null.
        path: file.path,
      );
    } catch (e, stackTrace) {
      log('Image compression failed', error: e, stackTrace: stackTrace);

      // Use original image when compression fails.
      return file;
    }
  }

  String _getCompressedFileName(String fileName) {
    final int dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1) {
      return '${fileName}_compressed.jpg';
    }

    final String nameWithoutExtension = fileName.substring(0, dotIndex);

    return '${nameWithoutExtension}_compressed.jpg';
  }
}
