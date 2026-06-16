import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/trend_analysis_service.dart';

final trendSelectedTabProvider = StateProvider<TrendTab>((Ref ref) {
  return TrendTab.steps;
});

final trendAnalysisServiceProvider = Provider<TrendAnalysisService>((Ref ref) {
  return TrendAnalysisService(
    metricsRepository: ref.watch(sharedMetricsRepo),
    usageRepository: ref.watch(sharedUsageRepo),
    ambientLightRepository: ref.watch(sharedAmbientLightRepo),
    noiseRepository: ref.watch(sharedNoiseRepo),
  );
});

final trendAnalysisViewModelProvider = FutureProvider<TrendSnapshot>((
  Ref ref,
) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);

  final selectedTab = ref.watch(trendSelectedTabProvider);
  final service = ref.watch(trendAnalysisServiceProvider);
  return service.build(
    referenceTime: DateTime.now(),
    selectedTab: selectedTab,
  );
});
