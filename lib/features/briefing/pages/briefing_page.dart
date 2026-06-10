import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';

/// 简报页 —— 当日健康聚合摘要。
///
/// 消费与首页相同的 [overviewViewModelProvider]，
/// 以列表形式展示所有维度的评估详情。
class BriefingPage extends ConsumerWidget {
  const BriefingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncVm = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('今日简报'), backgroundColor: theme.colorScheme.surface),
      body: asyncVm.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败')),
        data: (vm) => ListView(
          padding: EdgeInsets.all(tokens.spacingXl),
          children: [
            for (final v in vm.verdicts)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacingSm),
                child: Card(
                  child: ListTile(
                    title: Text(v.summary, style: tokens.sectionTitleStyle),
                    subtitle: Text(v.detail, style: tokens.bodyStyle),
                  ),
                ),
              ),
            if (vm.verdicts.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacingXxl),
                  child: Text('暂无评估数据，持续使用后自动生成。', style: tokens.bodyStyle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}