import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';

class HealthElevatedCard extends StatelessWidget {
  const HealthElevatedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    final borderRadius = BorderRadius.circular(radius ?? tokens.cardRadius);
    return HealthPressableSurface(
      onTap: onTap,
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? tokens.surface,
          borderRadius: borderRadius,
          boxShadow: tokens.cardShadow,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class HealthIconBubble extends StatelessWidget {
  const HealthIconBubble({
    super.key,
    required this.icon,
    required this.foreground,
    required this.background,
    this.size = 34,
    this.iconSize = 19,
    this.weight = 400,
    this.semanticLabel,
  });

  final String icon;
  final Color foreground;
  final Color background;
  final double size;
  final double iconSize;
  final int weight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Center(
          child: HealthVectorIcon(
            icon,
            size: iconSize,
            weight: weight,
            color: foreground,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

class HealthSegmentedControl<T> extends StatelessWidget {
  const HealthSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    final motion = context.healthMotion;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: values.map((value) {
          final active = value == selected;
          return Expanded(
            child: Semantics(
              selected: active,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: context.motionDuration(motion.base),
                  curve: motion.standardCurve,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? tokens.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: active
                        ? const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0D3D392F),
                              blurRadius: 9,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: context.motionDuration(motion.fast),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? tokens.sage : tokens.textSecondary,
                    ),
                    child: Text(labelBuilder(value)),
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class HealthAnimatedExpand extends StatelessWidget {
  const HealthAnimatedExpand({
    super.key,
    required this.expanded,
    required this.child,
  });

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1 : 0,
        duration: context.motionDuration(motion.base),
        curve: motion.standardCurve,
        child: AnimatedOpacity(
          opacity: expanded ? 1 : 0,
          duration: context.motionDuration(motion.base),
          child: child,
        ),
      ),
    );
  }
}
