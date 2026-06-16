import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/widgets/ai_suggestion_bubble.dart';
import 'package:health_monitor/features/overview/widgets/environment_snapshot_bar.dart';
import 'package:health_monitor/features/overview/widgets/health_score_hero.dart';
import 'package:health_monitor/features/overview/widgets/metric_cards.dart';
import 'package:health_monitor/features/overview/widgets/metric_detail_sheets.dart';
import 'package:health_monitor/features/state_pages/state_pages.dart';

const Color _surface = Color(0xFFFFFBF5);
const Color _surfaceSoft = Color(0xFFF6F0E7);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _line = Color(0xFFDDD8CF);

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncViewModel = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: asyncViewModel.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) =>
              const Center(child: Text('加载首页失败')),
          data: (OverviewDashboardViewModel viewModel) {
            switch (viewModel.screenState) {
              case OverviewScreenState.permissionDenied:
                return const PermissionDeniedPage();
              case OverviewScreenState.dataInsufficient:
                return const DataInsufficientPage();
              case OverviewScreenState.ready:
                return _OverviewDashboardBody(viewModel: viewModel);
            }
          },
        ),
      ),
    );
  }
}

class _OverviewDashboardBody extends StatelessWidget {
  const _OverviewDashboardBody({required this.viewModel});

  final OverviewDashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _PageHeader(),
          const SizedBox(height: 20),
          HealthScoreHero(
            snapshot: viewModel.dashboard,
            onTap: () => context.push('/trends'),
          ),
          if (viewModel.hasPreciseDetectionNotice) ...<Widget>[
            const SizedBox(height: 14),
            _InfoBanner(message: viewModel.preciseDetectionNotice!),
          ],
          if (viewModel.hasMissingDimensions) ...<Widget>[
            const SizedBox(height: 14),
            _InfoBanner(
              message: '部分维度仍在采集中：${viewModel.missingDimensions.join('、')}',
            ),
          ],
          const SizedBox(height: 18),
          MetricCards(
            snapshot: viewModel.dashboard,
            onStepTap: () => _showDetailSheet(
              context,
              StepTrendDetailSheet(card: viewModel.dashboard.stepCard),
            ),
            onSedentaryTap: () => _showDetailSheet(
              context,
              SedentaryTimelineDetailSheet(
                card: viewModel.dashboard.sedentaryCard,
              ),
            ),
            onScreenTap: () => _showDetailSheet(
              context,
              ScreenUsageDetailSheet(card: viewModel.dashboard.screenCard),
            ),
          ),
          const SizedBox(height: 18),
          EnvironmentSnapshotBar(
              snapshot: viewModel.dashboard.environmentSnapshot),
          const SizedBox(height: 18),
          AiSuggestionBubble(bubble: viewModel.dashboard.dailyAdviceBubble),
        ],
      ),
    );
  }
}

Future<void> _showDetailSheet(BuildContext context, Widget child) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return child;
    },
  );
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '今日仪表盘',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '先看整体健康分，再决定今天要优先调整哪一项。',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          height: 1.6,
          color: _textSecondary,
        ),
      ),
    );
  }
}
