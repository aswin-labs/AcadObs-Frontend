class StudentCompetencyAssessmentItem {
  final int id;
  final int schoolId;
  final int studentId;
  final int examId;
  final int competencyId;
  final int indicatorId;
  final int rating;
  final String remarks;
  final int? recordedBy;
  final String? createdAt;
  final String? updatedAt;
  final StudentCompetencyInfo? competency;
  final StudentCompetencyIndicatorInfo? indicator;
  final StudentCompetencyStudentInfo? student;
  final StudentCompetencyExamInfo? exam;

  StudentCompetencyAssessmentItem({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.examId,
    required this.competencyId,
    required this.indicatorId,
    required this.rating,
    required this.remarks,
    this.recordedBy,
    this.createdAt,
    this.updatedAt,
    this.competency,
    this.indicator,
    this.student,
    this.exam,
  });

  factory StudentCompetencyAssessmentItem.fromJson(Map<String, dynamic> json) {
    int parsedRating = 0;
    if (json['rating'] != null) {
      if (json['rating'] is int) {
        parsedRating = json['rating'] as int;
      } else {
        parsedRating = int.tryParse(json['rating'].toString()) ?? 0;
      }
    }

    return StudentCompetencyAssessmentItem(
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
      competencyId: json['competency_id'] is int
          ? json['competency_id']
          : int.tryParse(json['competency_id']?.toString() ?? '0') ?? 0,
      indicatorId: json['indicator_id'] is int
          ? json['indicator_id']
          : int.tryParse(json['indicator_id']?.toString() ?? '0') ?? 0,
      rating: parsedRating,
      remarks: json['remarks']?.toString() ?? '',
      recordedBy: json['recorded_by'] is int
          ? json['recorded_by']
          : int.tryParse(json['recorded_by']?.toString() ?? ''),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      competency: json['Competency'] is Map<String, dynamic>
          ? StudentCompetencyInfo.fromJson(json['Competency'])
          : null,
      indicator: json['CompetencyIndicator'] is Map<String, dynamic>
          ? StudentCompetencyIndicatorInfo.fromJson(json['CompetencyIndicator'])
          : null,
      student: json['Student'] is Map<String, dynamic>
          ? StudentCompetencyStudentInfo.fromJson(json['Student'])
          : null,
      exam: json['exam'] is Map<String, dynamic>
          ? StudentCompetencyExamInfo.fromJson(json['exam'])
          : null,
    );
  }

  static List<StudentCompetencyAssessmentItem> fromJsonList(dynamic list) {
    if (list is! List) return [];
    return list
        .map((e) => StudentCompetencyAssessmentItem.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

class StudentCompetencyInfo {
  final int id;
  final String title;
  final String? description;
  final int? displayOrder;
  final bool status;

  StudentCompetencyInfo({
    required this.id,
    required this.title,
    this.description,
    this.displayOrder,
    this.status = true,
  });

  factory StudentCompetencyInfo.fromJson(Map<String, dynamic> json) {
    return StudentCompetencyInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      displayOrder: json['display_order'] is int
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? ''),
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == 'true',
    );
  }
}

class StudentCompetencyIndicatorInfo {
  final int id;
  final int? competencyId;
  final String title;
  final int? displayOrder;
  final bool status;

  StudentCompetencyIndicatorInfo({
    required this.id,
    this.competencyId,
    required this.title,
    this.displayOrder,
    this.status = true,
  });

  factory StudentCompetencyIndicatorInfo.fromJson(Map<String, dynamic> json) {
    return StudentCompetencyIndicatorInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      competencyId: json['competency_id'] is int
          ? json['competency_id']
          : int.tryParse(json['competency_id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      displayOrder: json['display_order'] is int
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? ''),
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == 'true',
    );
  }
}

class StudentCompetencyStudentInfo {
  final int id;
  final String fullName;
  final int? rollNumber;

  StudentCompetencyStudentInfo({
    required this.id,
    required this.fullName,
    this.rollNumber,
  });

  factory StudentCompetencyStudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentCompetencyStudentInfo(
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

class StudentCompetencyExamInfo {
  final int id;
  final String examName;
  final String? educationYear;

  StudentCompetencyExamInfo({
    required this.id,
    required this.examName,
    this.educationYear,
  });

  factory StudentCompetencyExamInfo.fromJson(Map<String, dynamic> json) {
    return StudentCompetencyExamInfo(
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
      other is StudentCompetencyExamInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Grouped model structures for displaying Term 1, Term 2, etc. grouped together.
class GroupedCompetency {
  final int id;
  final String title;
  final String? description;
  final int displayOrder;
  final List<GroupedIndicator> indicators;

  GroupedCompetency({
    required this.id,
    required this.title,
    this.description,
    required this.displayOrder,
    required this.indicators,
  });

  double get averageRating {
    int totalRating = 0;
    int count = 0;
    for (final ind in indicators) {
      for (final a in ind.examAssessments.values) {
        if (a.rating > 0) {
          totalRating += a.rating;
          count++;
        }
      }
    }
    return count > 0 ? totalRating / count : 0.0;
  }
}

class GroupedIndicator {
  final int id;
  final int competencyId;
  final String title;
  final int displayOrder;
  final Map<int, StudentCompetencyAssessmentItem> examAssessments;

  GroupedIndicator({
    required this.id,
    required this.competencyId,
    required this.title,
    required this.displayOrder,
    required this.examAssessments,
  });

  StudentCompetencyAssessmentItem? getAssessmentForExam(int examId) {
    return examAssessments[examId];
  }

  double get averageRating {
    if (examAssessments.isEmpty) return 0.0;
    int total = 0;
    int count = 0;
    for (final a in examAssessments.values) {
      if (a.rating > 0) {
        total += a.rating;
        count++;
      }
    }
    return count > 0 ? total / count : 0.0;
  }
}

class StudentCompetencyHelper {
  /// Groups raw assessment items by Competency -> Indicator -> Exams (Terms)
  static List<GroupedCompetency> groupAssessments(
      List<StudentCompetencyAssessmentItem> items) {
    final Map<int, Map<String, dynamic>> compMap = {};

    for (final item in items) {
      final cId = item.competencyId;
      if (!compMap.containsKey(cId)) {
        compMap[cId] = {
          'id': cId,
          'title': item.competency?.title.isNotEmpty == true
              ? item.competency!.title
              : 'Competency $cId',
          'description': item.competency?.description,
          'displayOrder': item.competency?.displayOrder ?? cId,
          'indicators': <int, Map<String, dynamic>>{},
        };
      }

      final indMap =
          compMap[cId]!['indicators'] as Map<int, Map<String, dynamic>>;
      final indId = item.indicatorId;
      if (!indMap.containsKey(indId)) {
        indMap[indId] = {
          'id': indId,
          'competencyId': cId,
          'title': item.indicator?.title.isNotEmpty == true
              ? item.indicator!.title
              : 'Indicator $indId',
          'displayOrder': item.indicator?.displayOrder ?? indId,
          'examAssessments': <int, StudentCompetencyAssessmentItem>{},
        };
      }

      final assessments = indMap[indId]!['examAssessments']
          as Map<int, StudentCompetencyAssessmentItem>;
      assessments[item.examId] = item;
    }

    final List<GroupedCompetency> result = [];
    for (final cEntry in compMap.values) {
      final indMap = cEntry['indicators'] as Map<int, Map<String, dynamic>>;
      final List<GroupedIndicator> indicators = [];

      for (final iEntry in indMap.values) {
        indicators.add(
          GroupedIndicator(
            id: iEntry['id'] as int,
            competencyId: iEntry['competencyId'] as int,
            title: iEntry['title'] as String,
            displayOrder: iEntry['displayOrder'] as int,
            examAssessments: iEntry['examAssessments']
                as Map<int, StudentCompetencyAssessmentItem>,
          ),
        );
      }

      indicators.sort((a, b) {
        final cmp = a.displayOrder.compareTo(b.displayOrder);
        return cmp != 0 ? cmp : a.id.compareTo(b.id);
      });

      result.add(
        GroupedCompetency(
          id: cEntry['id'] as int,
          title: cEntry['title'] as String,
          description: cEntry['description'] as String?,
          displayOrder: cEntry['displayOrder'] as int,
          indicators: indicators,
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
  static List<StudentCompetencyExamInfo> getUniqueExams(
      List<StudentCompetencyAssessmentItem> items) {
    final Map<int, StudentCompetencyExamInfo> examMap = {};
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
