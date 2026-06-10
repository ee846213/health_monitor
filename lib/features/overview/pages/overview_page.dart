import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

/// Pencil 设计中的图标映射。
IconData _dimensionIcon(String dimension) {
  switch (dimension) {
    case 'activity': return Icons.directions_walk_rounded;
    case 'posture': return Icons.accessibility_new_rounded;
    case 'usage': return Icons.mouse_rounded;
    case 'environment': return Icons.volume_up_rounded;
    default: return Icons.circle_outlined;
  }
}

String _dimensionLabel(String dimension) {
  switch (dimension) {
    case 'activity': return '活动';
    case 'posture': return '姿势';
    case 'usage': return '数字生活';
    case 'environment': return '环境';
    default: return dimension;
  }
}

Color _levelColor(String level, HealthMonitorTheme tokens) {
  switch (level) {
    case 'concern': return tokens.verdictConcernColor;
    case 'warning': return tokens.verdictWarningColor;
    default: return tokens.verdictNormalColor;
  }
}

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncVm = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: asyncVm.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败', style: tokens.bodyStyle)),
          data: (vm) => _OverviewBody(vm: vm, tokens: tokens, theme: theme),
        ),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.vm, required this.tokens, required this.theme});
  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(tokens.spacingXl, 44, tokens.spacingXl, tokens.spacingXl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('今日概览', style: theme.textTheme.headlineMedium),
        SizedBox(height: tokens.spacingXl),
        // 核心结论卡片
        _PrimaryCard(vm: vm, tokens: tokens, theme: theme),
        if (vm.hasMissingDimensions) ...[
          SizedBox(height: tokens.spacingSm),
          _MissingBanner(vm: vm, tokens: tokens),
        ],
        SizedBox(height: tokens.spacingXl),
        // 维度卡片列表
        if (vm.verdicts.isEmpty)
          _EmptyHint(tokens: tokens)
        else
          for (final v in vm.verdicts)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: _DimensionCard(verdict: v, tokens: tokens, theme: theme),
            ),
      ]),
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  const _PrimaryCard({required this.vm, required this.tokens, required this.theme});
  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final level = vm.verdicts.isNotEmpty ? vm.verdicts.first.level : 'normal';
    final color = _levelColor(level, tokens);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingXl),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.sunny, size: 22, color: color),
          SizedBox(width: tokens.spacingSm),
          Text(vm.summaryLabel, style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
        ]),
        SizedBox(height: tokens.spacingSm),
        Text(vm.summaryDetail, style: theme.textTheme.bodyMedium),
      ]),
    );
  }
}

class _MissingBanner extends StatelessWidget {
  const _MissingBanner({required this.vm, required this.tokens});
  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        color: tokens.verdictWarningColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, size: 16, color: tokens.verdictWarningColor),
        SizedBox(width: tokens.spacingSm),
        Expanded(
          child: Text(
            '部分数据维度暂不可用（${vm.missingDimensions.map((d) => _dimensionLabel(d)).join('、')}）',
            style: tokens.bodyStyle.copyWith(color: tokens.verdictWarningColor, fontSize: 12),
          ),
        ),
      ]),
    );
  }
}

class _DimensionCard extends StatelessWidget {
  const _DimensionCard({required this.verdict, required this.tokens, required this.theme});
  final RuleVerdict verdict;
  final HealthMonitorTheme tokens;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(verdict.level, tokens);

    return Container(
      padding: EdgeInsets.all(tokens.spacingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(children: [
        Icon(_dimensionIcon(verdict.dimension), size: 24, color: color, semanticLabel: _dimensionLabel(verdict.dimension)),
        SizedBox(width: tokens.spacingMd),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_dimensionLabel(verdict.dimension), style: tokens.sectionTitleStyle),
            SizedBox(height: 2),
            Text(verdict.summary, style: tokens.bodyStyle),
          ]),
        ),
        Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
      ]),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.tokens});
  final HealthMonitorTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacingXxl),
        child: Text('暂无评估数据，持续使用后自动生成。', style: tokens.bodyStyle),
      ),
    );
  }
}