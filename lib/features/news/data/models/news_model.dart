import 'dart:convert';

News newsFromJson(String str) => News.fromJson(json.decode(str));

class News {
  int? id;
  int? schoolId;
  String title;
  String content;
  DateTime date;
  int? userId;
  List<NewsImage> images; 
  bool? trash;
  DateTime createdAt;
  DateTime? updatedAt;

  News({
    this.id,
    this.schoolId,
    required this.title,
    required this.content,
    required this.date,
    this.userId,
    required this.images,
    this.trash,
    required this.createdAt,
    this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json["id"],
      schoolId: json["school_id"],
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      date: DateTime.parse(json["date"]),
      userId: json["user_id"],
      images: json["NewsImages"] == null
          ? []
          : (json["NewsImages"] as List)
              .map((e) => NewsImage.fromJson(e))
              .toList(),
      trash: json["trash"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),
    );
  }
}


class NewsImage {
  int? id;
  String? imageUrl;
  String? caption;

  NewsImage({this.id, this.imageUrl, this.caption});
  factory NewsImage.fromJson(Map<String, dynamic> json) => NewsImage(
    id: json["id"],
    imageUrl: json["image_url"],
    caption: json["caption"],
  );
}
