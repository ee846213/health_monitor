import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

/// 首页 —— 今日健康概览。
///
/// 消费 [overviewViewModelProvider]，展示：
/// - 核心结论卡片（取最高优先级结论）
/// - 各维度摘要列表
/// - 数据不足 / 权限不足时的降级展示
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncViewModel = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: asyncViewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('加载失败: $err', style: tokens.bodyStyle),
          ),
          data: (vm) => _OverviewContent(vm: vm, tokens: tokens, theme: theme),
        ),
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.vm,
    required this.tokens,
    required this.theme,
  });

  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingXl,
        vertical: tokens.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(tokens: tokens, theme: theme),
          SizedBox(height: tokens.spacingXl),
          _PrimaryVerdictCard(vm: vm, tokens: tokens, theme: theme),
          if (vm.hasMissingDimensions) ...[
            SizedBox(height: tokens.spacingMd),
            _MissingDimensionsBanner(vm: vm, tokens: tokens),
          ],
          SizedBox(height: tokens.spacingXl),
          _DimensionsList(vm: vm, tokens: tokens, theme: theme),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.tokens, required this.theme});

  final HealthMonitorTheme tokens;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: tokens.spacingLg),
      child: Text(
        '今日概览',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _PrimaryVerdictCard extends StatelessWidget {
  const _PrimaryVerdictCard({
    required this.vm,
    required this.tokens,
    required this.theme,
  });

  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;
  final ThemeData theme;

  Color _levelColor(String level) {
    switch (level) {
      case 'concern':
        return tokens.verdictConcernColor;
      case 'warning':
        return tokens.verdictWarningColor;
      default:
        return tokens.verdictNormalColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = vm.verdicts.isNotEmpty ? vm.verdicts.first : null;
    final color = primary != null ? _levelColor(primary.level) : tokens.verdictNormalColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingXl),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.summaryLabel,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: tokens.spacingSm),
          Text(
            vm.summaryDetail,
            style: tokens.bodyStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingDimensionsBanner extends StatelessWidget {
  const _MissingDimensionsBanner({required this.vm, required this.tokens});

  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacingMd,
        vertical: tokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: tokens.verdictWarningColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '部分数据维度暂不可用（${vm.missingDimensions.join('、')}），当前结论基于可用数据生成。',
        style: tokens.bodyStyle.copyWith(
          color: tokens.verdictWarningColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DimensionsList extends StatelessWidget {
  const _DimensionsList({
    required this.vm,
    required this.tokens,
    required this.theme,
  });

  final OverviewViewModel vm;
  final HealthMonitorTheme tokens;
  final ThemeData theme;

  Color _levelColor(String level) {
    switch (level) {
      case 'concern':
        return tokens.verdictConcernColor;
      case 'warning':
        return tokens.verdictWarningColor;
      default:
        return tokens.verdictNormalColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vm.verdicts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spacingXxl),
          child: Text(
            '暂无评估数据，持续使用后自动生成。',
            style: tokens.bodyStyle,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final verdict in vm.verdicts)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacingSm),
            child: _DimensionRow(
              verdict: verdict,
              tokens: tokens,
              theme: theme,
              levelColor: _levelColor(verdict.level),
            ),
          ),
      ],
    );
  }
}

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({
    required this.verdict,
    required this.tokens,
    required this.theme,
    required this.levelColor,
  });

  final RuleVerdict verdict;
  final HealthMonitorTheme tokens;
  final ThemeData theme;
  final Color levelColor;

  String _dimensionLabel() {
    switch (verdict.dimension) {
      case 'activity':
        return '活动';
      case 'posture':
        return '姿势';
      case 'usage':
        return '数字生活';
      case 'environment':
        return '环境';
      default:
        return verdict.dimension;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(tokens.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: levelColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dimensionLabel(),
                  style: tokens.sectionTitleStyle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  verdict.summary,
                  style: tokens.bodyStyle.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}