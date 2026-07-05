import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

const int _trendVisibleSlots = 7;
const double _trendLineCurveSmoothness = 0.16;

class TrendChartPanel extends StatefulWidget {
  const TrendChartPanel({super.key, required this.snapshot});

  final TrendSnapshot snapshot;

  @override
  State<TrendChartPanel> createState() => _TrendChartPanelState();
}

class _TrendChartPanelState extends State<TrendChartPanel> {
  late ScrollController _scrollController;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _initialSelectedIndex();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant TrendChartPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot != widget.snapshot) {
      _selectedIndex = _initialSelectedIndex();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int? _initialSelectedIndex() {
    final points = widget.snapshot.points;
    if (points.isEmpty) {
      return null;
    }
    return widget.snapshot.defaultSelectedIndex ?? points.length - 1;
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients || _selectedIndex == null) {
      return;
    }
    final slotWidth =
        _scrollController.position.viewportDimension / _trendVisibleSlots;
    if (slotWidth <= 0) {
      return;
    }
    final target = (_selectedIndex! - (_trendVisibleSlots - 1)) * slotWidth;
    final maxExtent = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(target.clamp(0.0, maxExtent).toDouble());
  }

  void _selectIndex(int index) {
    if (index < 0 || index >= widget.snapshot.points.length) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  TrendPoint? get _headlinePoint {
    final points = widget.snapshot.points;
    if (points.isEmpty || _selectedIndex == null) {
      return null;
    }
    return points[_selectedIndex!.clamp(0, points.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final points = snapshot.points;
    final headline = _headlinePoint;
    final accent = _accentFor(snapshot.selectedTab, context);
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
                    HealthAnimatedNumberText(
                      value: headline == null
                          ? '暂无可用数据'
                          : '${headline.value.round()} ${snapshot.unitLabel}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: context.healthTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (headline != null)
                Text(
                  headline.label,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = constraints.maxWidth;
                  final slotWidth = viewportWidth / _trendVisibleSlots;
                  final slotCount = math.max(points.length, _trendVisibleSlots);
                  final contentWidth = slotWidth * slotCount;
                  return Column(
                    children: <Widget>[
                      HealthAnimatedValue(
                        key: ValueKey<String>(_trendAnimationKey(snapshot)),
                        value: 1,
                        duration: context.healthMotion.data,
                        builder: (context, progress, child) {
                          return SizedBox(
                            height: 244,
                            child: SingleChildScrollView(
                              key: const Key('trend-chart-scroll-view'),
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                width: contentWidth,
                                child: _TrendScrollableChart(
                                  points: points,
                                  slotWidth: slotWidth,
                                  progress: progress,
                                  accent: accent,
                                  selectedIndex: _selectedIndex,
                                  onSelect: _selectIndex,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (points.length > _trendVisibleSlots) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          '左右滑动查看更多日期',
                          textAlign: TextAlign.center,
                          style: context.healthTheme.dataStyle.copyWith(
                            fontSize: 11,
                            color: context.healthTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendScrollableChart extends StatelessWidget {
  const _TrendScrollableChart({
    required this.points,
    required this.slotWidth,
    required this.progress,
    required this.accent,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TrendPoint> points;
  final double slotWidth;
  final double progress;
  final Color accent;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  double get _chartMinX => -0.5;

  double get _chartMaxX => math.max(points.length, _trendVisibleSlots) - 0.5;

  List<FlSpot> get _spots => List<FlSpot>.generate(
        points.length,
        (index) => FlSpot(index.toDouble(), points[index].value.toDouble()),
      );

  List<FlSpot> _visibleSpots(List<FlSpot> spots, double progress) {
    if (spots.length <= 1) {
      return spots;
    }
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final lastPosition = (spots.length - 1) * clampedProgress;
    final lastWholeIndex = lastPosition.floor().clamp(0, spots.length - 1);
    final visible = <FlSpot>[
      for (var index = 0; index <= lastWholeIndex; index += 1) spots[index],
    ];
    if (lastWholeIndex < spots.length - 1) {
      final segmentProgress = lastPosition - lastWholeIndex;
      if (segmentProgress > 0) {
        final from = spots[lastWholeIndex];
        final to = spots[lastWholeIndex + 1];
        visible.add(
          FlSpot(
            from.x + (to.x - from.x) * segmentProgress,
            from.y + (to.y - from.y) * segmentProgress,
          ),
        );
      }
    }
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    final maxValue =
        points.map((point) => point.value.toDouble()).fold<double>(1, math.max);
    final spots = _spots;
    final visibleSpots = _visibleSpots(spots, progress);
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              IgnorePointer(
                child: LineChart(
                  key: const Key('trend-line-chart'),
                  transformationConfig: const FlTransformationConfig(
                    panEnabled: false,
                    scaleEnabled: false,
                  ),
                  LineChartData(
                    minX: _chartMinX,
                    maxX: _chartMaxX,
                    minY: 0,
                    maxY: maxValue * 1.12,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxValue / 3,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFFE8E2D9),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(),
                      topTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      bottomTitles: AxisTitles(),
                    ),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: <LineChartBarData>[
                      LineChartBarData(
                        spots: visibleSpots,
                        isCurved: true,
                        curveSmoothness: _trendLineCurveSmoothness,
                        color: accent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            final pointIndex = spot.x.round();
                            final selected = pointIndex == selectedIndex;
                            return FlDotCirclePainter(
                              radius: selected ? 5 : 3.5,
                              color: accent,
                              strokeWidth: selected ? 2 : 0,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                  duration: context.motionDuration(motion.fast),
                  curve: motion.standardCurve,
                ),
              ),
              Positioned.fill(
                child: _TrendChartTapLayer(
                  slotWidth: slotWidth,
                  pointCount: points.length,
                  onSelect: onSelect,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: Row(
            children: List<Widget>.generate(
              math.max(points.length, _trendVisibleSlots),
              (int index) {
                if (index >= points.length) {
                  return SizedBox(width: slotWidth, height: 32);
                }
                final point = points[index];
                final selected = index == selectedIndex;
                return SizedBox(
                  width: slotWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(index),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '${point.value.round()}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: context.healthTheme.dataStyle.copyWith(
                            fontSize: 9,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
                            color: selected
                                ? context.healthTheme.textPrimary
                                : context.healthTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          point.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.healthTheme.dataStyle.copyWith(
                            fontSize: 9,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? context.healthTheme.textPrimary
                                : context.healthTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendChartTapLayer extends StatefulWidget {
  const _TrendChartTapLayer({
    required this.slotWidth,
    required this.pointCount,
    required this.onSelect,
  });

  final double slotWidth;
  final int pointCount;
  final ValueChanged<int> onSelect;

  @override
  State<_TrendChartTapLayer> createState() => _TrendChartTapLayerState();
}

class _TrendChartTapLayerState extends State<_TrendChartTapLayer> {
  Offset? _downPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _downPosition = event.localPosition,
      onPointerCancel: (_) => _downPosition = null,
      onPointerUp: (event) {
        final down = _downPosition;
        _downPosition = null;
        if (down == null || widget.slotWidth <= 0) {
          return;
        }
        if ((event.localPosition - down).distance > 18) {
          return;
        }
        final index = (event.localPosition.dx / widget.slotWidth)
            .floor()
            .clamp(0, widget.pointCount - 1);
        widget.onSelect(index);
      },
      child: const SizedBox.expand(),
    );
  }
}

Color _accentFor(TrendTab tab, BuildContext context) {
  return switch (tab) {
    TrendTab.steps => context.healthTheme.sage,
    TrendTab.sedentary => context.healthTheme.sand,
    TrendTab.screen => context.healthTheme.blue,
  };
}

String _trendAnimationKey(TrendSnapshot snapshot) {
  final buffer = StringBuffer()
    ..write(snapshot.selectedTab.name)
    ..write('|')
    ..write(snapshot.range.name)
    ..write('|');
  for (final point in snapshot.points) {
    buffer
      ..write(point.label)
      ..write(':')
      ..write(point.value)
      ..write(':')
      ..write(point.hasData)
      ..write(';');
  }
  return buffer.toString();
}

String _semanticSummary(TrendSnapshot snapshot) {
  final values = snapshot.points
      .map((point) =>
          '${point.label} ${point.value.round()}${snapshot.unitLabel}')
      .join('，');
  return '${snapshot.title}。$values';
}
