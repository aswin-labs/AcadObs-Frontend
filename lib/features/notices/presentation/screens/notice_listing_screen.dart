import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/notices/presentation/provider/notice_provider.dart';
import 'package:acadobs/features/notices/presentation/widgets/notice_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NoticeListingScreen extends StatefulWidget {
  const NoticeListingScreen({super.key});

  @override
  State<NoticeListingScreen> createState() => _NoticeListingScreenState();
}

class _NoticeListingScreenState extends State<NoticeListingScreen> {
  late final NoticeProvider _provider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _provider = context.read<NoticeProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchNotices();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchNotices(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Notices', isBackButton: true),
      body: RefreshIndicator(
        onRefresh: () => _provider.fetchNotices(),
        child: Consumer<NoticeProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.noticesAll.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.noticesAll.isEmpty) {
              return emptyScreen(message: 'No Notices Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount:
                  provider.noticesAll.length + (provider.hasMore ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == provider.noticesAll.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notice = provider.noticesAll[index - 1];

                return NoticeCard(
                  title: notice.title ?? "",
                  date: DateFormatter.formatDateString(notice.date),
                  icon: Icons.notifications_none,
                  time: TimeFormatter.formatTime(notice.createdAt),
                  onTap:
                      () => context.pushNamed(
                        RouteConstants.noticedetails,
                        extra: notice,
                      ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
