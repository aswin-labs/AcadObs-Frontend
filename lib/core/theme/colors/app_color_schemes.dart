import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Holds both light and dark color schemes for the app
class AppColorSchemes {
  /// Light theme color scheme
  static final ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onError,
    outline: AppColors.outline,
    shadow: AppColors.shadow,
    tertiary: Colors.teal,
    onTertiary: Colors.white,
    inverseSurface: Colors.black,
    onInverseSurface: Colors.white,
    inversePrimary: Colors.blueGrey,
    surfaceTint: AppColors.primary,
  );

  /// Dark theme color scheme
  static final ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    error: AppColors.error,
    onError: AppColors.onError,
    outline: AppColors.outline,
    shadow: AppColors.shadow,
    tertiary: Colors.tealAccent,
    onTertiary: Colors.black,
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.onSurface,
    inversePrimary: Colors.blue[200]!,
    surfaceTint: AppColors.primary,
  );
}
