import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens =
        theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();

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
      body: ListView(
        padding: EdgeInsets.all(tokens.spacingXl),
        children: const <Widget>[
          _PreciseNoticeSection(),
          _ReminderRecordsSection(),
        ],
      ),
    );
  }
}

class _PreciseNoticeSection extends ConsumerWidget {
  const _PreciseNoticeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens =
        theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final preciseNotice = ref.watch(walkingScreenRiskNoticeProvider);

    return preciseNotice.when(
      skipLoadingOnRefresh: true,
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
    );
  }
}

class _ReminderRecordsSection extends ConsumerWidget {
  const _ReminderRecordsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens =
        theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncRecords = ref.watch(reminderListStateProvider);

    return asyncRecords.when(
      skipLoadingOnRefresh: true,
      loading: () => Padding(
        padding: EdgeInsets.all(tokens.spacingXl),
        child: const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (Object error, StackTrace _) => Card(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Text('加载提醒失败', style: tokens.bodyStyle),
        ),
      ),
      data: (List<ReminderRecord> records) {
        if (records.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: tokens.spacingXl),
            child: Center(
              child: Text('今天还没有触发提醒记录', style: tokens.bodyStyle),
            ),
          );
        }
        return Column(
          children: records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final card = Card(
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
            if (index >= 6) {
              return card;
            }
            return HealthStaggeredEntrance(index: index, child: card);
          }).toList(growable: false),
        );
      },
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
            HealthStaggeredEntrance(
              index: 0,
              child: _Section(
                label: '消息',
                content: record.message,
                tokens: tokens,
              ),
            ),
            HealthStaggeredEntrance(
              index: 1,
              child: _Section(
                label: '原因',
                content: record.reasonSummary,
                tokens: tokens,
              ),
            ),
            HealthStaggeredEntrance(
              index: 2,
              child: _Section(
                label: '建议',
                content: record.actionSuggestion,
                tokens: tokens,
              ),
            ),
            HealthStaggeredEntrance(
              index: 3,
              child: Text(
                '状态：${_responseLabel(record.response)}',
                style: tokens.sectionTitleStyle,
              ),
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
