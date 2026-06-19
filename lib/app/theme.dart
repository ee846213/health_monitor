import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';

ThemeData buildAppTheme() {
  const Color canvas = Color(0xFFF5F3EE);
  const Color surface = Color(0xFFFFFDF8);
  const Color line = Color(0xFFDDD8CF);
  const Color sage = Color(0xFF7B9786);
  const Color textPrimary = Color(0xFF1F2320);
  const Color textMuted = Color(0xFF7A8179);

  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: sage,
    brightness: Brightness.light,
    surface: surface,
    outline: line,
  ).copyWith(primary: sage, surface: surface, onSurface: textPrimary);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvas,
    fontFamily: 'Inter',
    extensions: <ThemeExtension<dynamic>>[
      HealthMonitorTheme.fallback(),
      const HealthMotionTokens.standard(),
    ],
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: textMuted),
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          side: BorderSide(color: line)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: sage,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    ),
  );
}
