import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';

ThemeData buildAppTheme() {
  const Color canvas = Color(0xFFF5F3EE);
  const Color surface = Color(0xFFFFFDF8);
  const Color outline = Color(0xFFDDD8CF);
  const Color primary = Color(0xFF7B9786);
  const Color onSurface = Color(0xFF1F2320);
  const Color secondaryText = Color(0xFF505750);

  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    surface: surface,
    outline: outline,
  ).copyWith(
    primary: primary,
    surface: surface,
    onSurface: onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: canvas,
    extensions: <ThemeExtension<dynamic>>[
  HealthMonitorTheme.fallback(),
],
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: secondaryText,
      ),
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        side: BorderSide(color: outline),
      ),
    ),
  );
}