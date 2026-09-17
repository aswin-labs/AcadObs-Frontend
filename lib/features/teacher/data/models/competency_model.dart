class CompetencyModel {
  final int id;
  final String title;
  final String? description;
  final int? displayOrder;
  final bool status;
  final List<CompetencyIndicatorModel> indicators;

  CompetencyModel({
    required this.id,
    required this.title,
    this.description,
    this.displayOrder,
    this.status = true,
    this.indicators = const [],
  });

  factory CompetencyModel.fromJson(Map<String, dynamic> json) {
    return CompetencyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      displayOrder: json['display_order'] is int
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? ''),
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      indicators: (json['CompetencyIndicators'] as List<dynamic>?)
              ?.map((item) => CompetencyIndicatorModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'display_order': displayOrder,
        'status': status,
        'CompetencyIndicators': indicators.map((e) => e.toJson()).toList(),
      };
}

class CompetencyIndicatorModel {
  final int id;
  final String title;
  final bool status;
  final int? displayOrder;

  CompetencyIndicatorModel({
    required this.id,
    required this.title,
    this.status = true,
    this.displayOrder,
  });

  factory CompetencyIndicatorModel.fromJson(Map<String, dynamic> json) {
    return CompetencyIndicatorModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      displayOrder: json['display_order'] is int
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'display_order': displayOrder,
      };
}

class StudentAssessmentEntry {
  final int competencyId;
  final int indicatorId;
  int rating; // 1 to 4
  String remarks;

  StudentAssessmentEntry({
    required this.competencyId,
    required this.indicatorId,
    required this.rating,
    this.remarks = '',
  });

  factory StudentAssessmentEntry.fromJson(Map<String, dynamic> json) {
    final parsedRating = json['rating'] is int
        ? json['rating'] as int
        : int.tryParse(json['rating']?.toString() ?? '0') ?? 0;

    return StudentAssessmentEntry(
      competencyId: json['competency_id'] is int
          ? json['competency_id']
          : int.tryParse(json['competency_id']?.toString() ?? '0') ?? 0,
      indicatorId: json['indicator_id'] is int
          ? json['indicator_id']
          : int.tryParse(json['indicator_id']?.toString() ?? '0') ?? 0,
      rating: parsedRating,
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'competency_id': competencyId,
        'indicator_id': indicatorId,
        'rating': rating.toString(),
        'remarks': remarks,
      };
}
