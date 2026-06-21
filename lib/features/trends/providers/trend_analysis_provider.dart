import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/trend_analysis_service.dart';

final trendSelectedTabProvider = StateProvider<TrendTab>((Ref ref) {
  return TrendTab.steps;
});

final trendRangeForTabProvider =
    StateProvider.family<TrendRange, TrendTab>((Ref ref, TrendTab tab) {
  return TrendRange.days7;
});

final trendSelectedRangeProvider = Provider<TrendRange>((Ref ref) {
  final tab = ref.watch(trendSelectedTabProvider);
  return ref.watch(trendRangeForTabProvider(tab));
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
  final selectedTab = ref.watch(trendSelectedTabProvider);
  final range = ref.watch(trendRangeForTabProvider(selectedTab));
  switch (selectedTab) {
    case TrendTab.steps:
    case TrendTab.sedentary:
      ref.watch(dataCollectorMetricsRevisionProvider);
      break;
    case TrendTab.screen:
      ref.watch(dataCollectorUsageRevisionProvider);
      break;
    case TrendTab.environment:
      ref.watch(dataCollectorEnvironmentRevisionProvider);
      break;
  }
  ref.watch(dataCollectorProvider);
  final service = ref.watch(trendAnalysisServiceProvider);
  return service.build(
    referenceTime: DateTime.now(),
    selectedTab: selectedTab,
    range: range,
  );
});

final _trendSnapshotCacheProvider = NotifierProvider<
    _TrendSnapshotCacheNotifier, Map<(TrendTab, TrendRange), TrendSnapshot>>(
  _TrendSnapshotCacheNotifier.new,
);

final trendSnapshotStateProvider =
    Provider<AsyncValue<TrendSnapshot>>((Ref ref) {
  final selectedTab = ref.watch(trendSelectedTabProvider);
  final range = ref.watch(trendRangeForTabProvider(selectedTab));
  final cachedSnapshot =
      ref.watch(_trendSnapshotCacheProvider)[(selectedTab, range)];
  final current = ref.watch(trendAnalysisViewModelProvider);
  if (current.isLoading && cachedSnapshot != null) {
    return AsyncData<TrendSnapshot>(cachedSnapshot);
  }
  return current;
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

class _TrendSnapshotCacheNotifier
    extends Notifier<Map<(TrendTab, TrendRange), TrendSnapshot>> {
  @override
  Map<(TrendTab, TrendRange), TrendSnapshot> build() {
    ref.listen<AsyncValue<TrendSnapshot>>(
      trendAnalysisViewModelProvider,
      (
        AsyncValue<TrendSnapshot>? previous,
        AsyncValue<TrendSnapshot> next,
      ) {
        final snapshot = next.valueOrNull;
        if (snapshot != null) {
          state = <(TrendTab, TrendRange), TrendSnapshot>{
            ...state,
            (snapshot.selectedTab, snapshot.range): snapshot,
          };
        }
      },
      fireImmediately: false,
    );
    final initial = ref.read(trendAnalysisViewModelProvider).valueOrNull;
    if (initial == null) {
      return const <(TrendTab, TrendRange), TrendSnapshot>{};
    }
    return <(TrendTab, TrendRange), TrendSnapshot>{
      (initial.selectedTab, initial.range): initial,
    };
  }
}
