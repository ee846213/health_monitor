import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/ambient_light_sample_repository.dart';
import 'package:health_monitor/storage/repositories/location_summary_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/noise_sample_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

/// 负责把各仓储查询结果组装成统一的 [RuleInput]。
///
/// 不同维度的查询粒度并不一致：
/// - activity / noise / light 直接按 [QueryWindow] 查询
/// - location / metrics 仍按天聚合
/// - usage 需要按窗口内日期逐天补齐
///
/// 当某个维度在当前窗口内没有可用数据时，会自动加入 `missingDimensions`，
/// 让规则层和页面层都能明确感知当前是“降级输入”。
class RuleInputService {
  RuleInputService({
    required ActivityRepository activityRepository,
    required AmbientLightSampleRepository ambientLightRepository,
    required LocationSummaryRepository locationRepository,
    required NoiseSampleRepository noiseRepository,
    required UsageSummaryRepository usageRepository,
    required MetricsRepository metricsRepository,
  })  : _activityRepository = activityRepository,
        _ambientLightRepository = ambientLightRepository,
        _locationRepository = locationRepository,
        _noiseRepository = noiseRepository,
        _usageRepository = usageRepository,
        _metricsRepository = metricsRepository;

  final ActivityRepository _activityRepository;
  final AmbientLightSampleRepository _ambientLightRepository;
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

    final activityFuture = disabledDimensions.contains('activity')
        ? Future<List<ActivitySample>>.value(const <ActivitySample>[])
        : _activityRepository.listByWindow(window);
    final locationFuture = disabledDimensions.contains('location')
        ? Future<List<LocationSummary>>.value(const <LocationSummary>[])
        : _locationRepository.listRecentDays(
            _daysForWindow(window),
            referenceDate: _referenceDateForWindow(window),
          );
    final noiseFuture = disabledDimensions.contains('noise')
        ? Future<List<NoiseSample>>.value(const <NoiseSample>[])
        : _noiseRepository.listByWindow(window);
    final lightFuture = disabledDimensions.contains('light')
        ? Future<List<AmbientLightSample>>.value(
            const <AmbientLightSample>[],
          )
        : _ambientLightRepository.listByWindow(window);
    final usageFuture = disabledDimensions.contains('digital_usage')
        ? Future<List<DigitalUsageSummary>>.value(
            const <DigitalUsageSummary>[],
          )
        : _usageRepository.listByWindow(window);
    final metricsFuture = disabledDimensions.contains('daily_metrics')
        ? Future<List<DailyMetrics>>.value(const <DailyMetrics>[])
        : _metricsRepository.listRecentDays(
            _daysForWindow(window),
            referenceDate: _referenceDateForWindow(window),
          );

    final activitySamples = await activityFuture;
    if (activitySamples.isEmpty && !disabledDimensions.contains('activity')) {
      missingDimensions.add('activity');
    }

    final locationSummaries = await locationFuture;
    if (locationSummaries.isEmpty && !disabledDimensions.contains('location')) {
      missingDimensions.add('location');
    }

    final noiseSamples = await noiseFuture;
    if (noiseSamples.isEmpty && !disabledDimensions.contains('noise')) {
      missingDimensions.add('noise');
    }

    final ambientLightSamples = await lightFuture;
    if (ambientLightSamples.isEmpty && !disabledDimensions.contains('light')) {
      missingDimensions.add('light');
    }

    final usageSummaries = await usageFuture;
    if (usageSummaries.isEmpty &&
        !disabledDimensions.contains('digital_usage')) {
      missingDimensions.add('digital_usage');
    }

    final dailyMetricsList = await metricsFuture;
    if (dailyMetricsList.isEmpty &&
        !disabledDimensions.contains('daily_metrics')) {
      missingDimensions.add('daily_metrics');
    }

    return RuleInput(
      window: window,
      activitySamples: activitySamples,
      locationSummaries: locationSummaries,
      noiseSamples: noiseSamples,
      ambientLightSamples: ambientLightSamples,
      usageSummaries: usageSummaries,
      dailyMetricsList: dailyMetricsList,
      missingDimensions: missingDimensions,
    );
  }
}

int _daysForWindow(QueryWindow window) {
  if (_isCalendarAligned(window)) {
    final days = window.endAt.difference(window.startAt).inDays;
    return days <= 0 ? 1 : days;
  }
  return 1;
}

DateTime _referenceDateForWindow(QueryWindow window) {
  final endExclusive = window.endAt.subtract(const Duration(microseconds: 1));
  return DateTime(endExclusive.year, endExclusive.month, endExclusive.day);
}

bool _isCalendarAligned(QueryWindow window) {
  final isStartAligned = window.startAt.hour == 0 &&
      window.startAt.minute == 0 &&
      window.startAt.second == 0 &&
      window.startAt.millisecond == 0 &&
      window.startAt.microsecond == 0;
  final isEndAligned = window.endAt.hour == 0 &&
      window.endAt.minute == 0 &&
      window.endAt.second == 0 &&
      window.endAt.millisecond == 0 &&
      window.endAt.microsecond == 0;
  return isStartAligned && isEndAligned;
}
