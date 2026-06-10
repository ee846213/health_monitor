import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

/// 规则输入构建器。
///
/// 从各仓储拉取数据并组装为统一的 [RuleInput]。
/// 各仓储查询接口不同，本服务负责适配：
/// - Activity / Noise 通过 [QueryWindow] 查询
/// - Location / Metrics 通过天级窗口查询
/// - Usage 逐日查询（窗口内遍历每个日期）
///
/// 当某仓储返回空结果时，自动将该维度加入 missingDimensions。
class RuleInputService {
  RuleInputService({
    required ActivityRepository activityRepository,
    required LocationSummaryRepository locationRepository,
    required NoiseSampleRepository noiseRepository,
    required UsageSummaryRepository usageRepository,
    required MetricsRepository metricsRepository,
  }) : _activityRepository = activityRepository,
       _locationRepository = locationRepository,
       _noiseRepository = noiseRepository,
       _usageRepository = usageRepository,
       _metricsRepository = metricsRepository;

  final ActivityRepository _activityRepository;
  final LocationSummaryRepository _locationRepository;
  final NoiseSampleRepository _noiseRepository;
  final UsageSummaryRepository _usageRepository;
  final MetricsRepository _metricsRepository;

  /// 构建规则输入。
  Future<RuleInput> buildInput({
    required QueryWindow window,
    List<String> disabledDimensions = const <String>[],
  }) async {
    final missingDimensions = <String>[...disabledDimensions];

    // 活动样本（同时作为姿势风险推断数据源）
    final activitySamples = disabledDimensions.contains('activity')
        ? <ActivitySample>[]
        : await _activityRepository.listByWindow(window);
    if (activitySamples.isEmpty && !disabledDimensions.contains('activity')) {
      missingDimensions.add('activity');
    }

    // 位置摘要（天级查询）
    final locationSummaries = disabledDimensions.contains('location')
        ? <LocationSummary>[]
        : await _locationRepository.listRecentDays(7, referenceDate: window.endAt);
    if (locationSummaries.isEmpty && !disabledDimensions.contains('location')) {
      missingDimensions.add('location');
    }

    // 噪音样本
    final noiseSamples = disabledDimensions.contains('noise')
        ? <NoiseSample>[]
        : await _noiseRepository.listByWindow(window);
    if (noiseSamples.isEmpty && !disabledDimensions.contains('noise')) {
      missingDimensions.add('noise');
    }

    // 数字生活摘要（逐日查询，窗口内最多 7 天，性能可接受）
    final usageSummaries = <DigitalUsageSummary>[];
    if (disabledDimensions.contains('digital_usage')) {
      // 跳过
    } else {
      for (final date in window.dailyDates()) {
        final summary = await _usageRepository.getByDate(date);
        if (summary != null) usageSummaries.add(summary);
      }
      if (usageSummaries.isEmpty) {
        missingDimensions.add('digital_usage');
      }
    }

    // 每日指标
    final dailyMetricsList = disabledDimensions.contains('daily_metrics')
        ? <DailyMetrics>[]
        : await _metricsRepository.listRecentDays(7, referenceDate: window.endAt);
    if (dailyMetricsList.isEmpty && !disabledDimensions.contains('daily_metrics')) {
      missingDimensions.add('daily_metrics');
    }

    return RuleInput(
      window: window,
      activitySamples: activitySamples,
      locationSummaries: locationSummaries,
      noiseSamples: noiseSamples,
      usageSummaries: usageSummaries,
      dailyMetricsList: dailyMetricsList,
      missingDimensions: missingDimensions,
    );
  }
}

