import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/ios_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
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
                title: '后台采集状态',
                child: Text(_backgroundSummary(snapshot.backgroundCaptureState)),
              ),
              _SectionCard(
                title: 'Android 宿主状态',
                child: Text(_androidHostSummary(snapshot.androidHostStatus)),
              ),
              _SectionCard(
                title: 'iPhone 宿主状态',
                child: Text(_iosHostSummary(snapshot.iosHostStatus)),
              ),
              _SectionCard(
                title: 'Android 前台服务策略',
                child: Text(
                  _foregroundServiceSummary(
                    snapshot.androidForegroundServiceStrategy,
                  ),
                ),
              ),
              _SectionCard(
                title: 'iPhone 后台刷新策略',
                child: Text(
                  _iosBackgroundStrategySummary(
                    snapshot.iosBackgroundCaptureStrategy,
                  ),
                ),
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

  String _backgroundSummary(BackgroundCaptureState state) {
    return '${state.label} · ${state.reason}';
  }

  String _androidHostSummary(AndroidBackgroundCaptureHostStatus? status) {
    if (status == null) {
      return 'Android 宿主状态暂不可读，说明原生后台桥接尚未返回状态摘要。';
    }
    final errorSuffix = status.lastErrorMessage == null
        ? ''
        : ' · 最近异常：${status.lastErrorMessage}';
    final notificationSuffix = status.notificationBody == null
        ? ''
        : ' · 通知：${status.notificationBody}';
    return '${status.isRunning ? '运行中' : '未运行'} · ${status.summary}$errorSuffix$notificationSuffix';
  }

  String _iosHostSummary(IosBackgroundCaptureHostStatus? status) {
    if (status == null) {
      return 'iPhone 宿主状态暂不可读，说明原生后台桥接尚未返回状态摘要。';
    }
    final errorSuffix = status.lastErrorMessage == null
        ? ''
        : ' · 最近异常：${status.lastErrorMessage}';
    final notificationSuffix = status.notificationBody == null
        ? ''
        : ' · 通知：${status.notificationBody}';
    return '${status.isRunning ? '运行中' : '未运行'} · ${status.summary}$errorSuffix$notificationSuffix';
  }

  String _foregroundServiceSummary(AndroidForegroundServiceStrategy strategy) {
    final stateLabel = strategy.isEnabled ? '已启用' : '已降级';
    if (strategy.reasons.isEmpty) {
      return '$stateLabel · ${strategy.title} · ${strategy.body}';
    }
    return '$stateLabel · ${strategy.reasons.join('；')}';
  }

  String _iosBackgroundStrategySummary(IosBackgroundCaptureStrategy strategy) {
    final stateLabel = strategy.isEnabled ? '已启用' : '已降级';
    final restrictedLabel = strategy.isRestricted ? '受限' : '完整';
    final modeLabel = strategy.supportedModes.isEmpty
        ? '无可用模式'
        : strategy.supportedModes.join('、');
    if (strategy.reasons.isEmpty) {
      return '$stateLabel · $restrictedLabel · $modeLabel · ${strategy.title} · ${strategy.body}';
    }
    return '$stateLabel · $restrictedLabel · $modeLabel · ${strategy.reasons.join('；')}';
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
