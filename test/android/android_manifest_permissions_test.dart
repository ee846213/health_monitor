import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 主清单必须声明活动识别、位置和麦克风权限', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android.permission.ACTIVITY_RECOGNITION'));
    expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
    expect(manifest, contains('android.permission.RECORD_AUDIO'));
  });
}
