class StudentPhysicalAssessmentEntry {
  final int studentId;
  String grade;

  StudentPhysicalAssessmentEntry({
    required this.studentId,
    this.grade = '',
  });

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'grade': grade,
  };

  factory StudentPhysicalAssessmentEntry.fromJson(Map<String, dynamic> json) {
    return StudentPhysicalAssessmentEntry(
      studentId:
          json['student_id'] is int
              ? json['student_id'] as int
              : int.tryParse(json['student_id'].toString()) ?? 0,
      grade: json['grade']?.toString() ?? '',
    );
  }

  StudentPhysicalAssessmentEntry copyWith({
    int? studentId,
    String? grade,
  }) {
    return StudentPhysicalAssessmentEntry(
      studentId: studentId ?? this.studentId,
      grade: grade ?? this.grade,
    );
  }
}

class PhysicalAssessmentHistoryRecord {
  final String id;
  final int examId;
  final String examName;
  final String standard;
  final String className;
  final int? classId;
  final String assessedAt;
  final int studentCount;
  final String averageGrade;
  final List<StudentPhysicalAssessmentEntry> assessments;
  final List<Map<String, dynamic>> studentDetails;

  PhysicalAssessmentHistoryRecord({
    required this.id,
    required this.examId,
    required this.examName,
    required this.standard,
    required this.className,
    this.classId,
    required this.assessedAt,
    required this.studentCount,
    required this.averageGrade,
    required this.assessments,
    this.studentDetails = const [],
  });
}

class RecordedCoScholasticItem {
  final int id;
  final int? schoolId;
  final int studentId;
  final int examId;
  final int areaId;
  final String? grade;
  final String? score;
  final String? remarks;
  final int? recordedBy;
  final String assessedAt;
  final String? createdAt;
  final String? updatedAt;
  final String areaName;
  final String studentName;
  final String rollNumber;
  final String regNo;
  final int? classId;
  final String className;
  final String examName;
  final String educationYear;

  RecordedCoScholasticItem({
    required this.id,
    this.schoolId,
    required this.studentId,
    required this.examId,
    required this.areaId,
    this.grade,
    this.score,
    this.remarks,
    this.recordedBy,
    required this.assessedAt,
    this.createdAt,
    this.updatedAt,
    required this.areaName,
    required this.studentName,
    required this.rollNumber,
    required this.regNo,
    this.classId,
    required this.className,
    required this.examName,
    required this.educationYear,
  });

  factory RecordedCoScholasticItem.fromJson(Map<String, dynamic> json) {
    final areaJson = json['CoScholasticArea'] as Map<String, dynamic>?;
    final studentJson = json['Student'] as Map<String, dynamic>?;
    final classJson = studentJson?['Class'] as Map<String, dynamic>?;
    final examJson = json['exam'] as Map<String, dynamic>?;

    final idRaw = json['id'];
    final schoolIdRaw = json['school_id'];
    final studentIdRaw = json['student_id'];
    final examIdRaw = json['exam_id'];
    final areaIdRaw = json['area_id'];
    final recordedByRaw = json['recorded_by'];
    final classIdRaw = classJson != null ? classJson['id'] : null;

    return RecordedCoScholasticItem(
      id: idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '0') ?? 0,
      schoolId: schoolIdRaw is int
          ? schoolIdRaw
          : int.tryParse(schoolIdRaw?.toString() ?? ''),
      studentId: studentIdRaw is int
          ? studentIdRaw
          : int.tryParse(studentIdRaw?.toString() ?? '0') ?? 0,
      examId: examIdRaw is int
          ? examIdRaw
          : int.tryParse(examIdRaw?.toString() ?? '0') ?? 0,
      areaId: areaIdRaw is int
          ? areaIdRaw
          : int.tryParse(areaIdRaw?.toString() ?? '0') ?? 0,
      grade: json['grade']?.toString(),
      score: json['score']?.toString(),
      remarks: json['remarks']?.toString(),
      recordedBy: recordedByRaw is int
          ? recordedByRaw
          : int.tryParse(recordedByRaw?.toString() ?? ''),
      assessedAt: json['assessed_at']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      areaName: areaJson?['name']?.toString() ?? '',
      studentName: studentJson?['full_name']?.toString() ?? '',
      rollNumber: studentJson?['roll_number']?.toString() ?? '',
      regNo: studentJson?['reg_no']?.toString() ?? '',
      classId: classIdRaw is int
          ? classIdRaw
          : int.tryParse(classIdRaw?.toString() ?? ''),
      className: classJson?['classname']?.toString() ?? '',
      examName: examJson?['exam_name']?.toString() ?? '',
      educationYear: examJson?['education_year']?.toString() ?? '',
    );
  }

  RecordedCoScholasticItem copyWith({
    int? id,
    int? schoolId,
    int? studentId,
    int? examId,
    int? areaId,
    String? grade,
    String? score,
    String? remarks,
    int? recordedBy,
    String? assessedAt,
    String? createdAt,
    String? updatedAt,
    String? areaName,
    String? studentName,
    String? rollNumber,
    String? regNo,
    int? classId,
    String? className,
    String? examName,
    String? educationYear,
  }) {
    return RecordedCoScholasticItem(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      examId: examId ?? this.examId,
      areaId: areaId ?? this.areaId,
      grade: grade ?? this.grade,
      score: score ?? this.score,
      remarks: remarks ?? this.remarks,
      recordedBy: recordedBy ?? this.recordedBy,
      assessedAt: assessedAt ?? this.assessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      areaName: areaName ?? this.areaName,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      regNo: regNo ?? this.regNo,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      examName: examName ?? this.examName,
      educationYear: educationYear ?? this.educationYear,
    );
  }
}

class RecordedCoScholasticResponse {
  final int totalContent;
  final int totalPages;
  final int currentPage;
  final List<RecordedCoScholasticItem> data;

  RecordedCoScholasticResponse({
    required this.totalContent,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory RecordedCoScholasticResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return RecordedCoScholasticResponse(
      totalContent: json['totalcontent'] is int
          ? json['totalcontent'] as int
          : int.tryParse(json['totalcontent']?.toString() ?? '0') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages'] as int
          : int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
      currentPage: json['currentPage'] is int
          ? json['currentPage'] as int
          : int.tryParse(json['currentPage']?.toString() ?? '1') ?? 1,
      data: list
          .whereType<Map<String, dynamic>>()
          .map((item) => RecordedCoScholasticItem.fromJson(item))
          .toList(),
    );
  }
}
