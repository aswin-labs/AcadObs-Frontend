import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/add_marks_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class MarksHomeScreen extends StatefulWidget {
  const MarksHomeScreen({super.key});

  @override
  State<MarksHomeScreen> createState() => _MarksHomeScreenState();
}

class _MarksHomeScreenState extends State<MarksHomeScreen> {
  late final MarksProvider _marksProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _marksProvider = context.read<MarksProvider>();
    _marksProvider.fetchAddedMarks();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom && !_marksProvider.isLoading && _marksProvider.hasMore) {
      _marksProvider.fetchAddedMarks(loadMore: true);
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
      appBar: CommonAppBar(title: "Marks"),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MarksProvider>().fetchAddedMarks(
            forceRefresh: true,
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<MarksProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.marks.isEmpty) {
                          return commonShimmerList();
                        }

                        if (provider.marks.isEmpty) {
                          return emptyScreen(message: 'No Records Found.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.marks.length,
                          itemBuilder: (context, index) {
                            final mark = provider.marks[index];

                            return ItemCard(
                              title: mark.internalName,
                              description: DateFormatter.formatDateString(
                                mark.date.toString(),
                              ),
                              iconColor: Color(0xFFB14F6F),
                              backgroundColor: Color(0xFFFFCEDE),
                              icon: LucideIcons.clipboardList,
                              onTap:
                                  () => context.pushNamed(
                                    RouteConstants.marksDetails,
                                    extra: mark,
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
                    SizedBox(height: Responsive.height * 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: CommonFloatingButton(
          onPressed: () => showAddMarksBottomSheet(context: context),
        ),
      ),
    );
  }
}
