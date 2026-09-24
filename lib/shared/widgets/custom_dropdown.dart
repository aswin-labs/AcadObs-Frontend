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
  final bool enabled;
  final String Function(String)? itemLabelBuilder;

  const CustomDropdown({
    super.key,
    required this.dropdownKey,
    required this.label,
    required this.icon,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DropdownProvider>(
      builder: (context, dropdownProvider, child) {
        final selectedValue =
            dropdownProvider.getSelectedItem(dropdownKey).isNotEmpty
                ? dropdownProvider.getSelectedItem(dropdownKey)
                : null;

        final isValueValid =
            selectedValue != null && items.contains(selectedValue);
        final currentVal = isValueValid ? selectedValue : null;

        return DropdownButtonFormField<String>(
          key: ValueKey('${dropdownKey}_$currentVal'),
          initialValue: currentVal,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            enabled: enabled,
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
          disabledHint: selectedValue != null
              ? Text(
                  itemLabelBuilder != null
                      ? itemLabelBuilder!(selectedValue)
                      : selectedValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                )
              : null,
          items:
              items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    itemLabelBuilder != null ? itemLabelBuilder!(value) : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: enabled
              ? (String? newValue) {
                  if (newValue != null) {
                    dropdownProvider.setSelectedItem(dropdownKey, newValue);
                    if (onChanged != null) {
                      onChanged!(newValue);
                    }
                  }
                }
              : null,
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
