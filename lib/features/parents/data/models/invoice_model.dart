class Invoice {
  int? id;
  int? schoolId;
  String? title;
  String? description;
  String? amount;
  DateTime? dueDate;
  String? category;
  int? recordedBy;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;

  Invoice({
    this.id,
    this.schoolId,
    this.title,
    this.description,
    this.amount,
    this.dueDate,
    this.category,
    this.recordedBy,
    this.trash,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"],
    description: json["description"],
    amount: json["amount"],
    dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
    category: json["category"],
    recordedBy: json["recorded_by"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );
}
