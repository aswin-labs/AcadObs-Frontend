import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/duty_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/duties/provider/duty_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DutyHomeScreen extends StatefulWidget {
  const DutyHomeScreen({super.key});

  @override
  State<DutyHomeScreen> createState() => _DutyHomeScreenState();
}

class _DutyHomeScreenState extends State<DutyHomeScreen> {
  late final DutyProvider _dutyProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dutyProvider = context.read<DutyProvider>();
    _dutyProvider.fetchStaffDuties();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom && !_dutyProvider.isLoading && _dutyProvider.hasMore) {
      _dutyProvider.fetchStaffDuties(loadMore: true);
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
      appBar: CommonAppBar(title: "Duties", isBackButton: true),
      body: RefreshIndicator(
        onRefresh: () => _dutyProvider.fetchStaffDuties(),
        child: Consumer<DutyProvider>(
          builder: (context, provider, _) {
            if (_dutyProvider.isLoading && _dutyProvider.staffDuties.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (_dutyProvider.staffDuties.isEmpty) {
              return emptyScreen(message: 'No Duties Found.');
            }

            // return ListView.builder(
            //   controller: _scrollController,
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   physics: const AlwaysScrollableScrollPhysics(),
            //   itemCount:
            //       _dutyProvider.staffDuties.length +
            //       (_dutyProvider.hasMore ? 2 : 1),
            //   itemBuilder: (context, index) {
            //     if (index == 0) {
            //       return SizedBox(height: Responsive.height * 3);
            //     }

            //     if (index == _dutyProvider.staffDuties.length + 1) {
            //       return const Padding(
            //         padding: EdgeInsets.all(16),
            //         child: Center(child: CircularProgressIndicator()),
            //       );
            //     }

            //     final grouped = _dutyProvider.staffDuties[index - 1];

            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           DateFormatter.formatDateTime(
            //             grouped.date ?? DateTime.now(),
            //           ),
            //           style: context.textTheme.titleSmall!.copyWith(
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //         SizedBox(height: Responsive.height * 1),
            //         ...grouped.requests!.map((d) {
            //           final dutyStatusStyle = getDutyStatusStyle(
            //             d.status ?? "",
            //           );
            //           return ItemCard(
            //             title: d.duty?.title ?? "",
            //             description: d.duty?.description ?? "",
            //             backgroundColor: dutyStatusStyle.backgroundColor,
            //             status:
            //                 d.status == "in_progress"
            //                     ? "In progress"
            //                     : d.status ?? "",
            //             icon: dutyStatusStyle.icon,
            //             iconColor: dutyStatusStyle.iconColor,
            //             onTap: () {
            //               context.pushNamed(
            //                 RouteConstants.dutyDetail,
            //                 extra: d.duty!,
            //               );
            //             },
            //           );
            //         }),
            //         SizedBox(height: Responsive.height * 2),
            //       ],
            //     );
            //   },
            // );

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  _dutyProvider.staffDuties.length +
                  (_dutyProvider.hasMore ? 2 : 1),
              itemBuilder: (context, index) {
                // final request = groupedDuty.requests![index];
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == _dutyProvider.staffDuties.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final grouped = _dutyProvider.staffDuties[index - 1];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDateTime(
                        grouped.date ?? DateTime.now(),
                      ),
                      style: context.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Responsive.height * 1),
                    ...grouped.requests!.map((d) {
                      final dutyStatusStyle = getDutyStatusStyle(
                        d.status ?? "",
                      );
                      return ItemCard(
                        title: d.duty?.title ?? "",
                        description: d.duty?.description ?? "",
                        backgroundColor: dutyStatusStyle.backgroundColor,
                        status:
                            d.status == "in_progress"
                                ? "In progress"
                                : d.status ?? "",
                        icon: dutyStatusStyle.icon,
                        iconColor: dutyStatusStyle.iconColor,
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.dutyDetail,
                            extra: d.duty!,
                          );
                        },
                      );
                    }),
                    SizedBox(height: Responsive.height * 2),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
    // return Scaffold(
    //   appBar: CommonAppBar(title: "Duties"),
    //   body: RefreshIndicator(
    //     onRefresh: () async {
    //       await context.read<DutyProvider>().fetchStaffDuties(
    //         forceRefresh: true,
    //       );
    //     },
    //     child: CustomScrollView(
    //       controller: _scrollController,
    //       physics: const BouncingScrollPhysics(
    //         parent: AlwaysScrollableScrollPhysics(),
    //       ),
    //       slivers: [
    //         SliverToBoxAdapter(
    //           child: Padding(
    //             padding: context.paddingHorizontal.add(
    //               EdgeInsets.only(top: Responsive.height * 2),
    //             ),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Consumer<DutyProvider>(
    //                   builder: (context, provider, _) {
    //                     if (provider.isLoading &&
    //                         provider.staffDuties.isEmpty) {
    //                       return commonShimmerList();
    //                     }

    //                     if (provider.staffDuties.isEmpty) {
    //                       return emptyScreen(message: 'No Duties Found.');
    //                     }

    //                     return ListView.builder(
    //                       shrinkWrap: true,
    //                       physics: const NeverScrollableScrollPhysics(),
    //                       itemCount: provider.staffDuties.length,
    //                       itemBuilder: (context, index) {
    //                         final duty = provider.staffDuties[index];
    //                         final dutyStatusStyle = getDutyStatusStyle(
    //                           duty.status,
    //                         );
    //                         return ItemCard(
    //                           title: duty.duty.title,
    //                           description: duty.duty.description,
    //                           status:
    //                               duty.status == "in_progress"
    //                                   ? "In Progress"
    //                                   : duty.status,
    //                           backgroundColor: dutyStatusStyle.backgroundColor,
    //                           icon: dutyStatusStyle.icon,
    //                           iconColor: dutyStatusStyle.iconColor,
    //                           onTap:
    //                               () => context.pushNamed(
    //                                 RouteConstants.dutyDetail,
    //                                 extra: duty,
    //                               ),
    //                         );
    //                       },
    //                     );
    //                   },
    //                 ),
    //                 Consumer<DutyProvider>(
    //                   builder: (context, provider, _) {
    //                     return provider.isLoading && provider.hasMore
    //                         ? const Padding(
    //                           padding: EdgeInsets.symmetric(vertical: 16),
    //                           child: Center(child: CircularProgressIndicator()),
    //                         )
    //                         : const SizedBox();
    //                   },
    //                 ),

    //                 SizedBox(height: Responsive.height * 4),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
