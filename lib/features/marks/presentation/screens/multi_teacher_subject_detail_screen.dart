import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/detail_section.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/viewing_grade_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiTeacherSubjectMarksDetailsScreen extends StatefulWidget {
  final int marksId;
  final int subjectId;

  const MultiTeacherSubjectMarksDetailsScreen({
    super.key,
    required this.marksId,
    required this.subjectId,
  });

  @override
  State<MultiTeacherSubjectMarksDetailsScreen> createState() =>
      _MultiTeacherSubjectMarksDetailsScreenState();
}

class _MultiTeacherSubjectMarksDetailsScreenState
    extends State<MultiTeacherSubjectMarksDetailsScreen> {
  late final TermExamProvider _termExamProvider;

  @override
  void initState() {
    super.initState();

    _termExamProvider = context.read<TermExamProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _termExamProvider.fetchSingleMultiTeacherSubjectMarks(
        marksId: widget.marksId,
        subjectId: widget.subjectId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false,
      child: Scaffold(
        appBar: CommonAppBar(title: "Marks", isBackButton: true),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Consumer<TermExamProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingForSingleMarks) {
                      return Column(
                        children: [
                          const CommonShimmerTile(height: 200),
                          SizedBox(height: Responsive.height * 2),
                          commonShimmerList(),
                        ],
                      );
                    }

                    final mark = provider.singleMarks;

                    if (mark == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text("Marks details not available"),
                        ),
                      );
                    }

                    final title =
                        mark.termExam?.examName == null
                            ? capitali(mark.internalName)
                            : capitali(
                              "${mark.termExam?.examName ?? ''} - "
                              "${mark.internalName} "
                              "(${mark.termExam?.educationYear ?? ''})",
                            );

                    final studentMarks = mark.studentMarks ?? [];

                    return Column(
                      children: [
                        DetailSection(
                          title: "Details",
                          details: {
                            "Title": title,
                            "Class": mark.classGrade?.classname ?? "",
                            "Total Marks": mark.maxMarks,
                            "Date": DateFormatter.formatDateTime(
                              mark.date ?? DateTime.now(),
                            ),
                            "Subject":
                                mark.subject?.subjectName ?? "Not Specified",
                            "Recorded By": mark.user?.name ?? "Not Specified",
                          },
                        ),
                        SizedBox(height: Responsive.height * 2),

                        if (studentMarks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text("No student marks available"),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: studentMarks.length,
                            itemBuilder: (context, index) {
                              final studentMark = studentMarks[index];

                              return ViewingGradeCard(
                                name: studentMark.student?.fullName ?? "",
                                rollNumber:
                                    studentMark.student?.rollNumber ?? 0,
                                isAbsent: studentMark.status == "absent",
                                mark: studentMark.marksObtained ?? "0",
                              );
                            },
                          ),

                        SizedBox(height: Responsive.height * 6),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
