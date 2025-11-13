import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';

import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NewsListingScreen extends StatefulWidget {
  final bool forStaff;
  const NewsListingScreen({super.key, required this.forStaff});

  @override
  State<NewsListingScreen> createState() => _NewsListingScreenState();
}

class _NewsListingScreenState extends State<NewsListingScreen> {
  late final NewsProvider _provider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _provider = context.read<NewsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchNews(forStaff: widget.forStaff);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchNews(loadMore: true, forStaff: widget.forStaff);
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
      appBar: CommonAppBar(title: 'News', isBackButton: widget.forStaff),
      body: RefreshIndicator(
        onRefresh: () => _provider.fetchLatestNews(forStaff: widget.forStaff),
        child: Consumer<NewsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.newsAll.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.newsAll.isEmpty) {
              return emptyScreen(message: 'No News Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: provider.newsAll.length + (provider.hasMore ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == provider.newsAll.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final news = provider.newsAll[index - 1];

                return NewsCard(
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}




// import 'package:acadobs/core/constants/app_constants.dart';
// import 'package:acadobs/core/utils/common_shimmer_list.dart';
// // import 'package:acadobs/core/utils/empty_screen.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:acadobs/core/utils/helpers/time_formatter.dart';
// import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
// import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
// import 'package:acadobs/routes/router_constants.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class NewsListingScreen extends StatefulWidget {
//   final bool forStaff;
//   const NewsListingScreen({super.key, this.forStaff = true});

//   @override
//   State<NewsListingScreen> createState() => _NewsListingScreenState();
// }

// class _NewsListingScreenState extends State<NewsListingScreen> {
//   late NewsProvider newsProvider;
//   @override
//   void initState() {
//     super.initState();
//     newsProvider = context.read<NewsProvider>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       refreshAllData();
//     });
//   }

//   Future<void> refreshAllData() async {
//     await Future.wait([
//       newsProvider.fetchNews(
//         limit: AppConstants.paginationLimit,
//         forceRefresh: true,
//         forStaff: widget.forStaff,
//       ),
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(title: "Notices", isBackButton: true),
//       body: Consumer<NewsProvider>(
//         builder: (context, newsProvider, _) {
//           if (newsProvider.isLoading) {
//             return commonShimmerList();
//           } else if (newsProvider.newsAll.isEmpty) {
//             return Center(
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.notification_important_outlined,
//                     color: Colors.grey,
//                     size: 35,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "No news avaliable",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             final todayNews = newsProvider.todayNews;
//             final yesterdayNews = newsProvider.yesterdayNews;
//             final earlierNews = newsProvider.earlierNews;

//             return NotificationListener<ScrollNotification>(
//               onNotification: (scrollNotification) {
//                 if (scrollNotification is ScrollEndNotification &&
//                     scrollNotification.metrics.pixels >=
//                         scrollNotification.metrics.maxScrollExtent - 100 &&
//                     !newsProvider.isLoading &&
//                     newsProvider.hasMore) {
//                   newsProvider.loadMore(forStaff: widget.forStaff);
//                 }
//                 return false;
//               },
//               child: RefreshIndicator(
//                 onRefresh: refreshAllData,
//                 child: ListView(
//                   padding: const EdgeInsets.only(bottom: 60),

//                   physics: AlwaysScrollableScrollPhysics(
//                     parent: BouncingScrollPhysics(),
//                   ),
//                   children: [
//                     if (todayNews.isNotEmpty) ...[
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         child: Text("Today", style: TextStyle(fontSize: 15)),
//                       ),
//                       ...todayNews.map(
//                         (news) => Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child:
// NewsCard(
//                             news: news,
//                             button:
//                                 () => context.pushNamed(
//                                   RouteConstants.newsScreen,
//                                   extra: news,
//                                 ),
//                             date: DateFormatter.formatDateTime(news.date),

//                             time: TimeFormatter.formatTime(news.createdAt),
//                             title: capitalizeEachWord(news.title),
//                             content: capitalizeEachWord(news.content),
//                           ),
                        // ),
//                       ),
//                     ],
//                     if (yesterdayNews.isNotEmpty) ...[
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         child: Text(
//                           "Yesterday",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                       ...yesterdayNews.map(
//                         (news) => Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           child: NewsCard(
//                             news: news,
//                             button:
//                                 () => context.pushNamed(
//                                   RouteConstants.newsScreen,
//                                   extra: news,
//                                 ),
//                             date: DateFormatter.formatDateTime(news.date),

//                             time: TimeFormatter.formatTime(news.createdAt),
//                             title: capitalizeEachWord(news.title),
//                             content: capitalizeEachWord(news.content),
//                           ),
//                         ),
//                       ),
//                     ],
//                     if (earlierNews.isNotEmpty) ...[
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         child: Text("Earlier", style: TextStyle(fontSize: 16)),
//                       ),
//                       ...earlierNews.map(
//                         (news) => Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           child: NewsCard(
//                             news: news,
//                             button:
//                                 () => context.pushNamed(
//                                   RouteConstants.newsScreen,
//                                   extra: news,
//                                 ),
//                             date: DateFormatter.formatDateTime(news.date),
//                             // time: DateFormatter.formatDateTime(news.date),
//                             time: TimeFormatter.formatTime(news.createdAt),
//                             title: capitalizeEachWord(news.title),
//                             content: capitalizeEachWord(news.content),
//                           ),
//                         ),
//                       ),
//                     ],
//                     if (newsProvider.isLoading)
//                       const Center(
//                         child: Padding(
//                           padding: EdgeInsets.all(12.0),
//                           child: CircularProgressIndicator(),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
