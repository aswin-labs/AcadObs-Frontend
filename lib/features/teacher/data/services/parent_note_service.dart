import 'dart:convert';
import 'dart:developer';

import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentNoteService {
  Future<Response> createParentNote({
    required BuildContext context,
    required String title,
    required String content,
    required List<Map<String, dynamic>> studentIds,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'parentNoteFile',
    );
    final fileUploadPath = fileUpload?.path;
    log("studentIds JSON: ${jsonEncode(studentIds)}");

    final formData = {
      "note_title": title,
      "note_content": content,
      // "studentIds": studentIds,
      "studentIds": studentIds.map((e) => e["student_id"]).toList(),
      if (fileUploadPath != null)
        "file": await MultipartFile.fromFile(
          fileUploadPath,
          filename: fileUploadPath.split('/').last,
        ),
    };

    log("ParentNote formData: $formData");

    final response = await ApiServices.post(
      ApiEndpoints.createParentNote,
      formData,
      isFormData: true,
    );
    log("the response is : $response");
    log("the statusCode is : ${response.statusCode}");
    return response;
  }

  //to list the parent note
  Future<Response> getParentNote({
    required int limit,
    required int pageNo,
  }) async {
    final response = ApiServices.get(
      '${ApiEndpoints.getLatestNotes}?pageNo=$pageNo&limit=$limit',
    );
    return response;
  }

  //delete note
  Future<Response> deleteNote({required int id}) async {
    final response = await ApiServices.delete("${ApiEndpoints.deleteNote}/$id");
    log("Delete URL: ${ApiEndpoints.deleteNote}/$id");

    return response;
  }
}
