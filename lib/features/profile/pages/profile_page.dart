import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<HealthMonitorTheme>() ?? HealthMonitorTheme.fallback();
    final matrix = CapabilityMatrix.defaultMatrix();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('我'), backgroundColor: theme.colorScheme.surface),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacingXl),
        children: [
          _sectionTitle('平台能力', tokens),
          ...['活动识别', '位置摘要', '环境噪音', '后台采集'].map((l) => _row(l, 'supported', tokens)),
          SizedBox(height: tokens.spacingXl),
          _sectionTitle('权限', tokens),
          for (final t in PermissionType.values) _row(t.name, '', tokens),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, HealthMonitorTheme tokens) =>
      Padding(padding: EdgeInsets.only(bottom: tokens.spacingSm), child: Text(text, style: tokens.sectionTitleStyle));

  Widget _row(String label, String value, HealthMonitorTheme tokens) => Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: tokens.bodyStyle)),
          Text(value, style: tokens.bodyStyle.copyWith(color: tokens.verdictNormalColor)),
        ]),
      );
}