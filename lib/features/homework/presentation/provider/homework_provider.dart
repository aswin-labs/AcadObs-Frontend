import 'dart:developer';

import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/homework/data/models/gouped_homework_model.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/data/models/student_homework_model.dart';
import 'package:acadobs/features/homework/data/services/homework_services.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';
import 'package:provider/provider.dart';

class HomeworkProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<GroupedHomework> _homeworks = [];
  List<GroupedHomework> get homeworks => _homeworks;

  final List<StudentHomeworkModel> _studentHomeworks = [];
  List<StudentHomeworkModel> get studentHomeworks => _studentHomeworks;

  HomeworkModel? singleHomework;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  int _currentPageForStudent = 1;
  int _totalPagesForStudent = 1;

  bool get hasMoreForStudent => _currentPageForStudent < _totalPagesForStudent;

  // bool _isFetchedOnceForStudent = false;

  //star points clickeable
  final Map<int, int> _studentPoints = {};
  int getPoint(int studentId) {
    return _studentPoints[studentId] ?? 0;
  }

  void updatePoint(int studentId, int point) {
    _studentPoints[studentId] = point;
    notifyListeners();
  }

  // Fetch homeworks
  Future<void> fetchHomeworks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;

    try {
      if (loadMore) {
        if (_currentPage >= _totalPages) {
          _isLoading = false;
          return;
        }
        _currentPage++;
      } else {
        _currentPage = 1;
        _homeworks.clear();
        _isFetchedOnce = false;
      }
      final response = await HomeworkServices().fetchHomeworksByTeacher(
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List homeworksJson = data['groupedHomework'];

        final List<GroupedHomework> fetchedHomeworks =
            homeworksJson
                .map((json) => GroupedHomework.fromJson(json))
                .toList();
        _homeworks.addAll(fetchedHomeworks);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch homeworks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create homework
  Future<void> createHomework({
    required BuildContext context,
    required int classId,
    required String title,
    required String description,
    required String dueDate,
    required int subjectId,
    required String type,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final selectedIds = context.read<StudentProvider>().selectedStudentIds;

      // Add validation here
      if (selectedIds.isEmpty) {
        CustomErrorDialog.show(context, "Please select at least one student");
        notifyListeners();
        return;
      }

      final studentIdList =
          selectedIds.map((id) => {"student_id": id}).toList();

      final response = await HomeworkServices().createHomework(
        context: context,
        classId: classId,
        title: title,
        description: description,
        dueDate: dueDate,
        subjectId: subjectId,
        type: type,
        studentIds: studentIdList,
      );

      if (response.statusCode == 201) {
        await fetchHomeworks(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Homework Added Successfully",
          type: SnackbarType.success,
        );
      }
      if (response.statusCode == 200) {
        if (!context.mounted) return;
        CustomErrorDialog.show(context, response.data["message"]);
        _isLoadingTwo = false;
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Get Single homework
  Future<void> fetchSingleHomework({required int homeworkId}) async {
    _isLoading = true;
    try {
      final response = await HomeworkServices().fetchSingleHomework(
        homeworkId: homeworkId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        singleHomework = HomeworkModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //edit homeworks
  Future<void> edithomeWork({
    required BuildContext context,
    required int subjectId,
    required String title,
    required String description,
    required String duedate,
    required int homeworkId,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await HomeworkServices().editHomeWork(
        homeworkId: homeworkId,
        subjectId: subjectId,
        title: title,
        description: description,
        duedate: duedate,
      );

      if (response.statusCode == 200) {
        await fetchHomeworks(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
        final updatedData = response.data['homework'];
        singleHomework?.subjectId = updatedData['subject_id'];
        singleHomework?.title = updatedData['title'];
        singleHomework?.description = updatedData['description'];
        singleHomework?.dueDate = DateTime.parse(updatedData['due_date']);

        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Homework details saved',
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 400) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: '${response.data["error"]}. cant update',
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('error: ${e.toString()}');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  //delete homework
  Future<void> deleteHomeWork(context) async {
    try {
      final response = await HomeworkServices().deleteHomeWork(
        homeworkId: singleHomework?.id ?? 0,
      );

      if (response.statusCode == 200) {
        await fetchHomeworks(forceRefresh: true);
        // _homeworks.removeWhere((hw) => hw.id == singleHomework?.id);
        singleHomework = null;
        notifyListeners();
        CustomSnackbar.show(
          context,
          message: "Homework deleted",
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        log('Failed to delete homework: ${response.statusCode}');
      }
    } catch (e) {
      log('error in the deleting the homework $e');
      CustomErrorDialog.show(context, "error in deleting homework");
    }
  }

  //homework ranking
  Future<void> homeworkRanking({
    required BuildContext context,
    required int homeworkId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await HomeworkServices().homeworkRanking(
        homeworkId: homeworkId,
        assignments: assignments,
      );

      if (response.statusCode == 200) {
        await fetchHomeworks(forceRefresh: true);
        log("Homework ranking submitted: ${response.data}");
        await fetchSingleHomework(homeworkId: homeworkId);
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Homework ranking submitted",
          type: SnackbarType.success,
        );
      } else {
        log("Homework ranking failed: ${response.statusCode}");
        if (!context.mounted) return;
        CustomErrorDialog.show(context, "Failed to submit homework ranking");
      }
      log("response: ${response.data}");
    } catch (e) {
      log('error: $e');
    }
    _isLoadingTwo = false;
    notifyListeners();
  }

  // Get homeworks by studentId
  Future<void> fetchHomeworksByStudentId({
    required int studentId,
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    try {
      if (loadMore) {
        _currentPageForStudent++;
      } else {
        _currentPageForStudent = 1;
        _studentHomeworks.clear();
      }
      final response = await HomeworkServices().fetchHomeworkByStudentId(
        studentId: studentId,
        forStaff: forStaff,
        pageNo: _currentPageForStudent,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesForStudent = data['totalPages'];
        _currentPageForStudent = data['currentPage'];

        final List homeworksJson = data['homework'];

        final List<StudentHomeworkModel> fetchHomeworks =
            homeworksJson
                .map((jsonItem) => StudentHomeworkModel.fromJson(jsonItem))
                .toList();

        _studentHomeworks.addAll(fetchHomeworks);
        _studentHomeworks.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      } else {
        throw Exception('Failed to fetch homeworks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //homework remark section
  Future<void> homeworkRemarks({
    required BuildContext context,
    required int studentHomeworkId,
    required String remarks,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HomeworkServices().homeworkRemark(
        homeworkId: studentHomeworkId,
        remarks: remarks,
      );
      log(response.toString());
      if (response.statusCode == 200) {
        final statuses = singleHomework?.studentHomeworkStatus;
        if (statuses != null) {
          final idx = statuses.indexWhere((s) => s.id == studentHomeworkId);
          if (idx != -1) {
            statuses[idx].remark = remarks;
            notifyListeners(); // refresh UI instantly
          }
        }
        notifyListeners();

        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Remarks added",
          type: SnackbarType.success,
        );

        // ❌ remove this line, it’s overwriting your local update
        // await fetchSingleHomework(homeworkId: homeworkId);
      } else {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Remarks failed adding ",
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log("error is $e");
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  final Map<int, String> _studentRemarks = {};
  String getRemark(int studentId) => _studentRemarks[studentId] ?? "";

  void updateRemark(int studentId, String remark) {
    _studentRemarks[studentId] = remark;
    notifyListeners();
  }

  List<Map<String, dynamic>> get studentRankingsList {
    return singleHomework?.studentHomeworkStatus
            ?.map(
              (status) => {
                "student_id": status.student?.id,
                "status": "submitted",
                "points": _studentPoints[status.student?.id ?? 0] ?? 0,
                "remark": _studentRemarks[status.student?.id ?? 0] ?? "",
              },
            )
            .toList() ??
        [];
  }

  // final Map<int, String> _studentRemarks = {};
  // String getRemark(int studentId) => _studentRemarks[studentId] ?? "";

  // void updateRemark(int studentId, String remark) {
  //   _studentRemarks[studentId] = remark;
  //   notifyListeners();
  // }
}
