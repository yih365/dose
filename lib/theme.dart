import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Organic palette — derived from styles.css token sheet
class AppColors {
  static const bg = Color(0xFFEFE4D2);
  static const text = Color(0xFF201E1D);
  static const divider = Color(0x14201E1D);

  // Neutral ramp
  static const neutral100 = Color(0xFFF5EAD8);
  static const neutral200 = Color(0xFFEBDAC0);
  static const neutral300 = Color(0xFFD9C5A6);
  static const neutral400 = Color(0xFFC4AA87);
  static const neutral500 = Color(0xFF9E8567);
  static const neutral600 = Color(0xFF7A6349);

  // Accent (terracotta) ramp
  static const accent100 = Color(0xFFF5E0CE);
  static const accent200 = Color(0xFFEFD0B0);
  static const accent = Color(0xFFC67139);
  static const accent400 = Color(0xFFD9975A);
  static const accent500 = Color(0xFFC67139);
  static const accent600 = Color(0xFFAD5C28);
  static const accent700 = Color(0xFF8C4A1A);
  static const accent800 = Color(0xFF6E3912);
  static const accent900 = Color(0xFF4F2808);

  // Accent-2 (sage) ramp
  static const accent2_100 = Color(0xFFDEE8CC);
  static const accent2_200 = Color(0xFFC5D4A8);
  static const accent2_500 = Color(0xFF7A8A5E);
  static const accent2_700 = Color(0xFF4A5A38);
  static const accent2_900 = Color(0xFF2A3520);

  // Semantic
  static const heartRed = Color(0xFFCF5B52);
  static const sleepBlue = Color(0xFF6D76A8);
}

ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.light(
      surface: AppColors.bg,
      primary: AppColors.accent,
      secondary: AppColors.accent2_500,
      onSurface: AppColors.text,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: GoogleFonts.figtreeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    splashFactory: InkRipple.splashFactory,
    splashColor: AppColors.accent200.withValues(alpha: 0.4),
    highlightColor: Colors.transparent,
  );
}

TextStyle headingStyle(double size, {Color color = AppColors.text}) =>
    GoogleFonts.caprasimo(fontSize: size, color: color, fontWeight: FontWeight.w400);
