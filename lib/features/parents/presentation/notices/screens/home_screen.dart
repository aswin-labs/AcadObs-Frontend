import 'package:acadobs/features/parents/presentation/notices/provider/notice_provider.dart';
import 'package:acadobs/features/parents/presentation/notices/widgets/notice_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_model.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NoticeProvider>().fetchLatestNotices(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text(
                      "ABC School Academy",
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
                    image: "assets/school.jpg",
                    ontap:
                        () => context.pushNamed(
                          RouteConstants.profileScreen,
                          extra: UserModel(
                            name: "Arun",
                            role: "Teacher",
                            email: "Arun@gmail.com",
                          ),
                        ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  CustomButtonContainer(
                    color: Colors.black,
                    text: 'leave request',
                    ontap: () {},
                  ),

                  const SizedBox(height: 24),
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
                  const SizedBox(height: 8),
                  ProfileTile(
                    name: 'Amal',
                    description: 'aaa Villa',
                    onPressed:
                        () => context.pushNamed(
                          RouteConstants.studentDetails,

                          extra: 2, // need to change
                        ),
                  ),

                  const SizedBox(height: 16),

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
                        child: Text(
                          "View",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  //notice listing in the parent home screen
                  Consumer<NoticeProvider>(
                    builder: (context, provider, _) {
                      final notices = provider.notices;
                      if (provider.isLoading && notices.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (notices.isEmpty) {
                        return Column(
                          children: [
                            Icon(
                              Icons.notifications_off_rounded,
                              color: Colors.grey,
                            ),
                            Text(
                              "No Notices avaliable",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children:
                            notices.map((notice) {
                              final date =
                                  "${notice.createdAt.day.toString().padLeft(2, '0')}-${notice.createdAt.month.toString().padLeft(2, '0')}-${notice.createdAt.year}";
                              final time =
                                  "${notice.createdAt.hour.toString().padLeft(2, '0')}:${notice.createdAt.minute.toString().padLeft(2, '0')}";
                              return NoticeCard(
                                title: notice.title ?? "N/A",
                                date: date,
                                icon: Icons.notifications,
                                time: time,
                                onTap: () {},
                              );
                            }).toList(),
                      );
                    },
                  ),

                  // NoticeCard(
                  //   title: 'PTA Meeting Class X',
                  //   date: "21-07-2025",
                  //   icon: Icons.notifications,
                  //   time: "12:30",
                  //   onTap: () {},
                  // ),
                ],
              ),
            ),

            ///////////////
          ],
        ),
      ),
    );
  }
}
