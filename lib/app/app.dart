import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_monitor/app/background_capture_bootstrap.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
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
    unawaited(ref.read(androidBackgroundCaptureBootstrapServiceProvider).sync());
    unawaited(ref.read(dataCollectorProvider).syncNativeRiskEvents());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    unawaited(ref.read(androidBackgroundCaptureBootstrapServiceProvider).sync());
    unawaited(ref.read(dataCollectorProvider).syncNativeRiskEvents());
    ref.invalidate(permissionStatusProvider);
    ref.invalidate(overviewViewModelProvider);
    ref.invalidate(diagnosticsSnapshotProvider);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
