import 'dart:async';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/marks/presentation/widgets/term_mark_card.dart';
import 'package:acadobs/features/marks/presentation/widgets/term_marks_filter_bottomsheet.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/my_class_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
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
          const SizedBox(height: 16),
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
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: const [Tab(text: 'Term Exams'), Tab(text: 'Class Tests')],
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

class _TermMarksTab extends StatefulWidget {
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;
  const _TermMarksTab({
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  State<_TermMarksTab> createState() => _TermMarksTabState();
}

class _TermMarksTabState extends State<_TermMarksTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final provider = context.read<MyClassProvider>();
    _searchController.text = provider.searchQuery;
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<MyClassProvider>().searchTermExamMarks(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    context.read<MyClassProvider>().clearSearchQuery();
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        backgroundColor: Colors.blue.shade50,
        side: BorderSide(color: Colors.blue.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  // Search and Filter Bar
                  Consumer<MyClassProvider>(
                    builder: (context, provider, _) {
                      final activeFilters = provider.activeFilterCount;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              // Search Input Box
                              Expanded(
                                child: Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(6),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) {
                                      setState(() {});
                                      _onSearchChanged(val);
                                    },
                                    style: const TextStyle(fontSize: 13.5),
                                    decoration: InputDecoration(
                                      hintText: "Search class term marks...",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13,
                                      ),
                                      prefixIcon: const Icon(
                                        LucideIcons.search,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  size: 18,
                                                ),
                                                onPressed: _clearSearch,
                                              )
                                              : null,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Filter Button with Badge
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color:
                                      activeFilters > 0
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        activeFilters > 0
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(6),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        LucideIcons.slidersHorizontal,
                                        size: 19,
                                        color:
                                            activeFilters > 0
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      onPressed: () {
                                        showTermMarksFilterBottomSheet(
                                          context: context,
                                          showClassFilter: false, // Class is already implicit
                                          initialExamId: provider.filterExamId,
                                          initialExamName:
                                              provider.filterExamName,
                                          initialSubjectId:
                                              provider.filterSubjectId,
                                          initialSubjectName:
                                              provider.filterSubjectName,
                                          onApply: ({
                                            examId,
                                            examName,
                                            standard,
                                            classId,
                                            className,
                                            subjectId,
                                            subjectName,
                                          }) {
                                            provider.applyTermExamFilters(
                                              examId: examId,
                                              examName: examName,
                                              subjectId: subjectId,
                                              subjectName: subjectName,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    if (activeFilters > 0)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            '$activeFilters',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Active Filter Chips
                          if (activeFilters > 0) ...[
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (provider.filterExamName != null)
                                    _buildFilterChip(
                                      label:
                                          "Exam: ${provider.filterExamName}",
                                      onDeleted:
                                          () => provider.clearExamFilter(),
                                    ),
                                  if (provider.filterSubjectName != null)
                                    _buildFilterChip(
                                      label:
                                          "Subject: ${provider.filterSubjectName}",
                                      onDeleted:
                                          () => provider.clearSubjectFilter(),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      provider.clearTermExamFilters();
                                    },
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      "Clear All",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Consumer<MyClassProvider>(
                    builder: (context, provider, _) {
                      if ((!provider.isTermMarksFetchedOnce ||
                              provider.isLoadingMarks) &&
                          provider.marks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
                      }

                      if (provider.marks.isEmpty) {
                        if (provider.hasActiveFilters) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.filterX,
                                    size: 44,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No matching marks found",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Try clearing filters or search terms",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.clearTermExamFilters();
                                    },
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text("Reset Filters"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

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

                          return TermMarkCard(
                            mark: mark,
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
                      if ((!provider.isInternalMarksFetchedOnce ||
                              provider.isLoadingInternalMarks) &&
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

                          return TermMarkCard(
                            mark: mark,
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
