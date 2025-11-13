import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
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
    return Column(
      children: [
        Row(
          children: [
            Text(
              "News",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                context.pushNamed(
                  RouteConstants.newsDetailsScreen,
                  extra: true,
                );
              },
              child: Text("View", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        SizedBox(height: 5),
        Consumer<NewsProvider>(
          builder: (context, provider, _) {
            final news = provider.newsLatest;
            if (provider.isLoading) {
              return Center(child: CommonShimmerTile());
            } else if (news.isEmpty) {
              return emptyScreen(
                message: "No News Avaliable",
                heightMultiplier: 5,
              );
            }

            return Column(
              children:
                  news.map((news) {
                    final formattedDate = DateFormat(
                      'dd-MM-yy',
                    ).format(news.date);
                    return NewsCard(
                      news: news,
                      button: () {
                        context.pushNamed(
                          RouteConstants.newsScreen,
                          extra: news,
                        );
                      },
                      date: formattedDate,
                      time: TimeFormatter.formatTime(news.createdAt),
                      title: capitalizeEachWord(news.title),
                      content: news.content,
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}
