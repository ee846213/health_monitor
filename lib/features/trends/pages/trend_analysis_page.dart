import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final asyncSnapshot = ref.watch(trendAnalysisViewModelProvider);

    return Scaffold(
      backgroundColor: _pageSurface,
      appBar: AppBar(
        title: const Text(
          '趋势分析',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _pageText,
          ),
        ),
        backgroundColor: _pageSurface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: asyncSnapshot.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => const Center(
            child: Text(
              '趋势页加载失败',
              style: TextStyle(color: _pageMuted),
            ),
          ),
          data: (TrendSnapshot snapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '近 7 天趋势会默认从步数开始，你也可以切换查看久坐、屏幕与环境健康分。',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: _pageMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TrendTabBar(
                    selectedTab: selectedTab,
                    onSelected: (TrendTab tab) {
                      ref.read(trendSelectedTabProvider.notifier).state = tab;
                    },
                  ),
                  const SizedBox(height: 18),
                  TrendChartPanel(snapshot: snapshot),
                  const SizedBox(height: 18),
                  TrendInsightPanel(text: snapshot.insightText),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
