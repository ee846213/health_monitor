import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/location/location_summary.dart';

void main() {
  test('位置摘要应支持计算移动强度与户外充足性', () {
    final summary = LocationSummary(
      date: DateTime(2026, 6, 9),
      distanceMeters: 4200,
      outdoorDuration: const Duration(minutes: 48),
      visitCount: 5,
      commuteCount: 2,
    );

    expect(summary.hasMeaningfulMobility, isTrue);
    expect(summary.hasOutdoorExposure, isTrue);
  });

  test('低活动位置摘要应标记为移动不足', () {
    final summary = LocationSummary(
      date: DateTime(2026, 6, 9),
      distanceMeters: 300,
      outdoorDuration: const Duration(minutes: 5),
      visitCount: 1,
      commuteCount: 0,
    );

    expect(summary.hasMeaningfulMobility, isFalse);
    expect(summary.hasOutdoorExposure, isFalse);
  });
}
