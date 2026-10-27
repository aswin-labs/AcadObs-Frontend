import 'dart:async';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/term_mark_card.dart';
import 'package:acadobs/features/marks/presentation/widgets/term_marks_filter_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _termExamProvider = context.read<TermExamProvider>();
    _searchController.text = _termExamProvider.multiSearchQuery;

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

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<TermExamProvider>().searchMultiTeacherMarks(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    context.read<TermExamProvider>().clearMultiSearchQuery();
  }

  Future<void> _refreshMarks() async {
    await _termExamProvider.fetchMultiTeacherSubjectMarks(forceRefresh: true);
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
                    // Search and Filter Bar
                    Consumer<TermExamProvider>(
                      builder: (context, provider, _) {
                        final activeFilters = provider.multiActiveFilterCount;

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
                                        hintText:
                                            "Search multi teacher marks...",
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
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
                                            showClassFilter: true,
                                            initialExamId:
                                                provider.multiFilterExamId,
                                            initialExamName:
                                                provider.multiFilterExamName,
                                            initialStandard:
                                                provider.multiFilterStandard,
                                            initialClassId:
                                                provider.multiFilterClassId,
                                            initialClassName:
                                                provider.multiFilterClassName,
                                            initialSubjectId:
                                                provider.multiFilterSubjectId,
                                            initialSubjectName:
                                                provider.multiFilterSubjectName,
                                            onApply: ({
                                              examId,
                                              examName,
                                              standard,
                                              classId,
                                              className,
                                              subjectId,
                                              subjectName,
                                            }) {
                                              provider.applyMultiTeacherFilters(
                                                examId: examId,
                                                examName: examName,
                                                standard: standard,
                                                classId: classId,
                                                className: className,
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
                                    if (provider.multiFilterExamName != null)
                                      _buildFilterChip(
                                        label:
                                            "Exam: ${provider.multiFilterExamName}",
                                        onDeleted:
                                          () => provider.clearMultiExamFilter(),
                                      ),
                                    if (provider.multiFilterClassName != null)
                                      _buildFilterChip(
                                        label:
                                            "Class: ${provider.multiFilterClassName}",
                                        onDeleted:
                                          () => provider
                                              .clearMultiClassFilter(),
                                      ),
                                    if (provider.multiFilterSubjectName != null)
                                      _buildFilterChip(
                                        label:
                                            "Subject: ${provider.multiFilterSubjectName}",
                                        onDeleted:
                                          () => provider
                                              .clearMultiSubjectFilter(),
                                      ),
                                    TextButton(
                                      onPressed: () {
                                        provider.clearMultiTeacherFilters();
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
                          if (provider.hasActiveMultiFilters) {
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
                                        provider.clearMultiTeacherFilters();
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

                            return TermMarkCard(
                              mark: mark,
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
