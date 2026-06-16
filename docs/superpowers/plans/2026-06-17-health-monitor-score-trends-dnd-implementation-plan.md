# 健康分数、趋势页与勿扰时段实施计划
> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 在首页增加可点击的健康分数圆环入口，新增真实数据驱动的趋势页，并把个人页里的勿扰时段设置接到本地通知派发链路上。

**架构：** 健康分数与趋势页继续复用现有 `dataCollectorRevisionProvider`、`HealthInsightService` 和真实聚合数据，不引入新的后端依赖。勿扰时段使用纯 Dart 领域模型 + Isar 持久化 + Riverpod 状态管理，通知发送通过 `flutter_local_notifications` 的本地封装完成，提醒派发逻辑放在服务层统一判断是否处于静默窗口。

**Tech Stack：** Flutter、Dart、Riverpod、GoRouter、Isar、flutter_local_notifications、flutter_test

---

## 文件结构

### 新增文件

- `lib/domain/scoring/health_score.dart`
- `lib/features/overview/widgets/health_score_ring.dart`
- `lib/features/trends/pages/trend_analysis_page.dart`
- `lib/features/trends/providers/trend_analysis_provider.dart`
- `lib/features/trends/widgets/trend_tab_bar.dart`
- `lib/features/trends/widgets/trend_chart_panel.dart`
- `lib/features/trends/widgets/trend_insight_panel.dart`
- `lib/domain/notification/notification_preference.dart`
- `lib/storage/isar/collections/notification_preference_record.dart`
- `lib/storage/repositories/notification_preference_repository.dart`
- `lib/features/profile/providers/notification_preference_provider.dart`
- `lib/features/profile/widgets/do_not_disturb_section.dart`
- `lib/services/local_notification_service.dart`
- `lib/services/reminder_delivery_service.dart`
- `test/domain/scoring/health_score_test.dart`
- `test/features/overview/overview_health_score_card_test.dart`
- `test/features/trends/trend_analysis_page_test.dart`
- `test/domain/notification/notification_preference_test.dart`
- `test/storage/repositories/notification_preference_repository_test.dart`
- `test/features/profile/do_not_disturb_section_test.dart`
- `test/services/local_notification_service_test.dart`
- `test/services/reminder_delivery_service_test.dart`

### 修改文件

- `lib/features/overview/providers/overview_providers.dart`
- `lib/features/overview/pages/overview_page.dart`
- `lib/app/router.dart`
- `lib/features/profile/pages/profile_page.dart`
- `lib/services/health_insight_service.dart`
- `lib/services/data_collector.dart`
- `lib/storage/isar/app_isar.dart`
- `test/features/overview/overview_page_test.dart`
- `test/features/profile/profile_page_test.dart`
- `test/features/app_shell_test.dart`

---

## Task 1: 健康分数计算与首页圆环入口

**Files:**
- Create: `lib/domain/scoring/health_score.dart`
- Create: `lib/features/overview/widgets/health_score_ring.dart`
- Modify: `lib/features/overview/providers/overview_providers.dart`
- Modify: `lib/features/overview/pages/overview_page.dart`
- Test: `test/domain/scoring/health_score_test.dart`
- Test: `test/features/overview/overview_health_score_card_test.dart`
- Test: `test/features/overview/overview_page_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
test('health score uses 40/40/20 weighted components', () {
  final score = calculateHealthScore(
    stepCount: 4800,
    sedentaryMinutes: 96,
    screenMinutes: 148,
  );

  expect(score.stepScore, 80);
  expect(score.sedentaryScore, 100);
  expect(score.screenScore, 82);
  expect(score.totalScore, 88);
});

testWidgets('overview shows health score ring and navigates to trends', (tester) async {
  const viewModel = OverviewViewModel(
    screenState: OverviewScreenState.ready,
    isLoading: false,
    verdicts: <RuleVerdict>[],
    summaryLabel: 'state',
    summaryDetail: 'detail',
    metrics: OverviewMetricSnapshot(
      stepCount: 6000,
      sedentaryMinutes: 0,
      screenMinutes: 0,
      outdoorMinutes: 0,
    ),
    reminders: <ReminderRecord>[],
    permissionStatuses: <PermissionType, PermissionGrantStatus>{},
    missingDimensions: <String>[],
    hasRealData: true,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
      ],
      child: const MaterialApp(home: OverviewPage()),
    ),
  );

  await tester.tap(find.text('综合健康分'));
  await tester.pumpAndSettle();

  expect(find.text('趋势分析'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试确认失败**

运行：`flutter test test/domain/scoring/health_score_test.dart test/features/overview/overview_health_score_card_test.dart`

预期：FAIL，原因是 `calculateHealthScore`、健康分圆环组件和 `/trends` 路由还不存在。

- [ ] **Step 3: 写最小实现**

```dart
class HealthScoreBreakdown {
  const HealthScoreBreakdown({
    required this.stepScore,
    required this.sedentaryScore,
    required this.screenScore,
    required this.totalScore,
  });

