// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';
import 'app_tokens.dart';

ThemeData lightTheme() {
  const outline = AppColors.espresso;
  const divider = AppColors.creamLine;
  final colorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.tomatoAction,
    onPrimary: AppColors.cream,
    secondary: AppColors.cheese,
    onSecondary: AppColors.espresso,
    tertiary: AppColors.mare,
    surface: AppColors.paper,
    onSurface: AppColors.espresso,
    error: AppColors.error,
    onError: AppColors.cream,
    outline: outline,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: colorScheme,
    textTheme: AppText.textTheme(AppColors.espresso, AppColors.muted),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        backgroundColor: AppColors.tomatoAction,
        foregroundColor: AppColors.cream,
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: outline, width: AppStroke.base),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        borderSide: const BorderSide(color: divider, width: 1.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        borderSide: const BorderSide(color: divider, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        borderSide: const BorderSide(color: outline, width: AppStroke.base),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
        side: BorderSide(color: outline, width: AppStroke.base),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.dialog)),
        side: BorderSide(color: outline, width: AppStroke.base),
      ),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1.5),
    extensions: const [AppThemeExtras(outline: outline, divider: divider)],
  );
}

ThemeData darkTheme() {
  const outline = AppColors.cream;
  const divider = AppColors.dLine;
  final colorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.tomatoAction,
    onPrimary: AppColors.cream,
    secondary: AppColors.cheese,
    onSecondary: AppColors.espresso,
    tertiary: AppColors.mare,
    surface: AppColors.dSurface,
    onSurface: AppColors.cream,
    error: AppColors.error,
    onError: AppColors.cream,
    outline: outline,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dBg,
    colorScheme: colorScheme,
    textTheme: AppText.textTheme(AppColors.cream, AppColors.dText2),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        backgroundColor: AppColors.tomatoAction,
        foregroundColor: AppColors.cream,
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: outline, width: AppStroke.base),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.dSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        borderSide: const BorderSide(color: divider, width: 1.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        borderSide: const BorderSide(color: divider, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        borderSide: const BorderSide(color: outline, width: AppStroke.base),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.dSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
        side: BorderSide(color: outline, width: AppStroke.base),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.dSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.dialog)),
        side: BorderSide(color: outline, width: AppStroke.base),
      ),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1.5),
    extensions: const [AppThemeExtras(outline: outline, divider: divider)],
  );
}
