import 'dart:math' as math;

import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/isar/collections/usage_summary_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';
import 'package:isar/isar.dart';

abstract class UsageSummaryRepository {
  Future<DigitalUsageSummary?> getByDate(DateTime date);

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
    for (final summary in summaries) {
      await upsertSummary(summary);
    }
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
