import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/duties/provider/duty_provider.dart';
import 'package:acadobs/presentation/widgets/common_appbar.dart';
import 'package:acadobs/presentation/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DutyHomeScreen extends StatefulWidget {
  const DutyHomeScreen({super.key});

  @override
  State<DutyHomeScreen> createState() => _DutyHomeScreenState();
}

class _DutyHomeScreenState extends State<DutyHomeScreen> {
  late DutyProvider dutyProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    dutyProvider = context.read<DutyProvider>();
    dutyProvider.fetchStaffDuties();

    // Listen for scroll end to trigger load more
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // When scrolled near the bottom, load more if available
      if (!dutyProvider.isLoading && dutyProvider.hasMore) {
        dutyProvider.fetchStaffDuties(loadMore: true);
      }
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
      appBar: CommonAppBar(title: "Duties"),
      body: Consumer<DutyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.staffDuties.isEmpty) {
            // Initial loading spinner
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.staffDuties.isEmpty) {
            // Empty state
            return const Center(child: Text('No Duties Found.'));
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: context.paddingHorizontal,
                sliver: SliverToBoxAdapter(
                  child: SizedBox(height: Responsive.height * 2),
                ),
              ),

              SliverPadding(
                padding: context.paddingHorizontal,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final duty = provider.staffDuties[index];
                    return ItemCard(
                      title: duty.duty.title,
                      description: duty.duty.description,
                      status: duty.status,
                      onTap: () {
                        // Handle tap
                      },
                    );
                  }, childCount: provider.staffDuties.length),
                ),
              ),

              // Load More Spinner at Bottom
              SliverToBoxAdapter(
                child:
                    provider.isLoading && provider.hasMore
                        ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox(),
              ),

              SliverPadding(
                padding: context.paddingHorizontal,
                sliver: SliverToBoxAdapter(
                  child: SizedBox(height: Responsive.height * 4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
