// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class AppText {
  AppText._();

  static const TextStyle display = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle bodyL = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  static const TextStyle cardName = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );
  static const TextStyle stat = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    height: 20 / 18,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle button = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: display.copyWith(color: primary),
      headlineLarge: h1.copyWith(color: primary),
      headlineMedium: h2.copyWith(color: primary),
      titleLarge: h3.copyWith(color: primary),
      titleMedium: title.copyWith(color: primary),
      bodyLarge: bodyL.copyWith(color: primary),
      bodyMedium: body.copyWith(color: primary),
      labelLarge: button.copyWith(color: primary),
      labelMedium: label.copyWith(color: secondary),
      bodySmall: caption.copyWith(color: secondary),
    );
  }
}
