import 'package:flutter/material.dart';

/// 健康监测 App 的 design tokens，对齐 Pencil 设计文件。
class HealthMonitorTheme extends ThemeExtension<HealthMonitorTheme> {
  const HealthMonitorTheme._({
    required this.cardRadius,
    required this.buttonRadius,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacingXxl,
    required this.sectionTitleStyle,
    required this.bodyStyle,
    required this.dataStyle,
    required this.verdictNormalColor,
    required this.verdictWarningColor,
    required this.verdictConcernColor,
  });

  final double cardRadius;
  final double buttonRadius;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;
  final TextStyle sectionTitleStyle;
  final TextStyle bodyStyle;
  final TextStyle dataStyle;
  final Color verdictNormalColor;
  final Color verdictWarningColor;
  final Color verdictConcernColor;

  factory HealthMonitorTheme.fallback() {
    return const HealthMonitorTheme._(
      cardRadius: 28,
      buttonRadius: 100,
      spacingXs: 4,
      spacingSm: 8,
      spacingMd: 12,
      spacingLg: 16,
      spacingXl: 24,
      spacingXxl: 32,
      sectionTitleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyStyle: TextStyle(fontSize: 14),
      dataStyle: TextStyle(fontSize: 13, fontFamily: 'IBM Plex Mono'),
      verdictNormalColor: Color(0xFF7B9786),
      verdictWarningColor: Color(0xFFD8A56E),
      verdictConcernColor: Color(0xFFC88976),
    );
  }

  @override
  HealthMonitorTheme copyWith({Object? replacement}) => this;

  @override
  ThemeExtension<HealthMonitorTheme> lerp(covariant ThemeExtension<HealthMonitorTheme>? other, double t) => this;
}