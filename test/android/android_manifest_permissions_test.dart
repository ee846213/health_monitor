import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 主清单必须声明活动识别、位置和麦克风权限', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android.permission.ACTIVITY_RECOGNITION'));
    expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
    expect(manifest, contains('android.permission.RECORD_AUDIO'));
    expect(manifest, contains('android.permission.health.READ_STEPS'));
    expect(
      manifest,
      contains('androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE'),
    );
    expect(
      manifest,
      contains('android.permission.START_VIEW_PERMISSION_USAGE'),
    );
    expect(manifest, contains('android.intent.action.VIEW_PERMISSION_USAGE'));
    expect(manifest, contains('android.intent.category.HEALTH_PERMISSIONS'));
    expect(manifest, contains('android.permission.health.START_ONBOARDING'));
    expect(
      manifest,
      contains(
          'com.google.android.apps.healthdata.permission.START_ONBOARDING'),
    );
    expect(
      manifest,
      contains('android.health.connect.action.SHOW_ONBOARDING'),
    );
    expect(manifest, contains('androidx.health.ACTION_SHOW_ONBOARDING'));
  });

  test('Health Connect 设置入口应优先打开本应用权限管理页', () {
    final source = File(
      'android/app/src/main/kotlin/com/example/health_monitor/healthconnect/'
      'AndroidHealthConnectReader.kt',
    ).readAsStringSync();

    expect(
      source,
      contains('android.health.connect.action.MANAGE_HEALTH_PERMISSIONS'),
    );
    expect(source, contains('Intent.EXTRA_PACKAGE_NAME'));
    expect(
        source, contains('HealthConnectClient.ACTION_HEALTH_CONNECT_SETTINGS'));
  });
}
