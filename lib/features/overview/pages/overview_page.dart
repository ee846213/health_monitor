import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/app_icons.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/widgets/metric_detail_sheets.dart';
import 'package:health_monitor/features/state_pages/state_pages.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

const Color _surface = Color(0xFFFFFDF8);
const Color _surfaceSoft = Color(0xFFF0ECE4);
const Color _sageSoft = Color(0xFFE6EEE8);
const Color _sageDeep = Color(0xFF5C7768);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);
const Color _line = Color(0xFFDDD8CF);
const Color _warmSand = Color(0xFFF4E8DA);
const Color _mistBlue = Color(0xFFE0EBEE);

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
              const Center(child: Text('加载首页状态失败')),
          data: (OverviewViewModel viewModel) {
            switch (viewModel.screenState) {
              case OverviewScreenState.permissionDenied:
                return const PermissionDeniedPage();
              case OverviewScreenState.dataInsufficient:
                return const DataInsufficientPage();
              case OverviewScreenState.ready:
                return _OverviewBody(viewModel: viewModel);
            }
          },
        ),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.viewModel});

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _PageHeader(),
          const SizedBox(height: 24),
          _TodayStatusCard(viewModel: viewModel),
          if (viewModel.hasPreciseDetectionNotice) ...<Widget>[
            const SizedBox(height: 12),
            _InfoBanner(message: viewModel.preciseDetectionNotice!),
          ],
          if (viewModel.hasMissingDimensions) ...<Widget>[
            const SizedBox(height: 12),
            _MissingBanner(viewModel: viewModel),
          ],
          const SizedBox(height: 24),
          _VerdictCard(verdicts: viewModel.secondaryVerdicts),
          const SizedBox(height: 24),
          _ReminderCard(reminders: viewModel.reminders),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '今日概览',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '这里展示规则引擎根据真实采集样本得出的今日重点。',
              style:
                  TextStyle(fontSize: 14, color: _textSecondary, height: 1.5),
            ),
          ],
        ),
        _TagChip(text: '我的感知'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
        ),
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({required this.viewModel});

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '今日状态',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.resolvedTodayStatusLabel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            viewModel.resolvedTodayStatusDetail,
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _ConclusionBox(viewModel: viewModel),
          const SizedBox(height: 10),
          _MetricsRow(
            metrics: viewModel.metrics,
            onStepTap: () => showStepDetailSheet(context),
            onSedentaryTap: () => showSedentaryDetailSheet(context),
            onScreenTap: () => showScreenDetailSheet(context),
          ),
        ],
      ),
    );
  }
}

class _ConclusionBox extends StatelessWidget {
  const _ConclusionBox({required this.viewModel});

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final tags = <String>[
      if (viewModel.metrics.sedentaryMinutes > 0)
        '久坐 ${viewModel.metrics.sedentaryMinutes} 分钟',
      if (viewModel.metrics.screenMinutes > 0)
        '看屏 ${viewModel.metrics.screenMinutes} 分钟',
      if (viewModel.metrics.outdoorMinutes > 0)
        '户外 ${viewModel.metrics.outdoorMinutes} 分钟',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '结论先看',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _sageDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.resolvedConclusionLabel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _sageDeep,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.resolvedConclusionDetail,
            style: const TextStyle(
              fontSize: 13,
              color: _sageDeep,
              height: 1.5,
            ),
          ),
          if (tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((String tag) => _MiniTag(text: tag))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textSecondary,
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.metrics,
    required this.onStepTap,
    required this.onSedentaryTap,
    required this.onScreenTap,
  });

  final OverviewMetricSnapshot metrics;
  final VoidCallback onStepTap;
  final VoidCallback onSedentaryTap;
  final VoidCallback onScreenTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricCard(
            name: '步数',
            value: '${metrics.stepCount}',
            unit: '步',
            status: metrics.stepCount >= 5000 ? '达标' : '偏少',
            backgroundColor: _surface,
            onTap: onStepTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            name: '久坐',
            value: '${metrics.sedentaryMinutes}',
            unit: '分钟',
            status: metrics.sedentaryMinutes >= 120 ? '偏高' : '可控',
            backgroundColor: _warmSand,
            onTap: onSedentaryTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            name: '看屏',
            value: '${metrics.screenMinutes}',
            unit: '分钟',
            status: metrics.screenMinutes >= 240 ? '偏多' : '正常',
            backgroundColor: _mistBlue,
            onTap: onScreenTap,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.backgroundColor,
    this.onTap,
  });

  final String name;
  final String value;
  final String unit;
  final String status;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingBanner extends StatelessWidget {
  const _MissingBanner({required this.viewModel});

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0x14D8A56E),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Text(
        '部分维度暂时没有采集到样本：${viewModel.missingDimensions.join('、')}',
        style: const TextStyle(fontSize: 12, color: Color(0xFFD8A56E)),
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
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0x140E6C80),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: Color(0xFF0E6C80)),
      ),
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.verdicts});

  final List<RuleVerdict> verdicts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '更多观察',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (verdicts.isEmpty)
            const Text(
              '当前只有一条核心结论，等更多样本进入后会看到更细的观察。',
              style:
                  TextStyle(fontSize: 13, color: _textSecondary, height: 1.5),
            )
          else
            ...verdicts.map(
              (RuleVerdict verdict) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ActionRow(
                  title: verdict.summary,
                  subtitle: verdict.detail,
                  actionLabel: '查看简报',
                  onTap: () => context.go('/briefing'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminders});

  final List<ReminderRecord> reminders;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '今日建议',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (reminders.isEmpty)
            const Text(
              '今天还没有触发提醒，继续正常使用手机，更多样本会自动进入规则计算。',
              style:
                  TextStyle(fontSize: 13, color: _textSecondary, height: 1.5),
            )
          else
            ...reminders.map(
              (ReminderRecord reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReminderRow(reminder: reminder),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.reminder});

  final ReminderRecord reminder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/reminders/explanation', extra: reminder),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _sageSoft,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                AppIcons.bellRing,
                size: 18,
                color: _sageDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reminder.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '原因',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