  final int stepScore;
  final int sedentaryScore;
  final int screenScore;
  final int totalScore;
}

HealthScoreBreakdown calculateHealthScore({
  required int stepCount,
  required int sedentaryMinutes,
  required int screenMinutes,
}) {
  final stepScore = ((stepCount / 6000).clamp(0, 1) * 100).round();
  final sedentaryScore = _linearScore(
    actual: sedentaryMinutes,
    idealUpperBound: 60,
    zeroAt: 360,
  );
  final screenScore = _linearScore(
    actual: screenMinutes,
    idealUpperBound: 120,
    zeroAt: 540,
  );
  final totalScore = (stepScore * 0.4 + sedentaryScore * 0.4 + screenScore * 0.2).round();
  return HealthScoreBreakdown(
    stepScore: stepScore,
    sedentaryScore: sedentaryScore,
    screenScore: screenScore,
    totalScore: totalScore,
  );
}
```

```dart
class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({
    super.key,
    required this.score,
    required this.onTap,
  });

  final HealthScoreBreakdown score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text('综合健康分 ${score.totalScore}'),
    );
  }
}
```

在 `OverviewViewModel` 里新增 `healthScore` 字段，并在 `overviewViewModelProvider` 中用当天真实聚合数据计算；`OverviewPage` 顶部插入 `HealthScoreRing`，点击后 `context.go('/trends')`。

- [ ] **Step 4: 重新运行测试**

运行：`flutter test test/domain/scoring/health_score_test.dart test/features/overview/overview_health_score_card_test.dart test/features/overview/overview_page_test.dart`

预期：PASS，首页能显示健康分圆环，点击会进入趋势页。

- [ ] **Step 5: 提交**

```bash
git add lib/domain/scoring/health_score.dart lib/features/overview/widgets/health_score_ring.dart lib/features/overview/providers/overview_providers.dart lib/features/overview/pages/overview_page.dart test/domain/scoring/health_score_test.dart test/features/overview/overview_health_score_card_test.dart test/features/overview/overview_page_test.dart
git commit -m "feat: add overview health score entry"
```

---

## Task 2: 趋势页与路由

**Files:**
- Create: `lib/features/trends/pages/trend_analysis_page.dart`
- Create: `lib/features/trends/providers/trend_analysis_provider.dart`
- Create: `lib/features/trends/widgets/trend_tab_bar.dart`
- Create: `lib/features/trends/widgets/trend_chart_panel.dart`
- Create: `lib/features/trends/widgets/trend_insight_panel.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/features/overview/pages/overview_page.dart`
- Test: `test/features/trends/trend_analysis_page_test.dart`
- Test: `test/features/overview/overview_page_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
testWidgets('trend page defaults to steps and switches to sedentary', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        trendAnalysisProvider.overrideWith((Ref ref) async => fakeTrendSnapshot()),
      ],
      child: const MaterialApp(home: TrendAnalysisPage()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('近7天步数'), findsOneWidget);
  await tester.tap(find.text('久坐'));
  await tester.pumpAndSettle();
  expect(find.text('近7天久坐时长'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试确认失败**

运行：`flutter test test/features/trends/trend_analysis_page_test.dart test/features/overview/overview_page_test.dart`

预期：FAIL，原因是 `/trends` 路由和趋势页 UI 还没有接上。

- [ ] **Step 3: 写最小实现**

```dart
enum TrendTab { steps, sedentary, screen, environment }

final selectedTrendTabProvider = StateProvider<TrendTab>((Ref ref) => TrendTab.steps);

final trendAnalysisProvider = FutureProvider<TrendSnapshot>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  final tab = ref.watch(selectedTrendTabProvider);
  return ref.watch(trendAnalysisServiceProvider).build(
        referenceTime: DateTime.now(),
        selectedTab: tab,
      );
});
```

```dart
GoRoute(
  path: '/trends',
  builder: (_, __) => const TrendAnalysisPage(),
),
```

`TrendAnalysisPage` 默认显示步数趋势，顶部 Tab 切换久坐、屏幕、环境趋势；图表先用 `CustomPainter` 或简单柱线组合实现，不引入额外图表包。

- [ ] **Step 4: 重新运行测试**

运行：`flutter test test/features/trends/trend_analysis_page_test.dart test/features/overview/overview_page_test.dart`

预期：PASS，首页圆环能进入趋势页，趋势页默认 Tab 和切换行为正确。

- [ ] **Step 5: 提交**

```bash
git add lib/features/trends/pages/trend_analysis_page.dart lib/features/trends/providers/trend_analysis_provider.dart lib/features/trends/widgets/trend_tab_bar.dart lib/features/trends/widgets/trend_chart_panel.dart lib/features/trends/widgets/trend_insight_panel.dart lib/app/router.dart lib/features/overview/pages/overview_page.dart test/features/trends/trend_analysis_page_test.dart test/features/overview/overview_page_test.dart
git commit -m "feat: add trend analysis page"
```

---

## Task 3: 勿扰时段偏好与个人页设置

**Files:**
- Create: `lib/domain/notification/notification_preference.dart`
- Create: `lib/storage/isar/collections/notification_preference_record.dart`
- Create: `lib/storage/repositories/notification_preference_repository.dart`
- Modify: `lib/storage/isar/app_isar.dart`
- Create: `lib/features/profile/providers/notification_preference_provider.dart`
- Create: `lib/features/profile/widgets/do_not_disturb_section.dart`
- Modify: `lib/features/profile/pages/profile_page.dart`
- Test: `test/domain/notification/notification_preference_test.dart`
- Test: `test/storage/repositories/notification_preference_repository_test.dart`
- Test: `test/features/profile/do_not_disturb_section_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
test('do not disturb window supports overnight range', () {
  const preference = NotificationPreference(
    enabled: true,
    startHour: 22,
    startMinute: 30,
    endHour: 7,
    endMinute: 0,
  );

  expect(preference.isWithinWindow(DateTime(2026, 6, 16, 23, 45)), isTrue);
  expect(preference.isWithinWindow(DateTime(2026, 6, 17, 6, 45)), isTrue);
  expect(preference.isWithinWindow(DateTime(2026, 6, 17, 9, 0)), isFalse);
});
```

- [ ] **Step 2: 运行测试确认失败**

运行：`flutter test test/domain/notification/notification_preference_test.dart test/storage/repositories/notification_preference_repository_test.dart test/features/profile/do_not_disturb_section_test.dart`

预期：FAIL，原因是偏好模型、持久化仓库和设置组件都还没有。

- [ ] **Step 3: 写最小实现**

```dart
class NotificationPreference {
  const NotificationPreference({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  bool isWithinWindow(DateTime dateTime) {
    if (!enabled) return false;
    final current = dateTime.hour * 60 + dateTime.minute;
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    return start < end ? current >= start && current < end : current >= start || current < end;
  }
}
```

`DoNotDisturbSection` 放在 `ProfilePage` 里，提供一个总开关和两个时间入口，默认使用一个跨午夜窗口，例如 `22:00 - 07:00`。

- [ ] **Step 4: 重新运行测试**

运行：`flutter test test/domain/notification/notification_preference_test.dart test/storage/repositories/notification_preference_repository_test.dart test/features/profile/do_not_disturb_section_test.dart test/features/profile/profile_page_test.dart`

预期：PASS，个人页能显示并修改勿扰时段。

- [ ] **Step 5: 提交**

```bash
git add lib/domain/notification/notification_preference.dart lib/storage/isar/collections/notification_preference_record.dart lib/storage/repositories/notification_preference_repository.dart lib/storage/isar/app_isar.dart lib/features/profile/providers/notification_preference_provider.dart lib/features/profile/widgets/do_not_disturb_section.dart lib/features/profile/pages/profile_page.dart test/domain/notification/notification_preference_test.dart test/storage/repositories/notification_preference_repository_test.dart test/features/profile/do_not_disturb_section_test.dart test/features/profile/profile_page_test.dart
git commit -m "feat: add do not disturb settings"
```

---

## Task 4: 通知派发遵循勿扰窗口

**Files:**
- Create: `lib/services/local_notification_service.dart`
- Create: `lib/services/reminder_delivery_service.dart`
- Modify: `lib/services/health_insight_service.dart`
- Modify: `lib/services/data_collector.dart`
- Test: `test/services/local_notification_service_test.dart`
- Test: `test/services/reminder_delivery_service_test.dart`
- Test: `test/services/data_collector_usage_sync_test.dart`

- [ ] **Step 1: 写失败测试**

```dart
test('reminder delivery skips notifications during do not disturb', () async {
  final preference = NotificationPreference(
    enabled: true,
    startHour: 22,
    startMinute: 0,
    endHour: 7,
    endMinute: 0,
  );
  final localNotificationService = FakeLocalNotificationService();
  final deliveryService = ReminderDeliveryService(
    preferenceRepository: FakePreferenceRepository(preference),
    localNotificationService: localNotificationService,
  );

  await deliveryService.deliver(
    records: <ReminderRecord>[fakeReminder('walk')],
    referenceTime: DateTime(2026, 6, 16, 23, 0),
  );

  expect(localNotificationService.deliveredMessages, isEmpty);
});
```

- [ ] **Step 2: 运行测试确认失败**

运行：`flutter test test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart test/services/data_collector_usage_sync_test.dart`

预期：FAIL，原因是本地通知封装和勿扰拦截链路还没有接入。

- [ ] **Step 3: 写最小实现**

```dart
class ReminderDeliveryService {
  ReminderDeliveryService({
    required this.preferenceRepository,
    required this.localNotificationService,
  });

  final NotificationPreferenceRepository preferenceRepository;
  final LocalNotificationService localNotificationService;

  Future<void> deliver({
    required List<ReminderRecord> records,
    required DateTime referenceTime,
  }) async {
    if (records.isEmpty) return;
    final preference = await preferenceRepository.read();
    if (preference.enabled && preference.isWithinWindow(referenceTime)) {
      return;
    }
    await localNotificationService.showReminders(records);
  }
}
```

`HealthInsightService.persistRuleReminders` 在保存提醒后，调用 `ReminderDeliveryService.deliver(...)`；`DataCollector` 继续保留现有 `persistRuleReminders` 钩子，但把派发责任交给服务层。

- [ ] **Step 4: 重新运行测试**

运行：`flutter test test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart test/services/data_collector_usage_sync_test.dart`

预期：PASS，勿扰窗口内不会弹系统通知，窗口外会正常发出。

- [ ] **Step 5: 提交**

```bash
git add lib/services/local_notification_service.dart lib/services/reminder_delivery_service.dart lib/services/health_insight_service.dart lib/services/data_collector.dart test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart test/services/data_collector_usage_sync_test.dart
git commit -m "feat: gate reminder notifications by quiet hours"
```

---

## 自检

### 覆盖检查

- 健康分数公式：Task 1
- 首页圆环入口：Task 1
- 趋势页与路由：Task 2
- 勿扰时段模型与持久化：Task 3
- 勿扰设置 UI：Task 3
- 本地通知与静默窗口拦截：Task 4
- 提醒写入到派发的接线：Task 4

### 类型一致性

- `HealthScoreBreakdown` 和 `calculateHealthScore` 在 Task 1 中先定义，后续首页卡片和趋势页都直接复用。
- `NotificationPreference` 在 Task 3 中先定义，Task 4 的通知派发直接读取该模型，不再重复解释时间窗口规则。
- `TrendTab`、`TrendSnapshot`、`TrendAnalysisPage` 保持同一命名，不在后续任务中改名。
