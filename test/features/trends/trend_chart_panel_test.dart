import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/trends/widgets/trend_chart_panel.dart';

void main() {
  testWidgets('近 30 天趋势图可左右自由滑动', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrendChartPanel(snapshot: _thirtyDaySnapshot()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const Key('trend-chart-scroll-view')),
    );
    expect(scrollView.scrollDirection, Axis.horizontal);
    expect(scrollView.physics, isA<BouncingScrollPhysics>());
    expect(find.byKey(const Key('trend-line-chart')), findsOneWidget);
    expect(_trendCurveSmoothness(tester), closeTo(0.16, 0.001));

    final controller = scrollView.controller!;
    expect(controller.offset, 0);

    await tester.drag(
      find.byKey(const Key('trend-chart-scroll-view')),
      const Offset(-180, 0),
    );
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
  });

  testWidgets('点击标签会更新卡片头部数值', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrendChartPanel(snapshot: _sevenDaySnapshot()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4860 步'), findsOneWidget);
    await tester.tap(find.text('6/10'));
    await tester.pumpAndSettle();
    expect(find.text('4200 步'), findsOneWidget);
    expect(find.text('6/10'), findsWidgets);
  });

  testWidgets('趋势点变化时会重新播放折线生长动画', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrendChartPanel(snapshot: _sevenDaySnapshot()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_visibleTrendProgress(tester, _sevenDaySnapshot()), 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrendChartPanel(snapshot: _changedSevenDaySnapshot()),
        ),
      ),
    );
    await tester.pump();

    expect(_visibleTrendProgress(tester, _changedSevenDaySnapshot()), 0);

    await tester.pumpAndSettle();

    expect(_visibleTrendProgress(tester, _changedSevenDaySnapshot()), 1);
  });
}

double _trendCurveSmoothness(WidgetTester tester) {
  final lineChart = tester.widget<LineChart>(
    find.byKey(const Key('trend-line-chart')),
  );
  return lineChart.data.lineBarsData.single.curveSmoothness;
}

TrendSnapshot _thirtyDaySnapshot() {
  final points = List<TrendPoint>.generate(30, (int index) {
    final day = index + 1;
    return TrendPoint(
      label: '5/$day',
      value: 3000 + index * 80,
    );
  });
  return TrendSnapshot(
    generatedAt: DateTime(2026, 6, 30),
    selectedTab: TrendTab.steps,
    range: TrendRange.days30,
    title: '近 30 天活动趋势',
    unitLabel: '步',
    points: points,
    insightText: '近 30 天活动趋势稳定。',
    defaultSelectedIndex: 0,
  );
}

double _visibleTrendProgress(WidgetTester tester, TrendSnapshot snapshot) {
  final lineChart = tester.widget<LineChart>(
    find.byKey(const Key('trend-line-chart')),
  );
  final spots = lineChart.data.lineBarsData.single.spots;
  if (spots.isEmpty) {
    return 0;
  }
  final maxX = snapshot.points.length - 1;
  if (maxX <= 0) {
    return 1;
  }
  return (spots.last.x / maxX).clamp(0.0, 1.0).toDouble();
}

TrendSnapshot _sevenDaySnapshot() {
  return TrendSnapshot(
    generatedAt: DateTime(2026, 6, 16, 9),
    selectedTab: TrendTab.steps,
    range: TrendRange.days7,
    title: '近 7 天活动趋势',
    unitLabel: '步',
    points: const <TrendPoint>[
      TrendPoint(label: '6/10', value: 4200),
      TrendPoint(label: '6/11', value: 5100),
      TrendPoint(label: '6/12', value: 6100),
      TrendPoint(label: '6/13', value: 5900),
      TrendPoint(label: '6/14', value: 6400),
      TrendPoint(label: '6/15', value: 5600),
      TrendPoint(label: '6/16', value: 4860),
    ],
    insightText: '趋势稳定。',
    defaultSelectedIndex: 6,
  );
}

TrendSnapshot _changedSevenDaySnapshot() {
  return TrendSnapshot(
    generatedAt: DateTime(2026, 6, 16, 10),
    selectedTab: TrendTab.steps,
    range: TrendRange.days7,
    title: '近 7 天活动趋势',
    unitLabel: '步',
    points: const <TrendPoint>[
      TrendPoint(label: '6/10', value: 4500),
      TrendPoint(label: '6/11', value: 5300),
      TrendPoint(label: '6/12', value: 6300),
      TrendPoint(label: '6/13', value: 6100),
      TrendPoint(label: '6/14', value: 6600),
      TrendPoint(label: '6/15', value: 5900),
      TrendPoint(label: '6/16', value: 5200),
    ],
    insightText: '趋势稳定。',
    defaultSelectedIndex: 6,
  );
}
