import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/app.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets('应用首帧不应等待 Isar 初始化完成', (WidgetTester tester) async {
    final blockedIsar = Completer<Isar>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appIsarProvider.overrideWith((Ref ref) => blockedIsar.future),
          permissionStatusProvider.overrideWith(
            (Ref ref) async => <PermissionType, PermissionGrantStatus>{},
          ),
        ],
        child: const HealthMonitorApp(),
      ),
    );
    await tester.pump();

    expect(blockedIsar.isCompleted, isFalse);
    expect(find.byKey(const Key('health-bottom-nav-track')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
