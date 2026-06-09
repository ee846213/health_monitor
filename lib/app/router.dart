import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/overview',
  routes: <RouteBase>[
    GoRoute(
      path: '/overview',
      builder: (BuildContext context, GoRouterState state) {
        return const _OverviewPage();
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

class _OverviewPage extends StatelessWidget {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '今日概览',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '看看你今天的状态，先从最重要的一件事开始。',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/diagnostics'),
                child: const Text('打开采集调试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
