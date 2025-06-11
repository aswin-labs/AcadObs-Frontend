import 'package:acadobs/core/controller/file_picker_provider.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SuperAdminServices {
  // **********SCHOOLS********** //
  // Get all schools
  Future<Response> getAllSchools({required int pageNo}) async {
    final response = await ApiServices.get('${ApiEndpoints.schools}?page=$pageNo');
    return response;
  }

  // Add school
  Future<Response> addSchool(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required String address,
    required String adminPassword,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile('logo');
    final fileUploadPath = fileUpload?.path;
    final formData = FormData.fromMap({
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "admin_password": adminPassword,
      // '_method': 'put',
      if (fileUploadPath != null)
        'logo': await MultipartFile.fromFile(fileUploadPath,
            filename: fileUploadPath.split('/').last),
    });
    final response =
        await ApiServices.post(ApiEndpoints.schools, formData, isFormData: true);
    return response;
  }

  // Edit school
  Future<Response> editSchool(
    BuildContext context, {
    required int schoolId,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile('logo');
    final fileUploadPath = fileUpload?.path;
    final formData = FormData.fromMap({
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      // '_method': 'put',
      if (fileUploadPath != null)
        'logo': await MultipartFile.fromFile(fileUploadPath,
            filename: fileUploadPath.split('/').last),
    });
    final response = await ApiServices.put(
        '${ApiEndpoints.schools}/$schoolId', formData,
        isFormData: true);
    return response;
  }

  // Delete a school
  Future<Response> deleteSchool({required int schoolId}) async {
    final response = await ApiServices.delete('${ApiEndpoints.schools}/$schoolId');
    return response;
  }

  // **********CLASSES********* //
  // Get all classes
  Future<Response> getAllClasses({required int pageNo}) async {
    final response = await ApiServices.get('${ApiEndpoints.classes}?page=$pageNo');
    return response;
  }

  // Add a class
  Future<Response> addClass({
    required String year,
    required String division,
    required String classname,
  }) async {
    final response = await ApiServices.post(ApiEndpoints.classes, {
      'year': year,
      'division': division,
      'classname': classname,
    });
    return response;
  }

  // Edit a class
  Future<Response> editClass({
    required int classId,
    required String year,
    required String division,
    required String classname,
  }) async {
    final response = await ApiServices.put('${ApiEndpoints.classes}/$classId', {
      'year': year,
      'division': division,
      'classname': classname,
    });
    return response;
  }

  // Delete a class
  Future<Response> deleteClass({required int classId}) async {
    final response = await ApiServices.delete('${ApiEndpoints.classes}/$classId');
    return response;
  }

  // **********SUBJECTS********* //
  // Get all subjects
  Future<Response> getAllSubjects({required int pageNo}) async {
    final response = await ApiServices.get('${ApiEndpoints.subjects}?page=$pageNo');
    return response;
  }

  // Add a subject
  Future<Response> addSubject({
    required String subjectName,
    required String classRange,
  }) async {
    final response = await ApiServices.post(ApiEndpoints.subjects, {
      'subject_name': subjectName,
      'class_range': classRange,
    });
    return response;
  }

  // Edit a subject
  Future<Response> editSubject({
    required int subjectId,
    required String subjectName,
    required String classRange,
  }) async {
    final response = await ApiServices.put('${ApiEndpoints.subjects}/$subjectId', {
      'subject_name': subjectName,
      'class_range': classRange,
    });
    return response;
  }

  // Delete a subject
  Future<Response> deleteSubject({required int subjectId}) async {
    final response = await ApiServices.delete('${ApiEndpoints.subjects}/$subjectId');
    return response;
  }
}
