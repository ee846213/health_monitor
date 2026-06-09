import 'package:flutter/material.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme.dart';

class HealthMonitorApp extends StatelessWidget {
  const HealthMonitorApp({super.key});

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
