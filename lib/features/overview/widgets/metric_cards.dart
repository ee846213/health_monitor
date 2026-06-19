import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';

const Color _metricSurface = Color(0xFFF8F3EA);
const Color _metricSand = Color(0xFFF3E6D4);
const Color _metricBlue = Color(0xFFE8F0F1);
const Color _metricText = Color(0xFF1F2320);
const Color _metricMuted = Color(0xFF58605A);
const Color _metricLine = Color(0xFFDDD8CF);

class MetricCards extends StatelessWidget {
  const MetricCards({
    super.key,
    this.onStepTap,
    this.onSedentaryTap,
    this.onScreenTap,
  });

  final VoidCallback? onStepTap;
  final VoidCallback? onSedentaryTap;
  final VoidCallback? onScreenTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _MetricCard(
              key: const Key('metric-step-card'),
              title: '步数',
              value: const _StepValueText(),
              caption: const _StepCaptionText(),
              backgroundColor: _metricSurface,
              onTap: onStepTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              key: const Key('metric-sedentary-card'),
              title: '久坐',
              value: const _SedentaryValueText(),
              caption: const _SedentaryCaptionText(),
              backgroundColor: _metricSand,
              onTap: onSedentaryTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              key: const Key('metric-screen-card'),
              title: '屏幕',
              value: const _ScreenValueText(),
              caption: const _ScreenCaptionText(),
              backgroundColor: _metricBlue,
              onTap: onScreenTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final Widget value;
  final Widget caption;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HealthPressableSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _metricLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _metricText,
              ),
            ),
            const SizedBox(height: 12),
            value,
            const SizedBox(height: 6),
            caption,
          ],
        ),
      ),
    );
  }
}

class _StepValueText extends ConsumerWidget {
  const _StepValueText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewStepValueTextProvider);
    return _MetricValueText(value: value);
  }
}

class _StepCaptionText extends ConsumerWidget {
  const _StepCaptionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = ref.watch(overviewStepCaptionTextProvider);
    return _MetricCaptionText(caption: caption);
  }
}

class _SedentaryValueText extends ConsumerWidget {
  const _SedentaryValueText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewSedentaryValueTextProvider);
    return _MetricValueText(value: value);
  }
}

class _SedentaryCaptionText extends ConsumerWidget {
  const _SedentaryCaptionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = ref.watch(overviewSedentaryCaptionTextProvider);
    return _MetricCaptionText(caption: caption);
  }
}

class _ScreenValueText extends ConsumerWidget {
  const _ScreenValueText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewScreenValueTextProvider);
    return _MetricValueText(value: value);
  }
}

class _ScreenCaptionText extends ConsumerWidget {
  const _ScreenCaptionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = ref.watch(overviewScreenCaptionTextProvider);
    return _MetricCaptionText(caption: caption);
  }
}

class _MetricValueText extends StatelessWidget {
  const _MetricValueText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return HealthAnimatedNumberText(
      value: value,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: _metricText,
      ),
    );
  }
}

class _MetricCaptionText extends StatelessWidget {
  const _MetricCaptionText({required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Text(
        caption,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          height: 1.5,
          color: _metricMuted,
        ),
      ),
    );
  }
}
