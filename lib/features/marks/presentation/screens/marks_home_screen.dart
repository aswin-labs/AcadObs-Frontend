import 'dart:async';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/add_marks_bottomsheet.dart';
import 'package:acadobs/features/marks/presentation/widgets/add_term_marks_bottomsheet.dart';
import 'package:acadobs/features/marks/presentation/widgets/term_mark_card.dart';
import 'package:acadobs/features/marks/presentation/widgets/term_marks_filter_bottomsheet.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _termMarksScrollController.addListener(_termMarksScrollListener);
    _otherMarksScrollController.addListener(_marksScrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _marksProvider.fetchAddedMarks();
      _termExamProvider.fetchTermExams();
      context.read<SubjectProvider>().fetchAllSubjects();
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
    final activeTabColor =
        _tabController.index == 0
            ? Theme.of(context).primaryColor
            : const Color(0xFFBE185D);

    return Scaffold(
      appBar: CommonAppBar(
        title: "Marks",
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'multi_teacher_marks') {
                  context.pushNamed(RouteConstants.multiTeacherSubjectMarks);
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem<String>(
                      value: 'multi_teacher_marks',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 20),
                          SizedBox(width: 10),
                          Text("Multi Teacher Subjects"),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: activeTabColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: activeTabColor.withAlpha(45),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade700,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.notebookTabs, size: 16),
                        SizedBox(width: 8),
                        Text("Term Exams"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.clipboardCheck, size: 16),
                        SizedBox(width: 8),
                        Text("Class Tests"),
                      ],
                    ),
                  ),
                ],
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
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<TermExamProvider>().searchQuery,
    );
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<TermExamProvider>().searchTermExamMarks(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    context.read<TermExamProvider>().clearSearchQuery();
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
                  // Action Banner for Term Exams
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.notebookTabs,
                                size: 20,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Term Examinations",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Official scheduled exams (Term 1, Term 2, Annual)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CommonButton(
                          minButtonHeight: 46,
                          backgroundColor: const Color(0xFF1D4ED8),
                          onPressed:
                              () => showAddTermMarksBottomSheet(context: context),
                          widget: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.plus, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Add Term Exam Marks",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<TermExamProvider>(
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
                                      hintText: "Search term marks...",
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
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: _clearSearch,
                                              )
                                              : null,
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Filter Button with Badge
                              Material(
                                color:
                                    activeFilters > 0
                                        ? Theme.of(context).primaryColor
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap:
                                      () => showTermMarksFilterBottomSheet(
                                        context: context,
                                      ),
                                  child: Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            activeFilters > 0
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.slidersHorizontal,
                                          size: 18,
                                          color:
                                              activeFilters > 0
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                        if (activeFilters > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "$activeFilters",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (provider.hasActiveFilters) ...[
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (provider.searchQuery.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
                                        label: Text(
                                          'Search: "${provider.searchQuery}"',
                                        ),
                                        labelStyle: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withAlpha(25),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onDeleted: _clearSearch,
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  if (provider.filterExamName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
                                        label: Text(provider.filterExamName!),
                                        labelStyle: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withAlpha(25),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onDeleted:
                                            () => provider.clearExamFilter(),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  if (provider.filterClassName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
                                        label: Text(
                                          "Class ${provider.filterClassName!}",
                                        ),
                                        labelStyle: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withAlpha(25),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onDeleted:
                                            () => provider.clearClassFilter(),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  if (provider.filterSubjectName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
                                        label: Text(
                                          provider.filterSubjectName!,
                                        ),
                                        labelStyle: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withAlpha(25),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onDeleted:
                                            () => provider.clearSubjectFilter(),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.clearTermExamFilters();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      "Clear all",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
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
                  Consumer<TermExamProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoadingMarks && provider.marks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: commonShimmerList(),
                        );
                      }

                      if (provider.marks.isEmpty) {
                        return Column(
                          children: [
                            emptyScreen(
                              message:
                                  provider.hasActiveFilters
                                      ? "No marks found matching selected filters / search"
                                      : "No marks found",
                              heightMultiplier: 16,
                            ),
                            if (provider.hasActiveFilters)
                              TextButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearTermExamFilters();
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text("Reset Filters"),
                              ),
                          ],
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

class _OtherMarksTab extends StatefulWidget {
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;
  const _OtherMarksTab({
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  State<_OtherMarksTab> createState() => _OtherMarksTabState();
}

class _OtherMarksTabState extends State<_OtherMarksTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
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
                  // Action Banner for Class Tests
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFBCFE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE7F3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.clipboardCheck,
                                size: 20,
                                color: Color(0xFFBE185D),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Class Tests",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF831843),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Unit tests, chapter tests, monthly tests & activities",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CommonButton(
                          minButtonHeight: 46,
                          backgroundColor: const Color(0xFFBE185D),
                          onPressed:
                              () => showAddMarksBottomSheet(context: context),
                          widget: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.plus, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Add Class Test Marks",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar for Internal Marks
                  Container(
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
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: "Search class tests by test, class, or subject...",
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
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFBE185D),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                          message: "No class tests found",
                          heightMultiplier: 16,
                        );
                      }

                      final displayedMarks =
                          _searchQuery.isEmpty
                              ? provider.marks
                              : provider.marks.where((mark) {
                                final name = mark.internalName.toLowerCase();
                                final subject =
                                    (mark.subject?.subjectName ?? '')
                                        .toLowerCase();
                                final className =
                                    (mark.classGrade?.classname ?? '')
                                        .toLowerCase();
                                return name.contains(_searchQuery) ||
                                    subject.contains(_searchQuery) ||
                                    className.contains(_searchQuery);
                              }).toList();

                      if (displayedMarks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.searchX,
                                  size: 40,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No matching class tests found",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Text("Clear Search"),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedMarks.length,
                        itemBuilder: (context, index) {
                          final mark = displayedMarks[index];

                          return TermMarkCard(
                            mark: mark,
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
