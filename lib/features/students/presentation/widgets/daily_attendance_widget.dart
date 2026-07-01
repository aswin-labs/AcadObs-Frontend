import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyAttendanceWidget extends StatefulWidget {
  final int totalPeriodCount;
  final List<String> statuses;
  final DateTime initialDate;
  final ValueChanged<String> onDateChanged;

  const DailyAttendanceWidget({
    super.key,
    required this.totalPeriodCount,
    required this.statuses,
    required this.onDateChanged,
    required this.initialDate,
  });

  @override
  State<DailyAttendanceWidget> createState() => _DailyAttendanceWidgetState();
}

class _DailyAttendanceWidgetState extends State<DailyAttendanceWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Spacer(),
                Text("Date"),
                DateWidget(
                  initialDate: _selectedDate,

                  onDateChanged: (newDate) {
                    setState(() {
                      _selectedDate = DateTime.parse(newDate);
                    });

                    final formattedDate = DateFormat(
                      "yyyy-MM-dd",
                    ).format(_selectedDate);
                    widget.onDateChanged(formattedDate);
                  },
                ),
              ],
            ),
            Text(
              DateFormat('EEEE').format(_selectedDate),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(
                widget.totalPeriodCount,
                (index) => PeriodContainer(
                  status:
                      (index < widget.statuses.length &&
                              widget.statuses[index].isNotEmpty)
                          ? widget.statuses[index]
                          : "",
                  periodNumber: index + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//date calendar
class DateWidget extends StatefulWidget {
  final ValueChanged<String> onDateChanged;
  final DateTime? initialDate;
  const DateWidget({super.key, required this.onDateChanged, this.initialDate});

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant DateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null && widget.initialDate != selectedDate) {
      setState(() {
        selectedDate = widget.initialDate!;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        final formatted = DateFormat('yyyy-MM-dd').format(selectedDate);
        widget.onDateChanged(formatted);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final bool isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final String displayText =
        isToday ? "Today" : DateFormat("dd-MM-yyyy").format(selectedDate);

    return TextButton.icon(
      onPressed: () => _selectDate(context),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      label: Text(
        displayText,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }
}

//period container
class PeriodContainer extends StatelessWidget {
  final String status;
  final int periodNumber;
  const PeriodContainer({
    super.key,
    required this.status,
    required this.periodNumber,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String status) {
      switch (status) {
        case "present":
          return Colors.green;
        case "absent":
          return Colors.red;
        case "late":
          return Colors.orange;
        default:
          return Colors.grey.shade300;
      }
    }

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: getStatusColor(status),

                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text("P$periodNumber", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
