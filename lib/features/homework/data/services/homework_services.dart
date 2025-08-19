import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
// import 'package:acadobs/features/teacher/data/models/homework/homework_model.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeworkServices {
  final int schoolId = 1;
  final int teacherId = 3;
  // final HomeworkModel homeworkmodel;

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
    final fileUploadPath = fileUpload?.path;
    final formData = {
      "teacher_id": teacherId,
      "class_id": classId,
      "subject_id": subjectId,
      "description": description,
      "due_date": dueDate,
      "title": title,
      "type": type,
      "assignments": studentIds,
      if (fileUploadPath != null)
        "file": await MultipartFile.fromFile(
          fileUploadPath,
          filename: fileUploadPath.split('/').last,
        ),
    };
    log(formData.toString());
    final response = await ApiServices.post(
      ApiEndpoints.homeworks,
      formData,
      isFormData: true,
    );
    return response;
  }

  // Get homeworks by teacher
  Future<Response> fetchHomeworksByTeacher({required int pageNo}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.homeworkByTeacher}?teacher_id=$teacherId&limit=${AppConstants.paginationLimit}&page=$pageNo",
    );
    return response;
  }

  // fetch individual homework
  Future<Response> fetchSingleHomework({required int homeworkId}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.homeworks}/$homeworkId",
    );
    return response;
  }

  //edit homework
  Future<Response> editHomeWork({
    required int homeworkId,
    required int subjectId,
    required String title,
    required String description,
    required String duedate,
  }) async {
    final response =
        await ApiServices.put("${ApiEndpoints.homeworks}/$homeworkId", {
          "subject_id": subjectId,
          "title": title.trim(),
          "description": description.trim(),
          "due_date": duedate,
        }, isFormData: true);

    return response;
  }

  //delete homeworks
  Future<Response> deleteHomeWork({required int homeworkId}) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.homeworks}/$homeworkId",
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

  // fetch homeworkby studentId
  Future<Response> fetchHomeworkByStudentId({
    required int studentId,
    required bool forParent,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      forParent
          ? "${ApiEndpoints.fetchHomeworksByStudentIdForGuardian}/$studentId?page=$pageNo&limit=${AppConstants.paginationLimit}"
          : "${ApiEndpoints.fetchHomeworksByStudentIdForStaff}/$studentId?page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }
}
