import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewsDetailsScreen extends StatefulWidget {
  final bool forStaff;
  const NewsDetailsScreen({super.key, this.forStaff = true});

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NewsProvider>(context, listen: false).fetchLatestNews(
          limit: AppConstants.paginationLimit,
          isRefresh: true,
          forStaff: widget.forStaff,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "News", isBackButton: widget.forStaff),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.newsModel.isEmpty) {
            return commonShimmerList();
          } else if (provider.error != null) {
            return Center(child: Text(provider.error!));
          } else if (provider.newsModel.isEmpty) {
            return emptyScreen(message: "No News Available");
          } else {
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
                  provider.loadMore(forStaff: widget.forStaff);
                }
                return false;
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification &&
                      scrollNotification.metrics.pixels >=
                          scrollNotification.metrics.maxScrollExtent - 100 &&
                      !provider.isLoading &&
                      provider.hasMore) {
                    provider.loadMore(forStaff: widget.forStaff);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todayNews.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              "Today",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          ...todayNews.map(
                            (news) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: NewsCard(
                                news: news,
                                button:
                                    () => context.pushNamed(
                                      RouteConstants.newsScreen,
                                      extra: news,
                                    ),
                                date: DateFormatter.formatDateTime(news.date),
                                // time: DateFormatter.formatDateTime(news.date),
                                time: TimeFormatter.formatTime(news.createdAt),

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
                            child: Text(
                              "Yesterday",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ...yesterdayNews.map(
                            (news) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: NewsCard(
                                news: news,
                                button:
                                    () => context.pushNamed(
                                      RouteConstants.newsScreen,
                                      extra: news,
                                    ),
                                date: DateFormatter.formatDateTime(news.date),
                                // time: DateFormatter.formatDateTime(news.date),
                                time: TimeFormatter.formatTime(news.createdAt),
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
                            child: Text(
                              "Earlier",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ...earlierNews.map(
                            (news) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: NewsCard(
                                news: news,
                                button:
                                    () => context.pushNamed(
                                      RouteConstants.newsScreen,
                                      extra: news,
                                    ),

                                time: TimeFormatter.formatTime(news.createdAt),

                                date: DateFormatter.formatDateTime(news.date),
                                title: capitalizeEachWord(news.title),
                                content: capitalizeEachWord(news.content),
                              ),
                            ),
                          ),
                        ],

                        if (provider.hasMore) ...[
                          const SizedBox(height: 20),
                          const Center(child: CircularProgressIndicator()),
                        ],
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// ),

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}
