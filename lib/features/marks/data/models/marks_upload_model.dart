class MarksUploadModel {
  final bool isTermExam;
  final int classId;
  final String className;
  final int subjectId;
  final String title;
  final int totalMarks;
  final String date;
  String? term;

  MarksUploadModel({
    this.isTermExam = false,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.title,
    required this.totalMarks,
    required this.date,
    this.term,
  });
}
