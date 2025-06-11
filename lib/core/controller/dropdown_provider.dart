import 'package:flutter/widgets.dart';

class DropdownProvider with ChangeNotifier {
  // Store selected items for each dropdownKey
  final Map<String, String> _selectedItems = {};


  String getSelectedItem(String key) {
    return _selectedItems[key] ?? '';
  }

  // Method to set the selected item
  void setSelectedItem(String key, String value) {
    _selectedItems[key] = value;
    notifyListeners();
  }

  void clearAllDropdowns() {
    _selectedItems.clear();
    notifyListeners();
  }

  void clearSelectedItem(String key) {
    _selectedItems[key] = "";
    notifyListeners();
  }
}
