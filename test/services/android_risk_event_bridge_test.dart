import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('health_monitor/platform_bridge_test');
  const eventChannel = EventChannel('health_monitor/platform_events_test');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('应读取并解析 Android 精确 walking screen 风险事件', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
          expect(call.method, 'android.riskEvents.drainWalkingScreenRisks');
          return <Object?>[
            <Object?, Object?>{
              'eventId': 'risk-1',
              'occurredAtMillis': DateTime(2026, 6, 15, 9, 0).millisecondsSinceEpoch,
              'screenOnStartedAtMillis': DateTime(2026, 6, 15, 8, 59, 52)
                  .millisecondsSinceEpoch,
              'continuousWalkingSeconds': 8,
              'stepDelta': 12,
            },
          ];
        });

    final bridge = AndroidRiskEventBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
      isAndroid: () => true,
    );

    final events = await bridge.drainWalkingScreenRiskEvents();

    expect(events, hasLength(1));
    expect(events.single.eventId, 'risk-1');
    expect(events.single.continuousWalkingSeconds, 8);
    expect(events.single.stepDelta, 12);
  });
}
