import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health_monitor/app/theme/app_vector_icons.dart';

/// 渲染与 Pencil 设计稿同源的 Material Symbols Rounded SVG。
class HealthVectorIcon extends StatelessWidget {
  const HealthVectorIcon(
    this.icon, {
    super.key,
    required this.size,
    this.color,
    this.weight = 400,
    this.semanticLabel,
  });

  final String icon;
  final double size;
  final Color? color;
  final int weight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppVectorIcons.path(icon, weight: weight),
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
