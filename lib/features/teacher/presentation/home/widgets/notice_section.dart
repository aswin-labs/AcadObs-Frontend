import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/notices/presentation/provider/notice_provider.dart';
import 'package:acadobs/features/notices/presentation/widgets/notice_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NoticeSection extends StatelessWidget {
  const NoticeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Notices",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                context.pushNamed(RouteConstants.noticeListscreen);
              },
              child: Text("View", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        Consumer<NoticeProvider>(
          builder: (context, provider, _) {
            final notices = provider.noticesLatest;
            if (provider.isLatestLoading && notices.isEmpty) {
              return const Center(child: CommonShimmerTile());
            }
            if (notices.isEmpty) {
              return emptyScreen(
                message: "No Notices Avaliable",
                heightMultiplier: 5,
              );
            }
            return Column(
              children:
                  notices.map((notice) {
                    final date =
                        "${notice.createdAt.day.toString().padLeft(2, '0')}-${notice.createdAt.month.toString().padLeft(2, '0')}-${notice.createdAt.year}";
                    return NoticeCard(
                      title: capitalizeEachWord(notice.title ?? "N/A"),
                      date: date,
                      icon: Icons.notifications,
                      time: TimeFormatter.formatTime(notice.createdAt),
                      onTap: () {
                        context.pushNamed(
                          RouteConstants.noticedetails,
                          extra: notice,
                        );
                      },
                    );
                  }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
