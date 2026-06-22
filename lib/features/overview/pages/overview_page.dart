import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_metric_trend_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/overview/widgets/daily_rhythm_timeline.dart';
import 'package:health_monitor/features/overview/widgets/metric_detail_sheets.dart';
import 'package:health_monitor/features/state_pages/state_pages.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    PrimaryTabScrollRegistry.register(0, _scrollController);
  }

  @override
  void dispose() {
    PrimaryTabScrollRegistry.unregister(0, _scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncScreenState = ref.watch(overviewScreenStateProvider);
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: asyncScreenState.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => _OverviewError(
            onRetry: () => ref.invalidate(overviewReadyDataProvider),
          ),
          data: (OverviewScreenState screenState) {
            switch (screenState) {
              case OverviewScreenState.permissionDenied:
                return const PermissionDeniedPage();
              case OverviewScreenState.dataInsufficient:
                return const DataInsufficientPage();
              case OverviewScreenState.ready:
                return _OverviewReadyBody(
                  controller: _scrollController,
                );
            }
          },
        ),
      ),
    );
  }
}

class _OverviewReadyBody extends ConsumerWidget {
  const _OverviewReadyBody({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(overviewDashboardSnapshotProvider);
    final rhythm = ref.watch(dailyRhythmUiModelProvider);
    if (dashboard == null || rhythm == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      color: context.healthTheme.sage,
      onRefresh: () async {
        ref.invalidate(overviewReadyDataProvider);
        await ref.read(overviewReadyDataProvider.future);
      },
      child: ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
        children: <Widget>[
          HealthStaggeredEntrance(
            index: 0,
            child: _Header(
              onSensingTap: () => _showSensingSheet(context, ref),
            ),
          ),
          const SizedBox(height: 10),
          HealthStaggeredEntrance(
            index: 1,
            child: DailyRhythmTimeline(
              model: rhythm,
              onNodeTap: (DailyRhythmNode node) {
                _showRhythmNodeSheet(context, node);
              },
              onCurrentTimeTap: (DateTime time) {
                _showCurrentStateSheet(context, dashboard, time);
              },
            ),
          ),
          HealthStaggeredEntrance(
            index: 2,
            child: _SummaryCard(
              dashboard: dashboard,
              onTap: () => _openTrend(
                context,
                ref,
                _priorityTrend(dashboard),
              ),
            ),
          ),
          const SizedBox(height: 16),
          HealthStaggeredEntrance(
            index: 3,
            child: _MetricGroup(
              dashboard: dashboard,
              onActivityTap: () => _showStepDetailSheet(context, ref),
              onPostureTap: () => _showSedentaryDetailSheet(context, ref),
              onNoiseTap: () => _openTrend(context, ref, TrendTab.environment),
              onDigitalTap: () => _showScreenDetailSheet(context, ref),
            ),
          ),
          const SizedBox(height: 16),
          HealthStaggeredEntrance(
            index: 4,
            child: _ActionCard(
              dashboard: dashboard,
              onTap: () => _showActionSheet(context, dashboard),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSensingTap});

  final VoidCallback onSensingTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '今天的节奏',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '身体没有催你，只是在提醒你换个姿势',
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: '个人感知',
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onSensingTap,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: tokens.borderSubtle),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0D3D392F),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  HealthVectorIcon(
                    'person',
                    size: 18,
                    color: tokens.sage,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '个人感知',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: tokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.dashboard,
    required this.onTap,
  });

  final DashboardSnapshot dashboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return HealthElevatedCard(
      key: const Key('overview-summary-card'),
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 17, 14, 17),
      child: Row(
        children: <Widget>[
          Expanded(
            child: HealthAnimatedSwitcher(
              childKey: ValueKey<int>(dashboard.healthScore.totalScore),
              child: Text(
                _summary(dashboard),
                style: TextStyle(
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 68,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F3),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  '今日状态',
                  style: TextStyle(fontSize: 9, color: tokens.textSecondary),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      HealthAnimatedNumberText(
                        value: '${dashboard.healthScore.totalScore}',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: tokens.sage,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 3),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: tokens.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGroup extends ConsumerWidget {
  const _MetricGroup({
    required this.dashboard,
    required this.onActivityTap,
    required this.onPostureTap,
    required this.onNoiseTap,
    required this.onDigitalTap,
  });

  final DashboardSnapshot dashboard;
  final VoidCallback onActivityTap;
  final VoidCallback onPostureTap;
  final VoidCallback onNoiseTap;
  final VoidCallback onDigitalTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.healthTheme;
    final trendData = ref.watch(overviewMetricTrendDataProvider).valueOrNull ??
        const OverviewMetricTrendData();
    final rows = <_MetricRowData>[
      _MetricRowData(
        key: const Key('metric-step-card'),
        dimension: DailyRhythmDimension.activity,
        icon: 'directions_walk',
        label: '活动',
        value: '${dashboard.stepCard.currentSteps}',
        unit: '步',
        status: dashboard.stepCard.achievementPercent >= 100 ? '良好' : '积累中',
        caption: '目标 ${dashboard.stepCard.goalSteps}',
        color: tokens.sage,
        background: tokens.sageSoft,
        values: trendData.activity,
        onTap: onActivityTap,
      ),
      _MetricRowData(
        key: const Key('metric-sedentary-card'),
        dimension: DailyRhythmDimension.posture,
        icon: 'chair_alt',
        label: '姿势',
        value: _hours(dashboard.sedentaryCard.totalMinutes),
        unit: '小时',
        status: dashboard.sedentaryCard.totalMinutes >= 120 ? '专注时段' : '平稳',
        caption: '最长 ${dashboard.sedentaryCard.longestSingleMinutes} 分钟',
        color: const Color(0xFFA77A42),
        background: tokens.sandSoft,
        values: trendData.posture,
        onTap: onPostureTap,
      ),
      _MetricRowData(
        key: const Key('metric-noise-card'),
        dimension: DailyRhythmDimension.noise,
        icon: 'graphic_eq',
        label: '环境噪音',
        value: dashboard.environmentSnapshot.noiseLabel,
        unit: '',
        status: dashboard.environmentSnapshot.noiseLabel == '嘈杂' ? '偏高' : '平稳',
        caption: '最近有效样本',
        color: tokens.coral,
        background: tokens.coralSoft,
        values: trendData.noise,
        onTap: onNoiseTap,
      ),
      _MetricRowData(
        key: const Key('metric-screen-card'),
        dimension: DailyRhythmDimension.digital,
        icon: 'phone_iphone',
        label: '数字习惯',
        value: _hours(dashboard.screenCard.totalMinutes),
        unit: '小时',
        status: dashboard.screenCard.totalMinutes >= 180 ? '偏多' : '适中',
        caption: _screenCaption(dashboard.screenCard),
        color: tokens.blue,
        background: tokens.blueSoft,
        values: trendData.digital,
        onTap: onDigitalTap,
      ),
    ];

    return HealthElevatedCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List<Widget>.generate(rows.length, (int index) {
          return Column(
            children: <Widget>[
              _MetricRow(data: rows[index]),
              if (index != rows.length - 1)
                Divider(height: 1, color: tokens.divider),
            ],
          );
        }),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.data});

  final _MetricRowData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return InkWell(
      key: data.key,
      borderRadius: BorderRadius.circular(20),
      onTap: data.onTap,
      child: SizedBox(
        height: 82,
        child: Row(
          children: <Widget>[
            HealthIconBubble(
              icon: data.icon,
              foreground: data.color,
              background: data.background,
              size: 36,
              iconSize: 19,
              weight: 500,
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 98,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: data.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                        if (data.unit.isNotEmpty)
                          TextSpan(
                            text: ' ${data.unit}',
                            style: TextStyle(
                              fontSize: 10,
                              color: tokens.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 34,
                child: CustomPaint(
                  key: Key('metric-${data.dimension.name}-trend'),
                  painter: _MiniTrendPainter(
                    values: data.values,
                    color: data.color,
                    baseline: data.background,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 66,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: data.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.25,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            HealthVectorIcon(
              'chevron_right',
              size: 15,
              color: tokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTrendPainter extends CustomPainter {
  _MiniTrendPainter({
    required this.values,
    required this.color,
    required this.baseline,
  });

  final List<double> values;
  final Color color;
  final Color baseline;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height - 4),
      Offset(size.width, size.height - 4),
      Paint()
        ..color = baseline
        ..strokeWidth = 1,
    );
    if (values.isEmpty) {
      // 没有真实序列时只保留轻量基线，不补造折线或末端状态点。
      return;
    }
    if (values.length == 1) {
      // 单个真实值不足以表达趋势，仅绘制当前数据点，避免暗示不存在的变化。
      canvas.drawCircle(
        Offset(size.width - 5, size.height / 2),
        3.5,
        Paint()..color = color,
      );
      return;
    }

    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final point = Offset(
        index / (values.length - 1) * (size.width - 5),
        size.height - 5 - values[index] * (size.height - 10),
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final last = values.last;
    canvas.drawCircle(
      Offset(
        size.width - 5,
        size.height - 5 - last * (size.height - 10),
      ),
      3.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniTrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.dashboard, required this.onTap});

  final DashboardSnapshot dashboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return HealthElevatedCard(
      key: const Key('overview-action-card'),
      onTap: onTap,
      color: const Color(0xFFFFF8ED),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          HealthIconBubble(
            icon: 'directions_walk',
            foreground: tokens.sage,
            background: tokens.sageSoft,
            size: 42,
            iconSize: 21,
            weight: 500,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                    children: <InlineSpan>[
                      const TextSpan(text: '现在起身活动 '),
                      TextSpan(
                        text: '3',
                        style: TextStyle(color: tokens.orange, fontSize: 24),
                      ),
                      const TextSpan(text: ' 分钟'),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '不用补运动量，先打断久坐就够了',
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.orange,
              shape: BoxShape.circle,
            ),
            child: const HealthVectorIcon(
              'arrow_forward',
              size: 22,
              weight: 500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(onPressed: onRetry, child: const Text('重新加载首页')),
    );
  }
}

class _MetricRowData {
  const _MetricRowData({
    required this.key,
    required this.dimension,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.caption,
    required this.color,
    required this.background,
    required this.values,
    required this.onTap,
  });

  final Key key;
  final DailyRhythmDimension dimension;
  final String icon;
  final String label;
  final String value;
  final String unit;
  final String status;
  final String caption;
  final Color color;
  final Color background;
  final List<double> values;
  final VoidCallback onTap;
}

void _openTrend(BuildContext context, WidgetRef ref, TrendTab tab) {
  ref.read(trendSelectedTabProvider.notifier).state = tab;
  context.go('/trends');
}

TrendTab _priorityTrend(DashboardSnapshot dashboard) {
  final scores = <TrendTab, int>{
    TrendTab.steps: dashboard.healthScore.stepScore,
    TrendTab.sedentary: dashboard.healthScore.sedentaryScore,
    TrendTab.screen: dashboard.healthScore.screenScore,
  };
  return scores.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
}

Future<void> _showStepDetailSheet(BuildContext context, WidgetRef ref) {
  final dashboard = ref.read(overviewDashboardSnapshotProvider);
  if (dashboard == null) {
    return Future<void>.value();
  }
  return showMetricDetailSheet(
    context,
    StepTrendDetailSheet(card: dashboard.stepCard),
  );
}

Future<void> _showSedentaryDetailSheet(BuildContext context, WidgetRef ref) {
  final dashboard = ref.read(overviewDashboardSnapshotProvider);
  if (dashboard == null) {
    return Future<void>.value();
  }
  return showMetricDetailSheet(
    context,
    SedentaryTimelineDetailSheet(card: dashboard.sedentaryCard),
  );
}

Future<void> _showScreenDetailSheet(BuildContext context, WidgetRef ref) {
  final dashboard = ref.read(overviewDashboardSnapshotProvider);
  if (dashboard == null) {
    return Future<void>.value();
  }
  return showMetricDetailSheet(
    context,
    ScreenUsageDetailSheet(card: dashboard.screenCard),
  );
}

Future<void> _showRhythmNodeSheet(
  BuildContext context,
  DailyRhythmNode node,
) {
  final tokens = context.healthTheme;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${_time(node.time)} · ${node.title}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(node.value, style: tokens.sectionTitleStyle),
              const SizedBox(height: 12),
              Text(node.reason, style: tokens.bodyStyle),
              const SizedBox(height: 12),
              Text(node.suggestion, style: tokens.bodyStyle),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showCurrentStateSheet(
  BuildContext context,
  DashboardSnapshot dashboard,
  DateTime time,
) {
  final tokens = context.healthTheme;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '当前状态 · ${_time(time)}',
                style: tokens.sectionTitleStyle,
              ),
              const SizedBox(height: 12),
              Text(_summary(dashboard), style: tokens.bodyStyle),
              const SizedBox(height: 12),
              Text(
                '综合活动、久坐、屏幕使用和环境摘要生成；数据不足的维度不会被当作正常值。',
                style: tokens.bodyStyle,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showSensingSheet(BuildContext context, WidgetRef ref) {
  final readyData = ref.read(overviewReadyDataStateProvider);
  final tokens = context.healthTheme;
  final missing = readyData?.missingDimensions ?? const <String>[];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('个人感知', style: tokens.sectionTitleStyle),
              const SizedBox(height: 12),
              Text(
                missing.isEmpty
                    ? '当前核心感知能力已参与分析。所有原始数据优先在本地处理。'
                    : '部分维度仍未参与分析：${missing.join('、')}。',
                style: tokens.bodyStyle,
              ),
              const SizedBox(height: 12),
              Text(
                '环境噪音只保存等级摘要，不保存原始音频。',
                style: tokens.bodyStyle,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showActionSheet(
  BuildContext context,
  DashboardSnapshot dashboard,
) {
  final tokens = context.healthTheme;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('起身活动 3 分钟', style: tokens.sectionTitleStyle),
              const SizedBox(height: 10),
              Text(
                '不要求补足运动量，只要站起来走动、伸展一下，打断连续久坐即可。',
                style: tokens.bodyStyle,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('很好，已经记下这次活动。')),
                    );
                  },
                  child: const Text('我已活动'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _summary(DashboardSnapshot dashboard) {
  if (!dashboard.hasRealData) {
    return '数据正在积累，稍后再回来看看';
  }
  if (dashboard.sedentaryCard.totalMinutes >= 120) {
    return '整体平稳，下午需要一次短暂活动';
  }
  if (dashboard.screenCard.totalMinutes >= 180) {
    return '状态不错，晚间可以少看一会屏幕';
  }
  return '整体平稳，继续保持现在的生活节奏';
}

String _hours(int minutes) {
  final hours = minutes / 60;
  return hours.toStringAsFixed(hours == hours.roundToDouble() ? 0 : 1);
}

String _screenCaption(DashboardScreenCard card) {
  switch (card.changeDirection) {
    case DashboardChangeDirection.up:
      return '比昨日多 ${card.yesterdayDeltaMinutes.abs()} 分钟';
    case DashboardChangeDirection.down:
      return '比昨日少 ${card.yesterdayDeltaMinutes.abs()} 分钟';
    case DashboardChangeDirection.steady:
      return '和昨日持平';
  }
}

String _time(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
