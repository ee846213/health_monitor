import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

/// 提醒记录提供者。
final reminderListProvider = FutureProvider<List<ReminderRecord>>((Ref ref) async {
  final repo = InMemoryReminderRepository(records: const []);
  return repo.listRecentDays(7, referenceDate: DateTime.now());
});

/// 提醒记录页 —— 展示历史提醒列表。
class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncRecords = ref.watch(reminderListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('提醒记录'), backgroundColor: theme.colorScheme.surface),
      body: asyncRecords.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败')),
        data: (records) => records.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingXxl),
                  child: Text('暂无提醒记录，持续使用后自动生成。', style: tokens.bodyStyle),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(tokens.spacingXl),
                itemCount: records.length,
                itemBuilder: (_, index) {
                  final r = records[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: tokens.spacingSm),
                    child: ListTile(
                      title: Text(r.title, style: tokens.sectionTitleStyle),
                      subtitle: Text(r.reasonSummary, style: tokens.bodyStyle),
                      trailing: Text(
                        r.response.name,
                        style: tokens.bodyStyle.copyWith(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// 提醒详情页 —— 展示单条提醒的完整解释。
class ReminderDetailPage extends StatelessWidget {
  const ReminderDetailPage({super.key, required this.record});

  final ReminderRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(record.title), backgroundColor: theme.colorScheme.surface),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('消息', style: tokens.sectionTitleStyle),
            SizedBox(height: tokens.spacingSm),
            Text(record.message, style: tokens.bodyStyle),
            SizedBox(height: tokens.spacingXl),
            Text('原因', style: tokens.sectionTitleStyle),
            SizedBox(height: tokens.spacingSm),
            Text(record.reasonSummary, style: tokens.bodyStyle),
            SizedBox(height: tokens.spacingXl),
            Text('建议', style: tokens.sectionTitleStyle),
            SizedBox(height: tokens.spacingSm),
            Text(record.actionSuggestion, style: tokens.bodyStyle),
            SizedBox(height: tokens.spacingXl),
            Row(
              children: [
                Text('状态: ', style: tokens.sectionTitleStyle),
                Text(record.response.name, style: tokens.bodyStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}