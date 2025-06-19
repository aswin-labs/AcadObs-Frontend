import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

class AppAppBarTheme {
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
}
