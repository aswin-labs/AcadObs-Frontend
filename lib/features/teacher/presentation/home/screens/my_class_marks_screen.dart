import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/my_class_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class MyClassMarksScreen extends StatefulWidget {
  final ClassGradeModel classGrade;
  const MyClassMarksScreen({super.key, required this.classGrade});

  @override
  State<MyClassMarksScreen> createState() => _MyClassMarksScreenState();
}

class _MyClassMarksScreenState extends State<MyClassMarksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MyClassProvider _myClassProvider;

  final ScrollController _termMarksScrollController = ScrollController();
  final ScrollController _otherMarksScrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    _myClassProvider = context.read<MyClassProvider>();

    _tabController = TabController(length: 2, vsync: this);

    _termMarksScrollController.addListener(_termMarksScrollListener);
    _otherMarksScrollController.addListener(_otherMarksScrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _myClassProvider.fetchMyClassTermExamMarks();
      _myClassProvider.fetchMyClassInternalMarks();
    });
  }

  void _termMarksScrollListener() {
    final isNearBottom =
        _termMarksScrollController.position.pixels >=
        _termMarksScrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_myClassProvider.isLoadingMarks &&
        _myClassProvider.hasMore) {
      _myClassProvider.fetchMyClassTermExamMarks(loadMore: true);
    }
  }

  void _otherMarksScrollListener() {
    final isNearBottom =
        _otherMarksScrollController.position.pixels >=
        _otherMarksScrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_myClassProvider.isLoadingMarks &&
        _myClassProvider.hasMore) {
      _myClassProvider.fetchMyClassTermExamMarks(loadMore: true);
    }
  }

  @override
  void dispose() {
    _otherMarksScrollController.dispose();
    _termMarksScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshTermMarks() async {
    await context.read<MyClassProvider>().fetchMyClassTermExamMarks(
      forceRefresh: true,
    );
  }

  Future<void> _refreshOtherMarks() async {
    await context.read<MyClassProvider>().fetchMyClassInternalMarks(
      forceRefresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Class ${widget.classGrade.classname}",
        isBackButton: true,
      ),
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
                  onRefresh: _refreshOtherMarks,
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
                  Consumer<MyClassProvider>(
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
                          final subjectName = mark.subject?.subjectName ?? "";

                          return ItemCard(
                            title:
                                subjectName.isNotEmpty
                                    ? subjectName
                                    : "Subject Not Specified",
                            description:
                                title.isNotEmpty ? title : "Not Specified",

                            iconColor: Colors.green,
                            backgroundColor: const Color(0xFFE8F5E9),
                            icon: LucideIcons.clipboardList,
                            onTap:
                                () => context.pushNamed(
                                  RouteConstants.marksDetails,
                                  extra: MarkDetailParameters(
                                    mark: mark,
                                    isEditNeeded: false,
                                  ),
                                ),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<MyClassProvider>(
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
                  Consumer<MyClassProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingInternalMarks &&
                          provider.internalMarks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
                      }

                      if (provider.internalMarks.isEmpty) {
                        return emptyScreen(
                          message: "No Marks found",
                          heightMultiplier: 16,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.internalMarks.length,
                        itemBuilder: (context, index) {
                          final mark = provider.internalMarks[index];
                          final subjectName = mark.subject?.subjectName ?? "";
                          return ItemCard(
                            title:
                                subjectName.isNotEmpty
                                    ? subjectName
                                    : "Subject Not Specified",
                            description: "Title: ${mark.internalName}",
                            iconColor: Color(0xFFB14F6F),
                            backgroundColor: Color(0xFFFFCEDE),
                            icon: LucideIcons.clipboardList,
                            onTap:
                                () => context.pushNamed(
                                  RouteConstants.marksDetails,
                                  extra: MarkDetailParameters(
                                    mark: mark,
                                    isEditNeeded: false,
                                  ),
                                ),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<MyClassProvider>(
                    builder: (context, provider, _) {
                      return provider.isLoadingInternalMarks &&
                              provider.hasMoreInternal
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
