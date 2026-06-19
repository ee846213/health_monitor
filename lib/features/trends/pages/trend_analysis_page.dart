import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/features/trends/widgets/trend_chart_panel.dart';
import 'package:health_monitor/features/trends/widgets/trend_insight_panel.dart';
import 'package:health_monitor/features/trends/widgets/trend_tab_bar.dart';

const Color _pageSurface = Color(0xFFFFFBF5);
const Color _pageText = Color(0xFF1F2320);
const Color _pageMuted = Color(0xFF5D645B);

class TrendAnalysisPage extends ConsumerWidget {
  const TrendAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(trendSelectedTabProvider);

    return Scaffold(
      backgroundColor: _pageSurface,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Hero(
              tag: 'health-score-hero',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF3EA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5E775F)),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    size: 19,
                    color: Color(0xFF5E775F),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '趋势分析',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _pageText,
              ),
            ),
          ],
        ),
        backgroundColor: _pageSurface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const HealthStaggeredEntrance(
                index: 0,
                child: Text(
                  '近 7 天趋势会默认从步数开始，你也可以切换查看久坐、屏幕与环境健康分。',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: _pageMuted,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HealthStaggeredEntrance(
                index: 1,
                child: TrendTabBar(
                  selectedTab: selectedTab,
                  onSelected: (TrendTab tab) {
                    ref.read(trendSelectedTabProvider.notifier).state = tab;
                  },
                ),
              ),
              const SizedBox(height: 18),
              const HealthStaggeredEntrance(
                index: 2,
                child: _TrendChartSection(),
              ),
              const SizedBox(height: 18),
              const HealthStaggeredEntrance(
                index: 3,
                child: _TrendInsightSection(),
              ),
            ],
          ),
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
      loading: () => const _CardLoadingPlaceholder(height: 290),
      error: (Object error, StackTrace _) => const _CardErrorPlaceholder(
        message: '趋势图加载失败',
        height: 160,
      ),
      data: (TrendSnapshot value) => HealthAnimatedSwitcher(
        childKey: ValueKey<TrendTab>(value.selectedTab),
        child: TrendChartPanel(snapshot: value),
      ),
    );
  }
}

class _TrendInsightSection extends ConsumerWidget {
  const _TrendInsightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(trendInsightTextProvider);
    return insight.when(
      skipLoadingOnRefresh: true,
      loading: () => const _CardLoadingPlaceholder(height: 120),
      error: (Object error, StackTrace _) => const _CardErrorPlaceholder(
        message: '洞察加载失败',
        height: 120,
      ),
      data: (String text) => HealthAnimatedSwitcher(
        childKey: ValueKey<String>(text),
        duration: const Duration(milliseconds: 320),
        child: TrendInsightPanel(text: text),
      ),
    );
  }
}

class _CardLoadingPlaceholder extends StatelessWidget {
  const _CardLoadingPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDAD4CA)),
      ),
      child: const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _CardErrorPlaceholder extends StatelessWidget {
  const _CardErrorPlaceholder({
    required this.message,
    required this.height,
  });

  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDAD4CA)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: _pageMuted),
      ),
    );
  }
}
