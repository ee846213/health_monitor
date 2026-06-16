import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';

const Color _heroSurface = Color(0xFFEEF3EA);
const Color _heroRing = Color(0xFF5E775F);
const Color _heroTrack = Color(0xFFD4DDCF);
const Color _heroText = Color(0xFF1F2320);
const Color _heroMuted = Color(0xFF556056);
const Color _heroLine = Color(0xFFD3D9CC);

class HealthScoreHero extends StatelessWidget {
  const HealthScoreHero({
    super.key,
    required this.snapshot,
    this.onTap,
  });

  final DashboardSnapshot snapshot;
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
                    CustomPaint(
                      size: const Size.square(120),
                      painter: _ScoreRingPainter(
                        progress: snapshot.healthScore.totalScore / 100,
                      ),
                    ),
                    Column(
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
                          '${snapshot.healthScore.totalScore}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: _heroText,
                          ),
                        ),
                      ],
                    ),
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
                    Text(
                      _scoreSummary(snapshot.healthScore.totalScore),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: _heroMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MetricPill(
                          label: '步数',
                          value: '${snapshot.healthScore.stepScore}',
                        ),
                        _MetricPill(
                          label: '久坐',
                          value: '${snapshot.healthScore.sedentaryScore}',
                        ),
                        _MetricPill(
                          label: '屏幕',
                          value: '${snapshot.healthScore.screenScore}',
                        ),
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

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
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
        '$label $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _heroText,
        ),
      ),
    );
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

String _scoreSummary(int score) {
  if (score >= 85) {
    return '今天整体节奏比较稳，适合继续保持当前活动边界。';
  }
  if (score >= 70) {
    return '整体状态还不错，再补一点步数或减少久坐会更漂亮。';
  }
  return '今天还有提升空间，先从最容易调整的一项开始就好。';
}
