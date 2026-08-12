import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MultiTeacherSubjectMarksScreen extends StatefulWidget {
  const MultiTeacherSubjectMarksScreen({super.key});

  @override
  State<MultiTeacherSubjectMarksScreen> createState() =>
      _MultiTeacherSubjectMarksScreenState();
}

class _MultiTeacherSubjectMarksScreenState
    extends State<MultiTeacherSubjectMarksScreen> {
  late final TermExamProvider _termExamProvider;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _termExamProvider = context.read<TermExamProvider>();

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _termExamProvider.fetchMultiTeacherSubjectMarks(forceRefresh: true);
    });
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_termExamProvider.isLoadingMultiSubjectMarks &&
        _termExamProvider.hasMoreMultiSubjectMarks) {
      _termExamProvider.fetchMultiTeacherSubjectMarks(loadMore: true);
    }
  }

  Future<void> _refreshMarks() async {
    await _termExamProvider.fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Multi Teacher Subjects", isBackButton: true),
      body: RefreshIndicator(
        onRefresh: _refreshMarks,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Consumer<TermExamProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingMultiSubjectMarks &&
                            provider.multiSubjectMarks.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: commonShimmerList(),
                          );
                        }

                        if (provider.multiSubjectMarks.isEmpty) {
                          return emptyScreen(
                            message: "No Marks Found",
                            heightMultiplier: 16,
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.multiSubjectMarks.length,
                          itemBuilder: (context, index) {
                            final mark = provider.multiSubjectMarks[index];

                            final className = mark.classGrade?.classname ?? '';

                            final subjectName = mark.subject?.subjectName ?? '';

                            final title =
                                "$className${subjectName.isNotEmpty ? ' - $subjectName' : ''}";

                            final description =
                                mark.termExam?.examName == null
                                    ? capitali(mark.internalName)
                                    : capitali(
                                      "${mark.termExam?.examName ?? ''} - "
                                      "${mark.internalName} "
                                      "(${mark.termExam?.educationYear ?? ''})",
                                    );

                            return ItemCard(
                              title: capitalizeEachWord(title),
                              description: description,
                              iconColor: Colors.green,
                              backgroundColor: const Color(0xFFE8F5E9),
                              icon: LucideIcons.clipboardList,
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants
                                      .multiTeacherSubjectMarksDetails,
                                  queryParameters: {
                                    'marksId': mark.id.toString(),
                                    'subjectId':
                                        mark.subject?.id.toString() ?? '0',
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    Consumer<TermExamProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingMultiSubjectMarks &&
                            provider.hasMoreMultiSubjectMarks) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
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
