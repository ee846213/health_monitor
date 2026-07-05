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
                      fontFamily:
                          Theme.of(context).textTheme.bodyMedium?.fontFamily,
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

/// 顶部导航图标按钮：保留 36x36 点击热区，只显示图标本身。
class HealthNavIconButton extends StatelessWidget {
  const HealthNavIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.semanticLabel,
    this.iconSize = 18,
    this.weight = 400,
  });

  final String icon;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double iconSize;
  final int weight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 36,
            child: Center(
              child: HealthVectorIcon(
                icon,
                size: iconSize,
                weight: weight,
                color: tokens.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 提醒记录页顶部筛选胶囊，对齐设计稿「全部 ▾」样式。
class HealthNavFilterChip extends StatelessWidget {
  const HealthNavFilterChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return Semantics(
      button: true,
      label: '筛选：$label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDE6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                HealthVectorIcon(
                  'keyboard_arrow_down',
                  size: 12,
                  color: tokens.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 一级 / 二级页面统一顶部导航栏：居中 18pt 标题，左右对称操作区。
class HealthPageHeader extends StatelessWidget {
  const HealthPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.trailing,
    this.trailingWidth = 36,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget? trailing;

  /// 右侧控件宽度，用于在无返回按钮时保持标题居中。
  final double trailingWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    final Widget left = leading ??
        (onBack != null
            ? HealthNavIconButton(
                icon: 'chevron_left',
                iconSize: 19,
                onTap: onBack,
                semanticLabel: '返回',
              )
            : SizedBox(width: trailingWidth));
    final Widget right = trailing ?? SizedBox(width: trailingWidth);

    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[left, right],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ),
        ],
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
