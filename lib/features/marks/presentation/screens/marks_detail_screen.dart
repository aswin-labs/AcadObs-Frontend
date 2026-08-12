import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/detail_section.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/viewing_grade_card.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MarksDetailScreen extends StatefulWidget {
  final MarkDetailParameters marksParams;
  const MarksDetailScreen({super.key, required this.marksParams});

  @override
  State<MarksDetailScreen> createState() => _MarksDetailScreenState();
}

class _MarksDetailScreenState extends State<MarksDetailScreen> {
  late MarksProvider marksProvider;
  @override
  void initState() {
    super.initState();
    marksProvider = context.read<MarksProvider>();
    marksProvider.fetchSingleMarks(marksId: widget.marksParams.mark.id);
  }

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false,
      child: Scaffold(
        appBar: CommonAppBar(
          title: "Marks",
          isBackButton: true,
          actions: [
            widget.marksParams.isEditNeeded
                ? Consumer2<TermExamProvider, MarksProvider>(
                  builder: (context, termProvider, markProvider, _) {
                    final mark = markProvider.singleMarks;
                    return CustomPopupMenu(
                      onEdit:
                          () => context.pushNamed(
                            RouteConstants.marksEdit,
                            extra: mark,
                          ),
                      onDelete:
                          () => showConfirmationDialog(
                            context: context,
                            title: 'Delete Marks',
                            content:
                                'Are you sure you want to delete this marks entry?',
                            onConfirm: () {
                              termProvider.deleteTermExamMarks(
                                context: context,
                                marksId: mark!.id,
                              );
                            },
                          ),
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        ),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Column(
                  children: [
                    Consumer<MarksProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingForSingleMarks) {
                          return CommonShimmerTile(height: 200);
                        }

                        final mark = provider.singleMarks;

                        if (mark == null) {
                          return const SizedBox.shrink();
                        }

                        final title =
                            mark.termExam?.examName == null
                                ? capitali(mark.internalName)
                                : capitali(
                                  "${mark.termExam?.examName ?? ''} - ${mark.internalName} (${mark.termExam?.educationYear ?? ''})",
                                );

                        return DetailSection(
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
                        );
                      },
                    ),

                    SizedBox(height: Responsive.height * 2),
                    Consumer<MarksProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingForSingleMarks) {
                          return commonShimmerList();
                        }

                        final studentMarks =
                            provider.singleMarks?.studentMarks ?? [];

                        if (studentMarks.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text("No student marks available"),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: studentMarks.length,
                          itemBuilder: (context, index) {
                            final studentMark = studentMarks[index];

                            return ViewingGradeCard(
                              name: studentMark.student?.fullName ?? "",
                              rollNumber: studentMark.student?.rollNumber ?? 0,
                              isAbsent: studentMark.status == "absent",
                              mark: studentMark.marksObtained ?? "0",
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 2),
                    widget.marksParams.isEditNeeded
                        ? Consumer<MarksProvider>(
                          builder: (context, provider, _) {
                            final mark = provider.singleMarks;
                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final alreadyAddedStudentIds =
                                      mark?.studentMarks
                                          ?.map((item) => item.student?.id)
                                          .whereType<int>()
                                          .toList() ??
                                      [];

                                  await context.pushNamed(
                                    RouteConstants.addMissingStudentMarks,
                                    extra: MissingStudentMarksParams(
                                      internalId: mark?.id ?? 0,
                                      classId: mark?.classGrade?.id ?? 0,
                                      totalMarks:
                                          double.tryParse(
                                            mark?.maxMarks ?? '0',
                                          ) ??
                                          0.0,
                                      studentIds: alreadyAddedStudentIds,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add More Students"),
                              ),
                            );
                          },
                        )
                        : SizedBox.shrink(),
                    SizedBox(height: Responsive.height * 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
