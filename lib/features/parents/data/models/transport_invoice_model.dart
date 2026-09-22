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
  });

  factory TransportInvoice.fromJson(Map<String, dynamic> json) {
    return TransportInvoice(
      id: json['id'] is int
          ? json['id']
          : json['transport_invoice_id'] is int
          ? json['transport_invoice_id']
          : int.tryParse(json['id']?.toString() ?? '') ??
              int.tryParse(json['transport_invoice_id']?.toString() ?? ''),
      schoolId: json['school_id'] is int
          ? json['school_id']
          : json['schoolId'] is int
          ? json['schoolId']
          : int.tryParse(json['school_id']?.toString() ?? '') ??
              int.tryParse(json['schoolId']?.toString() ?? ''),
      stopId: json['stop_id'] is int
          ? json['stop_id']
          : json['stopId'] is int
          ? json['stopId']
          : int.tryParse(json['stop_id']?.toString() ?? '') ??
              int.tryParse(json['stopId']?.toString() ?? ''),
      studentId: json['student_id'] is int
          ? json['student_id']
          : json['studentId'] is int
          ? json['studentId']
          : int.tryParse(json['student_id']?.toString() ?? '') ??
              int.tryParse(json['studentId']?.toString() ?? ''),
      amount: json['amount']?.toString(),
      term: json['term']?.toString(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      status: json['status']?.toString(),
      trash: json['trash'] is bool ? json['trash'] : false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      stop: json['Stop'] != null && json['Stop'] is Map
          ? TransportStop.fromJson(Map<String, dynamic>.from(json['Stop'] as Map))
          : json['stop'] != null && json['stop'] is Map
          ? TransportStop.fromJson(Map<String, dynamic>.from(json['stop'] as Map))
          : null,
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
  };
}

class TransportStop {
  final int? id;
  final String? stopName;
  final List<TransportRoute>? routes;

  TransportStop({
    this.id,
    this.stopName,
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
      routes: routesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stop_name': stopName,
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
