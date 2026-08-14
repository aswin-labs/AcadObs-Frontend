import 'dart:developer';

import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/homeworks/data/models/gouped_homework_model.dart';
import 'package:acadobs/features/homeworks/data/models/homework_model.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/homeworks/data/services/homeworks_services.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HomeworksProvider extends ChangeNotifier {
  bool _isLoadingHomeworks = false;
  bool get isLoadingHomeworks => _isLoadingHomeworks;

  bool _isLoadingSingleHomework = false;
  bool get isLoadingSingleHomework => _isLoadingSingleHomework;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingRemarks = false;
  bool get isLoadingRemarks => _isLoadingRemarks;

  final List<GroupedHomework> _homeworks = [];
  List<GroupedHomework> get homeworks => _homeworks;

  HomeworkModel? singleHomework;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  //star points clickeable
  final Map<int, int> _studentPoints = {};
  int getPoint(int studentId) {
    return _studentPoints[studentId] ?? 0;
  }

  // Fetch homeworks
  Future<void> fetchHomeworks({
    required HomeworkViewerType viewerType,
    int? studentId,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingHomeworks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh) return;

    _isLoadingHomeworks = true;

    try {
      if (loadMore) {
        if (_currentPage >= _totalPages) {
          _isLoadingHomeworks = false;
          return;
        }
        _currentPage++;
      } else {
        _currentPage = 1;
        _homeworks.clear();
      }
      final response = await HomeworksServices().fetchHomeworks(
        viewerType: viewerType,
        studentId: studentId,
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
      } else {
        throw Exception('Failed to fetch homeworks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingHomeworks = false;
      notifyListeners();
    }
  }

  // Get Single homework
  Future<void> fetchSingleHomework({
    required HomeworkViewerType viewerType,
    required int homeworkId,
    int? studentId,
  }) async {
    _isLoadingSingleHomework = true;
    try {
      final response = await HomeworksServices().fetchSingleHomework(
        viewerType: viewerType,
        homeworkId: homeworkId,
        studentId: studentId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        singleHomework = HomeworkModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingSingleHomework = false;
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
    _isLoading = true;
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

      final response = await HomeworksServices().createHomework(
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
        await fetchHomeworks(
          forceRefresh: true,
          viewerType: HomeworkViewerType.teacherView,
        );
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
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isLoadingMissingStudents = false;
  bool get isLoadingMissingStudents => _isLoadingMissingStudents;

  bool _isLoadingNewRanking = false;
  bool get isLoadingNewRanking => _isLoadingNewRanking;

  List<StudentModel> _missingStudents = [];
  List<StudentModel> get missingStudents => _missingStudents;

  // Fetch missing students by homework ID
  Future<void> fetchMissingStudentsByHomeworkId({
    required int homeworkId,
  }) async {
    _isLoadingMissingStudents = true;
    _missingStudents = [];
    notifyListeners();
    try {
      final response = await HomeworksServices()
          .fetchMissingStudentsByHomeworkId(homeworkId: homeworkId);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['students'] != null) {
          final List studentsJson = data['students'];
          _missingStudents =
              studentsJson.map((json) => StudentModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      log('Error fetching missing students: $e');
    } finally {
      _isLoadingMissingStudents = false;
      notifyListeners();
    }
  }

  // Submit ranking for newly added missing students
  Future<void> newStudentsHomeworkRanking({
    required BuildContext context,
    required int homeworkId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    _isLoadingNewRanking = true;
    notifyListeners();
    try {
      final response = await HomeworksServices().newStudentsHomeworkRanking(
        homeworkId: homeworkId,
        assignments: assignments,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleHomework(
          homeworkId: homeworkId,
          viewerType: HomeworkViewerType.teacherView,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "New students homework ranking added successfully",
          type: SnackbarType.success,
        );
      } else {
        log("New homework ranking failed: ${response.statusCode}");
        if (!context.mounted) return;
        CustomErrorDialog.show(
          context,
          response.data?["message"] ??
              "Failed to add new students homework ranking",
        );
      }
    } catch (e) {
      log('Error submitting new homework ranking: $e');
      if (context.mounted) {
        CustomErrorDialog.show(context, "An error occurred. Please try again.");
      }
    } finally {
      _isLoadingNewRanking = false;
      notifyListeners();
    }
  }

  //homework ranking
  Future<void> homeworkRanking({
    required BuildContext context,
    required int homeworkId,
    required List<Map<String, dynamic>> assignments,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await HomeworksServices().homeworkRanking(
        homeworkId: homeworkId,
        assignments: assignments,
      );

      if (response.statusCode == 200) {
        await fetchSingleHomework(
          homeworkId: homeworkId,
          viewerType: HomeworkViewerType.teacherView,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
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
    _isLoading = false;
    notifyListeners();
  }

  // update points
  void updatePoint(int studentId, int point) {
    _studentPoints[studentId] = point;
    notifyListeners();
  }

  //homework remark section
  Future<void> addHomeworkRemarks({
    required BuildContext context,
    required int studentHomeworkId,
    required String remarks,
  }) async {
    _isLoadingRemarks = true;
    notifyListeners();

    try {
      final response = await HomeworksServices().addHomeworkRemarks(
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
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Remarks added",
          type: SnackbarType.success,
        );
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
      _isLoadingRemarks = false;

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

  //edit homeworks
  Future<void> edithomeWork({
    required BuildContext context,
    required int subjectId,
    required String title,
    required String description,
    required String duedate,
    required int homeworkId,
    String? homeworkType,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await HomeworksServices().editHomeWork(
        context: context,
        homeworkId: homeworkId,
        subjectId: subjectId,
        title: title,
        description: description,
        duedate: duedate,
        type: homeworkType,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleHomework(
          homeworkId: homeworkId,
          viewerType: HomeworkViewerType.teacherView,
        );
        await fetchHomeworks(
          forceRefresh: true,
          viewerType: HomeworkViewerType.teacherView,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
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
      _isLoading = false;
      notifyListeners();
    }
  }

  //upload file and remarks guardian
  Future<void> uploadFileAndRemarksByGuardian({
    required BuildContext context,
    required int studentHomeworkId,
    required int studentId,
    required int homeworkId,
    String? remarks,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await HomeworksServices().uploadFileAndRemarksByGuardian(
        context: context,
        studentHomeworkId: studentHomeworkId,
        remarks: remarks,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleHomework(
          homeworkId: homeworkId,
          studentId: studentId,
          viewerType: HomeworkViewerType.guardianStudentView,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Homework Assignment Uploaded',
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 400) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: '${response.data["error"]}. cant upload',
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //delete homework
  Future<void> deleteHomeWork({required BuildContext context}) async {
    try {
      final response = await HomeworksServices().deleteHomeWork(
        homeworkId: singleHomework?.id ?? 0,
      );

      if (response.statusCode == 200) {
        await fetchHomeworks(
          forceRefresh: true,
          viewerType: HomeworkViewerType.teacherView,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
        notifyListeners();

        CustomSnackbar.show(
          context,
          message: "Homework deleted",
          type: SnackbarType.success,
        );
      } else {
        log('Failed to delete homework: ${response.statusCode}');
      }
    } catch (e) {
      log('error in the deleting the homework $e');
    }
  }

  //delete student from homework assignment
  Future<void> deleteHomeWorkStudent({
    required BuildContext context,
    required int studentHomeworkId,
    required int homeworkId,
  }) async {
    PopupLoader.show(context, message: "Deleting student...");
    try {
      final response = await HomeworksServices().deleteHomeWorkStudent(
        studentHomeworkId: studentHomeworkId,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleHomework(
          homeworkId: homeworkId,
          viewerType: HomeworkViewerType.teacherView,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Student removed successfully",
          type: SnackbarType.success,
        );
      } else {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Failed to remove student",
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('Delete homework student error: $e');
      if (!context.mounted) return;
      PopupLoader.hide(context);
      CustomSnackbar.show(
        context,
        message: "Something went wrong while removing student",
        type: SnackbarType.failure,
      );
    }
  }
}
