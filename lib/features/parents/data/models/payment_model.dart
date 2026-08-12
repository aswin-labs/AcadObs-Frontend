import 'dart:convert';

import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));


class Payment {
    int? id;
    int? schoolId;
    int? studentId;
    String? paymentCategory;
    String? amount;
    DateTime? paymentDate;
    String? paymentStatus;
    String? transactionId;
    int? invoiceStudentId;
    String? paymentMethod;
    int? recordedBy;
    dynamic updatedBy;
    String? paymentAttachment;
    dynamic remarks;
    bool? trash;
    DateTime? createdAt;
    DateTime? updatedAt;
    InvoiceStudent? invoiceStudent;

    Payment({
        this.id,
        this.schoolId,
        this.studentId,
        this.paymentCategory,
        this.amount,
        this.paymentDate,
        this.paymentStatus,
        this.transactionId,
        this.invoiceStudentId,
        this.paymentMethod,
        this.recordedBy,
        this.updatedBy,
        this.paymentAttachment,
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
        paymentCategory: json["payment_category"],
        amount: json["amount"],
        paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
        paymentStatus: json["payment_status"],
        transactionId: json["transaction_id"],
        invoiceStudentId: json["invoice_student_id"],
        paymentMethod: json["payment_method"],
        recordedBy: json["recorded_by"],
        updatedBy: json["updated_by"],
        paymentAttachment: json["payment_attachment"],
        remarks: json["remarks"],
        trash: json["trash"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        invoiceStudent: json["InvoiceStudent"] == null ? null : InvoiceStudent.fromJson(json["InvoiceStudent"]),
    );
}