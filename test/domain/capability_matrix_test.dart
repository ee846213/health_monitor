import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/capability_matrix.dart';

void main() {
  test('默认能力矩阵应包含 iPhone 和 Android 两端定义', () {
    final matrix = CapabilityMatrix.defaultMatrix();

    expect(matrix.ios.activityRecognition, CapabilitySupport.supported);
    expect(matrix.android.activityRecognition, CapabilitySupport.supported);
    expect(matrix.ios.appCategoryUsage, isNotNull);
    expect(matrix.android.appCategoryUsage, isNotNull);
  });
}
