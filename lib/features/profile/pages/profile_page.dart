import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/app/router.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/widgets/health_design_widgets.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/app/widgets/health_vector_icon.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/diagnostics/providers/diagnostics_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/domain/notification/reminder_category.dart';
import 'package:health_monitor/features/profile/providers/reminder_preferences_provider.dart';
import 'package:health_monitor/features/profile/widgets/do_not_disturb_section.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/services/permission_status_service.dart';

/// 提醒偏好页展示的细分类别（不含总开关）。
const List<ReminderCategory> _profileReminderCategories = <ReminderCategory>[
  ReminderCategory.sedentary,
  ReminderCategory.walkingScreen,
  ReminderCategory.nightUsage,
  ReminderCategory.noisyEnvironment,
];

final profileNowProvider = Provider<DateTime>((ref) => DateTime.now());

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    PrimaryTabScrollRegistry.register(3, _controller);
  }

  @override
  void dispose() {
    PrimaryTabScrollRegistry.unregister(3, _controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(profilePageReadyProvider);
    return Scaffold(
      backgroundColor: context.healthTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: ready.when(
          skipLoadingOnRefresh: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(overviewViewModelProvider),
              child: const Text('我的页面加载失败，点击重试'),
            ),
          ),
          data: (_) => ListView(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 112),
            children: <Widget>[
              const HealthStaggeredEntrance(index: 0, child: _Greeting()),
              const SizedBox(height: 18),
              const HealthStaggeredEntrance(
                index: 1,
                child: _SensingStatusCard(),
              ),
              const SizedBox(height: 16),
              HealthStaggeredEntrance(
                index: 2,
                child: _SettingsGroup(
                  children: <Widget>[
                    _SettingsRow(
                      key: const Key('profile-reminders-row'),
                      icon: 'notifications',
                      title: '提醒记录',
                      subtitle: '查看提醒原因和处理状态',
                      color: context.healthTheme.sand,
                      onTap: () => context.push('/reminders'),
                    ),
                    const DoNotDisturbSection(),
                    _SettingsRow(
                      key: const Key('profile-preferences-row'),
                      icon: 'devices',
                      title: '提醒偏好',
                      subtitle: '选择参与提醒的风险类型',
                      color: context.healthTheme.blue,
                      onTap: () => _showReminderPreferences(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              HealthStaggeredEntrance(
                index: 3,
                child: _SettingsGroup(
                  children: <Widget>[
                    _SettingsRow(
                      key: const Key('profile-permission-row'),
                      icon: 'verified_user',
                      title: '权限与隐私',
                      subtitle: '查看每项能力的用途与当前状态',
                      color: context.healthTheme.sage,
                      onTap: () => _showPermissionSheet(context, ref),
                    ),
                    _SettingsRow(
                      icon: 'link',
                      title: '数据与存储',
                      subtitle: '本地处理、保留与清理说明',
                      color: context.healthTheme.coral,
                      onTap: () => _showInfoSheet(
                        context,
                        '本地处理',
                        '原始感知数据优先在本地处理，不保存原始音频，也不展示虚假的云同步状态。',
                      ),
                    ),
                    _SettingsRow(
                      icon: 'info',
                      title: '关于我们',
                      subtitle: '版本、隐私政策与能力边界',
                      color: context.healthTheme.textSecondary,
                      onTap: () => _showInfoSheet(
                        context,
                        '关于健康感知',
                        '本应用提供生活节奏洞察，不构成医学诊断。首版不依赖额外硬件。',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = ref.watch(profileNowProvider).hour;
    final greeting = hour < 12
        ? '早上好'
        : hour < 18
            ? '下午好'
            : '晚上好';
    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: context.healthTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text('你的数据由你掌控', style: context.healthTheme.bodyStyle),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/illustrations/common/profile_plant.svg',
            width: 74,
            height: 86,
          ),
        ],
      ),
    );
  }
}

class _SensingStatusCard extends ConsumerWidget {
  const _SensingStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(profileViewModelStateProvider);
    final dashboard = model?.dashboard;
    final hasData = dashboard?.hasRealData == true;
    final score = dashboard?.healthScore.totalScore;
    final missing = model?.missingDimensions ?? const <String>[];
    return HealthElevatedCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Text(
              '我的感知状态',
              style: context.healthTheme.sectionTitleStyle,
            ),
          ),
          SizedBox(
            height: 120,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    key: const Key('profile-sensing-score'),
                    onTap: hasData
                        ? () => _openTrend(context, ref, TrendTab.steps)
                        : null,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            hasData ? '$score' : '--',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: context.healthTheme.sage,
                            ),
                          ),
                          Text(
                            hasData ? '综合状态' : '正在积累数据',
                            style: context.healthTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 76,
                  color: context.healthTheme.divider,
                ),
                Expanded(
                  child: InkWell(
                    key: const Key('profile-sensing-trend'),
                    onTap: hasData
                        ? () {
                            ref
                                .read(trendRangeForTabProvider(TrendTab.steps)
                                    .notifier)
                                .state = TrendRange.days7;
                            _openTrend(context, ref, TrendTab.steps);
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('近 7 天趋势', style: context.healthTheme.bodyStyle),
                          const SizedBox(height: 10),
                          Expanded(
                            child: CustomPaint(
                              painter: _SensingTrendPainter(
                                color: context.healthTheme.sage,
                                hasData: hasData,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            key: const Key('profile-sensing-verdict'),
            onTap: hasData
                ? () => _openTrend(context, ref, _priority(dashboard!))
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 15),
              decoration: BoxDecoration(
                color: context.healthTheme.sageSoft.withValues(alpha: .65),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(context.healthTheme.cardRadius),
                ),
              ),
              child: Text(
                !hasData
                    ? '数据正在积累，暂不生成分数'
                    : missing.isEmpty
                        ? '整体平稳，继续保持当前节奏'
                        : '整体平稳 · 部分维度暂缺：${missing.join('、')}',
                style: context.healthTheme.bodyStyle.copyWith(
                  color: context.healthTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensingTrendPainter extends CustomPainter {
  const _SensingTrendPainter({required this.color, required this.hasData});

  final Color color;
  final bool hasData;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = hasData ? color : const Color(0xFFDDD8CF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * .65)
      ..cubicTo(
        size.width * .18,
        size.height * .40,
        size.width * .32,
        size.height * .72,
        size.width * .48,
        size.height * .48,
      )
      ..cubicTo(
        size.width * .62,
        size.height * .28,
        size.width * .76,
        size.height * .50,
        size.width,
        size.height * .22,
      );
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(size.width, size.height * .22),
      4,
      Paint()..color = paint.color,
    );
  }

  @override
  bool shouldRepaint(covariant _SensingTrendPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.hasData != hasData;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return HealthElevatedCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: List<Widget>.generate(children.length * 2 - 1, (index) {
          if (index.isEven) return children[index ~/ 2];
          return Divider(height: 1, color: context.healthTheme.divider);
        }),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: <Widget>[
            HealthIconBubble(
              icon: icon,
              foreground: color,
              background: color.withValues(alpha: .15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: context.healthTheme.sectionTitleStyle),
                  const SizedBox(height: 3),
                  Text(subtitle, style: context.healthTheme.bodyStyle),
                ],
              ),
            ),
            const HealthVectorIcon('chevron_right', size: 18),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPermissionSheet(BuildContext context, WidgetRef ref) {
  final statuses = ref.read(profilePermissionStatusesProvider);
  final rows = <(PermissionType, String, String)>[
    (PermissionType.motion, '活动识别', '用于活动、久坐和姿势节奏判断'),
    (PermissionType.location, '位置', '用于室内外和活动范围判断'),
    (PermissionType.microphone, '麦克风环境噪音', '只评估等级，不保存原始音频'),
    (PermissionType.notification, '通知与风险提醒', '用于发送本地安全提醒'),
    if (defaultTargetPlatform == TargetPlatform.android)
      (PermissionType.usageAccess, '数字生活习惯分析', '用于屏幕使用趋势分析'),
    (PermissionType.backgroundCapture, '后台持续感知', '用于锁屏后的低频风险识别'),
  ];
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.healthTheme.surface,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('权限与隐私', style: context.healthTheme.sectionTitleStyle),
            const SizedBox(height: 6),
            Text(
              '单项权限失败不会影响其他设置项。',
              style: context.healthTheme.bodyStyle,
            ),
            const SizedBox(height: 10),
            ...rows.map((row) {
              final status = statuses[row.$1] ?? PermissionGrantStatus.unknown;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(row.$2),
                subtitle: Text(row.$3),
                trailing: Text(_permissionLabel(status)),
                onTap: () => _handlePermission(
                  sheetContext,
                  ref,
                  row.$1,
                  row.$2,
                  row.$3,
                  status,
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

Future<void> _handlePermission(
  BuildContext context,
  WidgetRef ref,
  PermissionType type,
  String title,
  String purpose,
  PermissionGrantStatus status,
) async {
  if (status == PermissionGrantStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title 已开启')),
    );
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text('$purpose。\n\n不开启时，相关维度将降级或显示数据不足。'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('稍后再说'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('立即处理'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final result = await ref
      .read(permissionInteractionServiceProvider)
      .handlePermissionTap(type);
  ref.invalidate(permissionStatusProvider);
  ref.invalidate(overviewViewModelProvider);
  ref.invalidate(overviewReadyDataProvider);
  ref.invalidate(diagnosticsSnapshotProvider);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_permissionResultMessage(title, result))),
  );
}

Future<void> _showReminderPreferences(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.healthTheme.surface,
    builder: (context) => SafeArea(
      child: Consumer(
        builder: (context, ref, child) {
          final preferencesAsync = ref.watch(reminderPreferencesProvider);
          return preferencesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
              child: Text(
                '提醒偏好加载失败',
                style: context.healthTheme.bodyStyle,
              ),
            ),
            data: (preferences) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                    Text('提醒偏好', style: context.healthTheme.sectionTitleStyle),
                    const SizedBox(height: 6),
                    Text(
                      '关闭后不会写入提醒记录，也不会发送系统通知。',
                      style: context.healthTheme.bodyStyle,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('总提醒开关'),
                      value: preferences.masterEnabled,
                      onChanged: (enabled) async {
                        try {
                          await ref
                              .read(reminderPreferencesProvider.notifier)
                              .save(preferences.toggleMaster(enabled));
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('保存失败，已恢复原设置')),
                          );
                        }
                      },
                    ),
                    ..._profileReminderCategories.map(
                      (category) => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(category.displayLabel),
                        value: preferences.isCategoryEnabled(category),
                        onChanged: preferences.masterEnabled
                            ? (enabled) async {
                                try {
                                  await ref
                                      .read(
                                          reminderPreferencesProvider.notifier)
                                      .save(
                                        preferences.toggleCategory(
                                          category,
                                          enabled,
                                        ),
                                      );
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('保存失败，已恢复原设置'),
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

Future<void> _showInfoSheet(
  BuildContext context,
  String title,
  String content,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.healthTheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.healthTheme.sectionTitleStyle),
            const SizedBox(height: 12),
            Text(content, style: context.healthTheme.bodyStyle),
          ],
        ),
      ),
    ),
  );
}

void _openTrend(BuildContext context, WidgetRef ref, TrendTab tab) {
  ref.read(trendSelectedTabProvider.notifier).state = tab;
  context.go('/trends');
}

TrendTab _priority(DashboardSnapshot dashboard) {
  final entries = <TrendTab, int>{
    TrendTab.steps: dashboard.healthScore.stepScore,
    TrendTab.sedentary: dashboard.healthScore.sedentaryScore,
    TrendTab.screen: dashboard.healthScore.screenScore,
  }.entries.toList()
    ..sort((left, right) => left.value.compareTo(right.value));
  return entries.first.key;
}

String _permissionLabel(PermissionGrantStatus status) => switch (status) {
      PermissionGrantStatus.granted => '已开启',
      PermissionGrantStatus.denied => '未开启',
      PermissionGrantStatus.restricted => '去设置',
      PermissionGrantStatus.unknown => '待确认',
    };

String _permissionResultMessage(String title, PermissionActionResult result) =>
    switch (result) {
      PermissionActionResult.granted => '$title 已开启',
      PermissionActionResult.denied => '$title 未开启，将继续降级运行',
      PermissionActionResult.openedSettings => '已打开系统设置，请完成后返回',
      PermissionActionResult.settingsUnavailable => '暂时无法打开系统设置',
    };
