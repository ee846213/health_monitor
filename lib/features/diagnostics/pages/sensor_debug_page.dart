import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

class SensorDebugPage extends ConsumerWidget {
  const SensorDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(diagnosticsSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('采集调试'),
      ),
      body: snapshotAsync.when(
        data: (DiagnosticsSnapshot snapshot) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _SectionCard(
                title: '权限状态',
                child: Text(_permissionSummary(snapshot.permissionStatuses)),
              ),
              _SectionCard(
                title: '实时活动样本',
                child: Text(_activitySummary(snapshot.liveActivity)),
              ),
              _SectionCard(
                title: '最近活动样本',
                child: Text(_activitySummary(snapshot.latestActivity)),
              ),
              _SectionCard(
                title: '最近位置摘要',
                child: Text(_locationSummary(snapshot.latestLocationSummary)),
              ),
              _SectionCard(
                title: '最近环境噪音',
                child: Text(_noiseSummary(snapshot.latestNoise)),
              ),
              _SectionCard(
                title: '实时数字生活入口',
                child: Text(_usageSummary(snapshot.liveUsageSummary)),
              ),
              _SectionCard(
                title: '最近数字生活',
                child: Text(_usageSummary(snapshot.latestUsageSummary)),
              ),
              _SectionCard(
                title: '本地写入状态',
                child: Text(snapshot.storageStatus.label),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          return Center(
            child: Text('调试页加载失败：$error'),
          );
        },
      ),
    );
  }

  String _permissionSummary(Map<PermissionType, PermissionGrantStatus> statuses) {
    if (statuses.isEmpty) {
      return '暂无权限状态';
    }

    final entries = statuses.entries.map((MapEntry<PermissionType, PermissionGrantStatus> entry) {
      return '${entry.key.name}: ${entry.value.name}';
    });
    return entries.join('\n');
  }

  String _activitySummary(ActivitySample? sample) {
    if (sample == null) {
      return '暂无活动样本';
    }
    return '${sample.type.name} · ${sample.duration.inMinutes} 分钟';
  }

  String _locationSummary(LocationSummary? summary) {
    if (summary == null) {
      return '暂无位置摘要';
    }
    return '距离 ${summary.distanceMeters.toStringAsFixed(0)} 米 · 户外 ${summary.outdoorDuration.inMinutes} 分钟';
  }

  String _noiseSummary(NoiseSample? sample) {
    if (sample == null) {
      return '暂无噪音样本';
    }
    return '${sample.level.name} · ${sample.decibel.toStringAsFixed(0)} dB';
  }

  String _usageSummary(DigitalUsageSummary? summary) {
    if (summary == null) {
      return '暂无数字生活摘要';
    }
    return '${summary.topCategory.name} · 亮屏 ${summary.screenOnDuration.inHours} 小时';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
