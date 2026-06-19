import 'package:flutter/material.dart';

/// 健康监测 App 的统一动效参数。
///
/// 动效只用于表达数据变化、交互反馈和页面层级，不用于持续吸引注意力。
@immutable
class HealthMotionTokens extends ThemeExtension<HealthMotionTokens> {
  const HealthMotionTokens({
    required this.fast,
    required this.base,
    required this.emphasized,
    required this.data,
    required this.stagger,
    required this.standardCurve,
  });

  const HealthMotionTokens.standard()
      : fast = const Duration(milliseconds: 150),
        base = const Duration(milliseconds: 220),
        emphasized = const Duration(milliseconds: 320),
        data = const Duration(milliseconds: 650),
        stagger = const Duration(milliseconds: 45),
        standardCurve = Curves.easeOutCubic;

  final Duration fast;
  final Duration base;
  final Duration emphasized;
  final Duration data;
  final Duration stagger;
  final Curve standardCurve;

  @override
  HealthMotionTokens copyWith({
    Duration? fast,
    Duration? base,
    Duration? emphasized,
    Duration? data,
    Duration? stagger,
    Curve? standardCurve,
  }) {
    return HealthMotionTokens(
      fast: fast ?? this.fast,
      base: base ?? this.base,
      emphasized: emphasized ?? this.emphasized,
      data: data ?? this.data,
      stagger: stagger ?? this.stagger,
      standardCurve: standardCurve ?? this.standardCurve,
    );
  }

  @override
  HealthMotionTokens lerp(
    covariant ThemeExtension<HealthMotionTokens>? other,
    double t,
  ) {
    if (other is! HealthMotionTokens) {
      return this;
    }
    return HealthMotionTokens(
      fast: _lerpDuration(fast, other.fast, t),
      base: _lerpDuration(base, other.base, t),
      emphasized: _lerpDuration(emphasized, other.emphasized, t),
      data: _lerpDuration(data, other.data, t),
      stagger: _lerpDuration(stagger, other.stagger, t),
      standardCurve: t < 0.5 ? standardCurve : other.standardCurve,
    );
  }
}

Duration _lerpDuration(Duration begin, Duration end, double t) {
  return Duration(
    microseconds:
        (begin.inMicroseconds + (end.inMicroseconds - begin.inMicroseconds) * t)
            .round(),
  );
}

extension HealthMotionContext on BuildContext {
  HealthMotionTokens get healthMotion {
    return Theme.of(this).extension<HealthMotionTokens>() ??
        const HealthMotionTokens.standard();
  }

  bool get reduceMotion => MediaQuery.maybeOf(this)?.disableAnimations ?? false;

  /// 降低动态效果时只保留极短淡入，避免位移和缩放。
  Duration motionDuration(Duration normal) {
    return reduceMotion ? const Duration(milliseconds: 80) : normal;
  }
}
