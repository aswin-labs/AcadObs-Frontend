// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  int? id;
  int? schoolId;
  int? studentId;
  String? paymentType;
  String? amount;
  DateTime? paymentDate;
  String? paymentStatus;
  String? transactionId;
  String? paymentMethod;
  int? recordedBy;
  dynamic remarks;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;

  Payment({
    this.id,
    this.schoolId,
    this.studentId,
    this.paymentType,
    this.amount,
    this.paymentDate,
    this.paymentStatus,
    this.transactionId,
    this.paymentMethod,
    this.recordedBy,
    this.remarks,
    this.trash,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    schoolId: json["school_id"],
    studentId: json["student_id"],
    paymentType: json["payment_type"],
    amount: json["amount"],
    paymentDate:
        json["payment_date"] == null
            ? null
            : DateTime.parse(json["payment_date"]),
    paymentStatus: json["payment_status"],
    transactionId: json["transaction_id"],
    paymentMethod: json["payment_method"],
    recordedBy: json["recorded_by"],
    remarks: json["remarks"],
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
