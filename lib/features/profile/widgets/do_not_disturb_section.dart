import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';

const Color _surface = Color(0xFFF0ECE4);
const Color _cardSurface = Color(0xFFFFFDF8);
const Color _line = Color(0xFFDDD8CF);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);

class DoNotDisturbSection extends ConsumerWidget {
  const DoNotDisturbSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPreference = ref.watch(notificationPreferenceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: asyncPreference.when(
        loading: () => const SizedBox(
          height: 96,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, StackTrace _) => const Text(
          '勿扰设置加载失败',
          style: TextStyle(color: _textSecondary),
        ),
        data: (NotificationPreference preference) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '勿扰时段',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '提醒通知会避开这段时间，减少夜间打扰。',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              _SettingRow(
                title: '启用勿扰',
                subtitle: preference.enabled ? '当前已生效' : '关闭后将全天允许提醒',
                trailing: Switch(
                  value: preference.enabled,
                  onChanged: (bool enabled) {
                    ref
                        .read(notificationPreferenceProvider.notifier)
                        .save(preference.copyWith(enabled: enabled));
                  },
                ),
              ),
              const SizedBox(height: 10),
              _TimeSettingRow(
                title: '开始时间',
                value: preference.startLabel,
                onTap: () => _pickTime(
                  context: context,
                  initialValue: TimeOfDay(
                    hour: preference.startHour,
                    minute: preference.startMinute,
                  ),
                  onSaved: (TimeOfDay time) {
                    return preference.copyWith(
                      startHour: time.hour,
                      startMinute: time.minute,
                    );
                  },
                  ref: ref,
                ),
              ),
              const SizedBox(height: 10),
              _TimeSettingRow(
                title: '结束时间',
                value: preference.endLabel,
                onTap: () => _pickTime(
                  context: context,
                  initialValue: TimeOfDay(
                    hour: preference.endHour,
                    minute: preference.endMinute,
                  ),
                  onSaved: (TimeOfDay time) {
                    return preference.copyWith(
                      endHour: time.hour,
                      endMinute: time.minute,
                    );
                  },
                  ref: ref,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '最小可用版本仅控制开始和结束时间，后续再扩展提醒类型与强度。',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: _textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickTime({
    required BuildContext context,
    required TimeOfDay initialValue,
    required NotificationPreference Function(TimeOfDay time) onSaved,
    required WidgetRef ref,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialValue,
    );
    if (picked == null) {
      return;
    }

    await ref
        .read(notificationPreferenceProvider.notifier)
        .save(onSaved(picked));
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _TimeSettingRow extends StatelessWidget {
  const _TimeSettingRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _textMuted),
          ],
        ),
      ),
    );
  }
}
