import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/widgets/metric_detail_sheets.dart';

class BriefingPage extends ConsumerStatefulWidget {
  const BriefingPage({super.key});

  @override
  ConsumerState<BriefingPage> createState() => _BriefingPageState();
}

class _BriefingPageState extends ConsumerState<BriefingPage> {
  final ScrollController _controller = ScrollController();
  int _weekOffset = 0;
  int? _expandedEvent;

  @override
  void initState() {
    super.initState();
    PrimaryTabScrollRegistry.register(2, _controller);
  }

  @override
  void dispose() {
    PrimaryTabScrollRegistry.unregister(2, _controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncRange = ref.watch(briefingPageRangeProvider);
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: asyncRange.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(briefingViewModelProvider),
              child: const Text('简报加载失败，点击重试'),
            ),
          ),
          data: (selectedRange) => ListView(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 112),
            children: <Widget>[
              HealthStaggeredEntrance(
                index: 0,
                child: _Header(onCalendarTap: _openCalendar),
              ),
              const SizedBox(height: 18),
              HealthStaggeredEntrance(
                index: 1,
                child: _WeekSelector(
                  weekOffset: _weekOffset,
                  selectedRange: selectedRange,
                  onPreviousWeek: () => setState(() => _weekOffset--),
                  onNextWeek: _weekOffset < 0
                      ? () => setState(() => _weekOffset++)
                      : null,
                  onDateSelected: _selectDate,
                  onSevenDaysSelected: _selectSevenDays,
                ),
              ),
              const SizedBox(height: 16),
              HealthStaggeredEntrance(
                index: 2,
                child: HealthAnimatedSwitcher(
                  childKey: ValueKey<Object>((
                    selectedRange,
                    ref.watch(briefingSelectedDateProvider),
                  )),
                  child: _ConclusionCard(
                    onTap: () => _showExplanation(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HealthStaggeredEntrance(
                index: 3,
                child: _Timeline(
                  expandedIndex: _expandedEvent,
                  onToggle: (index) {
                    setState(() {
                      _expandedEvent = _expandedEvent == index ? null : index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              const HealthStaggeredEntrance(
                index: 4,
                child: _SummarySection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(DateTime date) {
    ref.read(briefingSelectedDateProvider.notifier).state = date;
    ref.read(briefingTimeRangeProvider.notifier).state =
        BriefingTimeRange.today;
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectSevenDays() {
    ref.read(briefingSelectedDateProvider.notifier).state = null;
    ref.read(briefingTimeRangeProvider.notifier).state =
        BriefingTimeRange.recent7Days;
  }

  Future<void> _openCalendar() async {
    final now = ref.read(briefingReferenceTimeProvider)();
    final selected = ref.read(briefingSelectedDateProvider) ?? now;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.healthTheme.surface,
      builder: (context) => SafeArea(
        child: CalendarDatePicker(
          initialDate: selected,
          firstDate: now.subtract(const Duration(days: 90)),
          lastDate: now,
          onDateChanged: (date) {
            Navigator.of(context).pop();
            _selectDate(date);
          },
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.onCalendarTap});

  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '每日简报',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: context.healthTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ref.watch(briefingWindowLabelProvider),
                style: context.healthTheme.bodyStyle,
              ),
            ],
          ),
        ),
        InkWell(
          key: const Key('briefing-calendar-button'),
          onTap: onCalendarTap,
          borderRadius: BorderRadius.circular(22),
          child: HealthIconBubble(
            icon: 'calendar_month',
            foreground: context.healthTheme.sage,
            background: context.healthTheme.sageSoft,
            size: 44,
            iconSize: 21,
          ),
        ),
      ],
    );
  }
}

class _WeekSelector extends ConsumerWidget {
  const _WeekSelector({
    required this.weekOffset,
    required this.selectedRange,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onDateSelected,
    required this.onSevenDaysSelected,
  });

  final int weekOffset;
  final BriefingTimeRange selectedRange;
  final VoidCallback onPreviousWeek;
  final VoidCallback? onNextWeek;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onSevenDaysSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(briefingReferenceTimeProvider)();
    final selectedDate = ref.watch(briefingSelectedDateProvider) ?? now;
    final startOfThisWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final start = startOfThisWeek.add(Duration(days: weekOffset * 7));
    final dates = List<DateTime>.generate(
      7,
      (index) => start.add(Duration(days: index)),
    );
    return HealthElevatedCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onPreviousWeek,
                icon: const HealthVectorIcon('chevron_left', size: 20),
              ),
              Expanded(
                child: Text(
                  '${start.month}月${start.day}日 - ${dates.last.month}月${dates.last.day}日',
                  textAlign: TextAlign.center,
                  style: context.healthTheme.sectionTitleStyle,
                ),
              ),
              IconButton(
                onPressed: onNextWeek,
                icon: const HealthVectorIcon('chevron_right', size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: dates.map((date) {
              final future = date.isAfter(
                DateTime(now.year, now.month, now.day, 23, 59, 59),
              );
              final active = selectedRange != BriefingTimeRange.recent7Days &&
                  _sameDay(date, selectedDate);
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: active,
                  enabled: !future,
                  label: '${date.month}月${date.day}日',
                  child: InkWell(
                    key: Key('briefing-date-${date.day}'),
                    onTap: future ? null : () => onDateSelected(date),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? context.healthTheme.sage
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            _weekday(date.weekday),
                            style: TextStyle(
                              fontSize: 9,
                              color: active
                                  ? Colors.white
                                  : future
                                      ? context.healthTheme.borderSubtle
                                      : context.healthTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : future
                                      ? context.healthTheme.borderSubtle
                                      : context.healthTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              key: const Key('briefing-seven-days'),
              onPressed: onSevenDaysSelected,
              child: Text(
                selectedRange == BriefingTimeRange.recent7Days
                    ? '正在查看 7 日总结'
                    : '查看最近 7 日总结',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConclusionCard extends ConsumerWidget {
  const _ConclusionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = ref.watch(briefingHasRealDataProvider);
    return HealthElevatedCard(
      key: const Key('briefing-conclusion-card'),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              HealthIconBubble(
                icon: 'article',
                foreground: context.healthTheme.sage,
                background: context.healthTheme.sageSoft,
              ),
              const SizedBox(width: 10),
              Text(
                hasData ? ref.watch(briefingWindowLabelProvider) : '数据正在积累',
                style: context.healthTheme.sectionTitleStyle,
              ),
              const Spacer(),
              const HealthVectorIcon('chevron_right', size: 18),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            hasData ? ref.watch(briefingHeadlineProvider) : '今天还不能下结论',
            style: TextStyle(
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: context.healthTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ref.watch(briefingSupportingDetailProvider),
            style: context.healthTheme.bodyStyle,
          ),
        ],
      ),
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline({
    required this.expandedIndex,
    required this.onToggle,
  });

  final int? expandedIndex;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(briefingSuggestionsProvider);
    final metrics = ref.watch(briefingMetricsProvider);
    final events = <(String, String, String, String)>[
      (
        '09:00',
        '上午节奏',
        metrics.isEmpty
            ? '活动数据正在积累'
            : '已记录 ${metrics.first.value} ${metrics.first.unit}',
        '保持轻量活动，不需要为了数字补足运动量。',
      ),
      (
        '14:30',
        '久坐观察',
        metrics.length < 2
            ? '姿势数据正在积累'
            : '累计 ${metrics[1].value} ${metrics[1].unit}',
        '连续静坐时，起身走动两三分钟就足够。',
      ),
      (
        '21:00',
        '晚间提醒',
        metrics.length < 3
            ? '屏幕数据正在积累'
            : '亮屏 ${metrics[2].value} ${metrics[2].unit}',
        suggestions.isEmpty ? '给睡前留一点无屏幕时间。' : suggestions.first,
      ),
    ];
    return HealthElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('当日时间线', style: context.healthTheme.sectionTitleStyle),
          const SizedBox(height: 8),
          ...List<Widget>.generate(events.length, (index) {
            final event = events[index];
            final expanded = expandedIndex == index;
            return Column(
              children: <Widget>[
                InkWell(
                  key: Key('briefing-event-$index'),
                  onTap: () => onToggle(index),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: <Color>[
                              context.healthTheme.sage,
                              context.healthTheme.sand,
                              context.healthTheme.blue,
                            ][index],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 45,
                          child: Text(event.$1,
                              style: context.healthTheme.dataStyle),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(event.$2,
                                  style: context.healthTheme.sectionTitleStyle),
                              const SizedBox(height: 3),
                              Text(event.$3,
                                  style: context.healthTheme.bodyStyle),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: expanded ? .25 : 0,
                          duration: const Duration(milliseconds: 220),
                          child:
                              const HealthVectorIcon('chevron_right', size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                HealthAnimatedExpand(
                  expanded: expanded,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 22, bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.healthTheme.surfaceSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(event.$4, style: context.healthTheme.bodyStyle),
                  ),
                ),
                if (index < events.length - 1)
                  Divider(height: 1, color: context.healthTheme.divider),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SummarySection extends ConsumerWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(briefingMetricsProvider);
    final range = ref.watch(briefingTimeRangeProvider);
    if (metrics.length < 3) return const SizedBox.shrink();
    final items = <(String, String, String, Color, VoidCallback)>[
      (
        'directions_walk',
        metrics[0].label,
        '${metrics[0].value} ${metrics[0].unit}',
        context.healthTheme.sage,
        () => _showStepDetailSheet(
            context, range, int.tryParse(metrics[0].value) ?? 0),
      ),
      (
        'chair_alt',
        metrics[1].label,
        '${metrics[1].value} ${metrics[1].unit}',
        context.healthTheme.sand,
        () => _showSedentaryDetailSheet(
            context, range, int.tryParse(metrics[1].value) ?? 0),
      ),
      (
        'phone_iphone',
        metrics[2].label,
        '${metrics[2].value} ${metrics[2].unit}',
        context.healthTheme.blue,
        () => _showScreenDetailSheet(
            context, range, int.tryParse(metrics[2].value) ?? 0),
      ),
    ];
    return HealthElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            range == BriefingTimeRange.recent7Days ? '7 日总结' : '今日总结',
            style: context.healthTheme.sectionTitleStyle,
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate(items.length, (index) {
            final item = items[index];
            return InkWell(
              key: Key(<String>[
                'briefing-step-card',
                'briefing-sedentary-card',
                'briefing-screen-card',
              ][index]),
              onTap: item.$5,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: <Widget>[
                    HealthIconBubble(
                      icon: item.$1,
                      foreground: item.$4,
                      background: item.$4.withValues(alpha: .16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.$2,
                          style: context.healthTheme.sectionTitleStyle),
                    ),
                    Text(
                      item.$3,
                      style: context.healthTheme.dataStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const HealthVectorIcon('chevron_right', size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

Future<void> _showExplanation(BuildContext context) {
  final tokens = context.healthTheme;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: tokens.surface,
    builder: (context) => SafeArea(
      child: Consumer(
        builder: (context, ref, child) {
          final quality = ref.watch(briefingQualityNoteProvider);
          final metrics = ref.watch(briefingMetricsProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('为什么这样总结', style: tokens.sectionTitleStyle),
                const SizedBox(height: 12),
                Text(
                  metrics.isEmpty
                      ? '当前还没有足够的维度形成稳定结论。'
                      : '结论主要参考活动、久坐和屏幕使用的聚合结果，不直接展示原始传感器数据。',
                  style: tokens.bodyStyle,
                ),
                if (quality != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text('数据质量：$quality', style: tokens.bodyStyle),
                ],
              ],
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _showStepDetailSheet(
  BuildContext context,
  BriefingTimeRange range,
  int steps,
) {
  final goalSteps = range == BriefingTimeRange.recent7Days ? 42000 : 6000;
  return showMetricDetailSheet(
    context,
    StepTrendDetailSheet(
      card: DashboardStepCard(
        currentSteps: steps,
        goalSteps: goalSteps,
        achievementPercent:
            goalSteps == 0 ? 0 : (steps / goalSteps * 100).round(),
      ),
      detailProvider: briefingStepDetailProvider(range),
      summary: '${range.label}累计 $steps 步。',
      progressLabel:
          range == BriefingTimeRange.recent7Days ? '7 日目标进度' : '当日进度',
    ),
  );
}

Future<void> _showSedentaryDetailSheet(
  BuildContext context,
  BriefingTimeRange range,
  int minutes,
) {
  return showMetricDetailSheet(
    context,
    SedentaryTimelineDetailSheet(
      card: DashboardSedentaryCard(
        totalMinutes: minutes,
        longestSingleMinutes: 0,
      ),
      detailProvider: briefingSedentaryDetailProvider(range),
      title: '${range.label}久坐分布',
      summary: '${range.label}累计久坐 $minutes 分钟。',
    ),
  );
}

Future<void> _showScreenDetailSheet(
  BuildContext context,
  BriefingTimeRange range,
  int minutes,
) {
  return showMetricDetailSheet(
    context,
    ScreenUsageDetailSheet(
      card: DashboardScreenCard(
        totalMinutes: minutes,
        yesterdayDeltaMinutes: 0,
        changeDirection: DashboardChangeDirection.steady,
      ),
      detailProvider: briefingScreenDetailProvider(range),
      title: '${range.label}分时段使用分布',
      summary: '${range.label}亮屏 $minutes 分钟。',
    ),
  );
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _weekday(int weekday) {
  return const <String>['一', '二', '三', '四', '五', '六', '日'][weekday - 1];
}
