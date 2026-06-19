import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';
import 'package:health_monitor/features/state_pages/state_pages.dart';
import 'package:health_monitor/features/trends/pages/trend_analysis_page.dart';

const Color _textMuted = Color(0xFF7A8179);
const Color _sageSoft = Color(0xFFE6EEE8);
const Color _sageDeep = Color(0xFF5C7768);
const Color _glass = Color(0xFFFDF0CC);
const Color _line = Color(0xFFDDD8CF);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PrimaryTabTransition(
        location: GoRouterState.of(context).uri.path,
        child: child,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: const Color(0xFFF5F3EE),
        child: _TabBar(selectedIndex: _selectedIndex(context)),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/briefing')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1420231F),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        key: const Key('health-bottom-nav-track'),
        height: 50,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AnimatedAlign(
                  alignment: Alignment(
                    -1 + selectedIndex * 1.0,
                    0,
                  ),
                  duration: context.motionDuration(motion.base),
                  curve: motion.standardCurve,
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _sageSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _TabItem(
                        icon: '今日',
                        label: '首页',
                        isActive: selectedIndex == 0,
                        onTap: () => context.go('/overview'),
                      ),
                    ),
                    Expanded(
                      child: _TabItem(
                        icon: '回顾',
                        label: '简报',
                        isActive: selectedIndex == 1,
                        onTap: () => context.go('/briefing'),
                      ),
                    ),
                    Expanded(
                      child: _TabItem(
                        icon: '设置',
                        label: '我的',
                        isActive: selectedIndex == 2,
                        onTap: () => context.go('/profile'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedDefaultTextStyle(
              duration: context.motionDuration(motion.fast),
              curve: motion.standardCurve,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? _sageDeep : _textMuted,
              ),
              child: Text(
                icon,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: context.motionDuration(motion.fast),
              curve: motion.standardCurve,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? _sageDeep : _textMuted,
              ),
              child: Text(
                label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryTabTransition extends StatelessWidget {
  const _PrimaryTabTransition({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = context.healthMotion;
    final reduceMotion = context.reduceMotion;
    return AnimatedSwitcher(
      duration: context.motionDuration(const Duration(milliseconds: 180)),
      switchInCurve: motion.standardCurve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        if (reduceMotion) {
          return FadeTransition(opacity: animation, child: child);
        }
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.99, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey<String>(location), child: child),
    );
  }
}

CustomTransitionPage<void> _secondaryPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      if (context.reduceMotion) {
        return FadeTransition(opacity: curved, child: child);
      }
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.032, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/overview',
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppShell(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/overview',
          builder: (_, __) => const OverviewPage(),
        ),
        GoRoute(
          path: '/briefing',
          builder: (_, __) => const BriefingPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/trends',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const TrendAnalysisPage(),
      ),
    ),
    GoRoute(
      path: '/reminders',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const ReminderListPage(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'detail',
          pageBuilder: (BuildContext context, GoRouterState state) {
            final record = state.extra as ReminderRecord;
            return _secondaryPage(
              state: state,
              child: ReminderDetailPage(record: record),
            );
          },
        ),
        GoRoute(
          path: 'explanation',
          pageBuilder: (BuildContext context, GoRouterState state) {
            final record = state.extra as ReminderRecord;
            return _secondaryPage(
              state: state,
              child: ReminderExplanationPage(record: record),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/diagnostics',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const SensorDebugPage(),
      ),
    ),
    GoRoute(
      path: '/permission-denied',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const PermissionDeniedPage(),
      ),
    ),
    GoRoute(
      path: '/data-insufficient',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const DataInsufficientPage(),
      ),
    ),
  ],
);
