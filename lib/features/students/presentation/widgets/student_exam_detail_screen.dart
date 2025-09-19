import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/mark_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentExamDetailScreen extends StatefulWidget {
  final bool forParent;
  final int studentId;
  const StudentExamDetailScreen({
    super.key,
    required this.forParent,
    required this.studentId,
  });

  @override
  State<StudentExamDetailScreen> createState() =>
      _StudentExamDetailScreenState();
}

class _StudentExamDetailScreenState extends State<StudentExamDetailScreen> {
  late final MarksProvider _marksProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _marksProvider = context.read<MarksProvider>();
    _marksProvider.fetchStudentMarks(
      studentId: widget.studentId,
      forParent: widget.forParent,
    );
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom && !_marksProvider.isLoading && _marksProvider.hasMore) {
      _marksProvider.fetchStudentMarks(
        loadMore: true,
        studentId: widget.studentId,
        forParent: widget.forParent,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Consumer<MarksProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.studentMarks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: commonShimmerList(),
                  );
                }

                if (provider.studentMarks.isEmpty) {
                  return emptyScreen(
                    message: 'No Marks Found.',
                    heightMultiplier: 16,
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: provider.studentMarks.length,
                  itemBuilder: (context, index) {
                    final studentMark = provider.studentMarks[index];
                    return MarkCard(
                      examtitle:
                          studentMark.internalExam?.internalName ?? "N/A",
                      subject:
                          studentMark.internalExam?.subject?.subjectName ??
                          "N/A",
                      mark:
                          studentMark.marksObtained != null &&
                                  studentMark.marksObtained!.isNotEmpty
                              ? double.parse(studentMark.marksObtained!)
                              : 0.0,
                      total:
                          studentMark.internalExam?.maxMarks != null &&
                                  studentMark.internalExam!.maxMarks.isNotEmpty
                              ? double.parse(studentMark.internalExam!.maxMarks)
                              : 0.0,
                    );
                  },
                );
              },
            ),

            Consumer<MarksProvider>(
              builder: (context, provider, _) {
                return provider.isLoading && provider.hasMoreForStudent
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox();
              },
            ),
            SizedBox(height: Responsive.height * 4),
          ],
        ),
      ),
    );
  }
}
