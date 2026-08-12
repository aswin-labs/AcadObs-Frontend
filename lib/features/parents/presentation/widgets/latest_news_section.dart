import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Latest News',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
               Spacer(),
            TextButton(
              onPressed: () {
                context.pushNamed(
                  RouteConstants.newsDetailsScreen,
                  extra: false,
                );
              },
              child: Text("View", style: TextStyle(color: Colors.black)),
            ),
            ],
          ),
          SizedBox(height: 16),
          Consumer<NewsProvider>(
            builder: (context, provider, _) {
              final news = provider.newsLatest;
              if (provider.isLatestLoading && news.isEmpty) {
                return commonShimmerList(height: 80, itemCount: 3);
              }

              if (news.isEmpty) {
                return emptyScreen(
                  message: "No News Available",
                  heightMultiplier: 5,
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: news.length,
                separatorBuilder: (context, index) => SizedBox(height: 2),
                itemBuilder: (context, index) {
                  log("Length of news: ${news.length}");
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
              );
            },
          ),
        ],
      ),
    );
  }
}
