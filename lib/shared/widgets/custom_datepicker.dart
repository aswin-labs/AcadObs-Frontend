import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final TextEditingController dateController; // Expose the controller
  final Function(DateTime) onDateSelected;
  final String? hintText;
  final String label;
  final String? Function(String?)? validator;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate; // Add customizable initial date

  CustomDatePicker({super.key, 
    required this.dateController,
    required this.onDateSelected,
    required this.label,
    this.hintText,
    this.validator,
    DateTime? firstDate,
    DateTime? lastDate,
    this.initialDate,
  })  : firstDate = firstDate ?? DateTime(2000),
        lastDate = lastDate ?? DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime effectiveInitialDate = dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(dateController.text)
        : (initialDate ?? DateTime.now());

    final DateTime clampedInitialDate = effectiveInitialDate.isBefore(firstDate)
        ? firstDate
        : (effectiveInitialDate.isAfter(lastDate)
            ? lastDate
            : effectiveInitialDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: clampedInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontSize: 14),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
      dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey,
        ),
        prefixIcon: Icon(
          Icons.calendar_month,
          size: 22,
        ),
      ),
    );
  }
}
