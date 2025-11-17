import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';

import 'package:acadobs/features/students/presentation/widgets/time_table_list_card.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DayTab extends StatefulWidget {
  final int? id;
  final int dayOfWeek;
  final String dayName;
  const DayTab({
    super.key,
    required this.dayName,
    required this.dayOfWeek,
    this.id,
  });

  @override
  State<DayTab> createState() => _DayTabState();
}

class _DayTabState extends State<DayTab> {
  @override
  void initState() {
    super.initState();
    context.read<TimeTableProvider>().fetchAllDayTimeTableNew(
      studentId: widget.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              widget.dayName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ), // dynamic day

            SizedBox(height: 10),
            Expanded(
              child: Consumer<TimeTableProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return commonShimmerList();
                  }

                  if (provider.error != null) {
                    return Center(child: Text("Error: ${provider.error}"));
                  }

                  final dayPeriods = provider.getDayPeriods(widget.dayOfWeek);

                  if (dayPeriods.isEmpty) {
                    return emptyScreen(
                      message: "No classes for ${widget.dayName}",
                    );
                  }

                  return ListView.builder(
                    itemCount: dayPeriods.length,
                    itemBuilder: (context, index) {
                      final p = dayPeriods[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: TimeTableListCard(
                          subject: p.subject?.subjectName ?? "Unknown",
                          teacher: p.user?.name ?? "Unknown",
                          classname: p.periodClass?.classname ?? "-",
                          periodNumber: p.periodNumber ?? 0,
                          onTap: () {},
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
