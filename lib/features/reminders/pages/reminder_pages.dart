import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';

class ReminderListPage extends ConsumerStatefulWidget {
  const ReminderListPage({super.key});

  @override
  ConsumerState<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends ConsumerState<ReminderListPage> {
  ReminderType? _filter;
  String? _expandedHistoryDate;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(reminderListStateProvider);
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: HealthPageHeader(
                title: '提醒记录',
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go('/profile'),
                trailing: HealthNavFilterChip(
                  key: const Key('reminder-filter-button'),
                  label: _filter == null ? '全部' : _typeLabel(_filter!),
                  onTap: _showFilterSheet,
                ),
                trailingWidth: 55,
              ),
            ),
            const SizedBox(height: 17),
            Expanded(
              child: records.when(
                skipLoadingOnRefresh: true,
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(reminderListProvider),
                    child: const Text('提醒记录加载失败，点击重试'),
                  ),
                ),
                data: _buildRecords,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecords(List<ReminderRecord> allRecords) {
    final filtered = _filter == null
        ? allRecords
        : allRecords.where((record) => record.type == _filter).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HealthIconBubble(
                icon: 'notifications',
                foreground: context.healthTheme.sage,
                background: context.healthTheme.sageSoft,
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                _filter == null ? '还没有提醒记录' : '当前筛选没有结果',
                style: context.healthTheme.sectionTitleStyle,
              ),
              if (_filter != null)
                TextButton(
                  onPressed: () => setState(() => _filter = null),
                  child: const Text('清除筛选'),
                ),
            ],
          ),
        ),
      );
    }

    final groups = <String, List<ReminderRecord>>{};
    for (final record in filtered) {
      groups
          .putIfAbsent(
            _dateKey(record.triggeredAt),
            () => <ReminderRecord>[],
          )
          .add(record);
    }
    final keys = groups.keys.toList()
      ..sort((left, right) => right.compareTo(left));
    final todayKey = _dateKey(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: <Widget>[
        const _PreciseNoticeSection(),
        ...List<Widget>.generate(keys.length, (index) {
          final key = keys[index];
          final isToday = key == todayKey || index == 0;
          final expanded = isToday || _expandedHistoryDate == key;
          return HealthStaggeredEntrance(
            index: index.clamp(0, 5),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: HealthElevatedCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: <Widget>[
                    InkWell(
                      key: Key('reminder-date-$key'),
                      onTap: isToday
                          ? null
                          : () => setState(() {
                                _expandedHistoryDate = expanded ? null : key;
                              }),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                isToday ? '今日提醒' : _dateLabel(key),
                                style: context.healthTheme.sectionTitleStyle,
                              ),
                            ),
                            Text(
                              '${groups[key]!.length} 条',
                              style: context.healthTheme.dataStyle,
                            ),
                            if (!isToday) ...<Widget>[
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: expanded ? .25 : 0,
                                duration: const Duration(milliseconds: 220),
                                child: const HealthVectorIcon(
                                  'chevron_right',
                                  size: 18,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    HealthAnimatedExpand(
                      expanded: expanded,
                      child: Column(
                        children: groups[key]!
                            .map((record) => _ReminderCard(record: record))
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showFilterSheet() async {
    final selected = await showModalBottomSheet<ReminderType?>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.healthTheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: const Text('全部'),
                  trailing: _filter == null
                      ? const HealthVectorIcon('verified_user', size: 18)
                      : null,
                  onTap: () => Navigator.of(context).pop(),
                ),
                ...ReminderType.values.map(
                  (type) => ListTile(
                    title: Text(_typeLabel(type)),
                    trailing: _filter == type
                        ? const HealthVectorIcon('verified_user', size: 18)
                        : null,
                    onTap: () => Navigator.of(context).pop(type),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _filter = selected);
  }
}

class _PreciseNoticeSection extends ConsumerWidget {
  const _PreciseNoticeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(walkingScreenRiskNoticeProvider).valueOrNull;
    if (notice == null || notice.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.healthTheme.sandSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(notice, style: context.healthTheme.bodyStyle),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.record});

  final ReminderRecord record;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(record.type, context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        key: Key('reminder-card-${record.triggeredAt.millisecondsSinceEpoch}'),
        onTap: () => context.push('/reminders/detail', extra: record),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.healthTheme.surfaceSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  HealthIconBubble(
                    icon: _typeIcon(record.type),
                    foreground: color,
                    background: color.withValues(alpha: .15),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      record.title,
                      style: context.healthTheme.sectionTitleStyle,
                    ),
                  ),
                  Text(
                    _timeLabel(record.triggeredAt),
                    style: context.healthTheme.dataStyle,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(record.message, style: context.healthTheme.bodyStyle),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.push(
                        '/reminders/explanation',
                        extra: record,
                      ),
                      child: const Text('为什么提醒我？'),
                    ),
                  ),
                  _StatusChip(response: record.response),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.response});

  final ReminderResponse response;

  @override
  Widget build(BuildContext context) {
    final active = response == ReminderResponse.taken;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? context.healthTheme.sageSoft
            : response == ReminderResponse.pending
                ? context.healthTheme.sandSoft
                : context.healthTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        _responseLabel(response),
        style: context.healthTheme.dataStyle.copyWith(fontSize: 10),
      ),
    );
  }
}

class ReminderDetailPage extends ConsumerStatefulWidget {
  const ReminderDetailPage({super.key, required this.record});

  final ReminderRecord record;

  @override
  ConsumerState<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends ConsumerState<ReminderDetailPage> {
  late ReminderRecord _record = widget.record;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: HealthPageHeader(
                title: '提醒详情',
                onBack: () => context.pop(),
              ),
            ),
            const SizedBox(height: 17),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                children: <Widget>[
          HealthStaggeredEntrance(
            index: 0,
            child: HealthElevatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_record.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: context.healthTheme.textPrimary,
                      )),
                  const SizedBox(height: 10),
                  Text(_record.message, style: context.healthTheme.bodyStyle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          HealthStaggeredEntrance(
            index: 1,
            child: _DetailSection(
              title: '触发原因',
              content: _record.reasonSummary,
            ),
          ),
          const SizedBox(height: 14),
          HealthStaggeredEntrance(
            index: 2,
            child: _DetailSection(
              title: '建议动作',
              content: _record.actionSuggestion,
            ),
          ),
          const SizedBox(height: 14),
          HealthStaggeredEntrance(
            index: 3,
            child: _DetailSection(
              title: '记录信息',
              content:
                  '触发：${_fullTime(_record.triggeredAt)}\n投递：${_record.deliveredAt == null ? '未投递系统通知' : _fullTime(_record.deliveredAt!)}\n状态：${_responseLabel(_record.response)}',
            ),
          ),
          if (!_record.hasActioned && !_record.isIgnored) ...<Widget>[
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => _update(ReminderResponse.dismissed),
                    child: const Text('忽略'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        _saving ? null : () => _update(ReminderResponse.taken),
                    child: const Text('我已处理'),
                  ),
                ),
              ],
            ),
          ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(ReminderResponse response) async {
    setState(() => _saving = true);
    try {
      final repository = await ref.read(reminderRepositoryProvider.future);
      await repository.updateResponse(_record, response);
      if (!mounted) return;
      setState(() {
        _record = _record.copyWith(response: response);
        _saving = false;
      });
      ref.invalidate(reminderListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response == ReminderResponse.taken ? '已标记为处理' : '已忽略')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('状态保存失败，请重试')),
      );
    }
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return HealthElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: context.healthTheme.sectionTitleStyle),
          const SizedBox(height: 8),
          Text(content, style: context.healthTheme.bodyStyle),
        ],
      ),
    );
  }
}

