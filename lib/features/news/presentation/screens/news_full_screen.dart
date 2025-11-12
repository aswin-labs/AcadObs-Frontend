import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
// import 'package:acadobs/core/utils/empty_screen.dart';
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
  late NewsProvider newsProvider;
  @override
  void initState() {
    super.initState();
    newsProvider = context.read<NewsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshAllData();
    });
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      newsProvider.fetchLatestNews(
        limit: AppConstants.paginationLimit,
        isRefresh: true,
        forStaff: widget.forStaff,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Notices", isBackButton: true),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, _) {
          if (newsProvider.isLoading && newsProvider.newsModel.isEmpty) {
            return commonShimmerList();
          } else if (newsProvider.newsModel.isEmpty) {
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
                    "No news avaliable",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final todayNews = newsProvider.todayNews;
            final yesterdayNews = newsProvider.yesterdayNews;
            final earlierNews = newsProvider.earlierNews;

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent - 100 &&
                    !newsProvider.isLoading &&
                    newsProvider.hasMore) {
                  newsProvider.loadMore(forStaff: widget.forStaff);
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: refreshAllData,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 60),

                  physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: NewsCard(
                            news: news,
                            button:
                                () => context.pushNamed(
                                  RouteConstants.newsScreen,
                                  extra: news,
                                ),
                            date: DateFormatter.formatDateTime(news.date),

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
                            time: TimeFormatter.formatTime(news.createdAt),
                            title: capitalizeEachWord(news.title),
                            content: capitalizeEachWord(news.content),
                          ),
                        ),
                      ),
                    ],
                    if (newsProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: CommonAppBar(title: "News", isBackButton: widget.forStaff),
  //     body: Consumer<NewsProvider>(
  //       builder: (context, provider, _) {
  //         if (provider.isLoading && provider.newsModel.isEmpty) {
  //           return commonShimmerList();
  //         } else if (provider.error != null) {
  //           return Center(child: Text(provider.error!));
  //         } else if (provider.newsModel.isEmpty) {
  //           return emptyScreen(message: "No News Available");
  //         } else {
  //           final todayNews = provider.todayNews;
  //           final yesterdayNews = provider.yesterdayNews;
  //           final earlierNews = provider.earlierNews;

  //           return NotificationListener<ScrollNotification>(
  //             onNotification: (scrollNotification) {
  //               if (scrollNotification is ScrollEndNotification &&
  //                   scrollNotification.metrics.pixels >=
  //                       scrollNotification.metrics.maxScrollExtent - 100 &&
  //                   !provider.isLoading &&
  //                   provider.hasMore) {
  //                 provider.loadMore(forStaff: widget.forStaff);
  //               }
  //               return false;
  //             },
  //             child: NotificationListener<ScrollNotification>(
  //               onNotification: (scrollNotification) {
  //                 if (scrollNotification is ScrollEndNotification &&
  //                     scrollNotification.metrics.pixels >=
  //                         scrollNotification.metrics.maxScrollExtent - 100 &&
  //                     !provider.isLoading &&
  //                     provider.hasMore) {
  //                   provider.loadMore(forStaff: widget.forStaff);
  //                 }
  //                 return false;
  //               },
  //               child: SingleChildScrollView(
  //                 physics: const BouncingScrollPhysics(),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(1.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       if (todayNews.isNotEmpty) ...[
  //                         const Padding(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 16,
  //                             vertical: 8,
  //                           ),
  //                           child: Text(
  //                             "Today",
  //                             style: TextStyle(fontSize: 15),
  //                           ),
  //                         ),
  //                         ...todayNews.map(
  //                           (news) => Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                             ),
  //                             child: NewsCard(
  //                               news: news,
  //                               button:
  //                                   () => context.pushNamed(
  //                                     RouteConstants.newsScreen,
  //                                     extra: news,
  //                                   ),
  //                               date: DateFormatter.formatDateTime(news.date),
  //                               // time: DateFormatter.formatDateTime(news.date),
  //                               time: TimeFormatter.formatTime(news.createdAt),

  //                               title: capitalizeEachWord(news.title),
  //                               content: capitalizeEachWord(news.content),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                       if (yesterdayNews.isNotEmpty) ...[
  //                         const Padding(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 16,
  //                             vertical: 8,
  //                           ),
  //                           child: Text(
  //                             "Yesterday",
  //                             style: TextStyle(fontSize: 16),
  //                           ),
  //                         ),
  //                         ...yesterdayNews.map(
  //                           (news) => Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 15,
  //                             ),
  //                             child: NewsCard(
  //                               news: news,
  //                               button:
  //                                   () => context.pushNamed(
  //                                     RouteConstants.newsScreen,
  //                                     extra: news,
  //                                   ),
  //                               date: DateFormatter.formatDateTime(news.date),
  //                               // time: DateFormatter.formatDateTime(news.date),
  //                               time: TimeFormatter.formatTime(news.createdAt),
  //                               title: capitalizeEachWord(news.title),
  //                               content: capitalizeEachWord(news.content),
  //                             ),
  //                           ),
  //                         ),
  //                       ],

  //                       if (earlierNews.isNotEmpty) ...[
  //                         const Padding(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 16,
  //                             vertical: 8,
  //                           ),
  //                           child: Text(
  //                             "Earlier",
  //                             style: TextStyle(fontSize: 16),
  //                           ),
  //                         ),
  //                         ...earlierNews.map(
  //                           (news) => Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 15,
  //                             ),
  //                             child: NewsCard(
  //                               news: news,
  //                               button:
  //                                   () => context.pushNamed(
  //                                     RouteConstants.newsScreen,
  //                                     extra: news,
  //                                   ),

  //                               time: TimeFormatter.formatTime(news.createdAt),

  //                               date: DateFormatter.formatDateTime(news.date),
  //                               title: capitalizeEachWord(news.title),
  //                               content: capitalizeEachWord(news.content),
  //                             ),
  //                           ),
  //                         ),
  //                       ],

  //                       if (provider.hasMore) ...[
  //                         const SizedBox(height: 20),
  //                         const Center(child: CircularProgressIndicator()),
  //                       ],
  //                       SizedBox(height: 40),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }
}

// ),

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}
