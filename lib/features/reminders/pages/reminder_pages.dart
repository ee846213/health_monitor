import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

final reminderListProvider = FutureProvider<List<ReminderRecord>>((Ref ref) async {
  final repo = InMemoryReminderRepository(records: const []);
  return repo.listRecentDays(7, referenceDate: DateTime.now());
});

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncRecords = ref.watch(reminderListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('提醒记录'), backgroundColor: theme.colorScheme.surface),
      body: asyncRecords.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败', style: tokens.bodyStyle)),
        data: (records) => records.isEmpty
            ? Center(child: Text('暂无提醒记录', style: tokens.bodyStyle))
            : ListView.builder(
                padding: EdgeInsets.all(tokens.spacingXl),
                itemCount: records.length,
                itemBuilder: (_, i) {
                  final r = records[i];
                  return Card(
                    margin: EdgeInsets.only(bottom: tokens.spacingSm),
                    child: ListTile(
                      title: Text(r.title, style: tokens.sectionTitleStyle),
                      subtitle: Text(r.reasonSummary, style: tokens.bodyStyle),
                      trailing: Text(r.response.name, style: tokens.bodyStyle.copyWith(fontSize: 12)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class ReminderDetailPage extends StatelessWidget {
  const ReminderDetailPage({super.key, required this.record});
  final ReminderRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(record.title), backgroundColor: theme.colorScheme.surface),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacingXl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _section('消息', record.message, tokens),
          _section('原因', record.reasonSummary, tokens),
          _section('建议', record.actionSuggestion, tokens),
          Text('状态: ${record.response.name}', style: tokens.sectionTitleStyle),
        ]),
      ),
    );
  }

  Widget _section(String label, String content, HealthMonitorTheme tokens) => Padding(
        padding: EdgeInsets.only(bottom: tokens.spacingXl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: tokens.sectionTitleStyle),
          SizedBox(height: tokens.spacingSm),
          Text(content, style: tokens.bodyStyle),
        ]),
      );
}