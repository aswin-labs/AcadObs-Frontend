class StudentCoScholasticAssessmentItem {
  final int id;
  final int schoolId;
  final int studentId;
  final int examId;
  final int areaId;
  final String? grade;
  final double? score;
  final String? remarks;
  final int? recordedBy;
  final String? assessedAt;
  final String? createdAt;
  final String? updatedAt;
  final StudentCoScholasticAreaInfo? area;
  final StudentCoScholasticStudentInfo? student;
  final StudentCoScholasticExamInfo? exam;
  final StudentCoScholasticRecorderInfo? recorder;

  StudentCoScholasticAssessmentItem({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.examId,
    required this.areaId,
    this.grade,
    this.score,
    this.remarks,
    this.recordedBy,
    this.assessedAt,
    this.createdAt,
    this.updatedAt,
    this.area,
    this.student,
    this.exam,
    this.recorder,
  });

  factory StudentCoScholasticAssessmentItem.fromJson(
      Map<String, dynamic> json) {
    double? parsedScore;
    if (json['score'] != null) {
      parsedScore = double.tryParse(json['score'].toString());
    }

    final rawAssessedAt = json['assessed_at']?.toString();
    final cleanAssessedAt = rawAssessedAt?.split('T').first;

    return StudentCoScholasticAssessmentItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      schoolId: json['school_id'] is int
          ? json['school_id']
          : int.tryParse(json['school_id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id'] is int
          ? json['student_id']
          : int.tryParse(json['student_id']?.toString() ?? '0') ?? 0,
      examId: json['exam_id'] is int
          ? json['exam_id']
          : int.tryParse(json['exam_id']?.toString() ?? '0') ?? 0,
      areaId: json['area_id'] is int
          ? json['area_id']
          : int.tryParse(json['area_id']?.toString() ?? '0') ?? 0,
      grade: json['grade']?.toString(),
      score: parsedScore,
      remarks: json['remarks']?.toString(),
      recordedBy: json['recorded_by'] is int
          ? json['recorded_by']
          : int.tryParse(json['recorded_by']?.toString() ?? ''),
      assessedAt: cleanAssessedAt,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      area: json['CoScholasticArea'] is Map<String, dynamic>
          ? StudentCoScholasticAreaInfo.fromJson(json['CoScholasticArea'])
          : null,
      student: json['Student'] is Map<String, dynamic>
          ? StudentCoScholasticStudentInfo.fromJson(json['Student'])
          : null,
      exam: json['exam'] is Map<String, dynamic>
          ? StudentCoScholasticExamInfo.fromJson(json['exam'])
          : null,
      recorder: json['Recorder'] is Map<String, dynamic>
          ? StudentCoScholasticRecorderInfo.fromJson(json['Recorder'])
          : null,
    );
  }

  static List<StudentCoScholasticAssessmentItem> fromJsonList(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => StudentCoScholasticAssessmentItem.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

class StudentCoScholasticAreaInfo {
  final int id;
  final String name;
  final String? classGroup;
  final int? displayOrder;
  final bool status;

  StudentCoScholasticAreaInfo({
    required this.id,
    required this.name,
    this.classGroup,
    this.displayOrder,
    this.status = true,
  });

  factory StudentCoScholasticAreaInfo.fromJson(Map<String, dynamic> json) {
    return StudentCoScholasticAreaInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      classGroup: json['class_group']?.toString(),
      displayOrder: json['display_order'] is int
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? ''),
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == 'true',
    );
  }
}

class StudentCoScholasticExamInfo {
  final int id;
  final String examName;
  final String? educationYear;

  StudentCoScholasticExamInfo({
    required this.id,
    required this.examName,
    this.educationYear,
  });

  factory StudentCoScholasticExamInfo.fromJson(Map<String, dynamic> json) {
    return StudentCoScholasticExamInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      examName: json['exam_name']?.toString() ?? '',
      educationYear: json['education_year']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentCoScholasticExamInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class StudentCoScholasticRecorderInfo {
  final int id;
  final String name;
  final String? email;

  StudentCoScholasticRecorderInfo({
    required this.id,
    required this.name,
    this.email,
  });

  factory StudentCoScholasticRecorderInfo.fromJson(Map<String, dynamic> json) {
    return StudentCoScholasticRecorderInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }
}

class StudentCoScholasticStudentInfo {
  final int id;
  final String fullName;
  final int? rollNumber;

  StudentCoScholasticStudentInfo({
    required this.id,
    required this.fullName,
    this.rollNumber,
  });

  factory StudentCoScholasticStudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentCoScholasticStudentInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      rollNumber: json['roll_number'] is int
          ? json['roll_number']
          : int.tryParse(json['roll_number']?.toString() ?? ''),
    );
  }
}

/// Grouped model structure for displaying co-scholastic areas across terms.
class GroupedCoScholasticArea {
  final int id;
  final String name;
  final String? classGroup;
  final int displayOrder;
  final Map<int, StudentCoScholasticAssessmentItem> examAssessments;

  GroupedCoScholasticArea({
    required this.id,
    required this.name,
    this.classGroup,
    required this.displayOrder,
    required this.examAssessments,
  });

  StudentCoScholasticAssessmentItem? getAssessmentForExam(int examId) {
    return examAssessments[examId];
  }
}

class StudentCoScholasticHelper {
  /// Groups raw assessment items by Co-Scholastic Area -> Exams (Terms)
  static List<GroupedCoScholasticArea> groupAssessments(
      List<StudentCoScholasticAssessmentItem> items) {
    final Map<int, Map<String, dynamic>> areaMap = {};

    for (final item in items) {
      final aId = item.areaId;
      if (!areaMap.containsKey(aId)) {
        areaMap[aId] = {
          'id': aId,
          'name': item.area?.name.isNotEmpty == true
              ? item.area!.name
              : 'Area $aId',
          'classGroup': item.area?.classGroup,
          'displayOrder': item.area?.displayOrder ?? aId,
          'examAssessments': <int, StudentCoScholasticAssessmentItem>{},
        };
      }

      final assessments = areaMap[aId]!['examAssessments']
          as Map<int, StudentCoScholasticAssessmentItem>;
      assessments[item.examId] = item;
    }

    final List<GroupedCoScholasticArea> result = [];
    for (final aEntry in areaMap.values) {
      result.add(
        GroupedCoScholasticArea(
          id: aEntry['id'] as int,
          name: aEntry['name'] as String,
          classGroup: aEntry['classGroup'] as String?,
          displayOrder: aEntry['displayOrder'] as int,
          examAssessments: aEntry['examAssessments']
              as Map<int, StudentCoScholasticAssessmentItem>,
        ),
      );
    }

    result.sort((a, b) {
      final cmp = a.displayOrder.compareTo(b.displayOrder);
      return cmp != 0 ? cmp : a.id.compareTo(b.id);
    });

    return result;
  }

  /// Extracts unique exams sorted by id
  static List<StudentCoScholasticExamInfo> getUniqueExams(
      List<StudentCoScholasticAssessmentItem> items) {
    final Map<int, StudentCoScholasticExamInfo> examMap = {};
    for (final item in items) {
      if (item.exam != null && !examMap.containsKey(item.examId)) {
        examMap[item.examId] = item.exam!;
      }
    }
    final exams = examMap.values.toList();
    exams.sort((a, b) => a.id.compareTo(b.id));
    return exams;
  }
}
