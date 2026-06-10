import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/android_foreground_service_strategy.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/background/ios_background_capture_host_status.dart';
import 'package:health_monitor/domain/background/ios_background_capture_strategy.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('Debug page loads with full DiagnosticsSnapshot', (WidgetTester tester) async {
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
        label: 'Restricted',
        reason: 'Platform limits background continuity.',
      ),
      androidHostStatus: AndroidBackgroundCaptureHostStatus(
        isRunning: true,
        summary: 'Android host started.',
        lastErrorMessage: 'Recent failure recovered.',
      ),
      iosHostStatus: IosBackgroundCaptureHostStatus(
        isRunning: false,
        summary: 'iPhone host not started.',
      ),
      androidForegroundServiceStrategy: AndroidForegroundServiceStrategy(
        isEnabled: true,
        title: 'Running in background',
        body: 'Accumulating samples.',
        sampleIntervalMinutes: 15,
        reasons: <String>[],
      ),
      iosBackgroundCaptureStrategy: IosBackgroundCaptureStrategy(
        isEnabled: true,
        isRestricted: true,
        title: 'Refreshing in background',
        body: 'Refreshing activity, location and digital usage.',
        backgroundRefreshIntervalMinutes: 15,
        supportedModes: <String>['motion', 'location'],
        reasons: <String>['iPhone limited.'],
        captureMode: IosBackgroundCaptureMode.full,
        digitalUsageRefreshIntervalMinutes: 30,
        bgTaskEstimatedWindowSeconds: 30,
        canRestore: true,
        restoreStrategy: 'Next window will auto-restore.',
      ),
      storageStatus: DiagnosticsStorageStatus(
        kind: DiagnosticsStorageStatusKind.empty,
        label: 'No records yet',
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
    await tester.pump();

    // Minimal verification that the page loads without error.
    expect(find.byType(SensorDebugPage), findsOneWidget);
  });
}
