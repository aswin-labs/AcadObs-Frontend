import 'dart:convert';

import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

class PaymentStudentInfo {
  final int? id;
  final String? fullName;
  final String? regNo;
  final String? image;

  PaymentStudentInfo({
    this.id,
    this.fullName,
    this.regNo,
    this.image,
  });

  factory PaymentStudentInfo.fromJson(Map<String, dynamic> json) =>
      PaymentStudentInfo(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        fullName: json["full_name"]?.toString(),
        regNo: json["reg_no"]?.toString(),
        image: json["image"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "reg_no": regNo,
    "image": image,
  };
}

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
  int? transportInvoiceId;
  String? paymentMethod;
  int? recordedBy;
  dynamic updatedBy;
  String? paymentAttachment;
  dynamic remarks;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  InvoiceStudent? invoiceStudent;
  TransportInvoice? transportInvoice;
  PaymentStudentInfo? student;

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
    this.transportInvoiceId,
    this.paymentMethod,
    this.recordedBy,
    this.updatedBy,
    this.paymentAttachment,
    this.remarks,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.invoiceStudent,
    this.transportInvoice,
    this.student,
  });

  bool get isTransportPayment =>
      transportInvoice != null ||
      transportInvoiceId != null ||
      (paymentCategory?.toLowerCase() == 'transport');

  bool get isInvoicePayment =>
      invoiceStudent != null || invoiceStudentId != null;

  bool get isPending =>
      paymentStatus?.toLowerCase() == 'pending' ||
      paymentStatus?.toLowerCase() == 'waiting_for_approval';

  factory Payment.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataMap =
        (json['data'] != null && json['data'] is Map)
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;

    return Payment(
      id: dataMap["id"] is int
          ? dataMap["id"]
          : int.tryParse(dataMap["id"]?.toString() ?? ''),
      schoolId: dataMap["school_id"] is int
          ? dataMap["school_id"]
          : int.tryParse(dataMap["school_id"]?.toString() ?? ''),
      studentId: dataMap["student_id"] is int
          ? dataMap["student_id"]
          : int.tryParse(dataMap["student_id"]?.toString() ?? ''),
      paymentCategory:
          dataMap["payment_category"]?.toString() ??
          dataMap["paymentCategory"]?.toString(),
      amount: dataMap["amount"]?.toString(),
      paymentDate: dataMap["payment_date"] == null
          ? (dataMap["paymentDate"] == null
              ? null
              : DateTime.tryParse(dataMap["paymentDate"].toString()))
          : DateTime.tryParse(dataMap["payment_date"].toString()),
      paymentStatus:
          dataMap["payment_status"]?.toString() ??
          dataMap["paymentStatus"]?.toString(),
      transactionId:
          dataMap["transaction_id"]?.toString() ??
          dataMap["transactionId"]?.toString(),
      invoiceStudentId: dataMap["invoice_student_id"] is int
          ? dataMap["invoice_student_id"]
          : int.tryParse(dataMap["invoice_student_id"]?.toString() ?? ''),
      transportInvoiceId: dataMap["transport_invoice_id"] is int
          ? dataMap["transport_invoice_id"]
          : int.tryParse(dataMap["transport_invoice_id"]?.toString() ?? ''),
      paymentMethod:
          dataMap["payment_method"]?.toString() ??
          dataMap["paymentMethod"]?.toString(),
      recordedBy: dataMap["recorded_by"] is int
          ? dataMap["recorded_by"]
          : int.tryParse(dataMap["recorded_by"]?.toString() ?? ''),
      updatedBy: dataMap["updated_by"],
      paymentAttachment:
          dataMap["payment_attachment"]?.toString() ??
          dataMap["paymentAttachment"]?.toString(),
      remarks: dataMap["remarks"],
      trash: dataMap["trash"] is bool ? dataMap["trash"] : false,
      createdAt: dataMap["createdAt"] == null
          ? null
          : DateTime.tryParse(dataMap["createdAt"].toString()),
      updatedAt: dataMap["updatedAt"] == null
          ? null
          : DateTime.tryParse(dataMap["updatedAt"].toString()),
      invoiceStudent: dataMap["InvoiceStudent"] == null
          ? null
          : InvoiceStudent.fromJson(
              Map<String, dynamic>.from(dataMap["InvoiceStudent"] as Map),
            ),
      transportInvoice: dataMap["TransportInvoice"] == null
          ? null
          : TransportInvoice.fromJson(
              Map<String, dynamic>.from(dataMap["TransportInvoice"] as Map),
            ),
      student: dataMap["Student"] == null
          ? null
          : PaymentStudentInfo.fromJson(
              Map<String, dynamic>.from(dataMap["Student"] as Map),
            ),
    );
  }

  Payment copyWith({
    int? id,
    int? schoolId,
    int? studentId,
    String? paymentCategory,
    String? amount,
    DateTime? paymentDate,
    String? paymentStatus,
    String? transactionId,
    int? invoiceStudentId,
    int? transportInvoiceId,
    String? paymentMethod,
    int? recordedBy,
    dynamic updatedBy,
    String? paymentAttachment,
    dynamic remarks,
    bool? trash,
    DateTime? createdAt,
    DateTime? updatedAt,
    InvoiceStudent? invoiceStudent,
    TransportInvoice? transportInvoice,
    PaymentStudentInfo? student,
  }) {
    return Payment(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      paymentCategory: paymentCategory ?? this.paymentCategory,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
      invoiceStudentId: invoiceStudentId ?? this.invoiceStudentId,
      transportInvoiceId: transportInvoiceId ?? this.transportInvoiceId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedBy: recordedBy ?? this.recordedBy,
      updatedBy: updatedBy ?? this.updatedBy,
      paymentAttachment: paymentAttachment ?? this.paymentAttachment,
      remarks: remarks ?? this.remarks,
      trash: trash ?? this.trash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoiceStudent: invoiceStudent ?? this.invoiceStudent,
      transportInvoice: transportInvoice ?? this.transportInvoice,
      student: student ?? this.student,
    );
  }
}