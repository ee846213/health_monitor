import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';

class BriefingPage extends ConsumerWidget {
  const BriefingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final asyncVm = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('今日简报'), backgroundColor: theme.colorScheme.surface),
      body: asyncVm.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败', style: tokens.bodyStyle)),
        data: (vm) => vm.verdicts.isEmpty
            ? Center(child: Text('暂无评估数据', style: tokens.bodyStyle))
            : ListView(
                padding: EdgeInsets.all(tokens.spacingXl),
                children: [
                  for (final v in vm.verdicts)
                    Card(
                      margin: EdgeInsets.only(bottom: tokens.spacingSm),
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spacingLg),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(v.summary, style: tokens.sectionTitleStyle),
                          SizedBox(height: tokens.spacingSm),
                          Text(v.detail, style: tokens.bodyStyle),
                        ]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}