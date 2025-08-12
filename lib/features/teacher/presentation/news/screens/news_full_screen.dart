import 'dart:developer';
import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
// import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/teacher/presentation/news/widgets/news_card.dart';
import 'package:acadobs/features/teacher/presentation/news/provider/news_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NewsDetailsScreen extends StatefulWidget {
  const NewsDetailsScreen({super.key});

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NewsProvider>(
          context,
          listen: false,
        ).fetchNews(limit: AppConstants.paginationLimit, isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "News", isBackButton: true),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            log("error");
            return commonShimmerList();
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.newsModel.isEmpty) {
            return const Center(
              child: Column(
                children: [
                  Icon(Icons.newspaper_rounded, color: Colors.grey, size: 35),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "No News Found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // News lists
            final todayNews = provider.todayNews;
            final yesterdayNews = provider.yesterdayNews;
            final earlierNews = provider.earlierNews;

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent - 100 &&
                    !provider.isLoading &&
                    provider.hasMore) {
                  provider.loadMore();
                }
                return false;
              },
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 60),
                children: [
                  if (todayNews.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text("Today", style: TextStyle(fontSize: 15)),
                    ),
                    ...todayNews.map(
                      (news) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NewsCard(
                          news: news,
                          button:
                              () => context.pushNamed(
                                RouteConstants.newsScreen,
                                extra: news,
                              ),
                          date: DateFormatter.formatDateTime(news.date),
                          // time: DateFormatter.formatDateTime(news.date),
                          time: "",

                          title: capitalizeEachWord(news.title),
                          content: capitalizeEachWord(news.content),
                        ),
                      ),
                    ),
                  ],
                  if (yesterdayNews.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text("Yesterday", style: TextStyle(fontSize: 16)),
                    ),
                    ...yesterdayNews.map(
                      (news) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: NewsCard(
                          news: news,
                          button:
                              () => context.pushNamed(
                                RouteConstants.newsScreen,
                                extra: news,
                              ),
                          date: DateFormatter.formatDateTime(news.date),
                          // time: DateFormatter.formatDateTime(news.date),
                          time: "",
                          title: capitalizeEachWord(news.title),
                          content: capitalizeEachWord(news.content),
                        ),
                      ),
                    ),
                  ],
                  if (earlierNews.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text("Earlier", style: TextStyle(fontSize: 16)),
                    ),
                    ...earlierNews.map(
                      (news) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: NewsCard(
                          news: news,
                          button:
                              () => context.pushNamed(
                                RouteConstants.newsScreen,
                                extra: news,
                              ),
                          date: DateFormatter.formatDateTime(news.date),
                          // time: DateFormatter.formatDateTime(news.date),
                          time: '',
                          title: capitalizeEachWord(news.title),
                          content: capitalizeEachWord(news.content),
                        ),
                      ),
                    ),
                  ],

                  if (provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
      // ),
    );
  }
}
