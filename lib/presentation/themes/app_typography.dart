import 'package:flutter/material.dart';
import 'package:wortspion/presentation/themes/app_colors.dart';

class AppTypography {
  // Private Konstruktor, um Instanziierung zu verhindern
  AppTypography._();

  static const String fontFamily = 'Montserrat';

  // Text-Stile für Light Theme
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 28.0,
    color: AppColors.onBackground,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: AppColors.onBackground,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: AppColors.onBackground,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: AppColors.onBackground,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: AppColors.onBackground,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
    color: AppColors.onBackground,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
    color: AppColors.onBackground,
  );

  static final TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
    color: AppColors.onBackground.withOpacity(0.8),
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    letterSpacing: 1.2,
    color: Colors.white,
  );

  static const TextStyle wordDisplay = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 32.0,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );

  static const TextStyle timerDisplay = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    color: AppColors.accent,
  );

  static const TextStyle playerName = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: AppColors.onSurface,
  );

  // TextTheme für Light Theme
  static final TextTheme textTheme = TextTheme(
    displayLarge: headline1,
    displayMedium: headline2,
    displaySmall: headline3,
    titleLarge: subtitle1,
    titleMedium: subtitle2,
    bodyLarge: body1,
    bodyMedium: body2,
    bodySmall: caption,
    labelLarge: button,
  );

  // TextTheme für Dark Theme
  static final TextTheme textThemeDark = TextTheme(
    displayLarge: headline1.copyWith(color: Colors.white),
    displayMedium: headline2.copyWith(color: Colors.white),
    displaySmall: headline3.copyWith(color: Colors.white),
    titleLarge: subtitle1.copyWith(color: Colors.white),
    titleMedium: subtitle2.copyWith(color: Colors.white),
    bodyLarge: body1.copyWith(color: Colors.white),
    bodyMedium: body2.copyWith(color: Colors.white),
    bodySmall: caption.copyWith(color: Colors.white.withOpacity(0.8)),
    labelLarge: button,
  );
}
