import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/features/overview/widgets/daily_rhythm_timeline.dart';

void main() {
  test('节奏轴事件节点应落在实际绘制的曲线上', () {
    const width = 354.0;
    final path = DailyRhythmCurveGeometry.pathForWidth(width);
    final metric = path.computeMetrics().single;
    final times = <DateTime>[
      DateTime(2026, 6, 22, 9),
      DateTime(2026, 6, 22, 14, 30),
      DateTime(2026, 6, 22, 18),
      DateTime(2026, 6, 22, 21),
    ];

    for (final time in times) {
      final node = DailyRhythmCurveGeometry.pointForTime(time, width);
      var minimumDistance = double.infinity;
      for (var offset = 0.0; offset <= metric.length; offset += 0.25) {
        final tangent = metric.getTangentForOffset(offset);
        if (tangent == null) {
          continue;
        }
        minimumDistance = math.min(
          minimumDistance,
          (tangent.position - node).distance,
        );
      }
      expect(
        minimumDistance,
        lessThan(0.6),
        reason: '${time.hour}:${time.minute} 的节点没有落在节奏轴曲线上',
      );
    }
  });
}
