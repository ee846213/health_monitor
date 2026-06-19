import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/theme.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/overview/widgets/health_score_hero.dart';
import 'package:health_monitor/features/trends/widgets/trend_chart_panel.dart';
import 'package:health_monitor/features/trends/widgets/trend_tab_bar.dart';

void main() {
  testWidgets('健康分圆环具有开始态、中间态和结束态', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewHealthScoreProgressProvider.overrideWithValue(0.8),
          overviewHealthScoreValueProvider.overrideWithValue('80'),
          overviewHealthScoreSummaryProvider.overrideWithValue('状态稳定'),
          overviewHealthScoreStepPillProvider.overrideWithValue('步数 80'),
          overviewHealthScoreSedentaryPillProvider.overrideWithValue('久坐 80'),
          overviewHealthScoreScreenPillProvider.overrideWithValue('屏幕 80'),
        ],
        child: _TestApp(child: HealthScoreHero(onTap: () {})),
      ),
    );

    expect(_scoreRingProgress(tester), 0);
    await tester.pump(const Duration(milliseconds: 325));
    expect(_scoreRingProgress(tester), inExclusiveRange(0, 0.8));
    await tester.pumpAndSettle();
    expect(_scoreRingProgress(tester), closeTo(0.8, 0.001));
  });

  testWidgets('趋势图具有开始态、中间态和结束态', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: TrendChartPanel(snapshot: _snapshot),
      ),
    );

    expect(_trendProgress(tester), 0);
    await tester.pump(const Duration(milliseconds: 250));
    expect(_trendProgress(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_trendProgress(tester), 1);
  });

  testWidgets('减少动态效果时圆环与趋势图直接显示最终状态', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewHealthScoreProgressProvider.overrideWithValue(0.8),
          overviewHealthScoreValueProvider.overrideWithValue('80'),
          overviewHealthScoreSummaryProvider.overrideWithValue('状态稳定'),
          overviewHealthScoreStepPillProvider.overrideWithValue('步数 80'),
          overviewHealthScoreSedentaryPillProvider.overrideWithValue('久坐 80'),
          overviewHealthScoreScreenPillProvider.overrideWithValue('屏幕 80'),
        ],
        child: _TestApp(
          disableAnimations: true,
          child: Column(
            children: <Widget>[
              const HealthScoreHero(),
              TrendChartPanel(snapshot: _snapshot),
            ],
          ),
        ),
      ),
    );

    expect(_scoreRingProgress(tester), closeTo(0.8, 0.001));
    expect(_trendProgress(tester), 1);
  });

  testWidgets('趋势 Tab 的选中胶囊会平滑移动', (tester) async {
    await tester.pumpWidget(const _TestApp(child: _TrendTabHarness()));

    AnimatedAlign align = tester.widget(find.byType(AnimatedAlign));
    expect((align.alignment as Alignment).x, -1);

    await tester.tap(find.byKey(const ValueKey<String>('trend-tab-sedentary')));
    await tester.pump();

    align = tester.widget(find.byType(AnimatedAlign));
    expect((align.alignment as Alignment).x, closeTo(-1 / 3, 0.001));
    expect(align.duration, const Duration(milliseconds: 220));
  });
}

double _scoreRingProgress(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    find.byKey(const Key('health-score-ring')),
  );
  final dynamic painter = customPaint.painter;
  return painter.progress as double;
}

double _trendProgress(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    find.byKey(const Key('trend-chart-canvas')),
  );
  final dynamic painter = customPaint.painter;
  return painter.progress as double;
}

final TrendSnapshot _snapshot = TrendSnapshot(
  generatedAt: DateTime(2026, 6, 20),
  selectedTab: TrendTab.steps,
  title: '近 7 天步数趋势',
  unitLabel: '步',
  points: const <TrendPoint>[
    TrendPoint(label: '周一', value: 3000),
    TrendPoint(label: '周二', value: 6000),
    TrendPoint(label: '周三', value: 5000),
  ],
  insightText: '步数正在变得稳定。',
);

class _TrendTabHarness extends StatefulWidget {
  const _TrendTabHarness();

  @override
  State<_TrendTabHarness> createState() => _TrendTabHarnessState();
}

class _TrendTabHarnessState extends State<_TrendTabHarness> {
  TrendTab selectedTab = TrendTab.steps;

  @override
  Widget build(BuildContext context) {
    return TrendTabBar(
      selectedTab: selectedTab,
      onSelected: (TrendTab value) {
        setState(() => selectedTab = value);
      },
    );
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.disableAnimations = false,
  });

  final Widget child;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(disableAnimations: disableAnimations),
          child: child!,
        );
      },
      home: Scaffold(body: child),
    );
  }
}
