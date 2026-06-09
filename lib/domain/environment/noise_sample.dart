enum NoiseLevel {
  quiet,
  moderate,
  loud,
}

class NoiseSample {
  const NoiseSample({
    required this.capturedAt,
    required this.duration,
    required this.decibel,
    required this.level,
  });

  factory NoiseSample.fromDecibel({
    required DateTime capturedAt,
    required Duration duration,
    required double decibel,
  }) {
    return NoiseSample(
      capturedAt: capturedAt,
      duration: duration,
      decibel: decibel,
      level: _levelFromDecibel(decibel),
    );
  }

  final DateTime capturedAt;
  final Duration duration;
  final double decibel;
  final NoiseLevel level;

  bool get isDisturbing => level == NoiseLevel.loud;

  // 这里只做等级划分，不保存原始音频，也不推断内容，
  // 这样能和项目的隐私边界保持一致。
  static NoiseLevel _levelFromDecibel(double decibel) {
    if (decibel >= 70) {
      return NoiseLevel.loud;
    }
    if (decibel >= 40) {
      return NoiseLevel.moderate;
    }
    return NoiseLevel.quiet;
  }
}
