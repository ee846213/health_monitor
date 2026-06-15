import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

const Color _surface = Color(0xFFFFFDF8);
const Color _surfaceSoft = Color(0xFFF0ECE4);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);
const Color _line = Color(0xFFDDD8CF);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncViewModel = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        title: const Text(
          '我的',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        backgroundColor: _surface,
        elevation: 0,
      ),
      body: asyncViewModel.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) =>
            const Center(child: Text('加载我的页面失败')),
        data: (OverviewViewModel viewModel) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MyRemindersCard(viewModel: viewModel),
                const SizedBox(height: 20),
                const _ReminderPrefsCard(),
                const SizedBox(height: 20),
                _PermissionStatusCard(viewModel: viewModel),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MyRemindersCard extends StatelessWidget {
  const _MyRemindersCard({required this.viewModel});

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final latestReminder =
        viewModel.reminders.isEmpty ? null : viewModel.reminders.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '我的提醒',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '今天提醒 ${viewModel.reminders.length} 次',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            latestReminder == null
                ? '今天还没有触发提醒。'
                : '最近一条是 ${_timeLabel(latestReminder.triggeredAt)} 的“${latestReminder.title}”。',
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
          const SizedBox(height: 12),
          _ActionRow(
            title: '进入提醒记录',
            subtitle: '查看时间、提醒文案和触发原因',
            actionLabel: '查看',
            onTap: () => context.push('/reminders'),
          ),
        ],
      ),
    );
  }
}

class _ReminderPrefsCard extends StatelessWidget {
  const _ReminderPrefsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '提醒与显示偏好',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 10),
          _ValueRow(title: '久坐提醒强度', value: '轻柔'),
          SizedBox(height: 8),
          _ValueRow(title: '夜间减少提醒', value: '已开启'),
          SizedBox(height: 8),
          _ValueRow(title: '简报提醒时间', value: '20:30'),
          SizedBox(height: 8),
          _ValueRow(title: '扩展观察显示', value: '仅显示重点'),
        ],
      ),
    );
  }
}

class _PermissionStatusCard extends ConsumerWidget {
  const _PermissionStatusCard({required this.viewModel});

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionRows = <_PermissionRowData>[
      _PermissionRowData(
        type: PermissionType.motion,
        title: '活动识别',
        subtitle: '用于步行、久坐和活动节律判断。',
        status: viewModel.permissionStatuses[PermissionType.motion],
      ),
      _PermissionRowData(
        type: PermissionType.location,
        title: '位置',
        subtitle: '用于判断室内外和活动范围。',
        status: viewModel.permissionStatuses[PermissionType.location],
      ),
      _PermissionRowData(
        type: PermissionType.microphone,
        title: '麦克风环境噪音',
        subtitle: '用于环境噪音等级评估，不保存原始音频。',
        status: viewModel.permissionStatuses[PermissionType.microphone],
      ),
      _PermissionRowData(
        type: PermissionType.usageAccess,
        title: '数字生活习惯分析',
        subtitle: '用于判断看屏频率和碎片化查看时段。',
        status: viewModel.permissionStatuses[PermissionType.usageAccess],
      ),
    ].where((_PermissionRowData row) {
      // Usage Access 只在 Android 上有稳定的系统入口，iPhone 不展示，
      // 避免把“平台不支持”误导成“用户没开权限”。
      if (row.type == PermissionType.usageAccess &&
          defaultTargetPlatform != TargetPlatform.android) {
        return false;
      }
      return true;
    }).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '权限与感知状态',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...permissionRows.map(
            (_PermissionRowData row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ActionRow(
                title: row.title,
                subtitle: row.subtitle,
                actionLabel: _permissionLabel(row.status),
                onTap: () => _handlePermissionTap(context, ref, row),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermissionTap(
    BuildContext context,
    WidgetRef ref,
    _PermissionRowData row,
  ) async {
    if (row.status == PermissionGrantStatus.granted) {
      _showFeedback(context, '“${row.title}”已开启，当前感知链路可正常使用。');
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  row.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  row.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '如果系统仍允许再次申请，我们会先在当前页请求权限；如果系统已永久拒绝，再引导你前往设置页开启。',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('稍后再说'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('立即处理'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final service = ref.read(permissionInteractionServiceProvider);
    final result = await service.handlePermissionTap(row.type);

    if (!context.mounted) {
      return;
    }

    // 权限处理结束后立刻失效相关状态，避免用户从系统设置返回时仍停留在旧快照。
    // 这里不直接重建页面，而是让首页、我的页面和诊断页按各自 provider 自己重算。
    ref.invalidate(permissionStatusProvider);
    ref.invalidate(overviewViewModelProvider);
    ref.invalidate(diagnosticsSnapshotProvider);

    switch (result) {
      case PermissionActionResult.granted:
        _showFeedback(context, '“${row.title}”已开启，请返回后刷新当前状态。');
      case PermissionActionResult.denied:
        _showFeedback(context, '“${row.title}”仍未开启，当前将继续按降级模式运行。');
      case PermissionActionResult.openedSettings:
        _showFeedback(context, '系统已打开设置页，请开启“${row.title}”后返回应用。');
      case PermissionActionResult.settingsUnavailable:
        _showFeedback(context, '暂时无法打开系统设置页，请稍后重试。');
    }
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
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
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
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
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRowData {
  const _PermissionRowData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final PermissionType type;
  final String title;
  final String subtitle;
  final PermissionGrantStatus? status;
}

String _permissionLabel(PermissionGrantStatus? status) {
  switch (status) {
    case PermissionGrantStatus.granted:
      return '已开启';
    case PermissionGrantStatus.denied:
      return '未开启';
    case PermissionGrantStatus.restricted:
      return '去设置';
    case PermissionGrantStatus.unknown:
    case null:
      return '待确认';
  }
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
