import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/app.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarFuture = initializeAppIsar();
  runApp(
    ProviderScope(
      overrides: <Override>[
        appIsarProvider.overrideWith((Ref ref) => isarFuture),
      ],
      child: const HealthMonitorApp(),
    ),
  );
}
