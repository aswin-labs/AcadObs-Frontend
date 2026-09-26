class CoScholasticAreaModel {
  final int id;
  final int? schoolId;
  final int? syllabusId;
  final String name;
  final String? classGroup;
  final int? displayOrder;
  final bool status;

  CoScholasticAreaModel({
    required this.id,
    this.schoolId,
    this.syllabusId,
    required this.name,
    this.classGroup,
    this.displayOrder,
    this.status = true,
  });

  factory CoScholasticAreaModel.fromJson(Map<String, dynamic> json) {
    return CoScholasticAreaModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      schoolId: json['school_id'] as int?,
      syllabusId: json['syllabus_id'] as int?,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'syllabus_id': syllabusId,
        'name': name,
        'class_group': classGroup,
        'display_order': displayOrder,
        'status': status,
      };
}

class StudentCoScholasticAssessmentEntry {
  final int? id;
  final int areaId;
  String grade;
  double? score;
  String remarks;
  String assessedAt;
  final String? recorderName;
  final String? areaName;

  StudentCoScholasticAssessmentEntry({
    this.id,
    required this.areaId,
    this.grade = '',
    this.score,
    this.remarks = '',
    String? assessedAt,
    this.recorderName,
    this.areaName,
  }) : assessedAt = assessedAt ??
            DateTime.now().toIso8601String().split('T').first;

  factory StudentCoScholasticAssessmentEntry.fromJson(
      Map<String, dynamic> json) {
    final rawAreaId = json['area_id'] ??
        json['CoScholasticArea']?['id'] ??
        json['co_scholastic_area_id'];
    final parsedAreaId = rawAreaId is int
        ? rawAreaId
        : int.tryParse(rawAreaId?.toString() ?? '0') ?? 0;

    double? parsedScore;
    if (json['score'] != null) {
      parsedScore = double.tryParse(json['score'].toString());
    }

    return StudentCoScholasticAssessmentEntry(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      areaId: parsedAreaId,
      grade: json['grade']?.toString() ?? '',
      score: parsedScore,
      remarks: json['remarks']?.toString() ?? '',
      assessedAt: json['assessed_at']?.toString().split('T').first ??
          DateTime.now().toIso8601String().split('T').first,
      recorderName: json['Recorder']?['name']?.toString(),
      areaName: json['CoScholasticArea']?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson({required int studentId, required int examId}) {
    final Map<String, dynamic> map = {
      if (id != null) 'id': id,
      'student_id': studentId,
      'exam_id': examId,
      'area_id': areaId,
      'assessed_at': assessedAt,
    };
    if (grade.trim().isNotEmpty) {
      map['grade'] = grade.trim();
    }
    if (score != null) {
      map['score'] = score;
    }
    if (remarks.trim().isNotEmpty) {
      map['remarks'] = remarks.trim();
    }
    return map;
  }
}
