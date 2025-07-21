import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeworkServices {
  final int schoolId = 1;
  final int teacherId = 3;
  // create homework
  Future<Response> createHomework({
    required BuildContext context,
    required int classId,
    required String title,
    required String description,
    required String dueDate,
    required int subjectId,
    required String type,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'homeworkFile',
    );
    final fileUploadPath = fileUpload?.path;
    final formData = {
      "school_id": schoolId,
      "teacher_id": teacherId,
      "class_id": classId,
      "subject_id": subjectId,
      "description": description,
      "due_date": dueDate,
      "title": title,
      "type": type,
      if (fileUploadPath != null)
        "file": await MultipartFile.fromFile(
          fileUploadPath,
          filename: fileUploadPath.split('/').last,
        ),
    };
    final response = await ApiServices.post(
      ApiEndpoints.homeworks,
      formData,
      isFormData: true,
    );
    return response;
  }
}