String _typeLabel(ReminderType type) => switch (type) {
      ReminderType.sedentaryBreak => '久坐',
      ReminderType.postureRisk => '姿势',
      ReminderType.walkingScreenRisk => '移动看屏',
      ReminderType.nightUsage => '夜间使用',
      ReminderType.noisyEnvironment => '环境噪音',
    };

String _typeIcon(ReminderType type) => switch (type) {
      ReminderType.sedentaryBreak || ReminderType.postureRisk => 'chair_alt',
      ReminderType.walkingScreenRisk ||
      ReminderType.nightUsage =>
        'phone_iphone',
      ReminderType.noisyEnvironment => 'graphic_eq',
    };

Color _typeColor(ReminderType type, BuildContext context) => switch (type) {
      ReminderType.sedentaryBreak ||
      ReminderType.postureRisk =>
        context.healthTheme.sand,
      ReminderType.walkingScreenRisk ||
      ReminderType.nightUsage =>
        context.healthTheme.blue,
      ReminderType.noisyEnvironment => context.healthTheme.coral,
    };

String _responseLabel(ReminderResponse response) => switch (response) {
      ReminderResponse.pending => '待处理',
      ReminderResponse.dismissed => '已忽略',
      ReminderResponse.ignored => '未处理',
      ReminderResponse.taken => '已执行',
    };

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _dateLabel(String key) {
  final parts = key.split('-');
  return '${int.parse(parts[1])}月${int.parse(parts[2])}日';
}

String _timeLabel(DateTime dateTime) =>
    '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

String _fullTime(DateTime dateTime) =>
    '${dateTime.month}月${dateTime.day}日 ${_timeLabel(dateTime)}';
