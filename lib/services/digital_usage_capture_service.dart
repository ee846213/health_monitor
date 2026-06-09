import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';

typedef AppUsageEventStreamFactory = Stream<AppUsageEvent> Function();

enum AppUsageEventType {
  foregroundEntered,
  foregroundExited,
}

class AppUsageEvent {
  const AppUsageEvent({
    required this.occurredAt,
    required this.type,
  });

  final DateTime occurredAt;
  final AppUsageEventType type;
}

class DigitalUsageCaptureException implements Exception {
  const DigitalUsageCaptureException(this.message);

  final String message;

  @override
  String toString() => 'DigitalUsageCaptureException($message)';
}

class DigitalUsageCaptureService {
  DigitalUsageCaptureService({
    AppUsageEventStreamFactory? lifecycleEventStreamFactory,
  }) : _lifecycleEventStreamFactory =
           lifecycleEventStreamFactory ?? _defaultLifecycleSource.streamFactory;

  final AppUsageEventStreamFactory _lifecycleEventStreamFactory;

  static final _AppLifecycleUsageEventSource _defaultLifecycleSource =
      _AppLifecycleUsageEventSource();

  Stream<DigitalUsageSummary> watchUsageSummaries() {
    return _lifecycleEventStreamFactory().transform<DigitalUsageSummary>(
      StreamTransformer<AppUsageEvent, DigitalUsageSummary>.fromHandlers(
        handleData: (
          AppUsageEvent event,
          EventSink<DigitalUsageSummary> sink,
        ) {
          // 阶段 1 先把系统生命周期事件折算成“最小真实用机摘要”，
          // 让双平台都能产出统一语义的数字生活样本，后续再接 Android Usage Access 全量能力。
          _state.apply(event);
          sink.add(_state.toSummary());
        },
        handleError: (
          Object error,
          StackTrace stackTrace,
          EventSink<DigitalUsageSummary> sink,
        ) {
          sink.addError(
            DigitalUsageCaptureException('数字生活采集失败: $error'),
            stackTrace,
          );
        },
      ),
    );
  }

  final _DigitalUsageAccumulator _state = _DigitalUsageAccumulator.empty();
}

class _AppLifecycleUsageEventSource {
  _AppLifecycleUsageEventSource() {
    WidgetsFlutterBinding.ensureInitialized();
    lifecycleListener = AppLifecycleListener(
      onResume: () {
        _controller.add(
          AppUsageEvent(
            occurredAt: DateTime.now(),
            type: AppUsageEventType.foregroundEntered,
          ),
        );
      },
      onPause: () {
        _controller.add(
          AppUsageEvent(
            occurredAt: DateTime.now(),
            type: AppUsageEventType.foregroundExited,
          ),
        );
      },
      onDetach: () {
        _controller.add(
          AppUsageEvent(
            occurredAt: DateTime.now(),
            type: AppUsageEventType.foregroundExited,
          ),
        );
      },
    );
  }

  final StreamController<AppUsageEvent> _controller =
      StreamController<AppUsageEvent>.broadcast();
  // 这里需要保留 listener 引用，避免只注册回调却没有对象持有，
  // 导致调试阶段很难排查生命周期事件为什么没有持续进入流。
  late final AppLifecycleListener lifecycleListener;

  Stream<AppUsageEvent> streamFactory() => _controller.stream;
}

class _DigitalUsageAccumulator {
  _DigitalUsageAccumulator({
    required this.date,
    required this.screenOnDuration,
    required this.unlockCount,
    required this.nighttimeUsageDuration,
    required this.focusSessionBreakCount,
    required this.sessionStartedAt,
    required this.lastForegroundExitAt,
  });

  factory _DigitalUsageAccumulator.empty() {
    final now = DateTime.now();
    return _DigitalUsageAccumulator(
      date: DateTime(now.year, now.month, now.day),
      screenOnDuration: Duration.zero,
      unlockCount: 0,
      nighttimeUsageDuration: Duration.zero,
      focusSessionBreakCount: 0,
      sessionStartedAt: null,
      lastForegroundExitAt: null,
    );
  }

  DateTime date;
  Duration screenOnDuration;
  int unlockCount;
  Duration nighttimeUsageDuration;
  int focusSessionBreakCount;
  DateTime? sessionStartedAt;
  DateTime? lastForegroundExitAt;

  void apply(AppUsageEvent event) {
    _rolloverIfNeeded(event.occurredAt);

    switch (event.type) {
      case AppUsageEventType.foregroundEntered:
        unlockCount += 1;
        // 把短时间内再次回到前台视为一次专注中断，
        // 这样 Android 与 iPhone 都能先共享一套“碎片化查看”近似指标。
        if (lastForegroundExitAt != null &&
            event.occurredAt.difference(lastForegroundExitAt!) <=
                const Duration(minutes: 15)) {
          focusSessionBreakCount += 1;
        }
        sessionStartedAt = event.occurredAt;
      case AppUsageEventType.foregroundExited:
        if (sessionStartedAt == null) {
          lastForegroundExitAt = event.occurredAt;
          return;
        }

        final duration = event.occurredAt.difference(sessionStartedAt!);
        if (!duration.isNegative) {
          screenOnDuration += duration;
          nighttimeUsageDuration += _nightOverlap(
            sessionStartedAt!,
            event.occurredAt,
          );
        }
        sessionStartedAt = null;
        lastForegroundExitAt = event.occurredAt;
    }
  }

  DigitalUsageSummary toSummary() {
    return DigitalUsageSummary(
      date: date,
      screenOnDuration: screenOnDuration,
      unlockCount: unlockCount,
      nighttimeUsageDuration: nighttimeUsageDuration,
      focusSessionBreakCount: focusSessionBreakCount,
      topCategory: UsageCategory.unknown,
    );
  }

  void _rolloverIfNeeded(DateTime occurredAt) {
    final eventDate = DateTime(occurredAt.year, occurredAt.month, occurredAt.day);
    if (_isSameDay(date, eventDate)) {
      return;
    }

    // 当前阶段先保证“按天聚合的真实用机入口”成立。
    // 跨天仍在前台的长会话暂不拆分到前后两天，避免在阶段 1 过早引入复杂会话切割逻辑。
    date = eventDate;
    screenOnDuration = Duration.zero;
    unlockCount = 0;
    nighttimeUsageDuration = Duration.zero;
    focusSessionBreakCount = 0;
    sessionStartedAt = eventDate;
    lastForegroundExitAt = null;
  }

  Duration _nightOverlap(DateTime start, DateTime end) {
    final nightStart = DateTime(start.year, start.month, start.day, 22);
    final nightEnd = DateTime(start.year, start.month, start.day + 1, 6);
    final overlapStart = start.isAfter(nightStart) ? start : nightStart;
    final overlapEnd = end.isBefore(nightEnd) ? end : nightEnd;
    if (!overlapEnd.isAfter(overlapStart)) {
      return Duration.zero;
    }
    return overlapEnd.difference(overlapStart);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
