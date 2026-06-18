import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/ios_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/health/capture_checkpoint.dart';
import 'package:health_monitor/domain/health/capture_health_event.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('采集调试'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _DiagnosticsSection<Map<PermissionType, PermissionGrantStatus>>(
            title: '权限状态',
            selector: (snapshot) => snapshot.permissionStatuses,
            formatter: _permissionSummary,
          ),
          _DiagnosticsSection<ActivitySample?>(
            title: '实时活动样本',
            selector: (snapshot) => snapshot.liveActivity,
            formatter: _activitySummary,
          ),
          _DiagnosticsSection<ActivitySample?>(
            title: '最近活动样本',
            selector: (snapshot) => snapshot.latestActivity,
            formatter: _activitySummary,
          ),
          _DiagnosticsSection<LocationSummary?>(
            title: '最近位置摘要',
            selector: (snapshot) => snapshot.latestLocationSummary,
            formatter: _locationSummary,
          ),
          _DiagnosticsSection<NoiseSample?>(
            title: '最近环境噪音',
            selector: (snapshot) => snapshot.latestNoise,
            formatter: _noiseSummary,
          ),
          _DiagnosticsSection<AmbientLightSample?>(
            title: '最近环境光照',
            selector: (snapshot) => snapshot.latestLight,
            formatter: _lightSummary,
          ),
          _DiagnosticsSection<DigitalUsageSummary?>(
            title: '实时数字生活入口',
            selector: (snapshot) => snapshot.liveUsageSummary,
            formatter: _usageSummary,
          ),
          _DiagnosticsSection<DigitalUsageSummary?>(
            title: '最近数字生活',
            selector: (snapshot) => snapshot.latestUsageSummary,
            formatter: _usageSummary,
          ),
          _DiagnosticsSection<BackgroundCaptureState>(
            title: '后台采集状态',
            selector: (snapshot) => snapshot.backgroundCaptureState,
            formatter: _backgroundSummary,
          ),
          _DiagnosticsSection<AndroidBackgroundCaptureHostStatus?>(
            title: 'Android 宿主状态',
            selector: (snapshot) => snapshot.androidHostStatus,
            formatter: _androidHostSummary,
          ),
          _DiagnosticsSection<IosBackgroundCaptureHostStatus?>(
            title: 'iPhone 宿主状态',
            selector: (snapshot) => snapshot.iosHostStatus,
            formatter: _iosHostSummary,
          ),
          _DiagnosticsSection<AndroidForegroundServiceStrategy>(
            title: 'Android 前台服务策略',
            selector: (snapshot) => snapshot.androidForegroundServiceStrategy,
            formatter: _foregroundServiceSummary,
          ),
          _DiagnosticsSection<IosBackgroundCaptureStrategy>(
            title: 'iPhone 后台刷新策略',
            selector: (snapshot) => snapshot.iosBackgroundCaptureStrategy,
            formatter: _iosBackgroundStrategySummary,
          ),
          _DiagnosticsSection<String>(
            title: '本地写入状态',
            selector: (snapshot) => snapshot.storageStatus.label,
            formatter: (label) => label,
          ),
          _DiagnosticsSection<DigitalUsageSummary?>(
            title: '数字生活数据源',
            selector: (snapshot) => snapshot.latestUsageSummary,
            formatter: _digitalUsageSourceSummary,
          ),
          _DiagnosticsSection<List<CaptureCheckpoint>>(
            title: '最近检查点',
            selector: (snapshot) => snapshot.captureCheckpoints,
            formatter: _checkpointSummary,
          ),
          _DiagnosticsSection<List<CaptureHealthEvent>>(
            title: '最近健康事件',
            selector: (snapshot) => snapshot.captureHealthEvents,
            formatter: _healthEventSummary,
          ),
        ],
      ),
    );
  }

  String _permissionSummary(
    Map<PermissionType, PermissionGrantStatus> statuses,
  ) {
    if (statuses.isEmpty) {
      return '暂无权限状态';
    }

    final entries = statuses.entries
        .map((MapEntry<PermissionType, PermissionGrantStatus> entry) {
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

  String _lightSummary(AmbientLightSample? sample) {
    if (sample == null) {
      return '暂无光照样本';
    }
    return '${sample.level.name} · ${sample.lux.toStringAsFixed(0)} lux';
  }

  String _usageSummary(DigitalUsageSummary? summary) {
    if (summary == null) {
      return '暂无数字生活摘要';
    }
    final sourceLabel = switch (summary.source) {
      DigitalUsageSource.androidUsageStats => 'Android Usage Stats',
      DigitalUsageSource.lifecycleAlternative => '替代指标',
    };
    return '$sourceLabel · ${summary.topCategory.name} · 亮屏 ${summary.screenOnDuration.inMinutes} 分钟';
  }

  String _digitalUsageSourceSummary(DigitalUsageSummary? summary) {
    if (summary == null) {
      return '暂无可用的数字生活摘要。';
    }
    return '当前来源：${summary.source.name}，完整性：${summary.completeness.name}。';
  }

  String _checkpointSummary(List<CaptureCheckpoint> checkpoints) {
    if (checkpoints.isEmpty) {
      return '暂无检查点。';
    }

    final lines = checkpoints.map((CaptureCheckpoint checkpoint) {
      final lastEvent = checkpoint.lastEventTypeKey ?? 'unknown';
      final lastEventAt = checkpoint.lastEventAt?.toIso8601String() ?? 'n/a';
      return '${checkpoint.streamKey} · ${checkpoint.state.name} · 恢复 ${checkpoint.recoveryCount} 次 · 最近事件 $lastEvent @ $lastEventAt';
    });
    return lines.join('\n');
  }

  String _healthEventSummary(List<CaptureHealthEvent> events) {
    if (events.isEmpty) {
      return '暂无健康事件。';
    }

    final lines = events.take(10).map((CaptureHealthEvent event) {
      return '${event.streamKey} · ${event.eventType.name} · ${event.occurredAt.toIso8601String()}';
    });
    return lines.join('\n');
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

class _DiagnosticsSection<T> extends ConsumerWidget {
  const _DiagnosticsSection({
    required this.title,
    required this.selector,
    required this.formatter,
  });

  final String title;
  final T Function(DiagnosticsSnapshot snapshot) selector;
  final String Function(T value) formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      diagnosticsSnapshotStateProvider.select(
        (AsyncValue<DiagnosticsSnapshot> snapshot) {
          return snapshot.whenData(selector);
        },
      ),
    );

    return _SectionCard(
      title: title,
      child: value.when(
        skipLoadingOnRefresh: true,
        data: (T data) => Text(formatter(data)),
        loading: () => const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (Object error, StackTrace _) => const Text('当前卡片加载失败'),
      ),
    );
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
