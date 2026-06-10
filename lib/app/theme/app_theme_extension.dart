import 'package:flutter/material.dart';

/// 健康监测 App 的 design tokens。
///
/// 通过 [ThemeExtension] 机制注册到 Material [ThemeData]，
/// 页面层通过 `Theme.of(context).extension<HealthMonitorTheme>()` 读取。
///
/// Token 命名遵循 Flutter 设计落地文档。
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
    required this.verdictNormalColor,
    required this.verdictWarningColor,
    required this.verdictConcernColor,
  });

  // --- 圆角 ---

  /// 卡片圆角，28px（对应设计稿 card border-radius）。
  final double cardRadius;

  /// 按钮圆角，100px（pill 形状）。
  final double buttonRadius;

  // --- 间距 ---

  /// XS 间距 4px。
  final double spacingXs;

  /// SM 间距 8px。
  final double spacingSm;

  /// MD 间距 12px。
  final double spacingMd;

  /// LG 间距 16px。
  final double spacingLg;

  /// XL 间距 24px。
  final double spacingXl;

  /// XXL 间距 32px。
  final double spacingXxl;

  // --- 文字 ---

  /// 段落标题样式（16px / 600）。
  final TextStyle sectionTitleStyle;

  /// 正文样式（14px / 1.5 行高）。
  final TextStyle bodyStyle;

  // --- 语义色 ---

  /// 正常 / 安全（绿色调）。
  final Color verdictNormalColor;

  /// 警告 / 注意（暖色调）。
  final Color verdictWarningColor;

  /// 关注 / 风险（红色调）。
  final Color verdictConcernColor;

  /// 无主题上下文时的安全  fallback。
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
      verdictNormalColor: Color(0xFF7B9786),
      verdictWarningColor: Color(0xFFE8A838),
      verdictConcernColor: Color(0xFFD96C5A),
    );
  }

  /// 从给定的 \[ColorScheme\] 和 \[TextTheme\] 派生完整 token。
  static HealthMonitorTheme fromContext({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return HealthMonitorTheme._(
      cardRadius: 28,
      buttonRadius: 100,
      spacingXs: 4,
      spacingSm: 8,
      spacingMd: 12,
      spacingLg: 16,
      spacingXl: 24,
      spacingXxl: 32,
      sectionTitleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      verdictNormalColor: const Color(0xFF7B9786),
      verdictWarningColor: const Color(0xFFE8A838),
      verdictConcernColor: const Color(0xFFD96C5A),
    );
  }

  @override
  HealthMonitorTheme copyWith({Object? replacement}) => this;

  @override
  ThemeExtension<HealthMonitorTheme> lerp(covariant ThemeExtension<HealthMonitorTheme>? other, double t) => this;
}