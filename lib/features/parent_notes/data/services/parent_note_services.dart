import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/file_upload_utils.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentNoteServices {
  /// Create parent note
  /// Form data keys:
  /// - note_title
  /// - note_content
  /// - note_attachment (file)
  /// - studentIds: [1, 2]
  Future<Response> createParentNote({
    required BuildContext context,
    required String title,
    required String content,
    required List<int> studentIds,
    String fileKey = 'parentNoteFile',
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(fileKey);
    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);

    final formDataMap = {
      "note_title": title,
      "note_content": content,
      "studentIds": studentIds,
      if (multipartFile != null) "note_attachment": multipartFile,
    };

    log("PARENT NOTE CREATE FORMDATA => $formDataMap");

    final formData = FormData.fromMap(
      formDataMap,
      ListFormat.multiCompatible,
    );

    final response = await ApiServices.post(
      ApiEndpoints.parentNotes,
      formData,
      isFormData: true,
    );
    return response;
  }

  /// Fetch parent notes with pagination
  Future<Response> fetchParentNotes({required int pageNo, int? limit}) async {
    final effectiveLimit = limit ?? AppConstants.paginationLimit;
    final response = await ApiServices.get(
      "${ApiEndpoints.parentNotes}?limit=$effectiveLimit&pageNo=$pageNo&page=$pageNo",
    );
    return response;
  }

  /// Fetch single parent note by id
  Future<Response> fetchSingleParentNote({required int noteId}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.parentNotes}/$noteId",
    );
    return response;
  }

  /// Update parent note by id (PUT)
  Future<Response> updateParentNote({
    required BuildContext context,
    required int noteId,
    required String title,
    required String content,
    List<int>? studentIds,
    String fileKey = 'parentNoteFile',
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(fileKey);
    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);

    final formDataMap = {
      "note_title": title,
      "note_content": content,
      if (studentIds != null) "studentIds": studentIds,
      if (multipartFile != null) "note_attachment": multipartFile,
    };

    log("PARENT NOTE UPDATE ($noteId) => $formDataMap");

    final formData = FormData.fromMap(
      formDataMap,
      ListFormat.multiCompatible,
    );

    final response = await ApiServices.put(
      "${ApiEndpoints.parentNotes}/$noteId",
      formData,
      isFormData: true,
    );
    return response;
  }

  /// Delete parent note by id
  Future<Response> deleteParentNote({required int noteId}) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.parentNotes}/$noteId",
    );
    return response;
  }

  /// Fetch parent notes for a student (Guardian view) with pagination
  Future<Response> fetchParentNotesByStudentId({
    required int studentId,
    required int pageNo,
    int? limit,
  }) async {
    final effectiveLimit = limit ?? AppConstants.paginationLimit;
    final response = await ApiServices.get(
      "${ApiEndpoints.getParentNotesByStudentId}/$studentId?limit=$effectiveLimit&pageNo=$pageNo&page=$pageNo",
    );
    return response;
  }

  /// Fetch single parent note by noteId and studentId (Guardian view)
  Future<Response> fetchParentNoteByIdAndStudentId({
    required int noteId,
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getParentNotesByIdAndStudentId}/$noteId/$studentId",
    );
    return response;
  }

  /// Fetch unseen parent note count by studentId (Guardian view)
  Future<Response> fetchUnseenParentNoteCountByStudentId({
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getParentNoteUnseenCountByStudentId}/$studentId",
    );
    return response;
  }
}
