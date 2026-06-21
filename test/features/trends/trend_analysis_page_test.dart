import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/trends/pages/trend_analysis_page.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';

void main() {
  testWidgets('趋势页默认展示步数并能切换到久坐', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: <Override>[
        trendAnalysisViewModelProvider.overrideWith((Ref ref) async {
          final selectedTab = ref.watch(trendSelectedTabProvider);
          return _buildTrendSnapshot(selectedTab);
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendAnalysisPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('近 7 天步数趋势'), findsOneWidget);

    await tester.tap(find.text('姿势'));
    await tester.pumpAndSettle();

    expect(find.text('近 7 天久坐趋势'), findsOneWidget);
  });

  testWidgets('趋势数据刷新时保留当前卡片，不回退为整页加载', (
    WidgetTester tester,
  ) async {
    var completer = Completer<TrendSnapshot>();
    final container = ProviderContainer(
      overrides: <Override>[
        trendAnalysisViewModelProvider.overrideWith(
          (Ref ref) => completer.future,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendAnalysisPage()),
      ),
    );

    completer.complete(_buildTrendSnapshot(TrendTab.steps));
    await tester.pumpAndSettle();
    expect(find.text('近 7 天步数趋势'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    completer = Completer<TrendSnapshot>();
    container.invalidate(trendAnalysisViewModelProvider);
    await tester.pump();

    expect(find.text('近 7 天步数趋势'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    completer.complete(
      TrendSnapshot(
        generatedAt: DateTime(2026, 6, 18, 9),
        selectedTab: TrendTab.steps,
        title: '更新后的步数趋势',
        unitLabel: '步',
        points: const <TrendPoint>[
          TrendPoint(label: '6/18', value: 7200),
        ],
        insightText: '今天的活动节奏更稳定。',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('更新后的步数趋势'), findsOneWidget);
    expect(find.text('今天的活动节奏更稳定。'), findsOneWidget);
  });

  testWidgets('环境趋势缺失日期显示占位而不是 100 分', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: <Override>[
        trendAnalysisViewModelProvider.overrideWith((Ref ref) async {
          return TrendSnapshot(
            generatedAt: DateTime(2026, 6, 18, 9),
            selectedTab: TrendTab.environment,
            title: '近 7 天环境趋势',
            unitLabel: '分',
            points: const <TrendPoint>[
              TrendPoint(label: '6/12', value: 0, hasData: false),
              TrendPoint(label: '6/13', value: 82),
            ],
            insightText: '仅展示已采集日期。',
          );
        }),
        trendSelectedTabProvider.overrideWith((Ref ref) {
          return TrendTab.environment;
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendAnalysisPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('--'), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    expect(find.text('100'), findsNothing);
  });
}

TrendSnapshot _buildTrendSnapshot(TrendTab selectedTab) {
  switch (selectedTab) {
    case TrendTab.steps:
      return TrendSnapshot(
        generatedAt: DateTime(2026, 6, 16, 9),
        selectedTab: selectedTab,
        title: '近 7 天步数趋势',
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
        insightText: '过去一周你有 2 天步数超过 6000。',
      );
    case TrendTab.sedentary:
      return TrendSnapshot(
        generatedAt: DateTime(2026, 6, 16, 9),
        selectedTab: selectedTab,
        title: '近 7 天久坐趋势',
        unitLabel: '分钟',
        points: const <TrendPoint>[
          TrendPoint(label: '6/10', value: 98),
          TrendPoint(label: '6/11', value: 110),
          TrendPoint(label: '6/12', value: 125),
          TrendPoint(label: '6/13', value: 104),
          TrendPoint(label: '6/14', value: 132),
          TrendPoint(label: '6/15', value: 118),
          TrendPoint(label: '6/16', value: 96),
        ],
        insightText: '最近两天久坐时长开始回落。',
      );
    case TrendTab.screen:
      return TrendSnapshot(
        generatedAt: DateTime(2026, 6, 16, 9),
        selectedTab: selectedTab,
        title: '近 7 天屏幕趋势',
        unitLabel: '分钟',
        points: const <TrendPoint>[],
        insightText: '最近一周亮屏时长总体平稳。',
      );
    case TrendTab.environment:
      return TrendSnapshot(
        generatedAt: DateTime(2026, 6, 16, 9),
        selectedTab: selectedTab,
        title: '近 7 天环境趋势',
        unitLabel: '分',
        points: const <TrendPoint>[],
        insightText: '环境状态基本稳定。',
      );
  }
}
