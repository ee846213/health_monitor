import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

const Color _panelSurface = Color(0xFFFFFCF8);
const Color _panelSoft = Color(0xFFF3EEE5);
const Color _panelLine = Color(0xFFDAD4CA);
const Color _panelText = Color(0xFF1F2320);
const Color _panelMuted = Color(0xFF5D645B);
const Color _panelAccent = Color(0xFF5F775F);
const Color _panelAccentSoft = Color(0xFF9CB497);

class TrendChartPanel extends StatelessWidget {
  const TrendChartPanel({super.key, required this.snapshot});

  final TrendSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final isBarChart = snapshot.selectedTab == TrendTab.sedentary ||
        snapshot.selectedTab == TrendTab.environment;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _panelLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            snapshot.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _panelText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '单位：${snapshot.unitLabel}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _panelMuted,
            ),
          ),
          const SizedBox(height: 18),
          if (snapshot.emptyStateText != null) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                snapshot.emptyStateText!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: _panelMuted,
                ),
              ),
            ),
          ] else ...<Widget>[
            HealthAnimatedValue(
              key: ValueKey<int>(
                Object.hash(
                  snapshot.selectedTab,
                  Object.hashAll(snapshot.points),
                ),
              ),
              value: 1,
              duration: const Duration(milliseconds: 500),
              builder: (
                BuildContext context,
                double progress,
                Widget? child,
              ) {
                return SizedBox(
                  height: 200,
                  child: CustomPaint(
                    key: const Key('trend-chart-canvas'),
                    painter: _TrendChartPainter(
                      points: snapshot.points,
                      isBarChart: isBarChart,
                      progress: progress,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.points.map((TrendPoint point) {
                return Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        point.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _panelMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        point.hasData ? point.value.round().toString() : '--',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _panelText,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.isBarChart,
    required this.progress,
  });

  final List<TrendPoint> points;
  final bool isBarChart;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = _panelLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final guidePaint = Paint()
      ..color = _panelLine.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final chartRect = Rect.fromLTWH(0, 8, size.width, size.height - 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chartRect, const Radius.circular(18)),
      framePaint,
    );

    for (var index = 1; index <= 3; index++) {
      final dy = chartRect.top + chartRect.height * index / 4;
      canvas.drawLine(
        Offset(chartRect.left + 12, dy),
        Offset(chartRect.right - 12, dy),
        guidePaint,
      );
    }

    if (points.isEmpty) {
      return;
    }

    final availablePoints = points
        .where((TrendPoint point) => point.hasData)
        .toList(growable: false);
    if (availablePoints.isEmpty) {
      return;
    }

    final maxValue = availablePoints
        .map((TrendPoint point) => point.value)
        .fold<num>(0, math.max)
        .toDouble();
    final safeMaxValue = (maxValue <= 0 ? 1 : maxValue).toDouble();

    if (isBarChart) {
      _drawBars(canvas, chartRect, safeMaxValue, progress);
      return;
    }
    _drawLine(canvas, chartRect, safeMaxValue, progress);
  }

  void _drawBars(
    Canvas canvas,
    Rect chartRect,
    double safeMaxValue,
    double progress,
  ) {
    final slotWidth = chartRect.width / points.length;
    final barWidth = math.min(24.0, slotWidth * 0.54);
    final barPaint = Paint()
      ..color = _panelAccentSoft
      ..style = PaintingStyle.fill;

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      if (!point.hasData) {
        continue;
      }
      final ratio = point.value.toDouble() / safeMaxValue;
      final barHeight =
          math.max(8.0, chartRect.height * ratio * 0.82 * progress);
      final left =
          chartRect.left + slotWidth * index + (slotWidth - barWidth) / 2;
      final rect = Rect.fromLTWH(
        left,
        chartRect.bottom - barHeight - 8,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        barPaint,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Rect chartRect,
    double safeMaxValue,
    double progress,
  ) {
    final strokePaint = Paint()
      ..color = _panelAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[
          Color(0x665F775F),
          Color(0x005F775F),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chartRect);
    final dotPaint = Paint()..color = _panelAccent;

    final availableIndexes = <int>[
      for (var index = 0; index < points.length; index++)
        if (points[index].hasData) index,
    ];
    if (availableIndexes.isEmpty) {
      return;
    }

    final path = Path();
    final fillPath = Path();

    for (var position = 0; position < availableIndexes.length; position++) {
      final index = availableIndexes[position];
      final point = points[index];
      final dx = chartRect.left +
          (chartRect.width * index / math.max(points.length - 1, 1));
      final usableHeight = chartRect.height - 24;
      final ratio = point.value.toDouble() / safeMaxValue;
      final dy = chartRect.bottom - 12 - usableHeight * ratio;

      if (position == 0) {
        path.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, chartRect.bottom - 8)
          ..lineTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
    }

    final lastIndex = availableIndexes.last;
    final lastDx = chartRect.left +
        (chartRect.width * lastIndex / math.max(points.length - 1, 1));
    fillPath
      ..lineTo(lastDx, chartRect.bottom - 8)
      ..close();

    canvas.saveLayer(
      chartRect,
      Paint()..color = Colors.white.withValues(alpha: progress),
    );
    canvas.drawPath(fillPath, fillPaint);
    final metrics = path.computeMetrics().toList(growable: false);
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        strokePaint,
      );
    }

    for (var position = 0; position < availableIndexes.length; position++) {
      final index = availableIndexes[position];
      final revealAt = availableIndexes.length <= 1
          ? 0.0
          : position / (availableIndexes.length - 1);
      if (revealAt > progress) {
        continue;
      }
      final point = points[index];
      final dx = chartRect.left +
          (chartRect.width * index / math.max(points.length - 1, 1));
      final usableHeight = chartRect.height - 24;
      final ratio = point.value.toDouble() / safeMaxValue;
      final dy = chartRect.bottom - 12 - usableHeight * ratio;
      canvas.drawCircle(Offset(dx, dy), 4, dotPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.isBarChart != isBarChart ||
        oldDelegate.progress != progress;
  }
}
