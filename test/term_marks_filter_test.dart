import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:flutter_test/flutter_test.dart';

String buildTermExamMarksUrl({
  required String teacherId,
  required int pageNo,
  int? subjectId,
  int? classId,
  int? examId,
  String? query,
}) {
  final searchQuery = query != null ? Uri.encodeComponent(query) : '';
  String url =
      "${ApiEndpoints.termExamAddedByTeacher}?recorded_by=$teacherId&limit=${AppConstants.paginationLimit}&page=$pageNo&q=$searchQuery";
  if (subjectId != null) {
    url += "&subject_id=$subjectId";
  }
  if (classId != null) {
    url += "&class_id=$classId";
  }
  if (examId != null) {
    url += "&exam_id=$examId";
  }
  return url;
}

void main() {
  group('TermExamProvider Filters Test', () {
    late TermExamProvider provider;

    setUp(() {
      provider = TermExamProvider();
    });

    test('Initial filter state is empty', () {
      expect(provider.filterExamId, isNull);
      expect(provider.filterExamName, isNull);
      expect(provider.filterStandard, isNull);
      expect(provider.filterClassId, isNull);
      expect(provider.filterClassName, isNull);
      expect(provider.filterSubjectId, isNull);
      expect(provider.filterSubjectName, isNull);
      expect(provider.searchQuery, isEmpty);
      expect(provider.hasActiveFilters, isFalse);
      expect(provider.activeFilterCount, equals(0));
    });

    test('Filter URL formatting with &q=, subject_id, class_id, and exam_id', () {
      final limit = AppConstants.paginationLimit;

      // 1. Without filters (should still have &q=)
      final urlNoFilters = buildTermExamMarksUrl(
        teacherId: '10',
        pageNo: 1,
      );
      expect(urlNoFilters, contains('limit=$limit&page=1&q='));
      expect(urlNoFilters, isNot(contains('subject_id')));
      expect(urlNoFilters, isNot(contains('class_id')));
      expect(urlNoFilters, isNot(contains('exam_id')));

      // 2. With exact user format: limit=X&page=1&q=&subject_id=41&exam_id=1
      final urlUserFormat = buildTermExamMarksUrl(
        teacherId: '10',
        pageNo: 1,
        subjectId: 41,
        examId: 1,
      );
      expect(
        urlUserFormat,
        contains('limit=$limit&page=1&q=&subject_id=41&exam_id=1'),
      );

      // 3. With search query string
      final urlWithQuery = buildTermExamMarksUrl(
        teacherId: '10',
        pageNo: 1,
        query: 'maths exam',
        subjectId: 41,
        examId: 1,
      );
      expect(
        urlWithQuery,
        contains('limit=$limit&page=1&q=maths%20exam&subject_id=41&exam_id=1'),
      );

      // 4. With class_id only
      final urlWithClass = buildTermExamMarksUrl(
        teacherId: '10',
        pageNo: 2,
        classId: 12,
      );
      expect(urlWithClass, contains('limit=$limit&page=2&q=&class_id=12'));

      // 5. With all three filters
      final urlWithAll = buildTermExamMarksUrl(
        teacherId: '10',
        pageNo: 1,
        subjectId: 7,
        classId: 12,
        examId: 5,
      );
      expect(
        urlWithAll,
        contains('limit=$limit&page=1&q=&subject_id=7&class_id=12&exam_id=5'),
      );
    });

    test('Multi Teacher Subject filter state management', () {
      expect(provider.multiActiveFilterCount, equals(0));
      expect(provider.hasActiveMultiFilters, isFalse);

      provider.applyMultiTeacherFilters(
        examId: 10,
        examName: "Term 1",
        classId: 22,
        className: "Class 10 A",
        subjectId: 5,
        subjectName: "Science",
      );

      expect(provider.multiFilterExamId, equals(10));
      expect(provider.multiFilterExamName, equals("Term 1"));
      expect(provider.multiFilterClassId, equals(22));
      expect(provider.multiFilterClassName, equals("Class 10 A"));
      expect(provider.multiFilterSubjectId, equals(5));
      expect(provider.multiFilterSubjectName, equals("Science"));
      expect(provider.multiActiveFilterCount, equals(3));
      expect(provider.hasActiveMultiFilters, isTrue);

      provider.clearMultiTeacherFilters();
      expect(provider.multiActiveFilterCount, equals(0));
      expect(provider.hasActiveMultiFilters, isFalse);
    });
  });
}
