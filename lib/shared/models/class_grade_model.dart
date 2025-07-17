class ClassGradeModel {
  int id;
  String classname;
  String? division;
  int? year;

  ClassGradeModel({required this.id, required this.classname, this.division, this.year});

  factory ClassGradeModel.fromJson(Map<String, dynamic> json) =>
      ClassGradeModel(id: json["id"], classname: json["classname"], division:json["division"], year:json["year"]);
}