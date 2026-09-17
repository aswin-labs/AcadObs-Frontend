import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        final news = provider.newsLatest;
        final isLoading = provider.isLatestLoading && news.isEmpty;

        if (!provider.isLatestLoading && news.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              children: [
                const Text(
                  "News",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.pushNamed(
                      RouteConstants.newsDetailsScreen,
                      extra: true,
                    );
                  },
                  child: const Text("View", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (isLoading)
              commonShimmerList(height: 80, itemCount: 3)
            else
              Column(
                children:
                    news.map((newsItem) {
                      final formattedDate = DateFormat(
                        'dd-MM-yy',
                      ).format(newsItem.date);
                      return NewsCard(
                        news: newsItem,
                        button: () {
                          context.pushNamed(
                            RouteConstants.newsScreen,
                            extra: newsItem,
                          );
                        },
                        date: formattedDate,
                        time: TimeFormatter.formatTime(newsItem.createdAt),
                        title: capitalizeEachWord(newsItem.title),
                        content: newsItem.content,
                      );
                    }).toList(),
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
