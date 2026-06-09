import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

abstract class ActivityRepository {
  Future<List<ActivitySample>> listByWindow(QueryWindow window);
}

class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository({
    required List<ActivitySample> samples,
  }) : _samples = List<ActivitySample>.unmodifiable(samples);

  final List<ActivitySample> _samples;

  @override
  Future<List<ActivitySample>> listByWindow(QueryWindow window) async {
    final result = _samples.where((sample) => window.contains(sample.capturedAt)).toList();

    // 仓储层统一输出升序结果，后续聚合和调试页可以直接复用，
    // 避免每个调用方重复处理时间排序。
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }
}
