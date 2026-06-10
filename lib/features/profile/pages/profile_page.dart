import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/services/permission_status_service.dart';

/// 我页 —— 展示当前设备能力状态与权限状态。
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final matrix = CapabilityMatrix.defaultMatrix();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('我'), backgroundColor: theme.colorScheme.surface),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacingXl),
        children: [
          Text('平台能力', style: tokens.sectionTitleStyle),
          SizedBox(height: tokens.spacingSm),
          _CapabilityRow(label: '活动识别', support: matrix.android.activityRecognition, tokens: tokens),
          _CapabilityRow(label: '位置摘要', support: matrix.android.locationSummary, tokens: tokens),
          _CapabilityRow(label: '环境噪音', support: matrix.android.environmentNoise, tokens: tokens),
          _CapabilityRow(label: '后台采集', support: matrix.android.backgroundCapture, tokens: tokens),
          _CapabilityRow(label: '数字生活替代', support: matrix.android.digitalUsageAlternative, tokens: tokens),
          SizedBox(height: tokens.spacingXl),
          Text('权限', style: tokens.sectionTitleStyle),
          SizedBox(height: tokens.spacingSm),
          for (final type in PermissionType.values)
            _PermissionRow(type: type, tokens: tokens),
        ],
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.label, required this.support, required this.tokens});
  final String label;
  final CapabilitySupport support;
  final HealthMonitorTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: tokens.bodyStyle)),
          Text(support.name, style: tokens.bodyStyle.copyWith(color: tokens.verdictNormalColor)),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.type, required this.tokens});
  final PermissionType type;
  final HealthMonitorTheme tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(type.name, style: tokens.bodyStyle)),
          const Text('-', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}