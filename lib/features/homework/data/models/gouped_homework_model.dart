import 'package:acadobs/features/homework/data/models/homework_model.dart';

class GroupedHomework {
  DateTime? date;
  List<HomeworkModel>? homeworks;

  GroupedHomework({this.date, this.homeworks});

  factory GroupedHomework.fromJson(Map<String, dynamic> json) =>
      GroupedHomework(
        date:
            json["date"] == null
                ? DateTime.parse(json["due_date"])
                : DateTime.parse(json["date"]),
        homeworks:
            json["homeworks"] == null
                ? []
                : List<HomeworkModel>.from(
                  json["homeworks"]!.map((x) => HomeworkModel.fromJson(x)),
                ),
      );
}
