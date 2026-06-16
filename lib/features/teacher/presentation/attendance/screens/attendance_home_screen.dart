import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class AttendanceHomeScreen extends StatefulWidget {
  const AttendanceHomeScreen({super.key});

  @override
  State<AttendanceHomeScreen> createState() => _AttendanceHomeScreenState();
}

class _AttendanceHomeScreenState extends State<AttendanceHomeScreen> {
  late final AttendanceProvider _attendanceProvider;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _dateController = TextEditingController();

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _attendanceProvider = context.read<AttendanceProvider>();
    _scrollController.addListener(_scrollListener);

    // Run after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedDate = _attendanceProvider.selectedDate ?? DateTime.now();
      _dateController.text = _formatted(_selectedDate);

      _attendanceProvider.fetchAttendanceByTeacher(
        date: _formatted(_selectedDate),
      );
    });
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_attendanceProvider.isLoading &&
        _attendanceProvider.hasMore) {
      _attendanceProvider.fetchAttendanceByTeacher(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Attendance"),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AttendanceProvider>().fetchAttendanceByTeacher(
            forceRefresh: true,
            date: _formatted(_selectedDate),
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Column(
                  children: [
                    Consumer<AttendanceProvider>(
                      builder: (context, provider, child) {
                        _selectedDate = provider.selectedDate ?? DateTime.now();
                        _dateController.text = _formatted(_selectedDate);

                        final today = DateTime.now();
                        final yesterday = today.subtract(
                          const Duration(days: 1),
                        );

                        String displayText = '                 ';
                        if (_isSameDay(_selectedDate, today)) {
                          displayText = 'Today     ';
                        } else if (_isSameDay(_selectedDate, yesterday)) {
                          displayText = 'Yesterday';
                        }

                        return Row(
                          children: [
                            if (displayText.isNotEmpty)
                              Text(
                                displayText,
                                style: context.textTheme.titleLarge,
                              ),
                            SizedBox(width: Responsive.width * 24),
                            Expanded(
                              child: CustomDatePicker(
                                label: "Date",
                                initialDate: _selectedDate,
                                dateController: _dateController,
                                onDateSelected: (pickedDate) {
                                  _selectedDate = pickedDate;
                                  context
                                      .read<AttendanceProvider>()
                                      .setSelectedDate(pickedDate);
                                  context
                                      .read<AttendanceProvider>()
                                      .fetchAttendanceByTeacher(
                                        forceRefresh: true,
                                        date: _formatted(pickedDate),
                                      );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please select a date";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 1),
                    Consumer<AttendanceProvider>(
                      builder: (context, provider, _) {
                        if (!provider.hasFetchedOnce && provider.isLoading) {
                          return commonShimmerList();
                        }

                        if (provider.hasFetchedOnce &&
                            provider.attendanceByTeacher.isEmpty) {
                          return emptyScreen(message: 'No Records Found.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.attendanceByTeacher.length,
                          itemBuilder: (context, index) {
                            final attendance =
                                provider.attendanceByTeacher[index];
                            return ItemCard(
                              title:
                                  attendance.classDetails?.classname ?? "Class",
                              description:
                                  "Period ${attendance.period.toString()}",
                              backgroundColor: const Color(0xFFE8F5E9),
                              icon: LucideIcons.calendarCheck,
                              iconColor: Colors.green,
                              onTap:
                                  () => context.pushNamed(
                                    RouteConstants.attendanceDetails,
                                    extra: attendance,
                                  ),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<AttendanceProvider>(
                      builder: (context, provider, _) {
                        return provider.isLoading && provider.hasMore
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox();
                      },
                    ),
                    SizedBox(height: Responsive.height * 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: CommonFloatingButton(
          onPressed: () => showAttendanceBottomSheet(context),
        ),
      ),
    );
  }

  String _formatted(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
