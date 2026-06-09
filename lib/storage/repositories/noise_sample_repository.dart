import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

abstract class NoiseSampleRepository {
  Future<List<NoiseSample>> listByWindow(QueryWindow window);
}

class InMemoryNoiseSampleRepository implements NoiseSampleRepository {
  InMemoryNoiseSampleRepository({
    required List<NoiseSample> samples,
  }) : _samples = List<NoiseSample>.unmodifiable(samples);

  final List<NoiseSample> _samples;

  @override
  Future<List<NoiseSample>> listByWindow(QueryWindow window) async {
    final result = _samples.where((sample) => window.contains(sample.capturedAt)).toList();
    result.sort((left, right) => left.capturedAt.compareTo(right.capturedAt));
    return result;
  }
}
