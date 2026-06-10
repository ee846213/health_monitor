import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/ios_background_capture_config.dart';
import 'package:health_monitor/domain/background/ios_background_capture_host_status.dart';
import 'package:health_monitor/services/ios_background_capture_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('health_monitor/platform_bridge_test');
  const eventChannel = EventChannel('health_monitor/platform_events_test');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('启动 iPhone 后台采集时应按约定调用桥接方法', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          capturedCall = call;
          return null;
        });

    final bridge = IosBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    await bridge.startBackgroundCapture(
      const IosBackgroundCaptureConfig(
        statusTitle: '健康监测正在后台刷新',
        statusBody: '用于在系统允许范围内刷新活动、位置与数字生活替代指标。',
        enableMotion: true,
        enableLocation: true,
        enableDigitalUsage: true,
        backgroundRefreshIntervalMinutes: 15,
      ),
    );

    expect(capturedCall?.method, 'ios.background.start');
    expect(capturedCall?.arguments['enableLocation'], isTrue);
    expect(capturedCall?.arguments['backgroundRefreshIntervalMinutes'], 15);
  });

  test('查询 iPhone 宿主后台状态时应解析桥接结果', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          return <String, Object?>{
            'isRunning': true,
            'summary': 'iPhone 后台刷新已进入宿主骨架阶段。',
          };
        });

    final bridge = IosBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    final status = await bridge.getHostStatus();

    expect(
      status,
      const IosBackgroundCaptureHostStatus(
        isRunning: true,
        summary: 'iPhone 后台刷新已进入宿主骨架阶段。',
      ),
    );
  });

  test('上报 iPhone 后台异常时应调用错误通道', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          capturedCall = call;
          return null;
        });

    final bridge = IosBackgroundCaptureBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
    );

    await bridge.markBackgroundCaptureError('后台刷新调度失败');

    expect(capturedCall?.method, 'ios.background.error');
    expect(capturedCall?.arguments['message'], '后台刷新调度失败');
  });
}
