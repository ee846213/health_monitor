import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_window.dart';

class DailyRhythmTimeline extends StatefulWidget {
  const DailyRhythmTimeline({
    super.key,
    required this.model,
    required this.onNodeTap,
    this.endPointLabel = '现在',
  });

  final DailyRhythmUiModel model;
  final ValueChanged<DailyRhythmNode> onNodeTap;
  final String endPointLabel;

  @override
  State<DailyRhythmTimeline> createState() => _DailyRhythmTimelineState();
}

class _DailyRhythmTimelineState extends State<DailyRhythmTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 节奏轴入场：弧线从早晨端绘制到晚间端，节点随扫掠依次亮起。
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    // 推迟到下一帧再启动，保证首帧 progress 从 0 起算，沿曲线的扫掠不被跳过。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DailyRhythmTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 真实数据刷新或下拉刷新导致节点变化时，让动效从头重放一次。
    if (_shouldRestartAnimation(oldWidget)) {
      _controller
        ..reset()
        ..forward();
    }
  }

  bool _shouldRestartAnimation(DailyRhythmTimeline oldWidget) {
    final oldNodes = oldWidget.model.nodes;
    final newNodes = widget.model.nodes;
    if (oldNodes.length != newNodes.length) {
      return true;
    }
    for (var index = 0; index < oldNodes.length; index++) {
      final a = oldNodes[index];
      final b = newNodes[index];
      if (a.time != b.time ||
          a.dimension != b.dimension ||
          a.isAvailable != b.isAvailable) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建节点信息：时间、标题、维度图标。
  ///
  /// 弧线上的彩色圆点是节点本体（Painter 绘制）；标签始终与圆点共用
  /// 同一水平中心 [DailyRhythmLabelSlot.centerX]（即真实曲线 X），
  /// 仅在纵向按 [RhythmInfoPlacement] 排到弧线上方或下方，避免横向错位。
  List<Widget> _buildNodeLabels(
    BuildContext context,
    double width,
    double timelineHeight,
    List<DailyRhythmLabelSlot> slots,
    double animProgress,
    bool animationCompleted,
    DailyRhythmWindow window,
  ) {
    final nodes = widget.model.nodes;
    if (nodes.isEmpty) {
      return const <Widget>[];
    }
    return List<Widget>.generate(nodes.length, (int index) {
      final node = nodes[index];
      final slot = slots[index];
      final dot = _curvePoint(node.time, width, timelineHeight, window);
      final appear = DailyRhythmReveal.nodeAppear(
        nodeTime: node.time,
        window: window,
        animProgress: animProgress,
        animationCompleted: animationCompleted,
      );
      final top = DailyRhythmLayout.nodeBlockTop(
        dotY: dot.dy,
        placement: slot.placement,
      );
      final slideFrom =
          slot.placement == RhythmInfoPlacement.above ? 10.0 : -10.0;
      return Positioned(
        left: dot.dx - DailyRhythmLayout.nodeBlockHalfWidth,
        top: top,
        width: DailyRhythmLayout.nodeBlockWidth,
        child: IgnorePointer(
          ignoring: appear < 0.4,
          child: Opacity(
            opacity: appear,
            child: Transform.translate(
              offset: Offset(0, slideFrom * (1 - appear)),
              child: _RhythmNodeView(
                node: node,
                placement: slot.placement,
                color: _dimensionColor(context, node.dimension),
                background: _dimensionBackground(context, node.dimension),
                onTap: () => widget.onNodeTap(node),
              ),
            ),
          ),
        ),
      );
    }, growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.reduceMotion;
    const timelineHeight = DailyRhythmLayout.timelineHeight;
    return SizedBox(
      height: timelineHeight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final animationCompleted =
                  reduceMotion || _controller.status == AnimationStatus.completed;
              final animProgress =
                  reduceMotion ? 1.0 : _controller.value;
              final traceNorm = DailyRhythmReveal.traceNorm(
                animProgress: animProgress,
                animationCompleted: animationCompleted,
              );
              final width = constraints.maxWidth;
              final window = widget.model.window;
              final nodeSlots = DailyRhythmLabelLayout.arrangeSlots(
                dotXs: List<double>.generate(
                  widget.model.nodes.length,
                  (int index) => _curvePoint(
                    widget.model.nodes[index].time,
                    width,
                    timelineHeight,
                    window,
                  ).dx,
                ),
              );
              final morningPoint = DailyRhythmCurveGeometry.pointForTime(
                window.start,
                width,
                window,
                timelineHeight,
              );
              final endpointTop = morningPoint.dy - 28;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RhythmCurvePainter(
                        traceNorm: traceNorm,
                        nodes: widget.model.nodes,
                        colors: _dimensionColors(context),
                        animProgress: animProgress,
                        animationCompleted: animationCompleted,
                        timelineHeight: timelineHeight,
                        window: window,
                      ),
                    ),
                  ),
                  _Endpoint(
                    x: 0,
                    top: endpointTop,
                    icon: 'wb_sunny',
                    label: '早晨',
                    color: context.healthTheme.sand,
                  ),
                  _Endpoint(
                    x: width - DailyRhythmLayout.endpointWidth,
                    top: endpointTop,
                    icon: 'schedule',
                    label: widget.endPointLabel,
                    color: const Color(0xFFF0A23B),
                  ),
                  ..._buildNodeLabels(
                    context,
                    width,
                    timelineHeight,
                    nodeSlots,
                    animProgress,
                    animationCompleted,
                    window,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// 节点信息块：时间、标题、维度图标。弧线上的圆点由 Painter 单独绘制。
class _RhythmNodeView extends StatelessWidget {
  const _RhythmNodeView({
    required this.node,
    required this.placement,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final DailyRhythmNode node;
  final RhythmInfoPlacement placement;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final availableColor =
        node.isAvailable ? color : context.healthTheme.textSecondary;
    final texts = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (node.showEventTime) ...<Widget>[
          Text(
            _time(node.time),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: node.dimension == DailyRhythmDimension.activity
                  ? availableColor
                  : context.healthTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          node.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: context.healthTheme.textPrimary,
          ),
        ),
      ],
    );
    final icon = Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: node.isAvailable
            ? background
            : context.healthTheme.surfaceSoft,
        shape: BoxShape.circle,
      ),
      child: HealthVectorIcon(
        _dimensionIcon(node.dimension),
        size: 16,
        weight: 500,
        color: availableColor,
      ),
    );
    return Semantics(
      button: true,
      label: node.showEventTime
          ? '${_time(node.time)} ${node.title}'
          : node.title,
      child: InkWell(
        key: Key('rhythm-node-${node.dimension.name}'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: DailyRhythmLayout.nodeBlockHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: placement == RhythmInfoPlacement.above
                ? <Widget>[
                    texts,
                    const SizedBox(height: 5),
                    icon,
                  ]
                : <Widget>[
                    icon,
                    const SizedBox(height: 5),
                    texts,
                  ],
          ),
        ),
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.x,
    required this.top,
    required this.icon,
    required this.label,
    required this.color,
  });

  final double x;
  final double top;
  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: top,
      width: 42,
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            HealthVectorIcon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.healthTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmCurvePainter extends CustomPainter {
  _RhythmCurvePainter({
    required this.traceNorm,
    required this.nodes,
    required this.colors,
    required this.animProgress,
    required this.animationCompleted,
    required this.timelineHeight,
    required this.window,
  });

  final double traceNorm;
  final List<DailyRhythmNode> nodes;
  final List<Color> colors;
  final double animProgress;
  final bool animationCompleted;
  final double timelineHeight;
  final DailyRhythmWindow window;

  @override
  void paint(Canvas canvas, Size size) {
    final trace = DailyRhythmCurveGeometry.pathFromStart(
      size.width,
      traceNorm,
      timelineHeight,
    );
    canvas.drawPath(
      trace,
      Paint()
        ..color = const Color(0xFF9FA9A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    for (final node in nodes) {
      final appear = DailyRhythmReveal.nodeAppear(
        nodeTime: node.time,
        window: window,
        animProgress: animProgress,
        animationCompleted: animationCompleted,
      );
      if (appear <= 0) {
        continue;
      }
      final center = _curvePoint(node.time, size.width, timelineHeight, window);
      final color = colors[node.dimension.index];
      final dotColor = node.isAvailable ? color : const Color(0xFFB9B7B0);
      final ringRadius = DailyRhythmLayout.arcNodeRingRadius *
          (animationCompleted ? 1 : (0.55 + 0.45 * appear));
      final dotRadius = DailyRhythmLayout.arcNodeDotRadius *
          (animationCompleted ? 1 : (0.55 + 0.45 * appear));
      final opacity = animationCompleted ? 1.0 : appear;
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
      canvas.drawCircle(
        center,
        dotRadius,
        Paint()..color = dotColor.withOpacity(opacity),
      );
    }

  }

  @override
  bool shouldRepaint(covariant _RhythmCurvePainter oldDelegate) {
    return oldDelegate.traceNorm != traceNorm ||
        oldDelegate.animProgress != animProgress ||
        oldDelegate.animationCompleted != animationCompleted ||
        oldDelegate.timelineHeight != timelineHeight ||
        oldDelegate.window != window ||
        oldDelegate.nodes != nodes;
  }
}

Offset _curvePoint(
  DateTime time,
  double width,
  double timelineHeight,
  DailyRhythmWindow window,
) {
  return DailyRhythmCurveGeometry.pointForTime(
    time,
    width,
    window,
    timelineHeight,
  );
}

/// 节奏轴入场动效：弧线从早晨扫到现在，节点随扫掠尖端经过依次亮起。
class DailyRhythmReveal {
  const DailyRhythmReveal._();

  static const double _nodeFadeWindow = 0.18;

  static double traceNorm({
    required double animProgress,
    required bool animationCompleted,
  }) {
    if (animationCompleted) {
      return 1;
    }
    return animProgress.clamp(0.0, 1.0);
  }

  static double nodeAppear({
    required DateTime nodeTime,
    required DailyRhythmWindow window,
    required double animProgress,
    required bool animationCompleted,
  }) {
    if (animationCompleted) {
      return 1;
    }
    final nodeNorm = DailyRhythmCurveGeometry.normalizedForTime(
      nodeTime,
      window,
    );
    return _fadeIn(animProgress, nodeNorm, _nodeFadeWindow);
  }

  static double _fadeIn(double sweepNorm, double targetNorm, double window) {
    final value =
        ((sweepNorm - (targetNorm - window)) / window).clamp(0.0, 1.0);
    return Curves.easeOut.transform(value);
  }
}

/// 节奏轴整体尺寸与标签定位常量。
class DailyRhythmLayout {
  const DailyRhythmLayout._();

  static const double timelineHeight = 232;
  static const double endpointWidth = 42;
  static const double nodeBlockWidth = 64;
  static const double nodeBlockHalfWidth = nodeBlockWidth / 2;
  static const double nodeBlockHeight = 72;
  static const double nodeArcGap = 6;
  static const double arcNodeRingRadius = 7;
  static const double arcNodeDotRadius = 4;

  static double nodeBlockTop({
    required double dotY,
    required RhythmInfoPlacement placement,
  }) {
    if (placement == RhythmInfoPlacement.above) {
      return dotY -
          arcNodeRingRadius -
          nodeArcGap -
          nodeBlockHeight;
    }
    return dotY + arcNodeRingRadius + nodeArcGap;
  }
}

/// 节点信息相对弧线的上下方位。
enum RhythmInfoPlacement { above, below }

/// 单个节点信息的布局结果（横向中心 + 上下方位）。
class DailyRhythmLabelSlot {
  const DailyRhythmLabelSlot({
    required this.centerX,
    required this.placement,
  });

  final double centerX;
  final RhythmInfoPlacement placement;
}

/// 节奏轴节点信息的纵向错峰布局。
///
/// 标签与弧线上的圆点共用真实曲线 X，不做横向推开，避免文字/图标与圆点错位。
/// 当相邻节点在时间上过近时，仅通过上下交替（above / below）减轻遮挡。
class DailyRhythmLabelLayout {
  const DailyRhythmLabelLayout._();

  // 曲线 X 间距低于此值时，认为需要上下错位。
  static const double _verticalStaggerThreshold = 56;

  static List<DailyRhythmLabelSlot> arrangeSlots({
    required List<double> dotXs,
  }) {
    if (dotXs.isEmpty) {
      return const <DailyRhythmLabelSlot>[];
    }
    final placements = List<RhythmInfoPlacement>.filled(
      dotXs.length,
      RhythmInfoPlacement.above,
    );
    for (var index = 1; index < dotXs.length; index++) {
      if (dotXs[index] - dotXs[index - 1] < _verticalStaggerThreshold) {
        placements[index] = placements[index - 1] == RhythmInfoPlacement.above
            ? RhythmInfoPlacement.below
            : RhythmInfoPlacement.above;
      }
    }
    return List<DailyRhythmLabelSlot>.generate(
      dotXs.length,
      (int index) => DailyRhythmLabelSlot(
        centerX: dotXs[index],
        placement: placements[index],
      ),
      growable: false,
    );
  }

  /// 保留给测试：极端横向重叠时仍可做有限推开，但 UI 不再用推开后的 X 定位标签。
  static List<double> spread(List<double> dotXs, double width) {
    if (dotXs.isEmpty) {
      return const <double>[];
    }
    const endpointReserve = DailyRhythmLayout.endpointWidth;
    const halfCard = DailyRhythmLayout.nodeBlockHalfWidth;
    const minSpacing = DailyRhythmLayout.nodeBlockWidth;
    final minCenter =
        DailyRhythmCurveGeometry.arcHorizontalInset + halfCard;
    final maxCenter = width -
        DailyRhythmCurveGeometry.arcHorizontalInset -
        halfCard;
    if (maxCenter <= minCenter) {
      return List<double>.filled(dotXs.length, minCenter);
    }

    final result = List<double>.from(dotXs);
    for (var index = 0; index < result.length; index++) {
      result[index] = result[index].clamp(minCenter, maxCenter);
    }
    for (var index = 1; index < result.length; index++) {
      final minAllowed = result[index - 1] + minSpacing;
      if (result[index] < minAllowed) {
        result[index] = minAllowed;
      }
    }
    if (result.last > maxCenter) {
      result[result.length - 1] = maxCenter;
      for (var index = result.length - 2; index >= 0; index--) {
        final maxAllowed = result[index + 1] - minSpacing;
        if (result[index] > maxAllowed) {
          result[index] = maxAllowed;
        }
      }
    }
    return result;
  }
}

class DailyRhythmCurveGeometry {
  const DailyRhythmCurveGeometry._();

  static const int _segmentCount = 64;
  // 弧线两端与早晨/晚间图标的水平留白（大于端点图标宽度 42，形成可见间距）。
  static const double arcHorizontalInset = 52;
  // 正弦波振幅占时间轴高度的比例；越小弧线越平。
  static const double arcAmplitudeRatio = 0.11;

  static double arcStartX(double width) => arcHorizontalInset;

  static double arcEndX(double width) => width - arcHorizontalInset;

  static Path pathForWidth(double width, [double? timelineHeight]) {
    final height = timelineHeight ?? DailyRhythmLayout.timelineHeight;
    final path = Path();
    for (var index = 0; index <= _segmentCount; index++) {
      final point = _pointAt(index / _segmentCount, width, height);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  static Path pathFromStart(
    double width,
    double endNorm, [
    double? timelineHeight,
  ]) {
    final height = timelineHeight ?? DailyRhythmLayout.timelineHeight;
    final path = Path();
    final clamped = endNorm.clamp(0.0, 1.0);
    if (clamped <= 0) {
      return path;
    }
    final start = _pointAt(0, width, height);
    path.moveTo(start.dx, start.dy);
    final fullEnd = clamped * _segmentCount;
    final wholeIndex = fullEnd.floor();
    for (var index = 1; index <= wholeIndex; index++) {
      final point = _pointAt(index / _segmentCount, width, height);
      path.lineTo(point.dx, point.dy);
    }
    if (wholeIndex < _segmentCount && fullEnd > wholeIndex) {
      final prev = _pointAt(wholeIndex / _segmentCount, width, height);
      final next = _pointAt((wholeIndex + 1) / _segmentCount, width, height);
      final t = fullEnd - wholeIndex;
      path.lineTo(
        prev.dx + (next.dx - prev.dx) * t,
        prev.dy + (next.dy - prev.dy) * t,
      );
    }
    return path;
  }

  static Offset pointForTime(
    DateTime time,
    double width,
    DailyRhythmWindow window, [
    double? timelineHeight,
  ]) {
    return _pointAt(
      normalizedForTime(time, window),
      width,
      timelineHeight,
    );
  }

  static double normalizedForTime(
    DateTime time,
    DailyRhythmWindow window,
  ) {
    return window.normalizedFor(time);
  }

  static Offset _pointAt(
    double normalized,
    double width, [
    double? timelineHeight,
  ]) {
    final height = timelineHeight ?? DailyRhythmLayout.timelineHeight;
    final centerY = height * 0.64;
    final amplitude = height * arcAmplitudeRatio;
    final x = arcHorizontalInset + normalized * (width - arcHorizontalInset * 2);
    final y = centerY - math.sin(normalized * math.pi) * amplitude;
    return Offset(x, y);
  }
}

List<Color> _dimensionColors(BuildContext context) => <Color>[
      context.healthTheme.sage,
      context.healthTheme.sand,
      context.healthTheme.coral,
      context.healthTheme.blue,
    ];

Color _dimensionColor(
  BuildContext context,
  DailyRhythmDimension dimension,
) {
  return _dimensionColors(context)[dimension.index];
}

Color _dimensionBackground(
  BuildContext context,
  DailyRhythmDimension dimension,
) {
  return <Color>[
    context.healthTheme.sageSoft,
    context.healthTheme.sandSoft,
    context.healthTheme.coralSoft,
    context.healthTheme.blueSoft,
  ][dimension.index];
}

String _dimensionIcon(DailyRhythmDimension dimension) {
  return <String>[
    'directions_walk',
    'chair_alt',
    'graphic_eq',
    'phone_iphone',
  ][dimension.index];
}

String _time(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
