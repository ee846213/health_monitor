import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/services/step_counter_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('health_monitor/platform_bridge_test');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('步数读取应直接走原生后台步数通道', () async {
    MethodCall? capturedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          capturedCall = call;
          return <String, Object?>{
            'capturedAtMillis': 1710000000000,
            'stepCount': 5000,
            'isAvailable': true,
          };
        });

    final service = StepCounterService(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: const EventChannel('health_monitor/platform_events_test'),
      ),
      isAndroid: () => true,
    );

    final reading = await service.readCurrent();

    expect(capturedCall?.method, 'android.steps.current');
    expect(reading.isAvailable, isTrue);
    expect(reading.stepCount, 5000);
  });
}
