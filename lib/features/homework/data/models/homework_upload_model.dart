class HomeworkUploadModel {
  final int classId;
  final String title;
  final String description;
  final String dueDate;
  final String type;
  final int subjectId;

  HomeworkUploadModel({
    required this.classId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.subjectId,
  });
}
