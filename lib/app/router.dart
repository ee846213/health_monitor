import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';

const _textMuted = Color(0xFF7A8179);
const _sageSoft = Color(0xFFE6EEE8);
const _sageDeep = Color(0xFF5C7768);
const _glass = Color(0xFFFFFDF0CC);
const _line = Color(0xFFDDD8CF);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: const Color(0xFFF5F3EE),
        child: _TabBar(selectedIndex: _selectedIndex(context)),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/briefing')) return 1;
    if (loc.startsWith('/profile')) return 2;
    return 0;
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [BoxShadow(color: Color(0x1420231F), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _TabItem(icon: '今日', label: '首页', isActive: selectedIndex == 0, onTap: () => context.go('/overview')),
        _TabItem(icon: '回顾', label: '简报', isActive: selectedIndex == 1, onTap: () => context.go('/briefing')),
        _TabItem(icon: '设置', label: '我的', isActive: selectedIndex == 2, onTap: () => context.go('/profile')),
      ]),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, required this.isActive, required this.onTap});
  final String icon, label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _sageSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? _sageDeep : _textMuted)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? _sageDeep : _textMuted)),
        ]),
      ),
    );
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
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(path: '/diagnostics', builder: (_, __) => const SensorDebugPage()),
  ],
);