import 'package:flutter/material.dart';

/// `health-monitor-app-design.pen` 对应的统一视觉 Token。
@immutable
class HealthMonitorTheme extends ThemeExtension<HealthMonitorTheme> {
  const HealthMonitorTheme({
    required this.canvas,
    required this.surface,
    required this.surfaceSoft,
    required this.borderSubtle,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.sage,
    required this.sageSoft,
    required this.sand,
    required this.sandSoft,
    required this.coral,
    required this.coralSoft,
    required this.blue,
    required this.blueSoft,
    required this.orange,
    required this.cardRadius,
    required this.itemRadius,
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

  factory HealthMonitorTheme.fallback() {
    return const HealthMonitorTheme(
      canvas: Color(0xFFFAF5EC),
      surface: Color(0xFFFFFFFF),
      surfaceSoft: Color(0xFFF8F3EA),
      borderSubtle: Color(0xFFDDD8CF),
      divider: Color(0xFFECE7DE),
      textPrimary: Color(0xFF242724),
      textSecondary: Color(0xFF737873),
      sage: Color(0xFF6F9A72),
      sageSoft: Color(0xFFDDEBDD),
      sand: Color(0xFFD7B27B),
      sandSoft: Color(0xFFF3E6D2),
      coral: Color(0xFFDF7B6E),
      coralSoft: Color(0xFFF6DAD5),
      blue: Color(0xFF72A7C4),
      blueSoft: Color(0xFFDDECF3),
      orange: Color(0xFFF0A23B),
      cardRadius: 28,
      itemRadius: 22,
      buttonRadius: 999,
      spacingXs: 4,
      spacingSm: 8,
      spacingMd: 12,
      spacingLg: 16,
      spacingXl: 24,
      spacingXxl: 32,
      sectionTitleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF242724),
      ),
      bodyStyle: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Color(0xFF737873),
      ),
      dataStyle: TextStyle(
        fontSize: 13,
        fontFamily: 'Inter',
        color: Color(0xFF242724),
      ),
      verdictNormalColor: Color(0xFF6F9A72),
      verdictWarningColor: Color(0xFFF0A23B),
      verdictConcernColor: Color(0xFFDF7B6E),
    );
  }

  final Color canvas;
  final Color surface;
  final Color surfaceSoft;
  final Color borderSubtle;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color sage;
  final Color sageSoft;
  final Color sand;
  final Color sandSoft;
  final Color coral;
  final Color coralSoft;
  final Color blue;
  final Color blueSoft;
  final Color orange;
  final double cardRadius;
  final double itemRadius;
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

  List<BoxShadow> get cardShadow => const <BoxShadow>[
        BoxShadow(
          color: Color(0x0A3D392F),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
        BoxShadow(
          color: Color(0x123D392F),
          blurRadius: 30,
          offset: Offset(0, 14),
        ),
      ];

  @override
  HealthMonitorTheme copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceSoft,
    Color? borderSubtle,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? sage,
    Color? sageSoft,
    Color? sand,
    Color? sandSoft,
    Color? coral,
    Color? coralSoft,
    Color? blue,
    Color? blueSoft,
    Color? orange,
  }) {
    return HealthMonitorTheme(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      sage: sage ?? this.sage,
      sageSoft: sageSoft ?? this.sageSoft,
      sand: sand ?? this.sand,
      sandSoft: sandSoft ?? this.sandSoft,
      coral: coral ?? this.coral,
      coralSoft: coralSoft ?? this.coralSoft,
      blue: blue ?? this.blue,
      blueSoft: blueSoft ?? this.blueSoft,
      orange: orange ?? this.orange,
      cardRadius: cardRadius,
      itemRadius: itemRadius,
      buttonRadius: buttonRadius,
      spacingXs: spacingXs,
      spacingSm: spacingSm,
      spacingMd: spacingMd,
      spacingLg: spacingLg,
      spacingXl: spacingXl,
      spacingXxl: spacingXxl,
      sectionTitleStyle: sectionTitleStyle,
      bodyStyle: bodyStyle,
      dataStyle: dataStyle,
      verdictNormalColor: verdictNormalColor,
      verdictWarningColor: verdictWarningColor,
      verdictConcernColor: verdictConcernColor,
    );
  }

  @override
  HealthMonitorTheme lerp(
    covariant HealthMonitorTheme? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return copyWith(
      canvas: Color.lerp(canvas, other.canvas, t),
      surface: Color.lerp(surface, other.surface, t),
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t),
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t),
      divider: Color.lerp(divider, other.divider, t),
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
      sage: Color.lerp(sage, other.sage, t),
      sageSoft: Color.lerp(sageSoft, other.sageSoft, t),
      sand: Color.lerp(sand, other.sand, t),
      sandSoft: Color.lerp(sandSoft, other.sandSoft, t),
      coral: Color.lerp(coral, other.coral, t),
      coralSoft: Color.lerp(coralSoft, other.coralSoft, t),
      blue: Color.lerp(blue, other.blue, t),
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t),
      orange: Color.lerp(orange, other.orange, t),
    );
  }
}

extension HealthMonitorThemeContext on BuildContext {
  HealthMonitorTheme get healthTheme =>
      Theme.of(this).extension<HealthMonitorTheme>() ??
      HealthMonitorTheme.fallback();
}
