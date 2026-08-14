import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/file_upload_utils.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeworksServices {
  // fetch list of homeworks
  Future<Response> fetchHomeworks({
    required HomeworkViewerType viewerType,
    required int pageNo,
    int? studentId,
  }) {
    switch (viewerType) {
      case HomeworkViewerType.teacherView:
        return ApiServices.get(
          "${ApiEndpoints.homeworkByTeacher}?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );

      case HomeworkViewerType.myClassView:
        return ApiServices.get(
          "${ApiEndpoints.myClassHomeworks}?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );

      case HomeworkViewerType.teacherStudentView:
        return ApiServices.get(
          "${ApiEndpoints.homeworksByStudentIdForTeacher}/$studentId?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );
      case HomeworkViewerType.guardianStudentView:
        return ApiServices.get(
          "${ApiEndpoints.homeworksByStudentIdForGuardian}/$studentId?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );
    }
  }

  // fetch Single homework
  Future<Response> fetchSingleHomework({
    required HomeworkViewerType viewerType,
    required homeworkId,
    int? studentId,
  }) {
    switch (viewerType) {
      case HomeworkViewerType.teacherView:
        return ApiServices.get("${ApiEndpoints.homeworks}/$homeworkId");

      case HomeworkViewerType.myClassView:
        return ApiServices.get("${ApiEndpoints.homeworks}/$homeworkId");

      case HomeworkViewerType.teacherStudentView:
        return ApiServices.get(
          "${ApiEndpoints.singleHomeworkByStudentIdForTeacher}/$homeworkId/$studentId",
        );
      case HomeworkViewerType.guardianStudentView:
        return ApiServices.get(
          "${ApiEndpoints.singleHomeworkByStudentIdForGuardian}/$homeworkId/$studentId",
        );
    }
  }

  // Create Homework
  Future<Response> createHomework({
    required BuildContext context,
    required int classId,
    required String title,
    required String description,
    required String dueDate,
    required int subjectId,
    required String type,
    required List<Map<String, dynamic>> studentIds,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'homeworkFile',
    );

    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);

    final teacherId = await AuthStorageService().getUserId();
    final formData = {
      "teacher_id": teacherId,
      "class_id": classId,
      "subject_id": subjectId,
      "description": description,
      "due_date": dueDate,
      "title": title,
      "type": type,
      "assignments": studentIds,
      if (multipartFile != null) "file": multipartFile,
    };
    final response = await ApiServices.post(
      ApiEndpoints.homeworks,
      formData,
      isFormData: true,
    );
    return response;
  }

  //homework ranking
  Future<Response> homeworkRanking({
    required int homeworkId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    final response = await ApiServices.put(ApiEndpoints.homeworkRanking, {
      "homework_id": homeworkId,
      "assignments": assignments,
    });
    log("response: ${response.data}");
    return response;
  }

  //homework remarks
  Future<Response> addHomeworkRemarks({
    required int homeworkId,
    required String remarks,
  }) async {
    final data = {"remarks": remarks};
    final response = await ApiServices.put(
      "${ApiEndpoints.sendHomeworkRemarks}/$homeworkId",
      data,
    );
    return response;
  }

  //edit homework
  Future<Response> editHomeWork({
    required BuildContext context,
    required int homeworkId,
    required int subjectId,
    required String title,
    String? description,
    required String duedate,
    String? type,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'homeworkFile',
    );

    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);
    final data = {
      "subject_id": subjectId,
      "title": title,
      "description": description,
      "due_date": duedate,
      "type": type,
      if (multipartFile != null) "file": multipartFile,
    };

    log("EDIT HOMEWORK ID => $homeworkId");
    log("EDIT HOMEWORK DATA => $data");

    final response = await ApiServices.put(
      "${ApiEndpoints.homeworks}/$homeworkId",
      data,
      isFormData: true,
    );
    return response;
  }

  // add file and remarks by guardian
  Future<Response> uploadFileAndRemarksByGuardian({
    required BuildContext context,
    required int studentHomeworkId,
    String? remarks,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'assignmentFile',
    );

    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);
    final data = {
      "remarks": remarks,
      if (multipartFile != null) "solved_file": multipartFile,
    };

    final response = await ApiServices.put(
      "${ApiEndpoints.uploadHomeworkFileAndRemarksByGuardian}/$studentHomeworkId",
      data,
      isFormData: true,
    );
    return response;
  }

  //delete homeworks
  Future<Response> deleteHomeWork({required int homeworkId}) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.homeworks}/$homeworkId",
    );
    return response;
  }

  // fetch missing students in class by homework id
  Future<Response> fetchMissingStudentsByHomeworkId({
    required int homeworkId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getMissingStudentsfromClassByHomeworkId}/$homeworkId",
    );
    return response;
  }

  // add new student homework assignments
  Future<Response> newStudentsHomeworkRanking({
    required int homeworkId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    final response = await ApiServices.post(
      "${ApiEndpoints.createNewHomeworkAssignment}/$homeworkId",
      assignments,
    );
    log("response: ${response.data}");
    return response;
  }

   //delete student homework
  Future<Response> deleteHomeWorkStudent({required int studentHomeworkId}) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.deleteHomeworkAssignment}/$studentHomeworkId",
    );
    return response;
  }
}
