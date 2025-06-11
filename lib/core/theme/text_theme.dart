import 'package:flutter/material.dart';

class AppTextTheme {
  static const TextTheme lightTextTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),

    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black87),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
  );

  static const TextTheme darkTextTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),

    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70),
  );
}
