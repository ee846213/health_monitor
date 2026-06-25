import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

class AndroidUsageStatsBridgeException implements Exception {
  const AndroidUsageStatsBridgeException(this.message);

  final String message;

  @override
  String toString() => 'AndroidUsageStatsBridgeException($message)';
}

class AndroidUsageCapabilityStatus {
  const AndroidUsageCapabilityStatus({
    required this.isSupported,
    required this.hasUsageAccess,
  });

  final bool isSupported;
  final bool hasUsageAccess;

  bool get canReadUsageStats => isSupported && hasUsageAccess;
}

class AndroidUsageStatsBridge {
  AndroidUsageStatsBridge({
    PlatformBridgeService? platformBridgeService,
    bool Function()? isAndroid,
  }) : _platformBridgeService = platformBridgeService ?? PlatformBridgeService(),
       _isAndroid = isAndroid ?? (() => Platform.isAndroid);

  final PlatformBridgeService _platformBridgeService;
  final bool Function() _isAndroid;

  Future<AndroidUsageCapabilityStatus> getCapabilityStatus() async {
    if (!_isAndroid()) {
      return const AndroidUsageCapabilityStatus(
        isSupported: false,
        hasUsageAccess: false,
      );
    }

    try {
      final payload = await _platformBridgeService.methodChannel
          .invokeMapMethod<Object?, Object?>('android.usage.getCapabilityStatus');
      return AndroidUsageCapabilityStatus(
        isSupported: payload?['isSupported'] as bool? ?? false,
        hasUsageAccess: payload?['hasUsageAccess'] as bool? ?? false,
      );
    } on PlatformException catch (error) {
      throw AndroidUsageStatsBridgeException(
        '读取 Android Usage Stats 能力状态失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<DigitalUsageSummary?> readDailySummary({
    DateTime? referenceTime,
  }) async {
    if (!_isAndroid()) {
      return null;
    }

    try {
      final payload = await _platformBridgeService.methodChannel
          .invokeMapMethod<Object?, Object?>(
            'android.usage.readDailySummary',
            <String, Object>{
              if (referenceTime != null)
                'referenceTimeMillis': referenceTime.millisecondsSinceEpoch,
            },
          );
      if (payload == null || payload.isEmpty) {
        return null;
      }
      return _summaryFromPayload(payload);
    } on PlatformException catch (error) {
      throw AndroidUsageStatsBridgeException(
        '读取 Android 当日屏幕使用摘要失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<List<DigitalUsageSummary>> readRangeSummaries({
    required QueryWindow window,
  }) async {
    if (!_isAndroid()) {
      return const <DigitalUsageSummary>[];
    }

    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMethod<List<Object?>>(
            'android.usage.readRangeSummaries',
            <String, Object>{
              'startMillis': window.startAt.millisecondsSinceEpoch,
              'endMillis': window.endAt.millisecondsSinceEpoch,
            },
          ) ??
          const <Object?>[];
      return payload
          .whereType<Map<Object?, Object?>>()
          .map(_summaryFromPayload)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw AndroidUsageStatsBridgeException(
        '读取 Android 区间屏幕使用摘要失败: ${error.message ?? error.code}',
      );
    }
  }

  Future<List<DigitalUsageSummary>> drainPendingSummaries() async {
    if (!_isAndroid()) {
      return const <DigitalUsageSummary>[];
    }

    try {
      final payload =
          await _platformBridgeService.methodChannel.invokeMethod<List<Object?>>(
            'android.usage.drainPendingSummaries',
          ) ??
          const <Object?>[];
      return payload
          .whereType<Map<Object?, Object?>>()
          .map(_summaryFromPayload)
          .toList(growable: false);
    } on PlatformException catch (error) {
      throw AndroidUsageStatsBridgeException(
        '读取 Android 待同步屏幕使用摘要失败: ${error.message ?? error.code}',
      );
    }
  }

  DigitalUsageSummary _summaryFromPayload(Map<Object?, Object?> payload) {
    final dateKey = payload['dateKey'] as String? ?? '';
    final date = _dateFromKey(dateKey);
    return DigitalUsageSummary(
      date: date,
      screenOnDuration: Duration(
        milliseconds: payload['screenOnDurationMillis'] as int? ?? 0,
      ),
      unlockCount: payload['unlockCount'] as int? ?? 0,
      viewCount: payload['viewCount'] as int? ?? 0,
      nighttimeUsageDuration: Duration(
        milliseconds: payload['nighttimeUsageDurationMillis'] as int? ?? 0,
      ),
      focusSessionBreakCount: payload['focusSessionBreakCount'] as int? ?? 0,
      longestContinuousUsageDuration: Duration(
        milliseconds:
            payload['longestContinuousUsageDurationMillis'] as int? ?? 0,
      ),
      longestContinuousUsageStartedAt:
          payload['longestContinuousUsageStartedAtMillis'] is int
              ? DateTime.fromMillisecondsSinceEpoch(
                  payload['longestContinuousUsageStartedAtMillis'] as int,
                )
              : null,
      topCategory: UsageCategory.values.firstWhere(
        (item) => item.name == (payload['topCategoryKey'] as String? ?? ''),
        orElse: () => UsageCategory.unknown,
      ),
      source: DigitalUsageSource.androidUsageStats,
      completeness: UsageDataCompleteness.values.firstWhere(
        (item) =>
            item.name == (payload['completenessKey'] as String? ?? 'full'),
        orElse: () => UsageDataCompleteness.full,
      ),
    );
  }

  DateTime _dateFromKey(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return DateTime.now();
    }
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? DateTime.now().month,
      int.tryParse(parts[2]) ?? DateTime.now().day,
    );
  }
}
