import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';

const Color _envSurface = Color(0xFFF4EFE7);
const Color _envText = Color(0xFF1F2320);
const Color _envMuted = Color(0xFF59615B);
const Color _envLine = Color(0xFFDDD8CF);

class EnvironmentSnapshotBar extends StatelessWidget {
  const EnvironmentSnapshotBar({super.key});

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
                child: _LightEnvironmentItem(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NoiseEnvironmentItem(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LightEnvironmentItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = ref.watch(overviewEnvironmentLightIconProvider);
    final value = ref.watch(overviewEnvironmentLightTextProvider);
    return _EnvironmentItem(
      icon: _lightEmoji(icon),
      title: '光照',
      value: value,
    );
  }
}

class _NoiseEnvironmentItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = ref.watch(overviewEnvironmentNoiseIconProvider);
    final value = ref.watch(overviewEnvironmentNoiseTextProvider);
    return _EnvironmentItem(
      icon: _noiseEmoji(icon),
      title: '噪音',
      value: value,
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

String _lightEmoji(OverviewEnvironmentLightIcon icon) {
  switch (icon) {
    case OverviewEnvironmentLightIcon.bright:
      return '🌞';
    case OverviewEnvironmentLightIcon.comfortable:
      return '🌥';
    case OverviewEnvironmentLightIcon.dark:
      return '🌙';
    case OverviewEnvironmentLightIcon.waiting:
      return '🫥';
  }
}

String _noiseEmoji(OverviewEnvironmentNoiseIcon icon) {
  switch (icon) {
    case OverviewEnvironmentNoiseIcon.loud:
      return '🔊';
    case OverviewEnvironmentNoiseIcon.normal:
      return '🔉';
    case OverviewEnvironmentNoiseIcon.quiet:
      return '🔇';
    case OverviewEnvironmentNoiseIcon.waiting:
      return '🫥';
  }
}
