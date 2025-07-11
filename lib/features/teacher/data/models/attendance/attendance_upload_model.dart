class AttendanceUploadModel {
  final int classId;
  final String className;
  final String date;
  final int period;
  int? subjectId;
  String? subjectName;
  AttendanceUploadModel({
    required this.classId,
    required this.date,
    required this.className,
    required this.period,
    this.subjectId,
    this.subjectName
  });
}
