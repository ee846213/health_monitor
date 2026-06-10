import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/overview',
  routes: <RouteBase>[
    GoRoute(
      path: '/overview',
      builder: (BuildContext context, GoRouterState state) {
        return const OverviewPage();
      },
    ),
    GoRoute(
      path: '/diagnostics',
      builder: (BuildContext context, GoRouterState state) {
        return const SensorDebugPage();
      },
    ),
  ],
);