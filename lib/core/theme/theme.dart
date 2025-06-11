import 'package:acadobs/core/theme/app_bar_theme.dart';
import 'package:acadobs/core/theme/button_theme.dart';
import 'package:acadobs/core/theme/colors/app_color_schemes.dart';
import 'package:acadobs/core/theme/input_decoration_theme.dart';
import 'package:acadobs/core/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorSchemes.light,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    appBarTheme: AppAppBarTheme.appBarTheme,
    elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
    inputDecorationTheme: lightInputDecorationTheme,
    outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
    textTheme: AppTextTheme.lightTextTheme,
    scaffoldBackgroundColor: Colors.white,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorSchemes.dark,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: AppTextTheme.darkTextTheme,
  );
}
