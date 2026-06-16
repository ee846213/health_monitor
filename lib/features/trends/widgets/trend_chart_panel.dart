import 'dart:math' as math;

import 'package:flutter/material.dart';
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
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _TrendChartPainter(
                  points: snapshot.points,
                  isBarChart: isBarChart,
                ),
                child: const SizedBox.expand(),
              ),
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
                        point.value.round().toString(),
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
  });

  final List<TrendPoint> points;
  final bool isBarChart;

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

    final maxValue = points
        .map((TrendPoint point) => point.value)
        .fold<num>(0, math.max)
        .toDouble();
    final safeMaxValue = (maxValue <= 0 ? 1 : maxValue).toDouble();

    if (isBarChart) {
      _drawBars(canvas, chartRect, safeMaxValue);
      return;
    }
    _drawLine(canvas, chartRect, safeMaxValue);
  }

  void _drawBars(Canvas canvas, Rect chartRect, double safeMaxValue) {
    final slotWidth = chartRect.width / points.length;
    final barWidth = math.min(24.0, slotWidth * 0.54);
    final barPaint = Paint()
      ..color = _panelAccentSoft
      ..style = PaintingStyle.fill;

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final ratio = point.value.toDouble() / safeMaxValue;
      final barHeight = math.max(8.0, chartRect.height * ratio * 0.82);
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

  void _drawLine(Canvas canvas, Rect chartRect, double safeMaxValue) {
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

    final path = Path();
    final fillPath = Path();

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final dx = chartRect.left +
          (chartRect.width * index / math.max(points.length - 1, 1));
      final usableHeight = chartRect.height - 24;
      final ratio = point.value.toDouble() / safeMaxValue;
      final dy = chartRect.bottom - 12 - usableHeight * ratio;

      if (index == 0) {
        path.moveTo(dx, dy);
        fillPath
          ..moveTo(dx, chartRect.bottom - 8)
          ..lineTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }
    }

    fillPath
      ..lineTo(chartRect.right, chartRect.bottom - 8)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final dx = chartRect.left +
          (chartRect.width * index / math.max(points.length - 1, 1));
      final usableHeight = chartRect.height - 24;
      final ratio = point.value.toDouble() / safeMaxValue;
      final dy = chartRect.bottom - 12 - usableHeight * ratio;
      canvas.drawCircle(Offset(dx, dy), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.isBarChart != isBarChart;
  }
}
