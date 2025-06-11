import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

const InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  fillColor: Color(0xFFF8F8F9),
  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
  filled: true,
  border: outlineInputBorder,
  enabledBorder: outlineInputBorder,
  focusedBorder: focusedOutlineInputBorder,
  errorBorder: errorOutlineInputBorder,
);

const InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
  fillColor: AppColors.secondary,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey),
  border: outlineInputBorder,
  enabledBorder: outlineInputBorder,
  focusedBorder: focusedOutlineInputBorder,
  errorBorder: errorOutlineInputBorder,
);

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(AppConstants.defaultBorderRadius),
  ),
  borderSide: BorderSide(color: Color(0xFFBDC2C7)),
);

const OutlineInputBorder focusedOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(AppConstants.defaultBorderRadius),
  ),
  borderSide: BorderSide(color: Color(0xFFBDC2C7), width: 1.5),
);

const OutlineInputBorder errorOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(AppConstants.defaultBorderRadius),
  ),
  borderSide: BorderSide(color: AppColors.error),
);

OutlineInputBorder secodaryOutlineInputBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      Radius.circular(AppConstants.defaultBorderRadius),
    ),
    borderSide: BorderSide(color: Colors.grey),
  );
}
