import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_monitor/app/background_capture_bootstrap.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_clock_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/services/data_collector.dart';

class HealthMonitorApp extends StatelessWidget {
  const HealthMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (context, child) {
        return const _AppLifecycleRefreshScope(
          child: _AppContent(),
        );
      },
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '健康监测',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}

class _AppLifecycleRefreshScope extends ConsumerStatefulWidget {
  const _AppLifecycleRefreshScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppLifecycleRefreshScope> createState() =>
      _AppLifecycleRefreshScopeState();
}

class _AppLifecycleRefreshScopeState
    extends ConsumerState<_AppLifecycleRefreshScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _runStartupSyncAfterFirstFrame();
    });
  }

  void _runStartupSyncAfterFirstFrame() {
    unawaited(
        ref.read(androidBackgroundCaptureBootstrapServiceProvider).sync());
    unawaited(ref.read(dataCollectorProvider).syncNativeStepCount());
    unawaited(ref.read(dataCollectorProvider).syncUsageSummary());
    unawaited(ref.read(dataCollectorProvider).syncNativeRiskEvents());
  }

  void _invalidateForegroundDataProviders() {
    ref.invalidate(permissionStatusProvider);
    ref.invalidate(diagnosticsSnapshotProvider);
    ref.invalidate(dailyRhythmClockProvider);
    ref.invalidate(overviewReadyDataProvider);
    ref.invalidate(overviewViewModelProvider);
    ref.invalidate(briefingViewModelProvider);
    ref.invalidate(trendAnalysisViewModelProvider);
    ref.invalidate(reminderListProvider);
    ref.invalidate(latestReminderProvider);
  }

  Future<void> _refreshForegroundDataAfterResume() async {
    _invalidateForegroundDataProviders();
    await Future.wait<void>(<Future<void>>[
      ref.read(dataCollectorProvider).syncNativeStepCount(),
      ref.read(androidBackgroundCaptureBootstrapServiceProvider).sync(),
      ref.read(dataCollectorProvider).syncUsageSummary(),
      ref.read(dataCollectorProvider).syncNativeRiskEvents(),
    ]);
    if (!mounted) {
      return;
    }
    // 恢复前台后再补一次失效，避免页面停留在同步前的缓存快照。
    _invalidateForegroundDataProviders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(ref.read(dataCollectorProvider).pauseForegroundCapture());
      return;
    }
    if (state != AppLifecycleState.resumed) {
      return;
    }

    ref.read(dataCollectorProvider).resumeForegroundCapture();
    unawaited(_refreshForegroundDataAfterResume());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
