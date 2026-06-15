enum AmbientLightLevel {
  dark,
  comfortable,
  bright,
}

class AmbientLightSample {
  const AmbientLightSample({
    required this.capturedAt,
    required this.duration,
    required this.lux,
    required this.level,
  });

  factory AmbientLightSample.fromLux({
    required DateTime capturedAt,
    required Duration duration,
    required double lux,
  }) {
    return AmbientLightSample(
      capturedAt: capturedAt,
      duration: duration,
      lux: lux,
      level: _levelFromLux(lux),
    );
  }

  final DateTime capturedAt;
  final Duration duration;
  final double lux;
  final AmbientLightLevel level;

  static AmbientLightLevel _levelFromLux(double lux) {
    if (lux < 10) {
      return AmbientLightLevel.dark;
    }
    if (lux > 1000) {
      return AmbientLightLevel.bright;
    }
    return AmbientLightLevel.comfortable;
  }
}
