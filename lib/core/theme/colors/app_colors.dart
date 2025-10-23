import 'package:flutter/material.dart';

/// App-defined custom color palette — used for consistent theming
class AppColors {
  // Core brand colors
  static const Color primary = Colors.black;
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFFD9D9D9);
  static const Color onSecondary = Colors.black;

  // White and black
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Backgrounds and surfaces
  // static const Color background = Color(0xFFF4F4F4);
  static const Color background = Color(0xFFF0F2F5);
  static const Color onBackground = Colors.black;

  static const Color surface = Color(0xFFF5F5F5); // Light gray surface
  static const Color onSurface = Colors.black;

  // Error colors
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color onError = Colors.white;

  // Additional (for border, outlines, etc.)
  static const Color outline = Color(0xFFBDBDBD); // Grey outline
  static const Color shadow = Colors.black12;

  // Dark mode support (optional)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white;

  // Attendance Status Colors
  static const Color attendancePresent = Color.fromARGB(255, 85, 213, 89);
  static const Color attendanceLate = Color.fromARGB(255, 243, 173, 70);
  static const Color attendanceAbsent = Color(0xFFFF1C1C);
}
