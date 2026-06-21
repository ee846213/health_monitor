import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

class TrendChartPanel extends StatefulWidget {
  const TrendChartPanel({super.key, required this.snapshot});

  final TrendSnapshot snapshot;

  @override
  State<TrendChartPanel> createState() => _TrendChartPanelState();
}

class _TrendChartPanelState extends State<TrendChartPanel> {
  int? _selectedIndex;
  Timer? _restoreTimer;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.snapshot.defaultSelectedIndex;
  }

  @override
  void didUpdateWidget(covariant TrendChartPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot != widget.snapshot) {
      _selectedIndex = widget.snapshot.defaultSelectedIndex;
    }
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final selected =
        _selectedIndex == null || _selectedIndex! >= snapshot.points.length
            ? null
            : snapshot.points[_selectedIndex!];
    return HealthElevatedCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(snapshot.title,
                        style: context.healthTheme.sectionTitleStyle),
                    const SizedBox(height: 4),
                    Text(
                      selected?.hasData == true
                          ? '${selected!.value.round()} ${snapshot.unitLabel}'
                          : '暂无可用数据',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: context.healthTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected != null)
                Text(
                  selected.label,
                  style: context.healthTheme.dataStyle.copyWith(
                    fontSize: 11,
                    color: context.healthTheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (snapshot.emptyStateText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.healthTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                snapshot.emptyStateText!,
                style: context.healthTheme.bodyStyle,
              ),
            )
          else
            Semantics(
              label: _semanticSummary(snapshot),
              child: HealthAnimatedValue(
                key: ValueKey<Object>((snapshot.selectedTab, snapshot.range)),
                value: 1,
                duration: const Duration(milliseconds: 500),
                builder: (context, progress, child) {
                  return GestureDetector(
                    key: const Key('trend-chart-gesture-area'),
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _selectAt(details.localPosition.dx, context),
                    onHorizontalDragUpdate: (details) =>
                        _selectAt(details.localPosition.dx, context),
                    onHorizontalDragEnd: (_) => _scheduleRestore(),
                    child: SizedBox(
                      height: 214,
                      child: CustomPaint(
                        key: const Key('trend-chart-canvas'),
                        painter: _TrendChartPainter(
                          points: snapshot.points,
                          progress: progress,
                          selectedIndex: _selectedIndex,
                          accent: _accentFor(snapshot.selectedTab, context),
                          isBarChart:
                              snapshot.selectedTab == TrendTab.sedentary,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: snapshot.points.map((point) {
              return Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      point.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.healthTheme.dataStyle.copyWith(
                        fontSize: 9,
                        color: context.healthTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      point.hasData ? point.value.round().toString() : '--',
                      style: context.healthTheme.dataStyle.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(growable: false),
          ),
          if (snapshot.dataQuality == TrendDataQuality.partial) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              '部分日期数据暂缺，曲线不会用 0 补齐。',
              style: context.healthTheme.dataStyle.copyWith(
                fontSize: 11,
                color: context.healthTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectAt(double dx, BuildContext context) {
    final count = widget.snapshot.points.length;
    if (count == 0) return;
    final width = context.size?.width ?? 1;
    final index = ((dx / width) * count).floor().clamp(0, count - 1);
    if (widget.snapshot.points[index].hasData) {
      _restoreTimer?.cancel();
      setState(() => _selectedIndex = index);
    }
  }

  void _scheduleRestore() {
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _selectedIndex = widget.snapshot.defaultSelectedIndex);
      }
    });
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.progress,
    required this.selectedIndex,
    required this.accent,
    required this.isBarChart,
  });

  final List<TrendPoint> points;
  final double progress;
  final int? selectedIndex;
  final Color accent;
  final bool isBarChart;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final rect = Rect.fromLTWH(8, 16, size.width - 16, size.height - 30);
    final guide = Paint()
      ..color = const Color(0xFFE8E2D9)
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = rect.top + rect.height * index / 3;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), guide);
    }
    final available = points.where((point) => point.hasData).toList();
    if (available.isEmpty) return;
    final maxValue = available
        .map((point) => point.value.toDouble())
        .fold<double>(1, math.max);

    if (isBarChart) {
      _paintBars(canvas, rect, maxValue);
    } else {
      _paintLineSegments(canvas, rect, maxValue);
    }
    _paintSelection(canvas, rect, maxValue);
  }

  Offset _offsetFor(int index, Rect rect, double maxValue) {
    final x = rect.left + rect.width * index / math.max(points.length - 1, 1);
    final ratio = points[index].value.toDouble() / maxValue;
    return Offset(x, rect.bottom - rect.height * ratio * .84);
  }

  void _paintBars(Canvas canvas, Rect rect, double maxValue) {
    final width = rect.width / points.length;
    final paint = Paint()..color = accent.withValues(alpha: .72);
    for (var index = 0; index < points.length; index++) {
      if (!points[index].hasData) continue;
      final point = _offsetFor(index, rect, maxValue);
      final bar = Rect.fromLTRB(
        rect.left + index * width + width * .24,
        rect.bottom - (rect.bottom - point.dy) * progress,
        rect.left + (index + 1) * width - width * .24,
        rect.bottom,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(10)),
        paint,
      );
    }
  }

  void _paintLineSegments(Canvas canvas, Rect rect, double maxValue) {
    final stroke = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = accent;
    Path? segment;
    var segmentHasPoint = false;
    for (var index = 0; index < points.length; index++) {
      if (!points[index].hasData) {
        if (segment != null) {
          _drawAnimatedPath(canvas, segment, stroke);
          segment = null;
          segmentHasPoint = false;
        }
        continue;
      }
      final offset = _offsetFor(index, rect, maxValue);
      segment ??= Path();
      if (!segmentHasPoint) {
        segment.moveTo(offset.dx, offset.dy);
        segmentHasPoint = true;
      } else {
        segment.lineTo(offset.dx, offset.dy);
      }
      canvas.drawCircle(offset, 3.5 * progress, dot);
    }
    if (segment != null) _drawAnimatedPath(canvas, segment, stroke);
  }

  void _drawAnimatedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        paint,
      );
    }
  }

  void _paintSelection(Canvas canvas, Rect rect, double maxValue) {
    final index = selectedIndex;
    if (index == null || index >= points.length || !points[index].hasData) {
      return;
    }
    final point = _offsetFor(index, rect, maxValue);
    canvas.drawLine(
      Offset(point.dx, rect.top),
      Offset(point.dx, rect.bottom),
      Paint()
        ..color = accent.withValues(alpha: .3)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(point, 8, Paint()..color = Colors.white);
    canvas.drawCircle(point, 5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.accent != accent ||
        oldDelegate.isBarChart != isBarChart;
  }
}

Color _accentFor(TrendTab tab, BuildContext context) {
  return switch (tab) {
    TrendTab.steps => context.healthTheme.sage,
    TrendTab.sedentary => context.healthTheme.sand,
    TrendTab.environment => context.healthTheme.coral,
    TrendTab.screen => context.healthTheme.blue,
  };
}

String _semanticSummary(TrendSnapshot snapshot) {
  final values = snapshot.points
      .where((point) => point.hasData)
      .map((point) =>
          '${point.label} ${point.value.round()}${snapshot.unitLabel}')
      .join('，');
  return '${snapshot.title}。$values';
}
