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

final _trendSnapshotCacheProvider =
    NotifierProvider<_TrendSnapshotCacheNotifier, TrendSnapshot?>(
  _TrendSnapshotCacheNotifier.new,
);

final trendSnapshotStateProvider =
    Provider<AsyncValue<TrendSnapshot>>((Ref ref) {
  final selectedTab = ref.watch(trendSelectedTabProvider);
  final cachedSnapshot = ref.watch(_trendSnapshotCacheProvider);
  if (cachedSnapshot?.selectedTab == selectedTab) {
    return AsyncData<TrendSnapshot>(cachedSnapshot!);
  }
  return ref.watch(trendAnalysisViewModelProvider);
});

final trendChartSnapshotProvider =
    Provider<AsyncValue<TrendSnapshot>>((Ref ref) {
  return ref.watch(trendSnapshotStateProvider);
});

final trendInsightTextProvider = Provider<AsyncValue<String>>((Ref ref) {
  return ref.watch(trendSnapshotStateProvider).whenData(
        (TrendSnapshot snapshot) => snapshot.insightText,
      );
});

class _TrendSnapshotCacheNotifier extends Notifier<TrendSnapshot?> {
  @override
  TrendSnapshot? build() {
    ref.listen<AsyncValue<TrendSnapshot>>(
      trendAnalysisViewModelProvider,
      (
        AsyncValue<TrendSnapshot>? previous,
        AsyncValue<TrendSnapshot> next,
      ) {
        final snapshot = next.valueOrNull;
        if (snapshot != null) {
          state = snapshot;
        }
      },
      fireImmediately: true,
    );
    return ref.read(trendAnalysisViewModelProvider).valueOrNull;
  }
}
