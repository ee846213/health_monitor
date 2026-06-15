import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('health_monitor/platform_bridge_usage');
  const eventChannel = EventChannel('health_monitor/platform_events_usage');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('应解析 Android 当日与区间 usage summary', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
      switch (call.method) {
        case 'android.usage.readDailySummary':
          return <Object?, Object?>{
            'dateKey': '2026-06-16',
            'screenOnDurationMillis': 5400000,
            'unlockCount': 18,
            'viewCount': 26,
            'nighttimeUsageDurationMillis': 1200000,
            'focusSessionBreakCount': 7,
            'longestContinuousUsageDurationMillis': 1800000,
            'topCategoryKey': 'social',
            'completenessKey': 'full',
          };
        case 'android.usage.readRangeSummaries':
          return <Object?>[
            <Object?, Object?>{
              'dateKey': '2026-06-15',
              'screenOnDurationMillis': 4800000,
              'unlockCount': 14,
              'viewCount': 20,
              'nighttimeUsageDurationMillis': 600000,
              'focusSessionBreakCount': 5,
              'longestContinuousUsageDurationMillis': 1500000,
              'topCategoryKey': 'productivity',
              'completenessKey': 'partialGap',
            },
          ];
        default:
          return null;
      }
    });

    final bridge = AndroidUsageStatsBridge(
      platformBridgeService: PlatformBridgeService(
        methodChannel: methodChannel,
        eventChannel: eventChannel,
      ),
      isAndroid: () => true,
    );

    final daily = await bridge.readDailySummary(
      referenceTime: DateTime(2026, 6, 16, 9),
    );
    final range = await bridge.readRangeSummaries(
      window: QueryWindow.recentCalendarDays(
        2,
        referenceDate: DateTime(2026, 6, 16),
      ),
    );

    expect(daily, isNotNull);
    expect(daily!.source, DigitalUsageSource.androidUsageStats);
    expect(daily.viewCount, 26);
    expect(daily.longestContinuousUsageDuration, const Duration(minutes: 30));
    expect(daily.topCategory, UsageCategory.social);

    expect(range, hasLength(1));
    expect(range.single.completeness, UsageDataCompleteness.partialGap);
    expect(range.single.topCategory, UsageCategory.productivity);
  });
}
