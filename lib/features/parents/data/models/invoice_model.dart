class InvoiceModel {
  int? id;
  int? invoiceId;
  int? studentId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  Invoice? invoice;

  InvoiceModel({
    this.id,
    this.invoiceId,
    this.studentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.invoice,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    id: json["id"],
    invoiceId: json["invoice_id"],
    studentId: json["student_id"],
    status: json["status"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    invoice: json["Invoice"] == null ? null : Invoice.fromJson(json["Invoice"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_id": invoiceId,
    "student_id": studentId,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "Invoice": invoice?.toJson(),
  };
}

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

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_id": schoolId,
    "title": title,
    "description": description,
    "amount": amount,
    "due_date":
        dueDate == null
            ? null
            : "${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}",
    "category": category,
    "recorded_by": recordedBy,
    "trash": trash,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
