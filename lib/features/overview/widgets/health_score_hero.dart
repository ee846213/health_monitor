import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';

const Color _heroSurface = Color(0xFFEEF3EA);
const Color _heroRing = Color(0xFF5E775F);
const Color _heroTrack = Color(0xFFD4DDCF);
const Color _heroText = Color(0xFF1F2320);
const Color _heroMuted = Color(0xFF556056);
const Color _heroLine = Color(0xFFD3D9CC);

class HealthScoreHero extends StatelessWidget {
  const HealthScoreHero({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _heroSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _heroLine),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const _ScoreRing(),
                    const _HealthScoreValue(),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '当日聚合数据',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _heroMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '步数 40% · 久坐 40% · 屏幕 20%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _heroText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _HealthScoreSummaryText(),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _StepMetricPill(),
                        _SedentaryMetricPill(),
                        _ScreenMetricPill(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends ConsumerWidget {
  const _ScoreRing();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(overviewHealthScoreProgressProvider);
    return CustomPaint(
      size: const Size.square(120),
      painter: _ScoreRingPainter(progress: progress),
    );
  }
}

class _HealthScoreValue extends ConsumerWidget {
  const _HealthScoreValue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewHealthScoreValueProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          '综合健康分',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _heroMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: _heroText,
          ),
        ),
      ],
    );
  }
}

class _HealthScoreSummaryText extends ConsumerWidget {
  const _HealthScoreSummaryText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(overviewHealthScoreSummaryProvider);
    return Text(
      summary,
      style: const TextStyle(
        fontSize: 13,
        height: 1.6,
        color: _heroMuted,
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _heroText,
        ),
      ),
    );
  }
}

class _StepMetricPill extends ConsumerWidget {
  const _StepMetricPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewHealthScoreStepPillProvider);
    return _MetricPill(value: value);
  }
}

class _SedentaryMetricPill extends ConsumerWidget {
  const _SedentaryMetricPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewHealthScoreSedentaryPillProvider);
    return _MetricPill(value: value);
  }
}

class _ScreenMetricPill extends ConsumerWidget {
  const _ScreenMetricPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewHealthScoreScreenPillProvider);
    return _MetricPill(value: value);
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = _heroTrack
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = _heroRing
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
