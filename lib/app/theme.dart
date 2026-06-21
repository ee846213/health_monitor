import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';

ThemeData buildAppTheme({String? fontFamily}) {
  final tokens = HealthMonitorTheme.fallback();

  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: tokens.sage,
    brightness: Brightness.light,
    surface: tokens.surface,
    outline: tokens.borderSubtle,
  ).copyWith(
    primary: tokens.sage,
    surface: tokens.surface,
    onSurface: tokens.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.canvas,
    extensions: <ThemeExtension<dynamic>>[
      tokens,
      const HealthMotionTokens.standard(),
    ],
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: tokens.textSecondary,
      ),
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.sage,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
        ),
      ),
    ),
  );
}
