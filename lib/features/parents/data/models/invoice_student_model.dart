import 'package:acadobs/features/parents/data/models/invoice_model.dart';

class InvoiceStudent {
  int? id;
  int? invoiceId;
  int? studentId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  Invoice? invoice;

  InvoiceStudent({
    this.id,
    this.invoiceId,
    this.studentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.invoice,
  });

  factory InvoiceStudent.fromJson(Map<String, dynamic> json) => InvoiceStudent(
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
}