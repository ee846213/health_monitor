import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
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
    final asyncScreenState = ref.watch(overviewScreenStateProvider);

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: asyncScreenState.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) =>
              const Center(child: Text('加载首页失败')),
          data: (OverviewScreenState screenState) {
            switch (screenState) {
              case OverviewScreenState.permissionDenied:
                return const PermissionDeniedPage();
              case OverviewScreenState.dataInsufficient:
                return const DataInsufficientPage();
              case OverviewScreenState.ready:
                return const _OverviewDashboardBody();
            }
          },
        ),
      ),
    );
  }
}

class _OverviewDashboardBody extends ConsumerWidget {
  const _OverviewDashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const HealthStaggeredEntrance(
            index: 0,
            child: _PageHeader(),
          ),
          const SizedBox(height: 20),
          HealthStaggeredEntrance(
            index: 1,
            child: HealthScoreHero(
              onTap: () => context.push('/trends'),
            ),
          ),
          const _PreciseDetectionNoticeSection(),
          const _MissingDimensionsSection(),
          const SizedBox(height: 18),
          HealthStaggeredEntrance(
            index: 2,
            child: MetricCards(
              onStepTap: () => _showStepDetailSheet(context, ref),
              onSedentaryTap: () => _showSedentaryDetailSheet(context, ref),
              onScreenTap: () => _showScreenDetailSheet(context, ref),
            ),
          ),
          const SizedBox(height: 18),
          const HealthStaggeredEntrance(
            index: 3,
            child: EnvironmentSnapshotBar(),
          ),
          const SizedBox(height: 18),
          const HealthStaggeredEntrance(
            index: 4,
            child: AiSuggestionBubble(),
          ),
        ],
      ),
    );
  }
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

class _PreciseDetectionNoticeSection extends ConsumerWidget {
  const _PreciseDetectionNoticeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(overviewPreciseDetectionNoticeTextProvider);
    return AnimatedSize(
      duration: context.motionDuration(context.healthMotion.base),
      curve: context.healthMotion.standardCurve,
      alignment: Alignment.topCenter,
      child: message == null || message.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: <Widget>[
                const SizedBox(height: 14),
                _InfoBanner(message: message),
              ],
            ),
    );
  }
}

class _MissingDimensionsSection extends ConsumerWidget {
  const _MissingDimensionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(overviewMissingDimensionsTextProvider);
    return AnimatedSize(
      duration: context.motionDuration(context.healthMotion.base),
      curve: context.healthMotion.standardCurve,
      alignment: Alignment.topCenter,
      child: message == null || message.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: <Widget>[
                const SizedBox(height: 14),
                _InfoBanner(message: message),
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
