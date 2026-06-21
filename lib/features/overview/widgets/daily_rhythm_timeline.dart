import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';

class DailyRhythmTimeline extends StatefulWidget {
  const DailyRhythmTimeline({
    super.key,
    required this.model,
    required this.onNodeTap,
    required this.onCurrentTimeTap,
  });

  final DailyRhythmUiModel model;
  final ValueChanged<DailyRhythmNode> onNodeTap;
  final ValueChanged<DateTime> onCurrentTimeTap;

  @override
  State<DailyRhythmTimeline> createState() => _DailyRhythmTimelineState();
}

class _DailyRhythmTimelineState extends State<DailyRhythmTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.reduceMotion;
    return SizedBox(
      height: 176,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final progress = reduceMotion ? 1.0 : _controller.value;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RhythmCurvePainter(
                        progress: progress,
                        nodes: widget.model.nodes,
                        colors: _dimensionColors(context),
                      ),
                    ),
                  ),
                  _Endpoint(
                    x: 0,
                    top: 102,
                    icon: 'wb_sunny',
                    label: '早晨',
                    color: context.healthTheme.sand,
                  ),
                  _Endpoint(
                    x: constraints.maxWidth - 42,
                    top: 104,
                    icon: 'dark_mode',
                    label: '晚间',
                    color: const Color(0xFF9A968E),
                  ),
                  ...List<Widget>.generate(widget.model.nodes.length, (index) {
                    final node = widget.model.nodes[index];
                    final p = _curvePoint(node.time, constraints.maxWidth);
                    final appear = Curves.easeOut.transform(
                      ((progress - index * .12) / .52).clamp(0, 1),
                    );
                    return Positioned(
                      left: p.dx - 32,
                      // 事件图标悬浮在曲线上方，曲线上的小圆点由 Painter 单独绘制。
                      // 这样当前时间点即使靠近某个事件，也不会与事件图标相互遮挡。
                      top: p.dy - 96,
                      width: 64,
                      child: Opacity(
                        opacity: appear,
                        child: Transform.translate(
                          offset: Offset(0, 8 * (1 - appear)),
                          child: _RhythmNodeView(
                            node: node,
                            color: _dimensionColor(context, node.dimension),
                            background:
                                _dimensionBackground(context, node.dimension),
                            onTap: () => widget.onNodeTap(node),
                          ),
                        ),
                      ),
                    );
                  }),
                  _CurrentTimeMarker(
                    time: widget.model.currentTime,
                    width: constraints.maxWidth,
                    progress: progress,
                    onTap: () =>
                        widget.onCurrentTimeTap(widget.model.currentTime),
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

class _RhythmNodeView extends StatelessWidget {
  const _RhythmNodeView({
    required this.node,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final DailyRhythmNode node;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final availableColor =
        node.isAvailable ? color : context.healthTheme.textSecondary;
    return Semantics(
      button: true,
      label: '${_time(node.time)} ${node.title}',
      child: InkWell(
        key: Key('rhythm-node-${node.dimension.name}'),
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          height: 92,
          child: Column(
            children: <Widget>[
              Text(
                _time(node.time),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: node.dimension == DailyRhythmDimension.activity
                      ? availableColor
                      : context.healthTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                node.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: context.healthTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: node.isAvailable
                      ? background
                      : context.healthTheme.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: HealthVectorIcon(
                  _dimensionIcon(node.dimension),
                  size: 18,
                  weight: 500,
                  color: availableColor,
                ),
              ),
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

class _CurrentTimeMarker extends StatelessWidget {
  const _CurrentTimeMarker({
    required this.time,
    required this.width,
    required this.progress,
    required this.onTap,
  });

  final DateTime time;
  final double width;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final point = _curvePoint(time, width);
    final x = point.dx;
    final y = point.dy;
    return Positioned(
      left: x - 31,
      top: y - 15,
      width: 62,
      child: Opacity(
        opacity: Curves.easeOut.transform(((progress - .5) * 2).clamp(0, 1)),
        child: Semantics(
          button: true,
          label: '当前状态 ${_time(time)}',
          child: InkWell(
            key: const Key('rhythm-current-time'),
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Column(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                    border: Border.all(color: context.healthTheme.orange),
                  ),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: context.healthTheme.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '现在 ${_time(time)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.healthTheme.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RhythmCurvePainter extends CustomPainter {
  _RhythmCurvePainter({
    required this.progress,
    required this.nodes,
    required this.colors,
  });

  final double progress;
  final List<DailyRhythmNode> nodes;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(42, 126)
      ..cubicTo(
        size.width * .25,
        95,
        size.width * .42,
        91,
        size.width * .52,
        92,
      )
      ..cubicTo(
        size.width * .70,
        93,
        size.width * .84,
        109,
        size.width - 42,
        126,
      );

    final metrics = path.computeMetrics().first;
    final extracted = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(
      extracted,
      Paint()
        ..color = const Color(0xFF9FA9A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    for (var index = 0; index < nodes.length; index++) {
      final center = _curvePoint(nodes[index].time, size.width);
      final available = nodes[index].isAvailable;
      canvas.drawCircle(
        center,
        7,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        center,
        4,
        Paint()..color = available ? colors[index] : const Color(0xFFB9B7B0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmCurvePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.nodes != nodes;
  }
}

Offset _curvePoint(DateTime time, double width) {
  final normalized = ((time.hour + time.minute / 60 - 6) / 16).clamp(0.0, 1.0);
  final x = 42 + normalized * (width - 84);
  final y = 126 - math.sin(normalized * math.pi) * 34;
  return Offset(x, y);
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
