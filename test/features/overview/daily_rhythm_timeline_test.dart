import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_window.dart';
import 'package:health_monitor/features/overview/widgets/daily_rhythm_timeline.dart';

void main() {
  final window = DailyRhythmWindow(
    start: DateTime(2026, 6, 22, 6),
    end: DateTime(2026, 6, 22, 17, 30),
  );

  test('节奏轴入场结束后所有节点圆点应全显', () {
    expect(
      DailyRhythmReveal.nodeAppear(
        nodeTime: DateTime(2026, 6, 22, 16),
        window: window,
        animProgress: 0.5,
        animationCompleted: true,
      ),
      1,
    );
    expect(
      DailyRhythmReveal.nodeAppear(
        nodeTime: DateTime(2026, 6, 22, 9),
        window: window,
        animProgress: 0.2,
        animationCompleted: true,
      ),
      1,
    );
  });

  test('节奏轴扫掠应贯穿早晨到现在', () {
    expect(
      DailyRhythmReveal.traceNorm(
        animProgress: 1,
        animationCompleted: false,
      ),
      1,
    );
    expect(
      DailyRhythmReveal.traceNorm(
        animProgress: 0.5,
        animationCompleted: false,
      ),
      0.5,
    );
    expect(
      DailyRhythmReveal.traceNorm(
        animProgress: 0.3,
        animationCompleted: true,
      ),
      1,
    );
  });

  test('靠近现在时刻的节点应随扫掠经过依次亮起', () {
    final lateNode = DateTime(2026, 6, 22, 16, 30);
    expect(
      DailyRhythmReveal.nodeAppear(
        nodeTime: lateNode,
        window: window,
        animProgress: 0.5,
        animationCompleted: false,
      ),
      0,
    );
    expect(
      DailyRhythmReveal.nodeAppear(
        nodeTime: lateNode,
        window: window,
        animProgress: 1,
        animationCompleted: false,
      ),
      greaterThan(0.9),
    );
  });

  test('弧线两端应与早晨和现在图标保留水平间距', () {
    const width = 354.0;
    final start = DailyRhythmCurveGeometry.arcStartX(width);
    final end = DailyRhythmCurveGeometry.arcEndX(width);
    expect(
      start - DailyRhythmLayout.endpointWidth,
      greaterThanOrEqualTo(8),
      reason: '弧线起点应离开早晨图标',
    );
    expect(
      width - DailyRhythmLayout.endpointWidth - end,
      greaterThanOrEqualTo(8),
      reason: '弧线终点应离开现在图标',
    );
  });

  test('相近节点应交替排到弧线上方与下方', () {
    const width = 354.0;
    final dotXs = <double>[
      _curveX(13, 0, width, window),
      _curveX(14, 0, width, window),
      _curveX(16, 0, width, window),
    ];
    final slots = DailyRhythmLabelLayout.arrangeSlots(dotXs: dotXs);
    expect(slots[0].centerX, closeTo(dotXs[0], 0.001));
    expect(slots[1].placement, isNot(slots[0].placement));
    expect(slots[2].placement, slots[0].placement);
  });

  test('节点信息应与弧线圆点保持同一水平中心', () {
    const width = 354.0;
    final dotXs = <double>[
      _curveX(9, 0, width, window),
      _curveX(14, 30, width, window),
      _curveX(16, 0, width, window),
    ];
    final slots = DailyRhythmLabelLayout.arrangeSlots(dotXs: dotXs);
    for (var index = 0; index < dotXs.length; index++) {
      expect(
        slots[index].centerX,
        closeTo(dotXs[index], 0.001),
        reason: '第 $index 个节点标签不应横向偏离弧线圆点',
      );
    }
  });

  test('节奏轴扫掠路径在 endNorm 处的尖端应落在该归一化时间的曲线点上', () {
    const width = 354.0;
    const samples = <double>[0.0, 0.25, 0.5, 0.75, 1.0];
    for (final norm in samples) {
      final tipPath = DailyRhythmCurveGeometry.pathFromStart(width, norm);
      if (norm == 0) {
        expect(tipPath.getBounds().isEmpty, isTrue);
        continue;
      }
      final metric = tipPath.computeMetrics().single;
      final tip = metric.getTangentForOffset(metric.length)!.position;
      final spanMinutes = window.span.inMinutes;
      final offsetMinutes = spanMinutes * norm;
      final time = window.start.add(
        Duration(minutes: offsetMinutes.round()),
      );
      final expected = DailyRhythmCurveGeometry.pointForTime(
        time,
        width,
        window,
        DailyRhythmLayout.timelineHeight,
      );
      expect(
        (tip - expected).distance,
        lessThan(0.5),
        reason: '在 norm=$norm 处尖端 ($tip) 应贴近曲线 ($expected)',
      );
    }
  });

  test('normalizedForTime 应把窗口起止映射到 0 与 1', () {
    expect(
      DailyRhythmCurveGeometry.normalizedForTime(window.start, window),
      closeTo(0.0, 1e-9),
    );
    expect(
      DailyRhythmCurveGeometry.normalizedForTime(window.end, window),
      closeTo(1.0, 1e-9),
    );
    expect(
      DailyRhythmCurveGeometry.normalizedForTime(
        DateTime(2026, 6, 22, 11, 45),
        window,
      ),
      closeTo(0.5, 0.02),
    );
  });

  test('节奏轴事件节点应落在实际绘制的曲线上', () {
    const width = 354.0;
    final path = DailyRhythmCurveGeometry.pathForWidth(width);
    final metric = path.computeMetrics().single;
    final times = <DateTime>[
      DateTime(2026, 6, 22, 9),
      DateTime(2026, 6, 22, 14, 30),
      DateTime(2026, 6, 22, 16),
    ];

    for (final time in times) {
      final node = DailyRhythmCurveGeometry.pointForTime(
        time,
        width,
        window,
        DailyRhythmLayout.timelineHeight,
      );
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

double _curveX(
  int hour,
  int minute,
  double width,
  DailyRhythmWindow window,
) {
  return DailyRhythmCurveGeometry.pointForTime(
    DateTime(2026, 6, 22, hour, minute),
    width,
    window,
    DailyRhythmLayout.timelineHeight,
  ).dx;
}
