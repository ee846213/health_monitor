import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';

void main() {
  test('Android 后台采集配置应输出稳定桥接载荷', () {
    const config = AndroidBackgroundCaptureConfig(
      notificationTitle: '健康监测正在后台运行',
      notificationBody: '用于持续积累活动、位置与用机样本。',
      enableMotion: true,
      enableLocation: true,
      enableNoise: false,
      enableDigitalUsage: true,
      sampleIntervalMinutes: 15,
    );

    expect(config.channelPayload(), <String, Object>{
      'notificationTitle': '健康监测正在后台运行',
      'notificationBody': '用于持续积累活动、位置与用机样本。',
      'enableMotion': true,
      'enableLocation': true,
      'enableNoise': false,
      'enableDigitalUsage': true,
      'sampleIntervalMinutes': 15,
    });
  });
}
