class TransportInvoice {
  final int? id;
  final int? schoolId;
  final int? stopId;
  final int? studentId;
  final String? amount;
  final String? term;
  final DateTime? dueDate;
  final String? status;
  final bool? trash;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TransportStop? stop;
  final double? pendingAmount;
  final double? totalAmountPaid;

  TransportInvoice({
    this.id,
    this.schoolId,
    this.stopId,
    this.studentId,
    this.amount,
    this.term,
    this.dueDate,
    this.status,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.stop,
    this.pendingAmount,
    this.totalAmountPaid,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double? get totalAmountNum => amount != null ? double.tryParse(amount!) : null;

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

  factory TransportInvoice.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataMap =
        (json['data'] != null && json['data'] is Map)
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;

    final rawPendingAmount =
        json['pendingAmount'] ??
        json['pending_amount'] ??
        dataMap['pendingAmount'] ??
        dataMap['pending_amount'];

    final rawTotalAmountPaid =
        json['totalAmountPaid'] ??
        json['total_amount_paid'] ??
        json['totalPaidAmount'] ??
        dataMap['totalAmountPaid'] ??
        dataMap['total_amount_paid'] ??
        dataMap['totalPaidAmount'];

    return TransportInvoice(
      id: dataMap['id'] is int
          ? dataMap['id']
          : dataMap['transport_invoice_id'] is int
          ? dataMap['transport_invoice_id']
          : int.tryParse(dataMap['id']?.toString() ?? '') ??
              int.tryParse(dataMap['transport_invoice_id']?.toString() ?? ''),
      schoolId: dataMap['school_id'] is int
          ? dataMap['school_id']
          : dataMap['schoolId'] is int
          ? dataMap['schoolId']
          : int.tryParse(dataMap['school_id']?.toString() ?? '') ??
              int.tryParse(dataMap['schoolId']?.toString() ?? ''),
      stopId: dataMap['stop_id'] is int
          ? dataMap['stop_id']
          : dataMap['stopId'] is int
          ? dataMap['stopId']
          : int.tryParse(dataMap['stop_id']?.toString() ?? '') ??
              int.tryParse(dataMap['stopId']?.toString() ?? ''),
      studentId: dataMap['student_id'] is int
          ? dataMap['student_id']
          : dataMap['studentId'] is int
          ? dataMap['studentId']
          : int.tryParse(dataMap['student_id']?.toString() ?? '') ??
              int.tryParse(dataMap['studentId']?.toString() ?? ''),
      amount: dataMap['amount']?.toString(),
      term: dataMap['term']?.toString(),
      dueDate: dataMap['due_date'] != null
          ? DateTime.tryParse(dataMap['due_date'].toString())
          : dataMap['dueDate'] != null
          ? DateTime.tryParse(dataMap['dueDate'].toString())
          : null,
      status: dataMap['status']?.toString(),
      trash: dataMap['trash'] is bool ? dataMap['trash'] : false,
      createdAt: dataMap['createdAt'] != null
          ? DateTime.tryParse(dataMap['createdAt'].toString())
          : null,
      updatedAt: dataMap['updatedAt'] != null
          ? DateTime.tryParse(dataMap['updatedAt'].toString())
          : null,
      stop: dataMap['Stop'] != null && dataMap['Stop'] is Map
          ? TransportStop.fromJson(Map<String, dynamic>.from(dataMap['Stop'] as Map))
          : dataMap['stop'] != null && dataMap['stop'] is Map
          ? TransportStop.fromJson(Map<String, dynamic>.from(dataMap['stop'] as Map))
          : null,
      pendingAmount: _toDouble(rawPendingAmount),
      totalAmountPaid: _toDouble(rawTotalAmountPaid),
    );
  }

  TransportInvoice copyWith({
    int? id,
    int? schoolId,
    int? stopId,
    int? studentId,
    String? amount,
    String? term,
    DateTime? dueDate,
    String? status,
    bool? trash,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransportStop? stop,
    double? pendingAmount,
    double? totalAmountPaid,
  }) {
    return TransportInvoice(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      stopId: stopId ?? this.stopId,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      term: term ?? this.term,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      trash: trash ?? this.trash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stop: stop ?? this.stop,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      totalAmountPaid: totalAmountPaid ?? this.totalAmountPaid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'school_id': schoolId,
    'stop_id': stopId,
    'student_id': studentId,
    'amount': amount,
    'term': term,
    'due_date': dueDate?.toIso8601String(),
    'status': status,
    'trash': trash,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'Stop': stop?.toJson(),
    'pendingAmount': pendingAmount,
    'totalAmountPaid': totalAmountPaid,
  };
}

class TransportStop {
  final int? id;
  final String? stopName;
  final String? charge;
  final List<TransportRoute>? routes;

  TransportStop({
    this.id,
    this.stopName,
    this.charge,
    this.routes,
  });

  factory TransportStop.fromJson(Map<String, dynamic> json) {
    List<TransportRoute>? routesList;
    if (json['routes'] != null && json['routes'] is List) {
      routesList = (json['routes'] as List)
          .whereType<Map>()
          .map((r) => TransportRoute.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    return TransportStop(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      stopName: json['stop_name']?.toString(),
      charge: json['charge']?.toString(),
      routes: routesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stop_name': stopName,
    'charge': charge,
    'routes': routes?.map((r) => r.toJson()).toList(),
  };
}

class TransportRoute {
  final int? id;
  final String? routeName;
  final String? type; // PICKUP / DROP
  final bool? active;
  final StopRoutePriority? stopRoute;

  TransportRoute({
    this.id,
    this.routeName,
    this.type,
    this.active,
    this.stopRoute,
  });

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    return TransportRoute(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      routeName: json['route_name']?.toString(),
      type: json['type']?.toString(),
      active: json['active'] is bool ? json['active'] : null,
      stopRoute: json['StopRoute'] != null && json['StopRoute'] is Map
          ? StopRoutePriority.fromJson(Map<String, dynamic>.from(json['StopRoute'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'route_name': routeName,
    'type': type,
    'active': active,
    'StopRoute': stopRoute?.toJson(),
  };
}

class StopRoutePriority {
  final int? priority;

  StopRoutePriority({this.priority});

  factory StopRoutePriority.fromJson(Map<String, dynamic> json) {
    return StopRoutePriority(
      priority: json['priority'] is int
          ? json['priority']
          : int.tryParse(json['priority']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'priority': priority,
  };
}
