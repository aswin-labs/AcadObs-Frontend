class MusicArtsRoboticsAreaItem {
  final int id;
  final int? schoolId;
  final int? syllabusId;
  final String name;
  final String? classGroup;
  final int? displayOrder;
  final bool? status;

  const MusicArtsRoboticsAreaItem({
    required this.id,
    this.schoolId,
    this.syllabusId,
    required this.name,
    this.classGroup,
    this.displayOrder,
    this.status,
  });

  factory MusicArtsRoboticsAreaItem.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final schoolIdRaw = json['school_id'];
    final syllabusIdRaw = json['syllabus_id'];
    final displayOrderRaw = json['display_order'];

    return MusicArtsRoboticsAreaItem(
      id: idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '0') ?? 0,
      schoolId:
          schoolIdRaw is int
              ? schoolIdRaw
              : int.tryParse(schoolIdRaw?.toString() ?? ''),
      syllabusId:
          syllabusIdRaw is int
              ? syllabusIdRaw
              : int.tryParse(syllabusIdRaw?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      classGroup: json['class_group']?.toString(),
      displayOrder:
          displayOrderRaw is int
              ? displayOrderRaw
              : int.tryParse(displayOrderRaw?.toString() ?? ''),
      status: json['status'] is bool ? json['status'] as bool : null,
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

class StudentMusicArtsRoboticsEntry {
  final int studentId;
  // Map of areaId -> grade string (e.g. {3: 'A', 4: 'B'})
  final Map<int, String> areaGrades;

  StudentMusicArtsRoboticsEntry({
    required this.studentId,
    Map<int, String>? areaGrades,
  }) : areaGrades = areaGrades ?? {};

  String getGrade(int areaId) => areaGrades[areaId] ?? '';

  void setGrade(int areaId, String grade) {
    if (grade.trim().isEmpty) {
      areaGrades.remove(areaId);
    } else {
      areaGrades[areaId] = grade.trim();
    }
  }

  bool hasGrade(int areaId) {
    final g = areaGrades[areaId];
    return g != null && g.trim().isNotEmpty;
  }

  bool get hasAnyGrade => areaGrades.values.any((g) => g.trim().isNotEmpty);

  int get gradedCount =>
      areaGrades.values.where((g) => g.trim().isNotEmpty).length;

  bool isComplete(List<MusicArtsRoboticsAreaItem> areas) {
    if (areas.isEmpty) return false;
    for (final area in areas) {
      if (!hasGrade(area.id)) return false;
    }
    return true;
  }

  StudentMusicArtsRoboticsEntry copyWith({
    int? studentId,
    Map<int, String>? areaGrades,
  }) {
    return StudentMusicArtsRoboticsEntry(
      studentId: studentId ?? this.studentId,
      areaGrades: areaGrades != null ? Map.from(areaGrades) : Map.from(this.areaGrades),
    );
  }
}

class MusicArtsRoboticsHistoryRecord {
  final String id;
  final int examId;
  final String examName;
  final String standard;
  final String className;
  final int? classId;
  final String assessedAt;
  final int studentCount;
  final List<String> areaNames;
  final List<Map<String, dynamic>> studentDetails;

  const MusicArtsRoboticsHistoryRecord({
    required this.id,
    required this.examId,
    required this.examName,
    required this.standard,
    required this.className,
    this.classId,
    required this.assessedAt,
    required this.studentCount,
    required this.areaNames,
    this.studentDetails = const [],
  });
}
