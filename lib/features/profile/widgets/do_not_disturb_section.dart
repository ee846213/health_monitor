import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';

class DoNotDisturbSection extends ConsumerWidget {
  const DoNotDisturbSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(notificationPreferenceProvider);
    return preference.when(
      loading: () => const SizedBox(
        height: 68,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => HealthElevatedCard(
        child: Text('勿扰设置加载失败', style: context.healthTheme.bodyStyle),
      ),
      data: (value) => _SettingsRow(
        key: const Key('do-not-disturb-row'),
        icon: 'bedtime',
        title: '勿扰时间',
        subtitle: value.enabled
            ? '${value.startLabel}–${value.endLabel}'
            : '已关闭，时间设置会保留',
        color: context.healthTheme.blue,
        onTap: () => _showEditor(context, ref, value),
      ),
    );
  }
}

Future<void> _showEditor(
  BuildContext context,
  WidgetRef ref,
  NotificationPreference initial,
) async {
  var draft = initial;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.healthTheme.surface,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        final valid = draft.startHour != draft.endHour ||
            draft.startMinute != draft.endMinute;
        return PopScope(
          canPop: true,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                20 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('勿扰时间', style: context.healthTheme.sectionTitleStyle),
                  const SizedBox(height: 6),
                  Text(
                    '勿扰期只阻止主动通知，提醒记录仍会保留。',
                    style: context.healthTheme.bodyStyle,
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('启用勿扰'),
                    value: draft.enabled,
                    onChanged: (enabled) {
                      setModalState(() {
                        draft = draft.copyWith(enabled: enabled);
                      });
                    },
                  ),
                  _TimeRow(
                    title: '开始时间',
                    value: draft.startLabel,
                    onTap: () async {
                      final value = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: draft.startHour,
                          minute: draft.startMinute,
                        ),
                      );
                      if (value != null) {
                        setModalState(() {
                          draft = draft.copyWith(
                            startHour: value.hour,
                            startMinute: value.minute,
                          );
                        });
                      }
                    },
                  ),
                  _TimeRow(
                    title: '结束时间',
                    value: draft.endLabel,
                    onTap: () async {
                      final value = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: draft.endHour,
                          minute: draft.endMinute,
                        ),
                      );
                      if (value != null) {
                        setModalState(() {
                          draft = draft.copyWith(
                            endHour: value.hour,
                            endMinute: value.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: valid
                          ? () async {
                              try {
                                await ref
                                    .read(
                                        notificationPreferenceProvider.notifier)
                                    .save(draft);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (_) {
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('保存失败，已恢复原设置'),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value, style: context.healthTheme.dataStyle),
          const SizedBox(width: 6),
          const HealthVectorIcon('chevron_right', size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            HealthIconBubble(
              icon: icon,
              foreground: color,
              background: color.withValues(alpha: .15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: context.healthTheme.sectionTitleStyle),
                  const SizedBox(height: 3),
                  Text(subtitle, style: context.healthTheme.bodyStyle),
                ],
              ),
            ),
            const HealthVectorIcon('chevron_right', size: 18),
          ],
        ),
      ),
    );
  }
}
