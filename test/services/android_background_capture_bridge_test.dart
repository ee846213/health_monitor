import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/android_background_capture_config.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/services/android_background_capture_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('health_monitor/platform_bridge_test');
  const eventChannel = EventChannel('health_monitor/platform_events_test');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('启动 Android 后台采集时应按约定调用桥接方法', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          capturedCall = call;
          return null;
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    await bridge.startBackgroundCapture(
      const AndroidBackgroundCaptureConfig(
        notificationTitle: '健康监测正在后台运行',
        notificationBody: '用于持续积累活动、位置与用机样本。',
        enableMotion: true,
        enableLocation: true,
        enableNoise: false,
        enableDigitalUsage: true,
        sampleIntervalMinutes: 15,
      ),
    );

    expect(capturedCall?.method, 'android.background.start');
    expect(capturedCall?.arguments['enableLocation'], isTrue);
    expect(capturedCall?.arguments['sampleIntervalMinutes'], 15);
  });

  test('停止 Android 后台采集时应调用停止方法', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          capturedCall = call;
          return null;
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    await bridge.stopBackgroundCapture();

    expect(capturedCall?.method, 'android.background.stop');
  });

  test('桥接异常应转换为后台采集异常', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          throw PlatformException(code: 'unavailable', message: 'service missing');
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    await expectLater(
      bridge.startBackgroundCapture(
        const AndroidBackgroundCaptureConfig(
          notificationTitle: '健康监测正在后台运行',
          notificationBody: '用于持续积累活动、位置与用机样本。',
          enableMotion: true,
          enableLocation: true,
          enableNoise: false,
          enableDigitalUsage: true,
          sampleIntervalMinutes: 15,
        ),
      ),
      throwsA(isA<AndroidBackgroundCaptureException>()),
    );
  });

  test('查询 Android 宿主后台状态时应解析桥接结果', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          return <String, Object?>{
            'isRunning': true,
            'summary': 'Android 后台采集已进入宿主骨架阶段。',
          };
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    final status = await bridge.getHostStatus();

    expect(
      status,
      const AndroidBackgroundCaptureHostStatus(
        isRunning: true,
        summary: 'Android 后台采集已进入宿主骨架阶段。',
      ),
    );
  });

  test('上报 Android 后台异常时应调用错误通道', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          capturedCall = call;
          return null;
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    await bridge.markBackgroundCaptureError('后台服务启动失败');

    expect(capturedCall?.method, 'android.background.error');
    expect(capturedCall?.arguments['message'], '后台服务启动失败');
  });

  test('刷新 Android 后台调度时应调用刷新通道', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          return <String, Object?>{
            'isRunning': true,
            'summary': 'Android 后台采集已刷新。',
            'notificationTitle': '健康监测正在后台运行',
            'notificationBody': '用于持续积累活动、位置与用机样本。 当前调度能力：motion、location、digital_usage；周期 15 分钟。',
            'notificationChannelId': 'health_monitor_background',
          };
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    final status = await bridge.refreshBackgroundCapture();

    expect(status.isRunning, isTrue);
    expect(status.summary, 'Android 后台采集已刷新。');
    expect(
      status.notificationBody,
      contains('周期 15 分钟'),
    );
  });

  test('查询 Android 宿主状态时应解析通知字段', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          return <String, Object?>{
            'isRunning': true,
            'summary': 'Android 后台采集已刷新。',
            'lastErrorMessage': '前台服务启动失败',
            'notificationBody': '用于持续积累活动、位置与用机样本。 当前调度能力：motion、location、digital_usage；周期 15 分钟。',
          };
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    final status = await bridge.getHostStatus();

    expect(status.lastErrorMessage, '前台服务启动失败');
    expect(status.notificationBody, contains('周期 15 分钟'));
  });

  test('刷新 Android 后台调度时应解析通知标题与渠道', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          return <String, Object?>{
            'isRunning': true,
            'summary': 'Android 后台采集已刷新。',
            'notificationTitle': '健康监测正在后台运行',
            'notificationBody': '用于持续积累活动、位置与用机样本。 当前调度能力：motion、location、digital_usage；周期 15 分钟。',
            'notificationChannelId': 'health_monitor_background',
          };
        });

    final bridge = AndroidBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    final status = await bridge.refreshBackgroundCapture();

    expect(status.isRunning, isTrue);
    expect(status.summary, 'Android 后台采集已刷新。');
    expect(status.notificationBody, contains('周期 15 分钟'));
  });
}
