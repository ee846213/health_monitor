import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens =
        theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncRecords = ref.watch(reminderListProvider);
    final preciseNotice = ref.watch(walkingScreenRiskNoticeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            context.go('/profile');
          },
        ),
        title: const Text('提醒记录'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: asyncRecords.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) =>
            Center(child: Text('加载提醒失败', style: tokens.bodyStyle)),
        data: (List<ReminderRecord> records) {
          return ListView(
            padding: EdgeInsets.all(tokens.spacingXl),
            children: <Widget>[
              preciseNotice.when(
                data: (String? message) {
                  if (message == null || message.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: tokens.spacingSm),
                    child: Card(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spacingLg),
                        child: Text(message, style: tokens.bodyStyle),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              if (records.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: tokens.spacingXl),
                  child: Center(
                    child: Text('今天还没有触发提醒记录', style: tokens.bodyStyle),
                  ),
                )
              else
                ...records.map((ReminderRecord record) {
                  return Card(
                    margin: EdgeInsets.only(bottom: tokens.spacingSm),
                    child: ListTile(
                      onTap: () => context.push('/reminders/detail', extra: record),
                      title: Text(record.title, style: tokens.sectionTitleStyle),
                      subtitle: Text(record.reasonSummary, style: tokens.bodyStyle),
                      trailing: Text(
                        _timeLabel(record.triggeredAt),
                        style: tokens.bodyStyle.copyWith(fontSize: 12),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
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
    final tokens =
        theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(record.title),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Section(label: '消息', content: record.message, tokens: tokens),
            _Section(label: '原因', content: record.reasonSummary, tokens: tokens),
            _Section(
              label: '建议',
              content: record.actionSuggestion,
              tokens: tokens,
            ),
            Text(
              '状态：${_responseLabel(record.response)}',
              style: tokens.sectionTitleStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.content,
    required this.tokens,
  });

  final String label;
  final String content;
  final HealthMonitorTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: tokens.sectionTitleStyle),
          SizedBox(height: tokens.spacingSm),
          Text(content, style: tokens.bodyStyle),
        ],
      ),
    );
  }
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _responseLabel(ReminderResponse response) {
  switch (response) {
    case ReminderResponse.pending:
      return '待处理';
    case ReminderResponse.dismissed:
      return '已忽略';
    case ReminderResponse.ignored:
      return '未处理';
    case ReminderResponse.taken:
      return '已执行';
  }
}
