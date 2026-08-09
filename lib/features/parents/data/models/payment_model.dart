// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

import 'package:acadobs/features/parents/data/models/invoice_model.dart';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  int? id;
  int? schoolId;
  int? studentId;
  int? inVoiceStudentId;
  String? paymentType;
  String? amount;
  DateTime? paymentDate;
  String? paymentStatus;
  String? transactionId;
  String? paymentMethod;
  String? paymentAttachment;
  int? recordedBy;
  dynamic remarks;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  InvoiceModel? invoiceStudent;

  Payment({
    this.id,
    this.schoolId,
    this.studentId,
    this.inVoiceStudentId,
    this.paymentType,
    this.amount,
    this.paymentDate,
    this.paymentStatus,
    this.transactionId,
    this.paymentMethod,
    this.paymentAttachment,
    this.recordedBy,
    this.remarks,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.invoiceStudent,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    schoolId: json["school_id"],
    studentId: json["student_id"],
    inVoiceStudentId: json['invoice_student_id'],
    paymentType: json["payment_type"],
    amount: json["amount"],
    paymentDate:
        json["payment_date"] == null
            ? null
            : DateTime.parse(json["payment_date"]),
    paymentStatus: json["payment_status"],
    transactionId: json["transaction_id"],
    paymentMethod: json["payment_method"],
    paymentAttachment: json["payment_attachment"],
    recordedBy: json["recorded_by"],
    remarks: json["remarks"],
    invoiceStudent:
        json['InvoiceStudent'] == null
            ? null
            : InvoiceModel.fromJson(json["InvoiceStudent"]),
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_id": schoolId,
    "student_id": studentId,
    "invoice_student_id": inVoiceStudentId,
    "payment_type": paymentType,
    "amount": amount,
    "payment_date":
        "${paymentDate!.year.toString().padLeft(4, '0')}-${paymentDate!.month.toString().padLeft(2, '0')}-${paymentDate!.day.toString().padLeft(2, '0')}",
    "payment_status": paymentStatus,
    "transaction_id": transactionId,
    "payment_method": paymentMethod,
    "recorded_by": recordedBy,
    "remarks": remarks,
    "trash": trash,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
