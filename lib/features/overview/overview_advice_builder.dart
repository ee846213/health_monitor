import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/health_insight_service.dart';

String buildDashboardFallbackAdvice({
  required HealthInsightMetrics metrics,
  required List<RuleVerdict> verdicts,
  required EnvironmentOverview? environmentOverview,
}) {
  final hasLowSteps = metrics.stepCount < 6000;
  final hasLongSedentary = metrics.sedentaryMinutes >= 120;
  final hasHeavyScreen = metrics.screenMinutes >= 180;
  final hasHighNoise = environmentOverview?.primaryConcern ==
          EnvironmentPrimaryConcern.highNoise ||
      environmentOverview?.primaryConcern == EnvironmentPrimaryConcern.mixed;
  final hasLowLight = environmentOverview?.primaryConcern ==
          EnvironmentPrimaryConcern.lowLight ||
      environmentOverview?.primaryConcern == EnvironmentPrimaryConcern.mixed;

  if (hasLowSteps && hasLongSedentary) {
    return '今天步数还没到位，久坐时间也偏长，接下来安排 10 到 15 分钟走动，顺手把连续坐姿打断会更稳妥。';
  }
  if (hasLowSteps) {
    return '今天步数还差一点，晚些时候补一段 10 到 15 分钟的走动，会比集中冲量更轻松。';
  }
  if (hasLongSedentary) {
    return '今天久坐时间偏长，接下来每小时起身活动两三分钟，顺手走一小段会更舒服。';
  }
  if (hasHeavyScreen) {
    return '今天屏幕使用时间有些长，下一次拿起手机前先停一秒，尽量把查看集中到固定时段。';
  }
  if (hasHighNoise) {
    return '环境噪音有点高，尤其临近休息时尽量换到更安静的空间，让节奏更容易收下来。';
  }
  if (hasLowLight) {
    return '白天光线偏暗，工作或学习时尽量靠近窗边或更稳定的照明。';
  }

  for (final verdict in verdicts) {
    if (_isPreferredAdviceDimension(verdict.dimension) &&
        verdict.detail.trim().isNotEmpty) {
      return verdict.detail;
    }
  }

  if (environmentOverview != null &&
      environmentOverview.detail.trim().isNotEmpty) {
    return environmentOverview.detail;
  }

  if (verdicts.isNotEmpty && verdicts.first.detail.trim().isNotEmpty) {
    return verdicts.first.detail;
  }

  return '今天整体节奏比较平稳，继续留意步数、久坐和屏幕使用这几个关键项就很好。';
}

bool _isPreferredAdviceDimension(String dimension) {
  return switch (dimension) {
    'activity' || 'usage' || 'environment' || 'noise' => true,
    _ => false,
  };
}
