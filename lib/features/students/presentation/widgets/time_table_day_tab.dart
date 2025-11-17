// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/responsive.dart';
// import 'package:acadobs/features/students/presentation/widgets/sunday_tab.dart';

// import 'package:flutter/material.dart';

// class TimeTableDayTab extends StatelessWidget {
//   final int studentId;
//   const TimeTableDayTab({super.key, required this.studentId});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 7,
//       child: Scaffold(
//         body: NestedScrollView(
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: context.paddingHorizontal.add(
//                     EdgeInsets.only(top: Responsive.height * 5),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: const CircleAvatar(
//                               radius: 16,
//                               backgroundColor: Color(0xFFD9D9D9),
//                               child: Icon(
//                                 Icons.arrow_back_ios_new,
//                                 size: 18,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             textAlign: TextAlign.center,
//                             "Time Table",
//                             style: Theme.of(
//                               context,
//                             ).textTheme.bodyLarge!.copyWith(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 22,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),

//                           SizedBox(width: 30),
//                         ],
//                       ),
//                       SizedBox(height: Responsive.height * 3),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPadding(
//                 padding: EdgeInsets.only(bottom: Responsive.height * 2),
//               ),
//               SliverOverlapAbsorber(
//                 handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                   context,
//                 ),
//                 sliver: SliverAppBar(
//                   pinned: true,

//                   // backgroundColor: Colors.grey.shade200,
//                   bottom: PreferredSize(
//                     preferredSize: const Size.fromHeight(0),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                       child: TabBar(
//                         tabAlignment: TabAlignment.start,
//                         isScrollable: true,
//                         labelColor: Colors.black,
//                         unselectedLabelColor: Colors.grey,
//                         indicatorColor: Colors.black,
//                         labelPadding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                         ),
//                         tabs: const [
//                           Tab(text: "Monday"),
//                           Tab(text: "Tuesday"),
//                           Tab(text: "Wednesday"),
//                           Tab(text: "thursday"),
//                           Tab(text: 'Friday'),
//                           Tab(text: "Saturday"),
//                           Tab(text: "Sunday"),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ];
//           },
//           body: Padding(
//             padding: EdgeInsets.only(top: Responsive.height * 5),
//             child: TabBarView(
//               children: [
//                 SundayTab(
//                   dayOfWeek: 1,
//                   dayName: "Monday",
//                   studentId: studentId,
//                 ),
//                 SundayTab(
//                   dayOfWeek: 2,
//                   dayName: "Tuesday",
//                   studentId: studentId,
//                 ),
//                 SundayTab(
//                   dayOfWeek: 3,
//                   dayName: "Wednesday",
//                   studentId: studentId,
//                 ),
//                 SundayTab(
//                   dayOfWeek: 4,
//                   dayName: "Thursday",
//                   studentId: studentId,
//                 ),
//                 SundayTab(
//                   dayOfWeek: 5,
//                   dayName: "Friday",
//                   studentId: studentId,
//                 ),
//                 SundayTab(
//                   dayOfWeek: 6,
//                   dayName: "Saturday",
//                   studentId: studentId,
//                 ),
//                 SundayTab(
//                   dayOfWeek: 7,
//                   dayName: "Sunday",
//                   studentId: studentId,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/widgets/day_tab.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class TimeTableDayTab extends StatelessWidget {
  final int studentId;
  const TimeTableDayTab({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  shadowColor: Colors.black.withAlpha(23),
                  surfaceTintColor: Colors.transparent,

                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(
                            CupertinoIcons.chevron_back,
                            color: Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  title: const Text(
                    "Time Table",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(52),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(34),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Monday"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Tuesday"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Wednesday"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Thursday"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Friday"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Saturday"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Sunday"),
                            ),
                          ),
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
                DayTab(dayOfWeek: 1, dayName: "Monday", id: studentId),
                DayTab(dayOfWeek: 2, dayName: "Tuesday", id: studentId),
                DayTab(dayOfWeek: 3, dayName: "Wednesday", id: studentId),
                DayTab(dayOfWeek: 4, dayName: "Thursday", id: studentId),
                DayTab(dayOfWeek: 5, dayName: "Friday", id: studentId),
                DayTab(dayOfWeek: 6, dayName: "Saturday", id: studentId),
                DayTab(dayOfWeek: 7, dayName: "Sunday", id: studentId),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
