import 'dart:developer';

import 'package:acadobs/features/ai_insights/data/models/ai_career_prediction_model.dart';
import 'package:acadobs/features/ai_insights/data/models/ai_student_skills_model.dart';
import 'package:acadobs/features/ai_insights/data/services/ai_insights_services.dart';
import 'package:flutter/material.dart';

class AiInsightsProvider extends ChangeNotifier {
  final AiInsightsServices _services = AiInsightsServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AiStudentSkillsModel? _aiProfile;
  AiStudentSkillsModel? get aiProfile => _aiProfile;

  int? _activeStudentId;
  int? get activeStudentId => _activeStudentId;

  // Career Prediction State (cached per studentId to conserve free-tier API quota)
  bool _isCareerLoading = false;
  bool get isCareerLoading => _isCareerLoading;

  String? _careerErrorMessage;
  String? get careerErrorMessage => _careerErrorMessage;

  AiCareerPredictionModel? _careerPrediction;
  AiCareerPredictionModel? get careerPrediction => _careerPrediction;

  int? _careerStudentId;
  int? get careerStudentId => _careerStudentId;

  Future<void> fetchStudentAiInsights({
    required int studentId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _activeStudentId == studentId &&
        _aiProfile != null &&
        _errorMessage == null) {
      return;
    }

    _activeStudentId = studentId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _services.fetchStudentAiSkills(
        studentId: studentId,
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        final rawData = response.data as Map<String, dynamic>;
        _aiProfile = AiStudentSkillsModel.fromResponseJson(rawData);
      } else {
        _errorMessage =
            'Unable to load AI insights for this student (Status: ${response.statusCode}).';
      }
    } catch (e, stack) {
      log('Error fetching AI insights: $e', stackTrace: stack);
      _errorMessage =
          'Could not fetch AI insights right now. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStudentCareerPrediction({
    required int studentId,
    bool forceRefresh = false,
  }) async {
    if (studentId <= 0) return;

    if (!forceRefresh &&
        _careerStudentId == studentId &&
        _careerPrediction != null &&
        _careerErrorMessage == null) {
      return;
    }

    _careerStudentId = studentId;
    _isCareerLoading = true;
    _careerErrorMessage = null;
    notifyListeners();

    try {
      final response = await _services.fetchStudentCareerPath(
        studentId: studentId,
      );

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic>) {
        final rawData = response.data as Map<String, dynamic>;
        _careerPrediction = AiCareerPredictionModel.fromResponseJson(rawData);
      } else {
        _careerErrorMessage =
            'Unable to load career prediction right now (Status: ${response.statusCode}).';
      }
    } catch (e, stack) {
      log('Error fetching AI career prediction: $e', stackTrace: stack);
      _careerErrorMessage =
          'Could not generate career prediction right now. Please try again.';
    } finally {
      _isCareerLoading = false;
      notifyListeners();
    }
  }
}
