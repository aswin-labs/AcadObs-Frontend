import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  late ParentProvider parentProvider;
  @override
  void initState() {
    super.initState();
    parentProvider = context.read<ParentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      parentProvider.loadSchoolName();
    });
    parentProvider.fetchStudentsUnderParentBySchoolId();
    context.read<EventProvider>().fetchHomeLatestEvents(
      limit: 3,
      forStaff: false,
    );
    context.read<NewsProvider>().fetchHomeLatestNews(limit: 3, forStaff: false);
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = context.watch<ParentProvider>().schoolName;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: 250,
                  width: double.infinity,
                  child: Image.asset("assets/school.jpg", fit: BoxFit.cover),
                ),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xCC35C2C1), Color(0xCC00AEF0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child:
                        schoolName == null
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              schoolName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    "Hi, Parent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),

                //profile button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ProfileIcon(
                    // image: "assets/school.jpg",
                    icon: CupertinoIcons.profile_circled,
                    ontap:
                        () => context.pushNamed(
                          RouteConstants.profileScreen,
                          extra: false,
                        ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Children",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<ParentProvider>(
                    builder: (context, provider, _) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          return ProfileTile(
                            name: student.fullName,
                            description: student.classGrade?.classname ?? "",
                            onPressed:
                                () => context.pushNamed(
                                  RouteConstants.studentDetails,
                                  extra: StudentDetailParameters(
                                    forParent: true,
                                    studentId: student.id,
                                  ),
                                ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  //events listing
                  Row(
                    children: [
                      Text(
                        "Latest Events",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Consumer<EventProvider>(
                    builder: (context, provider, _) {
                      final events = provider.latestEvent;
                      if (provider.isLoading) {
                        return Center(child: commonShimmerList());
                      } else if (events.isEmpty) {
                        return emptyScreen(message: "No News Avaliable");
                      }

                      return Column(
                        children:
                            events.map((events) {
                              return EventCard(
                                event: events,
                                onViewTap:
                                    () => context.pushNamed(
                                      RouteConstants.eventlistdetails,
                                      extra: events,
                                    ),
                                time: TimeFormatter.formatTime(
                                  events.createdAt ?? DateTime.now(),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),

                  //listing news
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Latest News',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(
                            RouteConstants.newsDetailsScreen,
                            extra: false,
                          );
                        },
                        child: Text('View'),
                      ),
                    ],
                  ),
                  Consumer<NewsProvider>(
                    builder: (context, provider, _) {
                      final news = provider.latestNews;
                      if (provider.isLoading) {
                        return Center(child: commonShimmerList());
                      } else if (news.isEmpty) {
                        return emptyScreen(message: "No News Avaliable");
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
                                // time: formattedTime,
                                time: TimeFormatter.formatTime(news.createdAt),
                                title: capitalizeEachWord(news.title),
                                content: news.content,
                              );
                            }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
