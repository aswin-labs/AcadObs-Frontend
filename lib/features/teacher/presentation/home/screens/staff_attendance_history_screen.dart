import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/teacher/data/models/attendance/staff_attendance_history_model.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StaffAttendanceHistoryScreen extends StatefulWidget {
  const StaffAttendanceHistoryScreen({super.key});

  @override
  State<StaffAttendanceHistoryScreen> createState() =>
      _StaffAttendanceHistoryScreenState();
}

class _StaffAttendanceHistoryScreenState
    extends State<StaffAttendanceHistoryScreen> {
  final TextEditingController _dateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<TeacherAttendanceProvider>();
    _scrollController.addListener(_onScroll);

    // If there is an existing filter, set the controller text
    if (provider.historyDateFilter != null) {
      _dateController.text = provider.historyDateFilter!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchStaffAttendanceHistory(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<TeacherAttendanceProvider>()
          .loadMoreStaffAttendanceHistory();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatIsoTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '—';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('EEE, dd MMM yyyy').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildStatusBadge(String? status) {
    final statusLower = (status ?? '').toLowerCase().trim();
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (statusLower == 'present') {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
      label = 'Present';
    } else if (statusLower == 'absent') {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFC62828);
      icon = Icons.cancel_outlined;
      label = 'Absent';
    } else if (statusLower == 'late' || statusLower == 'half day') {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFEF6C00);
      icon = Icons.access_time;
      label = status ?? '';
    } else if (status != null && status.isNotEmpty) {
      bg = const Color(0xFFE3F2FD);
      fg = const Color(0xFF1565C0);
      icon = Icons.info_outline;
      label = status;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
      icon = Icons.help_outline;
      label = 'Not Specified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(StaffAttendanceHistoryItem item) {
    final checkIn = _formatIsoTime(item.checkInTime);
    final checkOut = _formatIsoTime(item.checkOutTime);
    final totalHours = item.totalHours;
    final markedMethod = item.markedMethod;
    final remarks = item.remarks;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(item.date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),

            // Middle: Check-in, Check-out, Total hours
            Row(
              children: [
                Expanded(
                  child: _buildTimeMetric(
                    label: "Check-in",
                    time: checkIn,
                    icon: Icons.login_rounded,
                    iconColor: Colors.green.shade600,
                  ),
                ),
                Container(height: 35, width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: _buildTimeMetric(
                    label: "Check-out",
                    time: checkOut,
                    icon: Icons.logout_rounded,
                    iconColor: Colors.orange.shade700,
                  ),
                ),
                if (totalHours != null && totalHours.trim().isNotEmpty) ...[
                  Container(height: 35, width: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildTimeMetric(
                      label: "Total Time",
                      time: "$totalHours hrs",
                      icon: Icons.timer_outlined,
                      iconColor: Colors.blue.shade600,
                    ),
                  ),
                ],
              ],
            ),

            // Bottom metadata: Method & Remarks
            if ((markedMethod != null && markedMethod.isNotEmpty) ||
                (remarks != null && remarks.trim().isNotEmpty)) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (markedMethod != null && markedMethod.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            markedMethod.toLowerCase() == 'self'
                                ? Icons.fingerprint
                                : Icons.edit_note,
                            size: 13,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            markedMethod,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (remarks != null && remarks.trim().isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            remarks,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetric({
    required String label,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: "Check-in History", isBackButton: true),
      body: Consumer<TeacherAttendanceProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Date Filter Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        dateController: _dateController,
                        label: "Filter by Date",
                        hintText: "Select Date",
                        onDateSelected: (selectedDate) {
                          final formatted = DateFormat(
                            'yyyy-MM-dd',
                          ).format(selectedDate);
                          provider.setHistoryDateFilter(formatted);
                        },
                      ),
                    ),
                    if (provider.historyDateFilter != null) ...[
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        tooltip: "Clear Filter",
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _dateController.clear();
                          provider.clearHistoryDateFilter();
                        },
                        icon: const Icon(Icons.clear, size: 20),
                      ),
                    ],
                  ],
                ),
              ),

              // Filter summary bar
              if (provider.historyDateFilter != null)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 16,
                        color: Colors.amber.shade900,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Showing records for: ${provider.historyDateFilter}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${provider.historyTotalContent} record(s)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

              // List of History Records
              Expanded(
                child: RefreshIndicator(
                  onRefresh:
                      () => provider.fetchStaffAttendanceHistory(refresh: true),
                  child:
                      provider.isLoadingHistory
                          ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: commonShimmerList(itemCount: 6, height: 110),
                          )
                          : provider.historyList.isEmpty
                          ? ListView(
                            children: [
                              emptyScreen(
                                message:
                                    provider.historyDateFilter != null
                                        ? "No attendance records found for ${provider.historyDateFilter}"
                                        : "No check-in history found",
                              ),
                            ],
                          )
                          : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount:
                                provider.historyList.length +
                                (provider.isFetchingMoreHistory ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == provider.historyList.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final item = provider.historyList[index];
                              return _buildHistoryCard(item);
                            },
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
