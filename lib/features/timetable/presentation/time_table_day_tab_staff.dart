import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/timetable/presentation/staff_day_tab.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class TimeTableDayTabStaff extends StatelessWidget {
  final bool? forStaff;
  const TimeTableDayTabStaff({super.key, this.forStaff});

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
                StaffDayTab(dayOfWeek: 1, dayName: "Monday"),
                StaffDayTab(dayOfWeek: 2, dayName: "Tuesday"),
                StaffDayTab(dayOfWeek: 3, dayName: "Wednesday"),
                StaffDayTab(dayOfWeek: 4, dayName: "Thursday"),
                StaffDayTab(dayOfWeek: 5, dayName: "Friday"),
                StaffDayTab(dayOfWeek: 6, dayName: "Saturday"),
                StaffDayTab(dayOfWeek: 7, dayName: "Sunday"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
