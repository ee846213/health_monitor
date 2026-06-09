import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/storage/repositories/date_key.dart';

abstract class ReminderRepository {
  Future<List<ReminderRecord>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  });

  Future<ReminderRecord?> getLatest();
}

class InMemoryReminderRepository implements ReminderRepository {
  InMemoryReminderRepository({
    required List<ReminderRecord> records,
  }) : _records = List<ReminderRecord>.unmodifiable(records);

  final List<ReminderRecord> _records;

  @override
  Future<List<ReminderRecord>> listRecentDays(
    int days, {
    required DateTime referenceDate,
  }) async {
    final keys = DateKey.recentDays(days, referenceDate: referenceDate).toSet();
    final result = _records
        .where((item) => keys.contains(DateKey.fromDate(item.triggeredAt)))
        .toList();

    // 提醒记录页需要稳定按时间回看，仓储层先统一排序，
    // 避免后续页面、规则解释页各自重复处理列表顺序。
    result.sort((left, right) => left.triggeredAt.compareTo(right.triggeredAt));
    return result;
  }

  @override
  Future<ReminderRecord?> getLatest() async {
    if (_records.isEmpty) {
      return null;
    }

    final sorted = _records.toList()
      ..sort((left, right) => left.triggeredAt.compareTo(right.triggeredAt));
    return sorted.last;
  }
}
