import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/widgets/sunday_tab.dart';

import 'package:flutter/material.dart';

class TimeTableDayTab extends StatelessWidget {
  final int studentId;
  const TimeTableDayTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingHorizontal.add(
                    EdgeInsets.only(top: Responsive.height * 5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFD9D9D9),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            "Time Table",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // widget.forParent
                          //     ? SizedBox.shrink()
                          //     : Consumer2<StudentProvider, ChatProvider>(
                          //       builder: (
                          //         context,
                          //         studentProvider,
                          //         chatProvider,
                          //         _,
                          //       ) {
                          //         final student =
                          //             studentProvider.individualStudent;
                          //         return GestureDetector(
                          //           onTap: () {
                          //             context
                          //                 .pushNamed(
                          //                   RouteConstants.chatScreen,
                          //                   extra: ChatModel(
                          //                     opponentId:
                          //                         student?.user?.id ?? 0,
                          //                     opponentName:
                          //                         student?.user?.name ?? "",
                          //                     studentId: student?.id,
                          //                   ),
                          //                 )
                          //                 .then((_) {
                          //                   if (!mounted) return;
                          //                   chatProvider.loadUsersList();
                          //                 });
                          //           },
                          //           child: Icon(Icons.chat),
                          //         );
                          //       },
                          //     ),
                          SizedBox(width: 30),
                        ],
                      ),
                      SizedBox(height: Responsive.height * 3),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: Responsive.height * 2),
              ),
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,

                  // backgroundColor: Colors.grey.shade200,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.black,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        tabs: const [
                          Tab(text: "Monday"),
                          Tab(text: "Tuesday"),
                          Tab(text: "Wednesday"),
                          Tab(text: "thursday"),
                          Tab(text: 'Friday'),
                          Tab(text: "Saturday"),
                          Tab(text: "Sunday"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.only(top: Responsive.height * 5),
            child: TabBarView(
              children: [
                SundayTab(dayOfWeek: 1, dayName: "Monday",studentId: studentId,),
                SundayTab(dayOfWeek: 2, dayName: "Tuesday",studentId: studentId,),
                SundayTab(dayOfWeek: 3, dayName: "Wednesday",studentId: studentId,),
                SundayTab(dayOfWeek: 4, dayName: "Thursday",studentId: studentId),
                SundayTab(dayOfWeek: 5, dayName: "Friday",studentId: studentId),
                SundayTab(dayOfWeek: 6, dayName: "Saturday",studentId: studentId),
                SundayTab(dayOfWeek: 7, dayName: "Sunday",studentId: studentId),
                // sunday
                // SundayTab(),
                // //monday
                // SundayTab(),
                // //tuesday
                // SundayTab(),
                // //wednesday
                // SundayTab(),
                // //thursday
                // SundayTab(),
                // //friday
                // SundayTab(),
                // //saturday
                // SundayTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
