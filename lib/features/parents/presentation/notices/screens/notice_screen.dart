import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/parents/presentation/notices/widgets/notice_card.dart';
import 'package:acadobs/features/parents/presentation/notices/provider/notice_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NoticeProvider>(context, listen: false).fetchNotices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Notices", isBackButton: true),
      body: Consumer<NoticeProvider>(
        builder: (context, noticeProvider, _) {
          if (noticeProvider.isLoading && noticeProvider.notices.isEmpty) {
            return commonShimmerList();
          } else if (noticeProvider.error != null) {
            return Center(child: Text(noticeProvider.error!));
          } else if (noticeProvider.notices.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notification_important_outlined,
                    color: Colors.grey,
                    size: 35,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Notices avaliable",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent - 100 &&
                    !noticeProvider.isLoading &&
                    noticeProvider.hasMore) {
                  noticeProvider.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 60),
                physics: const BouncingScrollPhysics(),
                itemCount:
                    noticeProvider.notices.length +
                    (noticeProvider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == noticeProvider.notices.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final notice = noticeProvider.notices[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: NoticeCard(
                      title: notice.title ?? "",
                      date: DateFormatter.formatDateString(notice.date),
                      icon: Icons.notifications_none,
                      time: TimeFormatter.formatTime(notice.createdAt),
                      //route
                      onTap:
                          () => context.pushNamed(
                            RouteConstants.noticedetails,
                            extra: notice,
                          ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
