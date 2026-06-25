import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/app.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 先完成数据库打开，再启动 UI，避免生命周期回调与 Isar.open 并发抢锁。
  final isar = await initializeAppIsar();
  runApp(
    ProviderScope(
      overrides: <Override>[
        appIsarProvider.overrideWith((Ref ref) async => isar),
      ],
      child: const HealthMonitorApp(),
    ),
  );
}
