import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/mark_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentExamScreen extends StatefulWidget {
  final bool forStaff;
  final int studentId;
  const StudentExamScreen({
    super.key,
    required this.forStaff,
    required this.studentId,
  });

  @override
  State<StudentExamScreen> createState() => _StudentExamScreenState();
}

class _StudentExamScreenState extends State<StudentExamScreen>
    with SingleTickerProviderStateMixin {
  late final MarksProvider _marksProvider;
  late final TermExamProvider _termExamProvider;
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

  final ScrollController _termMarksScrollController = ScrollController();
  final ScrollController _otherMarksScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _marksProvider = context.read<MarksProvider>();
    _termExamProvider = context.read<TermExamProvider>();
    _termExamProvider.fetchStudentTermExamMarks(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
    _marksProvider.fetchStudentMarks(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
    _termMarksScrollController.addListener(_termMarksScrollListener);
    _otherMarksScrollController.addListener(_otherMarksScrollListener);
  }

  void _termMarksScrollListener() {
    final isNearBottom =
        _termMarksScrollController.position.pixels >=
        _termMarksScrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_termExamProvider.isLoadingStudentMarks &&
        _termExamProvider.hasMore) {
      _termExamProvider.fetchStudentTermExamMarks(
        loadMore: true,
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      );
    }
  }

  void _otherMarksScrollListener() {
    final isNearBottom =
        _otherMarksScrollController.position.pixels >=
        _otherMarksScrollController.position.maxScrollExtent - 200;

    if (isNearBottom && !_marksProvider.isLoading && _marksProvider.hasMore) {
      _marksProvider.fetchStudentMarks(
        loadMore: true,
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _termMarksScrollController.dispose();
    _otherMarksScrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshMarks() async {
    await context.read<MarksProvider>().fetchStudentMarks(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Exams', isBackButton: true),
      body: Column(
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 211, 206, 206),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: const [Tab(text: 'Term Exams'), Tab(text: 'Other Marks')],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TermMarksTab(
                  scrollController: _termMarksScrollController,
                  onRefresh: _refreshMarks,
                ),
                _OtherMarksTab(
                  scrollController: _otherMarksScrollController,
                  onRefresh: _refreshMarks,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermMarksTab extends StatelessWidget {
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;
  const _TermMarksTab({
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Consumer<TermExamProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingStudentMarks &&
                          provider.studentMarks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: commonShimmerList(itemCount: 10),
                        );
                      }

                      if (provider.studentMarks.isEmpty) {
                        return emptyScreen(
                          message: 'No Marks Found.',
                          heightMultiplier: 25,
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.studentMarks.length,
                        itemBuilder: (context, index) {
                          final studentMark = provider.studentMarks[index];
                          final title =
                              "${studentMark.internalExam?.termExam?.examName ?? ''} - ${studentMark.internalExam?.internalName} (${studentMark.internalExam?.termExam?.educationYear ?? ''}) ";
                          return MarkCard(
                            examtitle: title,
                            subject:
                                studentMark
                                    .internalExam
                                    ?.subject
                                    ?.subjectName ??
                                "N/A",
                            mark:
                                studentMark.marksObtained != null &&
                                        studentMark.marksObtained!.isNotEmpty
                                    ? double.parse(studentMark.marksObtained!)
                                    : 0.0,
                            total:
                                studentMark.internalExam?.maxMarks != null &&
                                        studentMark
                                            .internalExam!
                                            .maxMarks
                                            .isNotEmpty
                                    ? double.parse(
                                      studentMark.internalExam!.maxMarks,
                                    )
                                    : 0.0,
                          );
                        },
                      );
                    },
                  ),

                  Consumer<TermExamProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoadingStudentMarks &&
                              provider.hasMoreStudentMarks
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
          ),
        ],
      ),
    );
  }
}

class _OtherMarksTab extends StatelessWidget {
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;
  const _OtherMarksTab({
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Consumer<MarksProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.studentMarks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: commonShimmerList(itemCount: 10),
                        );
                      }

                      if (provider.studentMarks.isEmpty) {
                        return emptyScreen(
                          message: 'No Marks Found.',
                          heightMultiplier: 25,
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.studentMarks.length,
                        itemBuilder: (context, index) {
                          final studentMark = provider.studentMarks[index];
                          return MarkCard(
                            examtitle:
                                studentMark.internalExam?.internalName ?? "N/A",
                            subject:
                                studentMark
                                    .internalExam
                                    ?.subject
                                    ?.subjectName ??
                                "N/A",
                            mark:
                                studentMark.marksObtained != null &&
                                        studentMark.marksObtained!.isNotEmpty
                                    ? double.parse(studentMark.marksObtained!)
                                    : 0.0,
                            total:
                                studentMark.internalExam?.maxMarks != null &&
                                        studentMark
                                            .internalExam!
                                            .maxMarks
                                            .isNotEmpty
                                    ? double.parse(
                                      studentMark.internalExam!.maxMarks,
                                    )
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
          ),
        ],
      ),
    );
  }
}
