import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('调试页应渲染权限状态、最新样本与写入状态区块', (WidgetTester tester) async {
    const snapshot = DiagnosticsSnapshot(
      permissionStatuses: <PermissionType, PermissionGrantStatus>{
        PermissionType.motion: PermissionGrantStatus.granted,
        PermissionType.location: PermissionGrantStatus.denied,
      },
      liveActivity: null,
      latestActivity: null,
      latestLocationSummary: null,
      latestNoise: null,
      liveUsageSummary: null,
      latestUsageSummary: null,
      backgroundCaptureState: BackgroundCaptureState(
        status: BackgroundCaptureStatus.restricted,
        label: '后台能力受限',
        reason: '系统限制了当前平台的后台连续性。',
      ),
      androidHostStatus: AndroidBackgroundCaptureHostStatus(
        isRunning: true,
        summary: 'Android 宿主后台骨架已启动。',
      ),
      androidForegroundServiceStrategy: AndroidForegroundServiceStrategy(
        isEnabled: true,
        title: '健康监测正在后台运行',
        body: '用于持续积累活动、位置与用机样本。',
        sampleIntervalMinutes: 15,
        reasons: <String>[],
      ),
      storageStatus: DiagnosticsStorageStatus(
        kind: DiagnosticsStorageStatusKind.empty,
        label: '暂无本地写入记录',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          diagnosticsSnapshotProvider.overrideWith((Ref ref) async => snapshot),
        ],
        child: const MaterialApp(
          home: SensorDebugPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('采集调试'), findsOneWidget);
    expect(find.text('权限状态'), findsOneWidget);
    expect(find.text('实时活动样本'), findsOneWidget);
    expect(find.text('最近活动样本'), findsOneWidget);
    expect(find.text('最近位置摘要'), findsOneWidget);
    expect(find.text('最近环境噪音'), findsOneWidget);
    expect(find.text('实时数字生活入口'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('最近数字生活'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('最近数字生活'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('后台采集状态'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('后台采集状态'), findsOneWidget);
    expect(find.text('Android 前台服务策略'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Android 宿主状态'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('Android 宿主状态'), findsOneWidget);
    expect(find.textContaining('宿主后台骨架已启动'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('本地写入状态'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地写入状态'), findsOneWidget);
    expect(find.text('暂无本地写入记录'), findsOneWidget);
  });
}
