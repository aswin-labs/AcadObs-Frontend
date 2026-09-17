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

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        final news = provider.newsLatest;
        final isLoading = provider.isLatestLoading && news.isEmpty;

        if (!provider.isLatestLoading && news.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Latest News',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.newsDetailsScreen,
                        extra: false,
                      );
                    },
                    child: const Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isLoading)
                commonShimmerList(height: 80, itemCount: 3)
              else
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: news.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final newsItem = news[index];
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
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
