import 'package:acadobs/features/parents/data/models/invoice_model.dart';

class InvoiceStudentInfo {
  final int? id;
  final String? fullName;

  InvoiceStudentInfo({this.id, this.fullName});

  factory InvoiceStudentInfo.fromJson(Map<String, dynamic> json) =>
      InvoiceStudentInfo(
        id: json["id"],
        fullName: json["full_name"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
  };
}

class InvoiceStudent {
  int? id;
  int? invoiceId;
  int? studentId;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  Invoice? invoice;
  double? pendingAmount;
  double? totalAmountPaid;
  InvoiceStudentInfo? student;

  InvoiceStudent({
    this.id,
    this.invoiceId,
    this.studentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.invoice,
    this.pendingAmount,
    this.totalAmountPaid,
    this.student,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double? get totalAmountNum =>
      invoice?.amount != null ? double.tryParse(invoice!.amount!) : null;

  bool get isPartiallyPaid =>
      status?.toLowerCase() == 'partially_paid' ||
      (pendingAmount != null &&
          pendingAmount! > 0 &&
          totalAmountPaid != null &&
          totalAmountPaid! > 0);

  String? get formattedPendingAmount {
    if (pendingAmount == null) return null;
    return pendingAmount! % 1 == 0
        ? pendingAmount!.toInt().toString()
        : pendingAmount!.toStringAsFixed(2);
  }

  String? get formattedTotalPaid {
    if (totalAmountPaid == null) return null;
    return totalAmountPaid! % 1 == 0
        ? totalAmountPaid!.toInt().toString()
        : totalAmountPaid!.toStringAsFixed(2);
  }

  factory InvoiceStudent.fromJson(Map<String, dynamic> json) => InvoiceStudent(
    id: json["id"],
    invoiceId: json["invoice_id"] ?? json["invoiceId"],
    studentId: json["student_id"] ?? json["studentId"],
    status: json["status"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    invoice: json["Invoice"] == null ? null : Invoice.fromJson(json["Invoice"]),
    pendingAmount: _toDouble(json["pendingAmount"] ?? json["pending_amount"]),
    totalAmountPaid:
        _toDouble(json["totalAmountPaid"] ?? json["total_amount_paid"]),
    student:
        json["Student"] == null
            ? null
            : InvoiceStudentInfo.fromJson(json["Student"]),
  );

  InvoiceStudent copyWith({
    int? id,
    int? invoiceId,
    int? studentId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Invoice? invoice,
    double? pendingAmount,
    double? totalAmountPaid,
    InvoiceStudentInfo? student,
  }) {
    return InvoiceStudent(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoice: invoice ?? this.invoice,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      totalAmountPaid: totalAmountPaid ?? this.totalAmountPaid,
      student: student ?? this.student,
    );
  }
}