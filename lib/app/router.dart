import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';

/// 主应用壳，提供底部导航。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首页'),
          NavigationDestination(icon: Icon(Icons.article_outlined), label: '简报'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: '提醒'),
          NavigationDestination(icon: Icon(Icons.person_outlined), label: '我'),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/overview') return 0;
    if (location == '/briefing') return 1;
    if (location == '/reminders') return 2;
    if (location == '/profile') return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/overview');
      case 1: context.go('/briefing');
      case 2: context.go('/reminders');
      case 3: context.go('/profile');
    }
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/overview',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/overview', builder: (_, __) => const OverviewPage()),
        GoRoute(path: '/briefing', builder: (_, __) => const BriefingPage()),
        GoRoute(path: '/reminders', builder: (_, __) => const ReminderListPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(path: '/diagnostics', builder: (_, __) => const SensorDebugPage()),
  ],
);