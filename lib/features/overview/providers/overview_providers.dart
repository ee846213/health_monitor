import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/rules/engine/activity_rules.dart';
import 'package:health_monitor/rules/engine/environment_rules.dart';
import 'package:health_monitor/rules/engine/posture_rules.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/engine/usage_rules.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/rules/input/rule_input_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

/// 首页视图模型：汇总当日各维度规则结论。
class OverviewViewModel {
  const OverviewViewModel({
    required this.isLoading,
    required this.verdicts,
    required this.summaryLabel,
    required this.summaryDetail,
    this.missingDimensions = const [],
  });

  final bool isLoading;
  final List<RuleVerdict> verdicts;
  final String summaryLabel;
  final String summaryDetail;
  final List<String> missingDimensions;

  bool get isEmpty => verdicts.isEmpty && !isLoading;
  bool get hasMissingDimensions => missingDimensions.isNotEmpty;
}

/// 首页 provider：读取规则引擎结果并组装 ViewModel。
final overviewViewModelProvider = FutureProvider<OverviewViewModel>((Ref ref) async {
  final now = DateTime.now();
  final window = QueryWindow.recentDay(referenceTime: now);

  // 真实场景中这里会从 Provider 注入的真实仓储获取。
  // 当前以空仓储临时实现，首页先展示"数据不足"状态。
  final inputService = RuleInputService(
    activityRepository: InMemoryActivityRepository(samples: const []),
    locationRepository: InMemoryLocationSummaryRepository(summaries: const []),
    noiseRepository: InMemoryNoiseSampleRepository(samples: const []),
    usageRepository: InMemoryUsageSummaryRepository(summaries: const []),
    metricsRepository: InMemoryMetricsRepository(metrics: const []),
  );

  final input = await inputService.buildInput(window: window);

  final rules = const <HealthRule>[
    ActivityRule(),
    PostureRule(),
    UsageRule(),
    EnvironmentRule(),
  ];

  final allVerdicts = <RuleVerdict>[];
  for (final rule in rules) {
    allVerdicts.addAll(rule.evaluate(input));
  }

  // 首页核心结论：按优先级取第一个 concern > warning > normal。
  final sorted = <RuleVerdict>[...allVerdicts]
    ..sort((a, b) {
      const priority = {'concern': 1, 'warning': 2, 'normal': 3};
      return (priority[a.level] ?? 4).compareTo(priority[b.level] ?? 4);
    });

  final primary = sorted.isNotEmpty ? sorted.first : null;

  return OverviewViewModel(
    isLoading: false,
    verdicts: sorted,
    summaryLabel: primary?.summary ?? '等待采集数据',
    summaryDetail: primary?.detail ?? '应用刚启动，数据积累还不够，稍后回来查看今天的健康概览。',
    missingDimensions: input.missingDimensions,
  );
});