import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';

typedef HealthAnimatedValueBuilder = Widget Function(
  BuildContext context,
  double value,
  Widget? child,
);

/// 对任意数值变化执行平滑插值。
class HealthAnimatedValue extends StatelessWidget {
  const HealthAnimatedValue({
    super.key,
    required this.value,
    required this.builder,
    this.duration,
    this.curve,
    this.child,
  });

  final double value;
  final HealthAnimatedValueBuilder builder;
  final Duration? duration;
  final Curve? curve;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) {
      return builder(context, value, child);
    }
    final motion = context.healthMotion;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration ?? motion.data,
      curve: curve ?? motion.standardCurve,
      builder: builder,
      child: child,
    );
  }
}

/// 为包含一个整数的文案提供数值插值，单位和说明文字保持不变。
class HealthAnimatedNumberText extends StatelessWidget {
  const HealthAnimatedNumberText({
    super.key,
    required this.value,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'-?\d+').firstMatch(value);
    if (match == null) {
      return HealthAnimatedSwitcher(
        childKey: ValueKey<String>(value),
        child: Text(
          value,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
    }
    final target = double.parse(match.group(0)!);
    return HealthAnimatedValue(
      value: target,
      builder: (BuildContext context, double current, Widget? child) {
        final animatedText = value.replaceRange(
          match.start,
          match.end,
          current.round().toString(),
        );
        return Text(
          animatedText,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// 统一的淡入和轻微上移动效。
class HealthAnimatedSwitcher extends StatelessWidget {
  const HealthAnimatedSwitcher({
    super.key,
    required this.child,
    this.childKey,
    this.duration,
    this.offset = const Offset(0, 0.025),
  });

  final Widget child;
  final Key? childKey;
  final Duration? duration;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    final reduceMotion = context.reduceMotion;
    return AnimatedSwitcher(
      duration: context.motionDuration(duration ?? motion.base),
      switchInCurve: motion.standardCurve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: motion.standardCurve,
        );
        if (reduceMotion) {
          return FadeTransition(opacity: fade, child: child);
        }
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: offset, end: Offset.zero).animate(fade),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: childKey, child: child),
    );
  }
}

/// 页面首次出现时使用的错峰入场容器。
class HealthStaggeredEntrance extends StatefulWidget {
  const HealthStaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 0.035),
  });

  final Widget child;
  final int index;
  final Offset offset;

  @override
  State<HealthStaggeredEntrance> createState() =>
      _HealthStaggeredEntranceState();
}

class _HealthStaggeredEntranceState extends State<HealthStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacity;
  Animation<Offset>? _position;
  bool _configured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configured) {
      return;
    }
    _configured = true;
    if (context.reduceMotion) {
      return;
    }
    final motion = context.healthMotion;
    final delay = motion.stagger * widget.index;
    final total = delay + motion.emphasized;
    final start = total.inMicroseconds == 0
        ? 0.0
        : delay.inMicroseconds / total.inMicroseconds;
    _controller = AnimationController(vsync: this, duration: total);
    final curve = CurvedAnimation(
      parent: _controller!,
      curve: Interval(
        start.clamp(0, 1).toDouble(),
        1,
        curve: motion.standardCurve,
      ),
    );
    _opacity = curve;
    _position = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(curve);
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion || _controller == null) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _opacity!,
      child: SlideTransition(position: _position!, child: widget.child),
    );
  }
}

/// 带轻微按压反馈的通用交互表面。
class HealthPressableSurface extends StatefulWidget {
  const HealthPressableSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  State<HealthPressableSurface> createState() => _HealthPressableSurfaceState();
}

class _HealthPressableSurfaceState extends State<HealthPressableSurface> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    final reduceMotion = context.reduceMotion;
    return Semantics(
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: reduceMotion || !_pressed ? 1 : 0.98,
          duration: reduceMotion ? Duration.zero : motion.fast,
          curve: motion.standardCurve,
          child: widget.child,
        ),
      ),
    );
  }
}
