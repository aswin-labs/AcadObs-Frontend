class AiStudentSkillsModel {
  final String profileVersion;
  final DateTime? generatedAt;
  final AiStudentInfo student;
  final AiOverallSummary overallSummary;
  final AiSkillSummary skillSummary;
  final AiAcademicProfile academicProfile;
  final AiHomeworkProfile homeworkProfile;
  final AiCoScholasticProfile coScholasticProfile;
  final AiAttendanceProfile attendanceProfile;
  final AiAchievementProfile achievementProfile;
  final AiDataQuality dataQuality;
  final AiCareerInput careerAiInput;

  AiStudentSkillsModel({
    required this.profileVersion,
    required this.generatedAt,
    required this.student,
    required this.overallSummary,
    required this.skillSummary,
    required this.academicProfile,
    required this.homeworkProfile,
    required this.coScholasticProfile,
    required this.attendanceProfile,
    required this.achievementProfile,
    required this.dataQuality,
    required this.careerAiInput,
  });

  factory AiStudentSkillsModel.fromResponseJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> payload = rawJson;
    if (payload['data'] is Map<String, dynamic>) {
      payload = payload['data'] as Map<String, dynamic>;
    }
    if (payload['data'] is Map<String, dynamic>) {
      payload = payload['data'] as Map<String, dynamic>;
    }
    return AiStudentSkillsModel.fromJson(payload);
  }

  factory AiStudentSkillsModel.fromJson(Map<String, dynamic> json) {
    return AiStudentSkillsModel(
      profileVersion: json['profile_version']?.toString() ?? '1.0',
      generatedAt:
          json['generated_at'] != null
              ? DateTime.tryParse(json['generated_at'].toString())
              : null,
      student: AiStudentInfo.fromJson(
        json['student'] is Map<String, dynamic>
            ? json['student'] as Map<String, dynamic>
            : {},
      ),
      overallSummary: AiOverallSummary.fromJson(
        json['overall_summary'] is Map<String, dynamic>
            ? json['overall_summary'] as Map<String, dynamic>
            : {},
      ),
      skillSummary: AiSkillSummary.fromJson(
        json['skill_summary'] is Map<String, dynamic>
            ? json['skill_summary'] as Map<String, dynamic>
            : {},
      ),
      academicProfile: AiAcademicProfile.fromJson(
        json['academic_profile'] is Map<String, dynamic>
            ? json['academic_profile'] as Map<String, dynamic>
            : {},
      ),
      homeworkProfile: AiHomeworkProfile.fromJson(
        json['homework_profile'] is Map<String, dynamic>
            ? json['homework_profile'] as Map<String, dynamic>
            : {},
      ),
      coScholasticProfile: AiCoScholasticProfile.fromJson(
        json['co_scholastic_profile'] is Map<String, dynamic>
            ? json['co_scholastic_profile'] as Map<String, dynamic>
            : {},
      ),
      attendanceProfile: AiAttendanceProfile.fromJson(
        json['attendance_profile'] is Map<String, dynamic>
            ? json['attendance_profile'] as Map<String, dynamic>
            : {},
      ),
      achievementProfile: AiAchievementProfile.fromJson(
        json['achievement_profile'] is Map<String, dynamic>
            ? json['achievement_profile'] as Map<String, dynamic>
            : {},
      ),
      dataQuality: AiDataQuality.fromJson(
        json['data_quality'] is Map<String, dynamic>
            ? json['data_quality'] as Map<String, dynamic>
            : {},
      ),
      careerAiInput: AiCareerInput.fromJson(
        json['career_ai_input'] is Map<String, dynamic>
            ? json['career_ai_input'] as Map<String, dynamic>
            : {},
      ),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

class AiStudentInfo {
  final int studentId;
  final String studentName;
  final int schoolId;
  final int classId;
  final String gender;
  final String? dateOfBirth;

  AiStudentInfo({
    required this.studentId,
    required this.studentName,
    required this.schoolId,
    required this.classId,
    required this.gender,
    this.dateOfBirth,
  });

  factory AiStudentInfo.fromJson(Map<String, dynamic> json) {
    return AiStudentInfo(
      studentId: _toInt(json['student_id']),
      studentName: json['student_name']?.toString() ?? 'Student',
      schoolId: _toInt(json['school_id']),
      classId: _toInt(json['class_id']),
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString(),
    );
  }
}

class AiOverallSummary {
  final double overallAcademicPercentage;
  final double weightedAcademicAverage;
  final double overallSkillScore;
  final double coScholasticAverage;
  final double homeworkAveragePoints;
  final double attendancePercentage;
  final int totalSkillsIdentified;
  final int totalAcademicAssessments;
  final int totalHomeworkAssignments;
  final int totalCoScholasticAssessments;
  final int totalAttendanceSessions;
  final int totalAchievements;

  AiOverallSummary({
    required this.overallAcademicPercentage,
    required this.weightedAcademicAverage,
    required this.overallSkillScore,
    required this.coScholasticAverage,
    required this.homeworkAveragePoints,
    required this.attendancePercentage,
    required this.totalSkillsIdentified,
    required this.totalAcademicAssessments,
    required this.totalHomeworkAssignments,
    required this.totalCoScholasticAssessments,
    required this.totalAttendanceSessions,
    required this.totalAchievements,
  });

  factory AiOverallSummary.fromJson(Map<String, dynamic> json) {
    return AiOverallSummary(
      overallAcademicPercentage: _toDouble(json['overall_academic_percentage']),
      weightedAcademicAverage: _toDouble(json['weighted_academic_average']),
      overallSkillScore: _toDouble(json['overall_skill_score']),
      coScholasticAverage: _toDouble(json['co_scholastic_average']),
      homeworkAveragePoints: _toDouble(json['homework_average_points']),
      attendancePercentage: _toDouble(json['attendance_percentage']),
      totalSkillsIdentified: _toInt(json['total_skills_identified']),
      totalAcademicAssessments: _toInt(json['total_academic_assessments']),
      totalHomeworkAssignments: _toInt(json['total_homework_assignments']),
      totalCoScholasticAssessments: _toInt(
        json['total_co_scholastic_assessments'],
      ),
      totalAttendanceSessions: _toInt(json['total_attendance_sessions']),
      totalAchievements: _toInt(json['total_achievements']),
    );
  }
}

class AiSkillSummary {
  final int totalSkills;
  final List<AiSkillItem> topSkills;
  final List<AiSkillItem> allSkills;

  AiSkillSummary({
    required this.totalSkills,
    required this.topSkills,
    required this.allSkills,
  });

  factory AiSkillSummary.fromJson(Map<String, dynamic> json) {
    final topList =
        (json['top_skills'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AiSkillItem.fromJson)
            .toList() ??
        [];
    final allList =
        (json['all_skills'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AiSkillItem.fromJson)
            .toList() ??
        [];
    return AiSkillSummary(
      totalSkills: _toInt(json['total_skills']),
      topSkills: topList,
      allSkills: allList,
    );
  }
}

class AiSkillItem {
  final String skill;
  final String category;
  final double? score;
  final String level;
  final String status;
  final String confidence;
  final String trend;
  final int scoreObservations;
  final List<String> dataSources;

  AiSkillItem({
    required this.skill,
    required this.category,
    required this.score,
    required this.level,
    required this.status,
    required this.confidence,
    required this.trend,
    required this.scoreObservations,
    required this.dataSources,
  });

  factory AiSkillItem.fromJson(Map<String, dynamic> json) {
    return AiSkillItem(
      skill: json['skill']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      score: _toNullableDouble(json['score']),
      level: json['level']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      confidence: json['confidence']?.toString() ?? '',
      trend: json['trend']?.toString() ?? 'stable',
      scoreObservations: _toInt(json['score_observations']),
      dataSources:
          (json['data_sources'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class AiAcademicProfile {
  final int totalAssessments;
  final double totalObtainedMarks;
  final double totalMaximumMarks;
  final double overallPercentage;
  final double weightedAveragePercentage;
  final int mainExamCount;
  final int otherExamCount;
  final int normalInternalCount;
  final AiExamTypeAverages examTypeAverages;
  final List<AiAcademicSubject> subjects;

  AiAcademicProfile({
    required this.totalAssessments,
    required this.totalObtainedMarks,
    required this.totalMaximumMarks,
    required this.overallPercentage,
    required this.weightedAveragePercentage,
    required this.mainExamCount,
    required this.otherExamCount,
    required this.normalInternalCount,
    required this.examTypeAverages,
    required this.subjects,
  });

  factory AiAcademicProfile.fromJson(Map<String, dynamic> json) {
    final subjectsList =
        (json['subjects'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AiAcademicSubject.fromJson)
            .toList() ??
        [];
    return AiAcademicProfile(
      totalAssessments: _toInt(json['total_assessments']),
      totalObtainedMarks: _toDouble(json['total_obtained_marks']),
      totalMaximumMarks: _toDouble(json['total_maximum_marks']),
      overallPercentage: _toDouble(json['overall_percentage']),
      weightedAveragePercentage: _toDouble(json['weighted_average_percentage']),
      mainExamCount: _toInt(json['main_exam_count']),
      otherExamCount: _toInt(json['other_exam_count']),
      normalInternalCount: _toInt(json['normal_internal_count']),
      examTypeAverages: AiExamTypeAverages.fromJson(
        json['exam_type_averages'] is Map<String, dynamic>
            ? json['exam_type_averages'] as Map<String, dynamic>
            : {},
      ),
      subjects: subjectsList,
    );
  }
}

class AiExamTypeAverages {
  final double? mainPublicExam;
  final double? otherExamLinked;
  final double? normalInternal;

  AiExamTypeAverages({
    this.mainPublicExam,
    this.otherExamLinked,
    this.normalInternal,
  });

  factory AiExamTypeAverages.fromJson(Map<String, dynamic> json) {
    return AiExamTypeAverages(
      mainPublicExam: _toNullableDouble(json['main_public_exam']),
      otherExamLinked: _toNullableDouble(json['other_exam_linked']),
      normalInternal: _toNullableDouble(json['normal_internal']),
    );
  }
}

class AiAcademicSubject {
  final String subject;
  final double obtainedMarks;
  final double maximumMarks;
  final double percentage;
  final double averageScore;
  final double? mainExamAverage;
  final double? otherExamAverage;
  final double? normalInternalAverage;
  final int assessmentCount;
  final String trend;

  AiAcademicSubject({
    required this.subject,
    required this.obtainedMarks,
    required this.maximumMarks,
    required this.percentage,
    required this.averageScore,
    this.mainExamAverage,
    this.otherExamAverage,
    this.normalInternalAverage,
    required this.assessmentCount,
    required this.trend,
  });

  factory AiAcademicSubject.fromJson(Map<String, dynamic> json) {
    return AiAcademicSubject(
      subject: json['subject']?.toString() ?? '',
      obtainedMarks: _toDouble(json['obtained_marks']),
      maximumMarks: _toDouble(json['maximum_marks']),
      percentage: _toDouble(json['percentage']),
      averageScore: _toDouble(json['average_score']),
      mainExamAverage: _toNullableDouble(json['main_exam_average']),
      otherExamAverage: _toNullableDouble(json['other_exam_average']),
      normalInternalAverage: _toNullableDouble(json['normal_internal_average']),
      assessmentCount: _toInt(json['assessment_count']),
      trend: json['trend']?.toString() ?? 'stable',
    );
  }
}

class AiHomeworkProfile {
  final int totalAssignments;
  final int assignmentsWithSubmissionFile;
  final int assignmentsWithoutSubmissionFile;
  final int withTeacherFeedback;
  final double totalPoints;
  final double averagePoints;
  final List<String> derivedSkills;
  final List<AiHomeworkSubject> subjects;
  final String pointsNote;

  AiHomeworkProfile({
    required this.totalAssignments,
    required this.assignmentsWithSubmissionFile,
    required this.assignmentsWithoutSubmissionFile,
    required this.withTeacherFeedback,
    required this.totalPoints,
    required this.averagePoints,
    required this.derivedSkills,
    required this.subjects,
    required this.pointsNote,
  });

  factory AiHomeworkProfile.fromJson(Map<String, dynamic> json) {
    final subjectsList =
        (json['subjects'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AiHomeworkSubject.fromJson)
            .toList() ??
        [];
    return AiHomeworkProfile(
      totalAssignments: _toInt(json['total_assignments']),
      assignmentsWithSubmissionFile: _toInt(
        json['assignments_with_submission_file'],
      ),
      assignmentsWithoutSubmissionFile: _toInt(
        json['assignments_without_submission_file'],
      ),
      withTeacherFeedback: _toInt(json['with_teacher_feedback']),
      totalPoints: _toDouble(json['total_points']),
      averagePoints: _toDouble(json['average_points']),
      derivedSkills:
          (json['derived_skills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      subjects: subjectsList,
      pointsNote: json['points_note']?.toString() ?? '',
    );
  }
}

class AiHomeworkSubject {
  final String subject;
  final int totalAssignments;
  final int assignmentsWithSubmissionFile;
  final int assignmentsWithoutSubmissionFile;
  final int withTeacherFeedback;
  final double totalPoints;
  final double averagePoints;
  final List<String> skills;

  AiHomeworkSubject({
    required this.subject,
    required this.totalAssignments,
    required this.assignmentsWithSubmissionFile,
    required this.assignmentsWithoutSubmissionFile,
    required this.withTeacherFeedback,
    required this.totalPoints,
    required this.averagePoints,
    required this.skills,
  });

  factory AiHomeworkSubject.fromJson(Map<String, dynamic> json) {
    return AiHomeworkSubject(
      subject: json['subject']?.toString() ?? '',
      totalAssignments: _toInt(json['total_assignments']),
      assignmentsWithSubmissionFile: _toInt(
        json['assignments_with_submission_file'],
      ),
      assignmentsWithoutSubmissionFile: _toInt(
        json['assignments_without_submission_file'],
      ),
      withTeacherFeedback: _toInt(json['with_teacher_feedback']),
      totalPoints: _toDouble(json['total_points']),
      averagePoints: _toDouble(json['average_points']),
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AiCoScholasticProfile {
  final int totalAssessments;
  final int validAssessments;
  final double averageScore;
  final List<AiCoScholasticArea> areas;

  AiCoScholasticProfile({
    required this.totalAssessments,
    required this.validAssessments,
    required this.averageScore,
    required this.areas,
  });

  factory AiCoScholasticProfile.fromJson(Map<String, dynamic> json) {
    final areasList =
        (json['areas'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(AiCoScholasticArea.fromJson)
            .toList() ??
        [];
    return AiCoScholasticProfile(
      totalAssessments: _toInt(json['total_assessments']),
      validAssessments: _toInt(json['valid_assessments']),
      averageScore: _toDouble(json['average_score']),
      areas: areasList,
    );
  }
}

class AiCoScholasticArea {
  final int areaId;
  final String area;
  final double averageScore;
  final int assessmentCount;

  AiCoScholasticArea({
    required this.areaId,
    required this.area,
    required this.averageScore,
    required this.assessmentCount,
  });

  factory AiCoScholasticArea.fromJson(Map<String, dynamic> json) {
    return AiCoScholasticArea(
      areaId: _toInt(json['area_id']),
      area: json['area']?.toString() ?? '',
      averageScore: _toDouble(json['average_score']),
      assessmentCount: _toInt(json['assessment_count']),
    );
  }
}

class AiAttendanceProfile {
  final int totalSessions;
  final int present;
  final int absent;
  final int lateCount;
  final int leave;
  final double attendancePercentage;

  AiAttendanceProfile({
    required this.totalSessions,
    required this.present,
    required this.absent,
    required this.lateCount,
    required this.leave,
    required this.attendancePercentage,
  });

  factory AiAttendanceProfile.fromJson(Map<String, dynamic> json) {
    return AiAttendanceProfile(
      totalSessions: _toInt(json['total_sessions']),
      present: _toInt(json['present']),
      absent: _toInt(json['absent']),
      lateCount: _toInt(json['late']),
      leave: _toInt(json['leave']),
      attendancePercentage: _toDouble(json['attendance_percentage']),
    );
  }
}

class AiAchievementProfile {
  final int totalAchievements;
  final List<AiAchievementCount> byCategory;
  final List<AiAchievementCount> byLevel;
  final List<AiAchievementCount> byPosition;

  AiAchievementProfile({
    required this.totalAchievements,
    required this.byCategory,
    required this.byLevel,
    required this.byPosition,
  });

  factory AiAchievementProfile.fromJson(Map<String, dynamic> json) {
    return AiAchievementProfile(
      totalAchievements: _toInt(json['total_achievements']),
      byCategory:
          (json['by_category'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (m) => AiAchievementCount(
                  label: m['category']?.toString() ?? '',
                  count: _toInt(m['count']),
                ),
              )
              .toList() ??
          [],
      byLevel:
          (json['by_level'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (m) => AiAchievementCount(
                  label: m['level']?.toString() ?? '',
                  count: _toInt(m['count']),
                ),
              )
              .toList() ??
          [],
      byPosition:
          (json['by_position'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (m) => AiAchievementCount(
                  label: m['position']?.toString() ?? '',
                  count: _toInt(m['count']),
                ),
              )
              .toList() ??
          [],
    );
  }
}

class AiAchievementCount {
  final String label;
  final int count;

  AiAchievementCount({required this.label, required this.count});
}

class AiDataQuality {
  final int academicRecords;
  final int homeworkRecords;
  final int attendanceRecords;
  final int coScholasticRecords;
  final int achievementRecords;
  final List<String> limitations;

  AiDataQuality({
    required this.academicRecords,
    required this.homeworkRecords,
    required this.attendanceRecords,
    required this.coScholasticRecords,
    required this.achievementRecords,
    required this.limitations,
  });

  factory AiDataQuality.fromJson(Map<String, dynamic> json) {
    return AiDataQuality(
      academicRecords: _toInt(json['academic_records']),
      homeworkRecords: _toInt(json['homework_records']),
      attendanceRecords: _toInt(json['attendance_records']),
      coScholasticRecords: _toInt(json['co_scholastic_records']),
      achievementRecords: _toInt(json['achievement_records']),
      limitations:
          (json['limitations'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class AiCareerInput {
  final bool ready;
  final String purpose;
  final String instruction;

  AiCareerInput({
    required this.ready,
    required this.purpose,
    required this.instruction,
  });

  factory AiCareerInput.fromJson(Map<String, dynamic> json) {
    return AiCareerInput(
      ready: json['ready'] == true,
      purpose: json['purpose']?.toString() ?? '',
      instruction: json['instruction']?.toString() ?? '',
    );
  }
}

