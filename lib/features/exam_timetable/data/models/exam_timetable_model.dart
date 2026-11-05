import 'package:intl/intl.dart';

class ExamTimetableResponse {
  final bool success;
  final int totalContent;
  final int totalPages;
  final int currentPage;
  final List<ExamTimetableItem> data;

  const ExamTimetableResponse({
    required this.success,
    required this.totalContent,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory ExamTimetableResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
            .whereType<Map<String, dynamic>>()
            .map(ExamTimetableItem.fromJson)
            .toList()
        : <ExamTimetableItem>[];

    return ExamTimetableResponse(
      success: json['success'] == true,
      totalContent: _parseInt(json['totalcontent']),
      totalPages: _parseInt(json['totalPages'], fallback: 1),
      currentPage: _parseInt(json['currentPage'], fallback: 1),
      data: items,
    );
  }
}

class ExamTimetableItem {
  final int id;
  final int schoolId;
  final int examId;
  final int subjectId;
  final String title;
  final int standard;
  final String examDate;
  final String startTime;
  final int durationMinutes;
  final String maxMarks;
  final String passMarks;
  final String? instructions;
  final String status;
  final bool trash;
  final int recordedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ExamInfo? exam;
  final ExamSubjectInfo? subject;
  final ExamUserInfo? user;

  const ExamTimetableItem({
    required this.id,
    required this.schoolId,
    required this.examId,
    required this.subjectId,
    required this.title,
    required this.standard,
    required this.examDate,
    required this.startTime,
    required this.durationMinutes,
    required this.maxMarks,
    required this.passMarks,
    this.instructions,
    required this.status,
    required this.trash,
    required this.recordedBy,
    this.createdAt,
    this.updatedAt,
    this.exam,
    this.subject,
    this.user,
  });

  factory ExamTimetableItem.fromJson(Map<String, dynamic> json) {
    return ExamTimetableItem(
      id: _parseInt(json['id']),
      schoolId: _parseInt(json['school_id']),
      examId: _parseInt(json['exam_id']),
      subjectId: _parseInt(json['subject_id']),
      title: (json['title'] ?? '').toString(),
      standard: _parseInt(json['standard']),
      examDate: (json['exam_date'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      durationMinutes: _parseInt(json['duration_minutes']),
      maxMarks: (json['max_marks'] ?? '').toString(),
      passMarks: (json['pass_marks'] ?? '').toString(),
      instructions: json['instructions']?.toString(),
      status: (json['status'] ?? 'scheduled').toString(),
      trash: json['trash'] == true,
      recordedBy: _parseInt(json['recorded_by']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      exam: json['exam'] is Map<String, dynamic>
          ? ExamInfo.fromJson(json['exam'] as Map<String, dynamic>)
          : null,
      subject: json['Subject'] is Map<String, dynamic>
          ? ExamSubjectInfo.fromJson(json['Subject'] as Map<String, dynamic>)
          : null,
      user: json['User'] is Map<String, dynamic>
          ? ExamUserInfo.fromJson(json['User'] as Map<String, dynamic>)
          : null,
    );
  }

  DateTime? get parsedExamDate {
    if (examDate.trim().isEmpty) return null;
    return DateTime.tryParse(examDate.trim());
  }

  String get formattedDate {
    final dt = parsedExamDate;
    if (dt == null) return examDate;
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String get dayNumber {
    final dt = parsedExamDate;
    if (dt == null) return '--';
    return DateFormat('dd').format(dt);
  }

  String get monthShort {
    final dt = parsedExamDate;
    if (dt == null) return '';
    return DateFormat('MMM').format(dt).toUpperCase();
  }

  String get weekdayShort {
    final dt = parsedExamDate;
    if (dt == null) return '';
    return DateFormat('EEE').format(dt);
  }

  String get weekdayFull {
    final dt = parsedExamDate;
    if (dt == null) return '';
    return DateFormat('EEEE').format(dt);
  }

  String get formattedDuration {
    if (durationMinutes <= 0) return '-';
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m ($durationMinutes mins)';
    } else if (hours > 0) {
      return '${hours} ${hours == 1 ? 'hr' : 'hrs'} ($durationMinutes mins)';
    }
    return '$durationMinutes mins';
  }

  String get cleanMaxMarks => _cleanDecimal(maxMarks);
  String get cleanPassMarks => _cleanDecimal(passMarks);

  String get standardDisplay {
    if (standard == -2) return 'LKG';
    if (standard == -1) return 'UKG';
    return 'Class $standard';
  }

  static String _cleanDecimal(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '-';
    final val = double.tryParse(trimmed);
    if (val == null) return trimmed;
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(2);
  }
}

class ExamInfo {
  final int id;
  final String examName;
  final String educationYear;
  final bool publish;

  const ExamInfo({
    required this.id,
    required this.examName,
    required this.educationYear,
    required this.publish,
  });

  factory ExamInfo.fromJson(Map<String, dynamic> json) {
    return ExamInfo(
      id: _parseInt(json['id']),
      examName: (json['exam_name'] ?? '').toString(),
      educationYear: (json['education_year'] ?? '').toString(),
      publish: json['publish'] == true,
    );
  }
}

class ExamSubjectInfo {
  final int id;
  final String subjectName;
  final String classRange;
  final bool isMultiTeacher;
  final int priority;

  const ExamSubjectInfo({
    required this.id,
    required this.subjectName,
    required this.classRange,
    required this.isMultiTeacher,
    required this.priority,
  });

  factory ExamSubjectInfo.fromJson(Map<String, dynamic> json) {
    return ExamSubjectInfo(
      id: _parseInt(json['id']),
      subjectName: (json['subject_name'] ?? '').toString(),
      classRange: (json['class_range'] ?? '').toString(),
      isMultiTeacher: json['is_multi_teacher'] == true,
      priority: _parseInt(json['priority']),
    );
  }
}

class ExamUserInfo {
  final int id;
  final String name;
  final String email;
  final String role;

  const ExamUserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ExamUserInfo.fromJson(Map<String, dynamic> json) {
    return ExamUserInfo(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value != null) {
    return int.tryParse(value.toString()) ?? fallback;
  }
  return fallback;
}

