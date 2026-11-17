class AiCareerPredictionModel {
  final int studentId;
  final DateTime? generatedAt;
  final AiCareerPathDetails careerPath;
  final int jobsCount;
  final List<AiPredictedJob> top10Jobs;

  AiCareerPredictionModel({
    required this.studentId,
    this.generatedAt,
    required this.careerPath,
    required this.jobsCount,
    required this.top10Jobs,
  });

  factory AiCareerPredictionModel.fromResponseJson(
    Map<String, dynamic> rawJson,
  ) {
    Map<String, dynamic> payload = rawJson;
    if (payload['data'] is Map<String, dynamic>) {
      payload = payload['data'] as Map<String, dynamic>;
    }
    if (payload['data'] is Map<String, dynamic>) {
      payload = payload['data'] as Map<String, dynamic>;
    }
    return AiCareerPredictionModel.fromJson(payload);
  }

  factory AiCareerPredictionModel.fromJson(Map<String, dynamic> json) {
    final jobsList =
        (json['top_10_jobs'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AiPredictedJob.fromJson)
            .toList() ??
        [];

    return AiCareerPredictionModel(
      studentId: _toInt(json['student_id']),
      generatedAt:
          json['generated_at'] != null
              ? DateTime.tryParse(json['generated_at'].toString())
              : null,
      careerPath: AiCareerPathDetails.fromJson(
        json['career_path'] is Map<String, dynamic>
            ? json['career_path'] as Map<String, dynamic>
            : {},
      ),
      jobsCount: _toInt(json['jobs_count'], fallback: jobsList.length),
      top10Jobs: jobsList,
    );
  }
}

class AiCareerPathDetails {
  final String primaryCareerDomain;
  final List<String> secondaryCareerDomains;
  final String recommendedAcademicStream;
  final String overallCareerSummary;
  final List<String> coreStrengths;
  final List<String> areasForGrowth;
  final AiCareerRoadmap careerRoadmap;

  AiCareerPathDetails({
    required this.primaryCareerDomain,
    required this.secondaryCareerDomains,
    required this.recommendedAcademicStream,
    required this.overallCareerSummary,
    required this.coreStrengths,
    required this.areasForGrowth,
    required this.careerRoadmap,
  });

  factory AiCareerPathDetails.fromJson(Map<String, dynamic> json) {
    return AiCareerPathDetails(
      primaryCareerDomain: json['primary_career_domain']?.toString() ?? '',
      secondaryCareerDomains: _toStringList(json['secondary_career_domains']),
      recommendedAcademicStream:
          json['recommended_academic_stream']?.toString() ?? '',
      overallCareerSummary: json['overall_career_summary']?.toString() ?? '',
      coreStrengths: _toStringList(json['core_strengths']),
      areasForGrowth: _toStringList(json['areas_for_growth']),
      careerRoadmap: AiCareerRoadmap.fromJson(
        json['career_roadmap'] is Map<String, dynamic>
            ? json['career_roadmap'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

class AiCareerRoadmap {
  final List<String> schoolFocus;
  final List<String> higherEducationOptions;
  final List<String> skillBuildingActions;

  AiCareerRoadmap({
    required this.schoolFocus,
    required this.higherEducationOptions,
    required this.skillBuildingActions,
  });

  factory AiCareerRoadmap.fromJson(Map<String, dynamic> json) {
    return AiCareerRoadmap(
      schoolFocus: _toStringList(json['school_focus']),
      higherEducationOptions: _toStringList(json['higher_education_options']),
      skillBuildingActions: _toStringList(json['skill_building_actions']),
    );
  }
}

class AiPredictedJob {
  final int rank;
  final String jobTitle;
  final String careerDomain;
  final double matchPercentage;
  final String fitLevel;
  final String whyBestForStudent;
  final List<String> matchingStudentSkills;
  final List<String> skillsToDevelop;
  final List<String> supportingSubjects;
  final String educationPathway;
  final String careerGrowthPath;

  AiPredictedJob({
    required this.rank,
    required this.jobTitle,
    required this.careerDomain,
    required this.matchPercentage,
    required this.fitLevel,
    required this.whyBestForStudent,
    required this.matchingStudentSkills,
    required this.skillsToDevelop,
    required this.supportingSubjects,
    required this.educationPathway,
    required this.careerGrowthPath,
  });

  factory AiPredictedJob.fromJson(Map<String, dynamic> json) {
    return AiPredictedJob(
      rank: _toInt(json['rank']),
      jobTitle: json['job_title']?.toString() ?? '',
      careerDomain: json['career_domain']?.toString() ?? '',
      matchPercentage: _toDouble(json['match_percentage']),
      fitLevel: json['fit_level']?.toString() ?? '',
      whyBestForStudent: json['why_best_for_student']?.toString() ?? '',
      matchingStudentSkills: _toStringList(json['matching_student_skills']),
      skillsToDevelop: _toStringList(json['skills_to_develop']),
      supportingSubjects: _toStringList(json['supporting_subjects']),
      educationPathway: json['education_pathway']?.toString() ?? '',
      careerGrowthPath: json['career_growth_path']?.toString() ?? '',
    );
  }

  List<String> get growthSteps {
    if (careerGrowthPath.trim().isEmpty) return [];
    return careerGrowthPath
        .split('->')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [];
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

