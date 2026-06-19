import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/usage/screen_usage_habit_summary.dart';
import 'package:health_monitor/services/health_insight_service.dart';

List<String> buildBriefingSuggestions(HealthInsightSnapshot snapshot) {
  final suggestions = <String>[];
  final metrics = snapshot.metrics;
  final usageSummary = snapshot.screenUsageHabitSummary;
  final environmentOverview = snapshot.environmentOverview;

  if (metrics.stepCount < 6000) {
    suggestions.add('今天活动量还可以再补一点，安排一次 10 到 15 分钟走动，会比临时冲步更容易坚持。');
  }

  if (metrics.sedentaryMinutes >= 120) {
    suggestions.add('久坐时间偏长，接下来每小时起身活动两三分钟，顺手走一小段会更稳妥。');
  }

  final screenSuggestion =
      _buildScreenSuggestion(usageSummary, metrics.screenMinutes);
  if (screenSuggestion != null) {
    suggestions.add(screenSuggestion);
  }

  if (environmentOverview?.primaryConcern ==
          EnvironmentPrimaryConcern.highNoise ||
      environmentOverview?.primaryConcern == EnvironmentPrimaryConcern.mixed) {
    suggestions.add('环境噪音偏高，尤其准备休息前尽量切到更安静的空间。');
  }

  if (environmentOverview?.primaryConcern ==
          EnvironmentPrimaryConcern.lowLight ||
      environmentOverview?.primaryConcern == EnvironmentPrimaryConcern.mixed) {
    suggestions.add('白天光线偏暗，工作或学习时尽量靠近自然光或补足照明。');
  }

  if (suggestions.isEmpty) {
    suggestions.add('整体节奏比较平稳，继续保持现在的步数、久坐间隔和用机边界。');
  }

  return suggestions.take(4).toList(growable: false);
}

String? _buildScreenSuggestion(
  ScreenUsageHabitSummary? usageSummary,
  int screenMinutes,
) {
  if (usageSummary != null && usageSummary.headline.contains('深夜')) {
    return '今晚尽量提前结束看屏，把最后十分钟留给放松和入睡准备。';
  }
  if (usageSummary != null && usageSummary.headline.contains('查看频率偏高')) {
    return '把零散查看压缩到固定时段，给连续专注留出完整区间。';
  }
  if (usageSummary != null && usageSummary.headline.contains('时段激活过密')) {
    return '遇到短间隔再次拿起手机时，先停一秒确认是否真的需要查看。';
  }
  if (screenMinutes >= 180) {
    return '今天屏幕使用时间偏长，后面尽量把查看合并到固定时段，给眼睛和注意力留出缓冲。';
  }
  return null;
}
