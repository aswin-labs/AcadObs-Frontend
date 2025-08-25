import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FilePickerProvider with ChangeNotifier {
  static const int _maxSize = 5 * 1024 * 1024;
  final Map<String, PlatformFile?> _files = {};
  final Map<String, String?> _errors = {};

  PlatformFile? getFile(String fieldName) => _files[fieldName];
  String? getError(String fieldName) => _errors[fieldName];

  Future<void> pickFile(
    String fieldName, {
    bool imagesOnly = false,
    
  }) async {
    if (imagesOnly) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          File file = File(image.path);

          if (!_validateSize(file, fieldName)) return;

          File? compressedFile = await _compressImage(file);

          if (!_validateSize(compressedFile ?? file, fieldName)) return;

          _storeFile(fieldName, compressedFile ?? file);
          notifyListeners();
        }
      } catch (e) {
        log("Error picking image: $e");
      }
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile selectedFile = result.files.first;
        File file = File(selectedFile.path!);

        if (!_validateSize(file, fieldName)) return;

        if (_isImage(file.path)) {
          File? compressedFile = await _compressImage(file);
          if (!_validateSize(compressedFile ?? file, fieldName)) return;
          _storeFile(fieldName, compressedFile ?? file);
        } else {
          _storeFile(fieldName, file);
        }
        notifyListeners();
      }
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

  bool _validateSize(File file, String fieldName) {
    final size = file.lengthSync();
    if (size > _maxSize) {
      _files.remove(fieldName);
      _errors[fieldName] = 'File must be smaller than 5 MB';
      notifyListeners();
     
      return false;
    }
    _errors.remove(fieldName);
    return true;
  }

  void _storeFile(String fieldName, File file) {
    _files[fieldName] = PlatformFile(
      name: file.path.split('/').last,
      path: file.path,
      size: file.lengthSync(),
    );
    _errors.remove(fieldName);
  }

  bool _isImage(String filePath) {
    return filePath.endsWith('.jpg') ||
        filePath.endsWith('.jpeg') ||
        filePath.endsWith('.png') ||
        filePath.endsWith('.gif');
  }

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    String targetPath =
        '${dir.path}/${file.path.split('/').last}_compressed.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
    );

    return compressedFile != null ? File(compressedFile.path) : null;
  }
}
