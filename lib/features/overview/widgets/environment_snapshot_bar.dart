import 'package:flutter/material.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';

const Color _envSurface = Color(0xFFF4EFE7);
const Color _envText = Color(0xFF1F2320);
const Color _envMuted = Color(0xFF59615B);
const Color _envLine = Color(0xFFDDD8CF);

class EnvironmentSnapshotBar extends StatelessWidget {
  const EnvironmentSnapshotBar({
    super.key,
    required this.snapshot,
  });

  final DashboardEnvironmentSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _envSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _envLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '环境快照',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _envText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _EnvironmentItem(
                  icon: _lightEmoji(snapshot.lightLabel),
                  title: '光照',
                  value: snapshot.lightLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EnvironmentItem(
                  icon: _noiseEmoji(snapshot.noiseLabel),
                  title: '噪音',
                  value: snapshot.noiseLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnvironmentItem extends StatelessWidget {
  const _EnvironmentItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final String icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _envMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _envText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _lightEmoji(String label) {
  switch (label) {
    case '明亮':
      return '🌞';
    case '舒适':
      return '🌥';
    case '过暗':
      return '🌙';
    default:
      return '🫥';
  }
}

String _noiseEmoji(String label) {
  switch (label) {
    case '嘈杂':
      return '🔊';
    case '正常':
      return '🔉';
    case '安静':
      return '🔇';
    default:
      return '🫥';
  }
}
