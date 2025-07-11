class ClassGradeModel {
  int id;
  String classname;

  ClassGradeModel({required this.id, required this.classname});

  factory ClassGradeModel.fromJson(Map<String, dynamic> json) =>
      ClassGradeModel(id: json["id"], classname: json["classname"]);
}