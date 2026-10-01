import 'dart:convert';

StudentProgressReportModel studentProgressReportModelFromJson(String str) =>
    StudentProgressReportModel.fromJson(json.decode(str));

String studentProgressReportModelToJson(StudentProgressReportModel data) =>
    json.encode(data.toJson());

class StudentProgressReportModel {
  final String? educationYear;
  final ProgressReportStudent? student;
  final List<ProgressReportExam> exams;
  final List<ProgressReportColumn> columns;
  final List<ProgressReportSubject> subjects;

  StudentProgressReportModel({
    this.educationYear,
    this.student,
    this.exams = const [],
    this.columns = const [],
    this.subjects = const [],
  });

  factory StudentProgressReportModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return StudentProgressReportModel(
      educationYear: data['education_year']?.toString(),
      student:
          data['student'] != null
              ? ProgressReportStudent.fromJson(data['student'])
              : null,
      exams:
          (data['exams'] as List<dynamic>?)
              ?.map((e) => ProgressReportExam.fromJson(e))
              .toList() ??
          [],
      columns:
          (data['columns'] as List<dynamic>?)
              ?.map((c) => ProgressReportColumn.fromJson(c))
              .toList() ??
          [],
      subjects:
          (data['subjects'] as List<dynamic>?)
              ?.map((s) => ProgressReportSubject.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'education_year': educationYear,
    'student': student?.toJson(),
    'exams': exams.map((e) => e.toJson()).toList(),
    'columns': columns.map((c) => c.toJson()).toList(),
    'subjects': subjects.map((s) => s.toJson()).toList(),
  };

  /// Returns columns filtered by [examId].
  List<ProgressReportColumn> getColumnsForExam(int examId) {
    return columns.where((c) => c.examId == examId).toList();
  }
}

class ProgressReportStudent {
  final int? id;
  final String? fullName;
  final int? rollNumber;
  final int? classId;
  final String? className;

  ProgressReportStudent({
    this.id,
    this.fullName,
    this.rollNumber,
    this.classId,
    this.className,
  });

  factory ProgressReportStudent.fromJson(Map<String, dynamic> json) {
    return ProgressReportStudent(
      id: _toInt(json['id']),
      fullName: json['full_name']?.toString(),
      rollNumber: _toInt(json['roll_number']),
      classId: _toInt(json['class_id']),
      className: json['class_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'roll_number': rollNumber,
    'class_id': classId,
    'class_name': className,
  };
}

class ProgressReportExam {
  final int? examId;
  final String? examName;
  final String? educationYear;
  final List<ProgressReportInternal> internals;

  ProgressReportExam({
    this.examId,
    this.examName,
    this.educationYear,
    this.internals = const [],
  });

  factory ProgressReportExam.fromJson(Map<String, dynamic> json) {
    return ProgressReportExam(
      examId: _toInt(json['exam_id']),
      examName: json['exam_name']?.toString(),
      educationYear: json['education_year']?.toString(),
      internals:
          (json['internals'] as List<dynamic>?)
              ?.map((i) => ProgressReportInternal.fromJson(i))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'exam_id': examId,
    'exam_name': examName,
    'education_year': educationYear,
    'internals': internals.map((i) => i.toJson()).toList(),
  };
}

class ProgressReportInternal {
  final int? internalId;
  final String? internalName;
  final String? maxMarks;
  final String? date;

  ProgressReportInternal({
    this.internalId,
    this.internalName,
    this.maxMarks,
    this.date,
  });

  double? get maxMarksNum =>
      maxMarks != null ? double.tryParse(maxMarks!) : null;

  factory ProgressReportInternal.fromJson(Map<String, dynamic> json) {
    return ProgressReportInternal(
      internalId: _toInt(json['internal_id']),
      internalName: json['internal_name']?.toString(),
      maxMarks: json['max_marks']?.toString(),
      date: json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'internal_id': internalId,
    'internal_name': internalName,
    'max_marks': maxMarks,
    'date': date,
  };
}

class ProgressReportColumn {
  final String key;
  final int? examId;
  final String? examName;
  final int? internalId;
  final String? internalName;
  final String? maxMarks;

  ProgressReportColumn({
    required this.key,
    this.examId,
    this.examName,
    this.internalId,
    this.internalName,
    this.maxMarks,
  });

  double? get maxMarksNum =>
      maxMarks != null ? double.tryParse(maxMarks!) : null;

  factory ProgressReportColumn.fromJson(Map<String, dynamic> json) {
    return ProgressReportColumn(
      key: json['key']?.toString() ?? '',
      examId: _toInt(json['exam_id']),
      examName: json['exam_name']?.toString(),
      internalId: _toInt(json['internal_id']),
      internalName: json['internal_name']?.toString(),
      maxMarks: json['max_marks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'exam_id': examId,
    'exam_name': examName,
    'internal_id': internalId,
    'internal_name': internalName,
    'max_marks': maxMarks,
  };
}

class ProgressReportMarkEntry {
  final String? marksObtained;
  final String? status;
  final String? maxMarks;

  ProgressReportMarkEntry({
    this.marksObtained,
    this.status,
    this.maxMarks,
  });

  double? get marksObtainedNum =>
      marksObtained != null ? double.tryParse(marksObtained!) : null;

  double? get maxMarksNum =>
      maxMarks != null ? double.tryParse(maxMarks!) : null;

  bool get isAbsent => status?.toLowerCase() == 'absent';
  bool get isPresent => status?.toLowerCase() == 'present';
  bool get hasAttempted => marksObtained != null || status != null;

  factory ProgressReportMarkEntry.fromJson(Map<String, dynamic> json) {
    return ProgressReportMarkEntry(
      marksObtained: json['marks_obtained']?.toString(),
      status: json['status']?.toString(),
      maxMarks: json['max_marks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'marks_obtained': marksObtained,
    'status': status,
    'max_marks': maxMarks,
  };
}

class ProgressReportSubject {
  final int? subjectId;
  final String? subjectName;
  final int? priority;
  final Map<String, ProgressReportMarkEntry> marksByColumnKey;

  ProgressReportSubject({
    this.subjectId,
    this.subjectName,
    this.priority,
    this.marksByColumnKey = const {},
  });

  factory ProgressReportSubject.fromJson(Map<String, dynamic> json) {
    final Map<String, ProgressReportMarkEntry> marks = {};

    json.forEach((key, value) {
      if (key != 'subject_id' &&
          key != 'subject_name' &&
          key != 'priority' &&
          value is Map<String, dynamic>) {
        marks[key] = ProgressReportMarkEntry.fromJson(value);
      }
    });

    return ProgressReportSubject(
      subjectId: _toInt(json['subject_id']),
      subjectName: json['subject_name']?.toString(),
      priority: _toInt(json['priority']),
      marksByColumnKey: marks,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'priority': priority,
    };
    marksByColumnKey.forEach((key, value) {
      json[key] = value.toJson();
    });
    return json;
  }

  ProgressReportMarkEntry? getMarkForColumn(String columnKey) =>
      marksByColumnKey[columnKey];
}

int? _toInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  return int.tryParse(val.toString());
}
