import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/features/trends/widgets/trend_chart_panel.dart';
import 'package:health_monitor/features/trends/widgets/trend_tab_bar.dart';

class TrendAnalysisPage extends ConsumerStatefulWidget {
  const TrendAnalysisPage({super.key});

  @override
  ConsumerState<TrendAnalysisPage> createState() => _TrendAnalysisPageState();
}

class _TrendAnalysisPageState extends ConsumerState<TrendAnalysisPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    PrimaryTabScrollRegistry.register(1, _controller);
  }

  @override
  void dispose() {
    PrimaryTabScrollRegistry.unregister(1, _controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(trendSelectedTabProvider);
    final selectedRange = ref.watch(trendSelectedRangeProvider);
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 112),
          children: <Widget>[
            HealthStaggeredEntrance(
              index: 0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '趋势分析',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: context.healthTheme.textPrimary,
                      ),
                    ),
                  ),
                  HealthIconBubble(
                    icon: 'show_chart',
                    foreground: context.healthTheme.sage,
                    background: context.healthTheme.sageSoft,
                    size: 40,
                    iconSize: 21,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HealthStaggeredEntrance(
              index: 1,
              child: HealthSegmentedControl<TrendRange>(
                values: TrendRange.values,
                selected: selectedRange,
                labelBuilder: (range) => range.label,
                onSelected: (range) {
                  ref
                      .read(trendRangeForTabProvider(selectedTab).notifier)
                      .state = range;
                },
              ),
            ),
            const SizedBox(height: 16),
            HealthStaggeredEntrance(
              index: 2,
              child: TrendTabBar(
                selectedTab: selectedTab,
                onSelected: (tab) {
                  ref.read(trendSelectedTabProvider.notifier).state = tab;
                },
              ),
            ),
            const SizedBox(height: 18),
            const HealthStaggeredEntrance(
              index: 3,
              child: _TrendChartSection(),
            ),
            const SizedBox(height: 16),
            const HealthStaggeredEntrance(
              index: 4,
              child: _TrendInsightSection(),
            ),
            const SizedBox(height: 16),
            const HealthStaggeredEntrance(
              index: 5,
              child: _DailyComparisonSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChartSection extends ConsumerWidget {
  const _TrendChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(trendChartSnapshotProvider);
    return snapshot.when(
      skipLoadingOnRefresh: true,
      loading: () => const _CardLoadingPlaceholder(height: 330),
      error: (error, stackTrace) => _CardErrorPlaceholder(
        message: '趋势数据暂时无法加载',
        onRetry: () => ref.invalidate(trendAnalysisViewModelProvider),
      ),
      data: (value) => HealthAnimatedSwitcher(
        childKey: ValueKey<Object>((value.selectedTab, value.range)),
        child: TrendChartPanel(snapshot: value),
      ),
    );
  }
}

class _TrendInsightSection extends ConsumerWidget {
  const _TrendInsightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(trendSnapshotStateProvider);
    return snapshot.when(
      skipLoadingOnRefresh: true,
      loading: () => const _CardLoadingPlaceholder(height: 138),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (value) => HealthAnimatedSwitcher(
        childKey: ValueKey<String>(value.insightText),
        child: HealthElevatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  HealthIconBubble(
                    icon: 'info',
                    foreground: context.healthTheme.sage,
                    background: context.healthTheme.sageSoft,
                  ),
                  const SizedBox(width: 10),
                  Text('本期洞察', style: context.healthTheme.sectionTitleStyle),
                ],
              ),
              const SizedBox(height: 12),
              Text(value.insightText, style: context.healthTheme.bodyStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyComparisonSection extends ConsumerStatefulWidget {
  const _DailyComparisonSection();

  @override
  ConsumerState<_DailyComparisonSection> createState() =>
      _DailyComparisonSectionState();
}

class _DailyComparisonSectionState
    extends ConsumerState<_DailyComparisonSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(trendSnapshotStateProvider).valueOrNull;
    if (snapshot == null || snapshot.points.isEmpty) {
      return const SizedBox.shrink();
    }
    final selected = _selectedIndex ?? snapshot.defaultSelectedIndex ?? 0;
    return HealthElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('每日对比', style: context.healthTheme.sectionTitleStyle),
          const SizedBox(height: 6),
          Text(
            snapshot.points[selected].hasData
                ? '${snapshot.points[selected].label} · ${snapshot.points[selected].value.round()} ${snapshot.unitLabel}'
                : '${snapshot.points[selected].label} · 数据暂缺',
            style: context.healthTheme.dataStyle.copyWith(
              fontSize: 11,
              color: context.healthTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 86,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(snapshot.points.length, (index) {
                final point = snapshot.points[index];
                final max = snapshot.points
                    .where((item) => item.hasData)
                    .fold<num>(
                        1,
                        (value, item) =>
                            item.value > value ? item.value : value);
                final active = index == selected;
                return Expanded(
                  child: Semantics(
                    button: true,
                    label: '${point.label} ${point.value}${snapshot.unitLabel}',
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: snapshot.points.length > 12 ? 7 : 18,
                          height:
                              point.hasData ? 18 + 58 * point.value / max : 4,
                          decoration: BoxDecoration(
                            color: active
                                ? context.healthTheme.sage
                                : context.healthTheme.sageSoft,
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLoadingPlaceholder extends StatelessWidget {
  const _CardLoadingPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return HealthElevatedCard(
      child: SizedBox(
        height: height,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.healthTheme.sage,
          ),
        ),
      ),
    );
  }
}

class _CardErrorPlaceholder extends StatelessWidget {
  const _CardErrorPlaceholder({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HealthElevatedCard(
      child: Column(
        children: <Widget>[
          const HealthVectorIcon('info', size: 24),
          const SizedBox(height: 10),
          Text(message, style: context.healthTheme.bodyStyle),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
