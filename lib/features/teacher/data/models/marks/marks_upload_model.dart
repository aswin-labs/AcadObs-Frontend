class MarksUploadModel {
  final int classId;
  final String className;
  final int subjectId;
  final String title;
  final int totalMarks;
  final String date;

  MarksUploadModel({
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.title,
    required this.totalMarks,
    required this.date,
  });
}
