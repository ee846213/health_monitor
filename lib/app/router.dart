import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/diagnostics/pages/sensor_debug_page.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';
import 'package:health_monitor/features/state_pages/state_pages.dart';
import 'package:health_monitor/features/trends/pages/trend_analysis_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// 一级页面可注册自己的滚动控制器，以支持再次点击当前 Tab 回到顶部。
class PrimaryTabScrollRegistry {
  PrimaryTabScrollRegistry._();

  static final Map<int, ScrollController> _controllers =
      <int, ScrollController>{};

  static void register(int index, ScrollController controller) {
    _controllers[index] = controller;
  }

  static void unregister(int index, ScrollController controller) {
    if (identical(_controllers[index], controller)) {
      _controllers.remove(index);
    }
  }

  static Future<void> scrollToTop(int index) async {
    final controller = _controllers[index];
    if (controller == null || !controller.hasClients) {
      return;
    }
    await controller.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return Scaffold(
      backgroundColor: tokens.canvas,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: _HealthBottomNavigation(
          selectedIndex: navigationShell.currentIndex,
          onSelected: (int index) {
            if (index == navigationShell.currentIndex) {
              PrimaryTabScrollRegistry.scrollToTop(index);
              return;
            }
            navigationShell.goBranch(index);
          },
        ),
      ),
    );
  }
}

class _HealthBottomNavigation extends StatelessWidget {
  const _HealthBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<(String, String)> _items = <(String, String)>[
    ('home', '首页'),
    ('show_chart', '趋势'),
    ('article', '简报'),
    ('person', '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.healthTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: tokens.cardShadow,
      ),
      child: SizedBox(
        key: const Key('health-bottom-nav-track'),
        height: 60,
        child: Row(
          children: List<Widget>.generate(_items.length, (int index) {
            final item = _items[index];
            final active = index == selectedIndex;
            return Expanded(
              child: Semantics(
                selected: active,
                button: true,
                label: item.$2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => onSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: AnimatedContainer(
                      duration: context.motionDuration(
                        context.healthMotion.base,
                      ),
                      curve: context.healthMotion.standardCurve,
                      decoration: BoxDecoration(
                        color: active ? tokens.sage : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          HealthVectorIcon(
                            item.$1,
                            size: 19,
                            weight: 500,
                            color: active ? Colors.white : tokens.textPrimary,
                          ),
                          const SizedBox(height: 1),
                          AnimatedDefaultTextStyle(
                            duration: context.motionDuration(
                              context.healthMotion.fast,
                            ),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color:
                                  active ? Colors.white : tokens.textSecondary,
                            ),
                            child: Text(item.$2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
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
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/overview',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/overview',
              builder: (_, __) => const OverviewPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/trends',
              builder: (_, __) => const TrendAnalysisPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/briefing',
              builder: (_, __) => const BriefingPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reminders',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const ReminderListPage(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'detail',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _secondaryPage(
              state: state,
              child: ReminderDetailPage(
                record: state.extra! as ReminderRecord,
              ),
            );
          },
        ),
        GoRoute(
          path: 'explanation',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return _secondaryPage(
              state: state,
              child: ReminderExplanationPage(
                record: state.extra! as ReminderRecord,
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/diagnostics',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const SensorDebugPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/permission-denied',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const PermissionDeniedPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/data-insufficient',
      pageBuilder: (_, GoRouterState state) => _secondaryPage(
        state: state,
        child: const DataInsufficientPage(),
      ),
    ),
  ],
);
