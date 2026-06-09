import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';

void main() {
  test('前后台切换事件应生成最小数字生活摘要', () async {
    final controller = StreamController<AppUsageEvent>();
    final service = DigitalUsageCaptureService(
      lifecycleEventStreamFactory: () => controller.stream,
    );

    final future = service.watchUsageSummaries().take(3).toList();
    controller
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 9, 9, 0),
          type: AppUsageEventType.foregroundEntered,
        ),
      )
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 9, 9, 12),
          type: AppUsageEventType.foregroundExited,
        ),
      )
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 9, 9, 18),
          type: AppUsageEventType.foregroundEntered,
        ),
      );

    final summaries = await future;

    expect(summaries[0].unlockCount, 1);
    expect(summaries[0].screenOnDuration, Duration.zero);
    expect(summaries[1].screenOnDuration, const Duration(minutes: 12));
    expect(summaries[2].unlockCount, 2);
    expect(summaries[2].focusSessionBreakCount, 1);
    expect(summaries[2].topCategory, UsageCategory.unknown);

    await controller.close();
  });

  test('夜间时段应累积夜间使用时长', () async {
    final controller = StreamController<AppUsageEvent>();
    final service = DigitalUsageCaptureService(
      lifecycleEventStreamFactory: () => controller.stream,
    );

    final future = service.watchUsageSummaries().take(2).toList();
    controller
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 9, 21, 50),
          type: AppUsageEventType.foregroundEntered,
        ),
      )
      ..add(
        AppUsageEvent(
          occurredAt: DateTime(2026, 6, 9, 22, 20),
          type: AppUsageEventType.foregroundExited,
        ),
      );

    final summaries = await future;

    expect(summaries.last.screenOnDuration, const Duration(minutes: 30));
    expect(summaries.last.nighttimeUsageDuration, const Duration(minutes: 20));

    await controller.close();
  });

  test('事件流错误应转换为可消费异常', () async {
    final controller = StreamController<AppUsageEvent>();
    final service = DigitalUsageCaptureService(
      lifecycleEventStreamFactory: () => controller.stream,
    );

    final future = service.watchUsageSummaries().first;
    controller.addError(StateError('lifecycle missing'));

    await expectLater(future, throwsA(isA<DigitalUsageCaptureException>()));
    await controller.close();
  });
}
