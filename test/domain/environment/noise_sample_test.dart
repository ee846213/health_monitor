import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';

void main() {
  test('噪音样本应根据分贝推断噪音等级', () {
    final sample = NoiseSample.fromDecibel(
      capturedAt: DateTime(2026, 6, 9, 23),
      duration: const Duration(minutes: 20),
      decibel: 72,
    );

    expect(sample.level, NoiseLevel.loud);
    expect(sample.isDisturbing, isTrue);
  });

  test('安静环境不应被识别为噪音干扰', () {
    final sample = NoiseSample.fromDecibel(
      capturedAt: DateTime(2026, 6, 9, 7),
      duration: const Duration(minutes: 15),
      decibel: 34,
    );

    expect(sample.level, NoiseLevel.quiet);
    expect(sample.isDisturbing, isFalse);
  });
}
