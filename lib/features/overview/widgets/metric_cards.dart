import 'package:flutter/material.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';

const Color _metricSurface = Color(0xFFF8F3EA);
const Color _metricSand = Color(0xFFF3E6D4);
const Color _metricBlue = Color(0xFFE8F0F1);
const Color _metricText = Color(0xFF1F2320);
const Color _metricMuted = Color(0xFF58605A);
const Color _metricLine = Color(0xFFDDD8CF);

class MetricCards extends StatelessWidget {
  const MetricCards({
    super.key,
    required this.snapshot,
    this.onStepTap,
    this.onSedentaryTap,
    this.onScreenTap,
  });

  final DashboardSnapshot snapshot;
  final VoidCallback? onStepTap;
  final VoidCallback? onSedentaryTap;
  final VoidCallback? onScreenTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricCard(
            key: const Key('metric-step-card'),
            title: '步数',
            value: '${snapshot.stepCard.currentSteps}',
            caption:
                '目标 ${snapshot.stepCard.goalSteps} · ${snapshot.stepCard.achievementPercent}%',
            backgroundColor: _metricSurface,
            onTap: onStepTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            key: const Key('metric-sedentary-card'),
            title: '久坐',
            value: '${snapshot.sedentaryCard.totalMinutes}',
            caption: '最长 ${snapshot.sedentaryCard.longestSingleMinutes} 分钟',
            backgroundColor: _metricSand,
            onTap: onSedentaryTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            key: const Key('metric-screen-card'),
            title: '屏幕',
            value: '${snapshot.screenCard.totalMinutes}',
            caption: _screenCaption(snapshot.screenCard),
            backgroundColor: _metricBlue,
            onTap: onScreenTap,
          ),
        ),
      ],
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
  final String value;
  final String caption;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _metricText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: _metricMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _screenCaption(DashboardScreenCard card) {
  switch (card.changeDirection) {
    case DashboardChangeDirection.up:
      return '较昨日 ↑ ${card.yesterdayDeltaMinutes.abs()} 分钟';
    case DashboardChangeDirection.down:
      return '较昨日 ↓ ${card.yesterdayDeltaMinutes.abs()} 分钟';
    case DashboardChangeDirection.steady:
      return '和昨日基本持平';
  }
}
