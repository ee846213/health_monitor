import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/capability_matrix.dart';

void main() {
  test('默认能力矩阵应包含 iPhone 和 Android 两端定义', () {
    final matrix = CapabilityMatrix.defaultMatrix();

    expect(matrix.ios.activityRecognition, CapabilitySupport.supported);
    expect(matrix.android.activityRecognition, CapabilitySupport.supported);
    expect(matrix.ios.appCategoryUsage, CapabilitySupport.unsupported);
    expect(matrix.android.appCategoryUsage, CapabilitySupport.supported);
  });

  test('默认能力矩阵应补充后台采集与数字生活替代能力字段', () {
    final matrix = CapabilityMatrix.defaultMatrix();

    expect(matrix.ios.backgroundCapture, CapabilitySupport.limited);
    expect(matrix.android.backgroundCapture, CapabilitySupport.supported);
    expect(matrix.ios.digitalUsageAlternative, CapabilitySupport.supported);
    expect(matrix.android.digitalUsageAlternative, CapabilitySupport.supported);
    expect(matrix.ios.environmentNoise, CapabilitySupport.supported);
    expect(matrix.android.environmentNoise, CapabilitySupport.supported);
  });

  test('默认能力矩阵应能区分完整能力端与受限正式端', () {
    final matrix = CapabilityMatrix.defaultMatrix();

    expect(matrix.android.tier, PlatformCapabilityTier.full);
    expect(matrix.ios.tier, PlatformCapabilityTier.limitedOfficial);
  });

  test('能力矩阵应暴露支持受限能力检查', () {
    final matrix = CapabilityMatrix.defaultMatrix();

    expect(matrix.ios.hasLimitedCapabilities, isTrue);
    expect(matrix.android.hasLimitedCapabilities, isFalse);
    expect(matrix.ios.supportFor(CapabilityKey.backgroundCapture), CapabilitySupport.limited);
    expect(
      matrix.android.supportFor(CapabilityKey.screenUsageSummary),
      CapabilitySupport.supported,
    );
  });
}
