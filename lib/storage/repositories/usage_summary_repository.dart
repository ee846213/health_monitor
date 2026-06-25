import 'dart:math' as math;

import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/isar/collections/usage_summary_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:isar/isar.dart';

abstract class UsageSummaryRepository {
  Future<DigitalUsageSummary?> getByDate(DateTime date);

  Future<List<DigitalUsageSummary>> listByWindow(QueryWindow window);

  Future<void> upsertSummary(DigitalUsageSummary summary);

  Future<void> upsertAll(List<DigitalUsageSummary> summaries);
}

class InMemoryUsageSummaryRepository implements UsageSummaryRepository {
  InMemoryUsageSummaryRepository({
    required List<DigitalUsageSummary> summaries,
  }) : _summaries = <DigitalUsageSummary>[
          ...summaries,
        ];

  final List<DigitalUsageSummary> _summaries;

  @override
  Future<DigitalUsageSummary?> getByDate(DateTime date) async {
    final key = DateKey.fromDate(date);

    for (final summary in _summaries) {
      if (DateKey.fromDate(summary.date) == key) {
        return summary;
      }
    }

    return null;
  }

  @override
  Future<List<DigitalUsageSummary>> listByWindow(QueryWindow window) async {
    final summaries = _summaries
        .where((summary) => window.contains(summary.date))
        .toList(growable: false);
    summaries.sort((left, right) => left.date.compareTo(right.date));
    return summaries;
  }

  @override
  Future<void> upsertSummary(DigitalUsageSummary summary) async {
    final key = DateKey.fromDate(summary.date);
    final existingIndex = _summaries.indexWhere(
      (item) => DateKey.fromDate(item.date) == key,
    );
    final existing = existingIndex == -1 ? null : _summaries[existingIndex];
    _summaries.removeWhere((item) => DateKey.fromDate(item.date) == key);
    _summaries.add(
      existing == null
          ? summary
          : mergeUsageSummaryPreservingProgress(existing, summary),
    );
  }

  @override
  Future<void> upsertAll(List<DigitalUsageSummary> summaries) async {
    for (final summary in summaries) {
      await upsertSummary(summary);
    }
  }
}

class IsarUsageSummaryRepository implements UsageSummaryRepository {
  IsarUsageSummaryRepository(this._isarFuture);

  final Future<Isar> _isarFuture;

  @override
  Future<DigitalUsageSummary?> getByDate(DateTime date) async {
    final isar = await _isarFuture;
    final key = DateKey.fromDate(date);
    final record =
        await isar.usageSummaryRecords.filter().dateKeyEqualTo(key).findFirst();
    return record?.toDomain();
  }

  @override
  Future<List<DigitalUsageSummary>> listByWindow(QueryWindow window) async {
    final isar = await _isarFuture;
    final keys = window.dailyDates().map(DateKey.fromDate).toSet();
    if (keys.isEmpty) {
      return const <DigitalUsageSummary>[];
    }
    final records = await isar.usageSummaryRecords
        .filter()
        .anyOf(
          keys,
          (query, String key) => query.dateKeyEqualTo(key),
        )
        .findAll();
    final summaries =
        records.map((record) => record.toDomain()).toList(growable: false);
    summaries.sort((left, right) => left.date.compareTo(right.date));
    return summaries;
  }

  @override
  Future<void> upsertSummary(DigitalUsageSummary summary) async {
    final isar = await _isarFuture;
    await isar.writeTxn(() async {
      final incomingRecord = UsageSummaryRecord.fromDomain(summary);
      final existing = await isar.usageSummaryRecords
          .filter()
          .dateKeyEqualTo(incomingRecord.dateKey)
          .findAll();
      var mergedSummary = summary;
      for (final record in existing) {
        mergedSummary = mergeUsageSummaryPreservingProgress(
          record.toDomain(),
          mergedSummary,
        );
      }
      if (existing.isNotEmpty) {
        await isar.usageSummaryRecords.deleteAll(
          existing.map((item) => item.id).toList(growable: false),
        );
      }
      await isar.usageSummaryRecords.put(
        UsageSummaryRecord.fromDomain(mergedSummary),
      );
    });
  }

  @override
  Future<void> upsertAll(List<DigitalUsageSummary> summaries) async {
    if (summaries.isEmpty) {
      return;
    }
    final isar = await _isarFuture;
    await isar.writeTxn(() async {
      for (final summary in summaries) {
        final incomingRecord = UsageSummaryRecord.fromDomain(summary);
        final existing = await isar.usageSummaryRecords
            .filter()
            .dateKeyEqualTo(incomingRecord.dateKey)
            .findAll();
        var merged = summary;
        for (final record in existing) {
          merged = mergeUsageSummaryPreservingProgress(
            record.toDomain(),
            merged,
          );
        }
        if (existing.isNotEmpty) {
          await isar.usageSummaryRecords.deleteAll(
            existing.map((item) => item.id).toList(growable: false),
          );
        }
        final value = existing.isEmpty ? summary : merged;
        await isar.usageSummaryRecords.put(
          UsageSummaryRecord.fromDomain(value),
        );
      }
    });
  }
}

DigitalUsageSummary mergeUsageSummaryPreservingProgress(
  DigitalUsageSummary existing,
  DigitalUsageSummary incoming,
) {
  if (!_hasUsageProgress(incoming)) {
    return existing;
  }
  if (!_hasUsageProgress(existing)) {
    return incoming;
  }

  return DigitalUsageSummary(
    date: incoming.date,
    screenOnDuration:
        _maxDuration(existing.screenOnDuration, incoming.screenOnDuration),
    unlockCount: math.max(existing.unlockCount, incoming.unlockCount),
    viewCount: math.max(existing.viewCount, incoming.viewCount),
    nighttimeUsageDuration: _maxDuration(
      existing.nighttimeUsageDuration,
      incoming.nighttimeUsageDuration,
    ),
    focusSessionBreakCount: math.max(
      existing.focusSessionBreakCount,
      incoming.focusSessionBreakCount,
    ),
    longestContinuousUsageDuration: _maxDuration(
      existing.longestContinuousUsageDuration,
      incoming.longestContinuousUsageDuration,
    ),
    // 最长会话起点必须跟随被保留的“最长时长”，否则会出现时长来自一份摘要、
    // 起点来自另一份摘要的错配。时长相等时优先采用 incoming 的最新观测。
    longestContinuousUsageStartedAt:
        incoming.longestContinuousUsageDuration >=
                existing.longestContinuousUsageDuration
            ? (incoming.longestContinuousUsageStartedAt ??
                existing.longestContinuousUsageStartedAt)
            : existing.longestContinuousUsageStartedAt,
    topCategory: incoming.topCategory == UsageCategory.unknown
        ? existing.topCategory
        : incoming.topCategory,
    source: incoming.source,
    completeness: incoming.completeness,
  );
}

bool _hasUsageProgress(DigitalUsageSummary summary) {
  return summary.screenOnDuration > Duration.zero ||
      summary.unlockCount > 0 ||
      summary.viewCount > 0 ||
      summary.nighttimeUsageDuration > Duration.zero ||
      summary.focusSessionBreakCount > 0 ||
      summary.longestContinuousUsageDuration > Duration.zero;
}

Duration _maxDuration(Duration first, Duration second) {
  return first >= second ? first : second;
}
