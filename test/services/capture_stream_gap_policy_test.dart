import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/services/capture_health_service.dart';
import 'package:health_monitor/services/capture_stream_gap_policy.dart';

void main() {
  test('高频采集流应使用更短的缺口阈值', () {
    expect(captureGapThresholdFor(streamMotion), const Duration(minutes: 3));
    expect(captureGapThresholdFor(streamSteps), const Duration(minutes: 8));
    expect(captureGapThresholdFor(streamNoise), const Duration(minutes: 10));
    expect(captureGapThresholdFor(streamLight), const Duration(minutes: 10));
  });

  test('低频摘要流应使用更宽松的缺口阈值', () {
    expect(captureGapThresholdFor(streamLocation), const Duration(minutes: 45));
    expect(
      captureGapThresholdFor(streamDigitalUsageAndroid),
      const Duration(hours: 18),
    );
    expect(
      captureGapThresholdFor(streamDigitalUsageAlternative),
      const Duration(hours: 24),
    );
    expect(captureGapThresholdFor(streamNativeRisk), const Duration(hours: 24));
  });
}
