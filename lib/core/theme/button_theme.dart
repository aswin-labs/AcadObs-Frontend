import 'package:acadobs/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'colors/app_colors.dart';

class AppButtonTheme {
static final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    backgroundColor: AppColors.black,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 32),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  ),
);

  /// Theme for OutlinedButton (bordered buttons, used for secondary actions)
  static final OutlinedButtonThemeData outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary, // Text/icon color
          side: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ), // Border color & width
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
