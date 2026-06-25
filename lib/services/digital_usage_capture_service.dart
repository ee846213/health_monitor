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
    DigitalUsageSummary? restoredSummary,
  }) : _lifecycleEventStreamFactory =
           lifecycleEventStreamFactory ?? _defaultLifecycleSource.streamFactory,
       _state = _DigitalUsageAccumulator.fromSummary(
         restoredSummary ?? _DigitalUsageAccumulator.empty().toSummary(),
       );

  final AppUsageEventStreamFactory _lifecycleEventStreamFactory;

  static final _AppLifecycleUsageEventSource _defaultLifecycleSource =
      _AppLifecycleUsageEventSource();

  final _DigitalUsageAccumulator _state;

  Stream<DigitalUsageSummary> watchUsageSummaries() {
    return _lifecycleEventStreamFactory().transform<DigitalUsageSummary>(
      StreamTransformer<AppUsageEvent, DigitalUsageSummary>.fromHandlers(
        handleData: (
          AppUsageEvent event,
          EventSink<DigitalUsageSummary> sink,
        ) {
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
    required this.viewCount,
    required this.longestContinuousUsageDuration,
    required this.longestContinuousUsageStartedAt,
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
      viewCount: 0,
      longestContinuousUsageDuration: Duration.zero,
      longestContinuousUsageStartedAt: null,
      sessionStartedAt: null,
      lastForegroundExitAt: null,
    );
  }

  factory _DigitalUsageAccumulator.fromSummary(DigitalUsageSummary summary) {
    return _DigitalUsageAccumulator(
      date: DateTime(summary.date.year, summary.date.month, summary.date.day),
      screenOnDuration: summary.screenOnDuration,
      unlockCount: summary.unlockCount,
      nighttimeUsageDuration: summary.nighttimeUsageDuration,
      focusSessionBreakCount: summary.focusSessionBreakCount,
      viewCount: summary.effectiveViewCount,
      longestContinuousUsageDuration: summary.longestContinuousUsageDuration,
      longestContinuousUsageStartedAt: summary.longestContinuousUsageStartedAt,
      sessionStartedAt: null,
      lastForegroundExitAt: null,
    );
  }

  DateTime date;
  Duration screenOnDuration;
  int unlockCount;
  Duration nighttimeUsageDuration;
  int focusSessionBreakCount;
  int viewCount;
  Duration longestContinuousUsageDuration;
  DateTime? longestContinuousUsageStartedAt;
  DateTime? sessionStartedAt;
  DateTime? lastForegroundExitAt;

  void apply(AppUsageEvent event) {
    _splitRolloverIfNeeded(event.occurredAt);

    switch (event.type) {
      case AppUsageEventType.foregroundEntered:
        unlockCount += 1;
        if (lastForegroundExitAt != null &&
            event.occurredAt.difference(lastForegroundExitAt!) <=
                const Duration(minutes: 15)) {
          focusSessionBreakCount += 1;
        }
        viewCount += 1;
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
          if (duration > longestContinuousUsageDuration) {
            longestContinuousUsageDuration = duration;
            // 记录“最长连续使用”的起点，作为数字习惯节点的真实代表时刻。
            longestContinuousUsageStartedAt = sessionStartedAt;
          }
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
      viewCount: viewCount,
      longestContinuousUsageDuration: longestContinuousUsageDuration,
      longestContinuousUsageStartedAt: longestContinuousUsageStartedAt,
      topCategory: UsageCategory.unknown,
      source: DigitalUsageSource.lifecycleAlternative,
    );
  }

  void _splitRolloverIfNeeded(DateTime occurredAt) {
    if (_isSameDay(date, occurredAt)) {
      return;
    }

    if (sessionStartedAt != null) {
      final endOfCurrentDay = DateTime(date.year, date.month, date.day + 1);
      final partialDuration = endOfCurrentDay.difference(sessionStartedAt!);
      if (!partialDuration.isNegative) {
        screenOnDuration += partialDuration;
        nighttimeUsageDuration += _nightOverlap(
          sessionStartedAt!,
          endOfCurrentDay,
        );
        if (partialDuration > longestContinuousUsageDuration) {
          longestContinuousUsageDuration = partialDuration;
          longestContinuousUsageStartedAt = sessionStartedAt;
        }
      }
      sessionStartedAt = DateTime(
        occurredAt.year,
        occurredAt.month,
        occurredAt.day,
      );
    }

    date = DateTime(occurredAt.year, occurredAt.month, occurredAt.day);
    screenOnDuration = Duration.zero;
    unlockCount = 0;
    nighttimeUsageDuration = Duration.zero;
    focusSessionBreakCount = 0;
    viewCount = 0;
    longestContinuousUsageDuration = Duration.zero;
    longestContinuousUsageStartedAt = null;
    lastForegroundExitAt = null;
  }

  Duration _nightOverlap(DateTime start, DateTime end) {
    var total = Duration.zero;
    var cursor = DateTime(start.year, start.month, start.day);
    while (cursor.isBefore(end)) {
      final nightStart = DateTime(cursor.year, cursor.month, cursor.day, 22);
      final nightEnd = DateTime(cursor.year, cursor.month, cursor.day + 1, 6);
      final overlapStart = start.isAfter(nightStart) ? start : nightStart;
      final overlapEnd = end.isBefore(nightEnd) ? end : nightEnd;
      if (overlapEnd.isAfter(overlapStart)) {
        total += overlapEnd.difference(overlapStart);
      }
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return total;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
