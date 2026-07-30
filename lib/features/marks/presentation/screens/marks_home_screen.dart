import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/add_marks_bottomsheet.dart';
import 'package:acadobs/features/marks/presentation/widgets/add_term_marks_bottomsheet.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MarksHomeScreen extends StatefulWidget {
  const MarksHomeScreen({super.key});

  @override
  State<MarksHomeScreen> createState() => _MarksHomeScreenState();
}

class _MarksHomeScreenState extends State<MarksHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MarksProvider _marksProvider;
  late final TermExamProvider _termExamProvider;

  final ScrollController _termMarksScrollController = ScrollController();
  final ScrollController _otherMarksScrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    _marksProvider = context.read<MarksProvider>();
    _termExamProvider = context.read<TermExamProvider>();

    _tabController = TabController(length: 2, vsync: this);

    _termMarksScrollController.addListener(_termMarksScrollListener);
    _otherMarksScrollController.addListener(_marksScrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _marksProvider.fetchAddedMarks();
      _termExamProvider.fetchTermExams();
      context.read<TermExamProvider>().fetchAddedTermExamMarks(
        forceRefresh: true,
      );
    });
  }

  void _marksScrollListener() {
    final isNearBottom =
        _otherMarksScrollController.position.pixels >=
        _otherMarksScrollController.position.maxScrollExtent - 200;

    if (isNearBottom && !_marksProvider.isLoading && _marksProvider.hasMore) {
      _marksProvider.fetchAddedMarks(loadMore: true);
    }
  }

  void _termMarksScrollListener() {
    final isNearBottom =
        _termMarksScrollController.position.pixels >=
        _termMarksScrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_termExamProvider.isLoadingMarks &&
        _termExamProvider.hasMore) {
      _termExamProvider.fetchAddedTermExamMarks(loadMore: true);
    }
  }

  @override
  void dispose() {
    _otherMarksScrollController.dispose();
    _termMarksScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshMarks() async {
    await context.read<MarksProvider>().fetchAddedMarks(forceRefresh: true);
  }

  Future<void> _refreshTermMarks() async {
    await context.read<TermExamProvider>().fetchAddedTermExamMarks(
      forceRefresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Marks"),
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
                dividerColor: Colors.transparent, // Removes the black line
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
                  onRefresh: _refreshTermMarks,
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
                  CommonButton(
                    onPressed:
                        () => {showAddTermMarksBottomSheet(context: context)},
                    widget: Text("Add Term Marks"),
                  ),
                  SizedBox(height: 16),
                  Consumer<TermExamProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingMarks && provider.marks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
                      }

                      if (provider.marks.isEmpty) {
                        return emptyScreen(
                          message: "No marks found",
                          heightMultiplier: 16,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.marks.length,
                        itemBuilder: (context, index) {
                          final mark = provider.marks[index];

                          final title = capitali(
                            "${mark.termExam?.examName ?? ''} - ${mark.internalName} (${mark.termExam?.educationYear ?? ''}) ",
                          );

                          final className = mark.classGrade?.classname ?? '';
                          final subjectName = mark.subject?.subjectName ?? "";
                          return ItemCard(
                            title: title,
                            description: "Class: $className - $subjectName",
                            iconColor: Colors.green,
                            backgroundColor: const Color(0xFFE8F5E9),
                            icon: LucideIcons.clipboardList,
                            onTap:
                                () => context.pushNamed(
                                  RouteConstants.marksDetails,
                                  extra: MarkDetailParameters(
                                    mark: mark,
                                    isEditNeeded: true,
                                  ),
                                ),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<TermExamProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoadingMarks && provider.hasMore
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox();
                    },
                  ),
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
                  CommonButton(
                    onPressed:
                        () => {showAddMarksBottomSheet(context: context)},
                    widget: Text("Add Marks"),
                  ),
                  SizedBox(height: 16),
                  Consumer<MarksProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.marks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
                      }

                      if (provider.marks.isEmpty) {
                        return emptyScreen(
                          message: "No marks found",
                          heightMultiplier: 16,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.marks.length,
                        itemBuilder: (context, index) {
                          final mark = provider.marks[index];
                          final subjectName = mark.subject?.subjectName ?? "";
                          final className = mark.classGrade?.classname ?? '';

                          return ItemCard(
                            title: mark.internalName,
                            description: "Class: $className - $subjectName",
                            iconColor: Color(0xFFB14F6F),
                            backgroundColor: Color(0xFFFFCEDE),
                            icon: LucideIcons.clipboardList,
                            onTap:
                                () => context.pushNamed(
                                  RouteConstants.marksDetails,
                                  extra: MarkDetailParameters(
                                    mark: mark,
                                    isEditNeeded: true,
                                  ),
                                ),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<MarksProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoading && provider.hasMore
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
