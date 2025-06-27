import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDropdown extends StatelessWidget {
  final String dropdownKey;
  final String label;
  final IconData icon;
  final List<String> items;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.dropdownKey,
    required this.label,
    required this.icon,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DropdownProvider>(
      builder: (context, dropdownProvider, child) {
        final selectedValue =
            dropdownProvider.getSelectedItem(dropdownKey).isNotEmpty
                ? dropdownProvider.getSelectedItem(dropdownKey)
                : null;

        return DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(icon),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              dropdownProvider.setSelectedItem(dropdownKey, newValue);
              if (onChanged != null) {
                onChanged!(newValue); // Trigger the external callback
              }
            }
          },
          validator: validator,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black),
          menuMaxHeight: 200,
          borderRadius: BorderRadius.circular(24),
        );
      },
    );
  }
}
