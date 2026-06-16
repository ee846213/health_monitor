# Overview Field-Level Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将首页 `OverviewPage` 从整页聚合刷新改成字段级刷新，只让变化的文本、图标和图形参数更新。

**Architecture:** 保留一个首页 `ready` 态共享快照上游 provider，再在 `features/overview/providers/overview_ready_providers.dart` 中拆出字段级 provider。页面壳只关心 `OverviewScreenState`，各个 widget 内部用小粒度 provider 驱动对应 `Text`、图标和图形参数。

**Tech Stack:** Flutter, Dart, Riverpod, flutter_test

---

### Task 1: 拆出首页状态入口与 ready 态上游快照

**Files:**
- Modify: `lib/features/overview/providers/overview_providers.dart`
- Create: `lib/features/overview/providers/overview_ready_providers.dart`
- Test: `test/features/overview/overview_field_level_refresh_test.dart`

- [ ] **Step 1: 写失败测试，验证步数字段更新不会带动环境字段 provider**

```dart
test('步数变化时只更新步数相关 provider，不更新噪音图标 provider', () async {
  final container = _createOverviewFieldRefreshContainer(
    initialSnapshot: _buildSnapshot(
      steps: 1200,
      noiseLabel: '正常',
    ),
  );
  addTearDown(container.dispose);

  final stepEvents = <String>[];
  final noiseEvents = <String>[];

  final stepSub = container.listen<String>(
    overviewStepValueTextProvider,
    (previous, next) => stepEvents.add(next),
    fireImmediately: false,
  );
  final noiseSub = container.listen<String>(
    overviewEnvironmentNoiseIconProvider,
    (previous, next) => noiseEvents.add(next),
    fireImmediately: false,
  );
  addTearDown(stepSub.close);
  addTearDown(noiseSub.close);

  _setOverviewSnapshot(
    container,
    _buildSnapshot(
      steps: 2400,
      noiseLabel: '正常',
    ),
  );

  expect(stepEvents, contains('2400'));
  expect(noiseEvents, isEmpty);
});
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/features/overview/overview_field_level_refresh_test.dart`
Expected: FAIL，提示缺少 `overviewStepValueTextProvider`、`overviewEnvironmentNoiseIconProvider` 或 provider 通知边界不满足预期

- [ ] **Step 3: 最小实现首页状态入口与 ready 态上游 provider**

```dart
final overviewScreenStateProvider = FutureProvider<OverviewScreenState>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);

  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final dashboard = await ref.watch(overviewDashboardSnapshotProvider.future);

  return resolveOverviewScreenState(
    permissionStatuses: permissionStatuses,
    hasRealData: dashboard.hasRealData,
    hasReminderHistory: dashboard.hasReminderHistory,
  );
});

final overviewDashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);

  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.build(referenceTime: DateTime.now());
});

final overviewDashboardDataProvider = Provider<DashboardSnapshot?>((Ref ref) {
  return ref.watch(
    overviewDashboardSnapshotProvider.select(
      (AsyncValue<DashboardSnapshot> value) => value.valueOrNull,
    ),
  );
});
```

- [ ] **Step 4: 运行测试，确认 provider 定义生效但字段测试仍可能未全绿**

Run: `flutter test test/features/overview/overview_field_level_refresh_test.dart`
Expected: 测试从“provider 未定义”推进到“字段 provider 未定义”或更细的断言失败

- [ ] **Step 5: 提交一个小步快照**

```bash
git add lib/features/overview/providers/overview_providers.dart lib/features/overview/providers/overview_ready_providers.dart test/features/overview/overview_field_level_refresh_test.dart
git commit -m "feat: 拆出首页ready态快照provider"
```

### Task 2: 拆出字段级 provider

**Files:**
- Modify: `lib/features/overview/providers/overview_ready_providers.dart`
- Test: `test/features/overview/overview_field_level_refresh_test.dart`

- [ ] **Step 1: 写失败测试，验证环境变化只更新环境文本和图标**

```dart
test('环境变化时只更新环境相关 provider，不更新步数字段 provider', () async {
  final container = _createOverviewFieldRefreshContainer(
    initialSnapshot: _buildSnapshot(
      steps: 1200,
      lightLabel: '舒适',
      noiseLabel: '正常',
    ),
  );
  addTearDown(container.dispose);

  final lightTextEvents = <String>[];
  final lightIconEvents = <String>[];
  final stepEvents = <String>[];

  final lightTextSub = container.listen<String>(
    overviewEnvironmentLightTextProvider,
    (previous, next) => lightTextEvents.add(next),
    fireImmediately: false,
  );
  final lightIconSub = container.listen<String>(
    overviewEnvironmentLightIconProvider,
    (previous, next) => lightIconEvents.add(next),
    fireImmediately: false,
  );
  final stepSub = container.listen<String>(
    overviewStepValueTextProvider,
    (previous, next) => stepEvents.add(next),
    fireImmediately: false,
  );
  addTearDown(lightTextSub.close);
  addTearDown(lightIconSub.close);
  addTearDown(stepSub.close);

  _setOverviewSnapshot(
    container,
    _buildSnapshot(
      steps: 1200,
      lightLabel: '明亮',
      noiseLabel: '正常',
    ),
  );

  expect(lightTextEvents, contains('明亮'));
  expect(lightIconEvents, isNotEmpty);
  expect(stepEvents, isEmpty);
});
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/features/overview/overview_field_level_refresh_test.dart`
Expected: FAIL，字段级 provider 尚未完成或 `select` 范围过宽

- [ ] **Step 3: 最小实现字段级 provider**

```dart
final overviewStepValueTextProvider = Provider<String>((Ref ref) {
  return ref.watch(
        overviewDashboardDataProvider.select(
          (DashboardSnapshot? snapshot) => snapshot?.stepCard.currentSteps,
        ),
      )?.toString() ??
      '--';
});

final overviewEnvironmentNoiseIconProvider = Provider<String>((Ref ref) {
  final label = ref.watch(overviewEnvironmentNoiseTextProvider);
  return _noiseIconForLabel(label);
});
```

同时补齐 spec 中列出的字段 provider：

- `overviewHealthScoreValueProvider`
- `overviewHealthScoreProgressProvider`
- `overviewHealthScoreSummaryProvider`
- `overviewHealthScoreStepPillProvider`
- `overviewHealthScoreSedentaryPillProvider`
- `overviewHealthScoreScreenPillProvider`
- `overviewStepValueTextProvider`
- `overviewStepCaptionTextProvider`
- `overviewSedentaryValueTextProvider`
- `overviewSedentaryCaptionTextProvider`
- `overviewScreenValueTextProvider`
- `overviewScreenCaptionTextProvider`
- `overviewEnvironmentLightTextProvider`
- `overviewEnvironmentLightIconProvider`
- `overviewEnvironmentNoiseTextProvider`
- `overviewEnvironmentNoiseIconProvider`
- `overviewAdviceSourceTextProvider`
- `overviewAdviceBodyTextProvider`
- `overviewPreciseDetectionNoticeTextProvider`
- `overviewMissingDimensionsTextProvider`

- [ ] **Step 4: 运行测试，确认字段通知边界转绿**

Run: `flutter test test/features/overview/overview_field_level_refresh_test.dart`
Expected: PASS

- [ ] **Step 5: 提交字段 provider**

```bash
git add lib/features/overview/providers/overview_ready_providers.dart test/features/overview/overview_field_level_refresh_test.dart
git commit -m "feat: 拆出首页字段级刷新provider"
```

### Task 3: 改首页页面壳只消费页面状态

**Files:**
- Modify: `lib/features/overview/pages/overview_page.dart`
- Test: `test/features/overview/overview_refresh_preserves_content_test.dart`

- [ ] **Step 1: 写失败测试，验证首页刷新中保留 ready 态内容而不是回到 loading**

```dart
testWidgets('首页刷新仪表盘数据时保留已显示内容而不回到loading', (WidgetTester tester) async {
  final container = _createPendingOverviewPageContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: OverviewPage()),
    ),
  );
  await tester.pumpAndSettle();

  container.invalidate(overviewDashboardSnapshotProvider);
  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.text('综合健康分'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/features/overview/overview_refresh_preserves_content_test.dart`
Expected: FAIL，页面仍然直接依赖整份 `overviewViewModelProvider`

- [ ] **Step 3: 最小改造页面壳**

```dart
final asyncScreenState = ref.watch(overviewScreenStateProvider);

return asyncScreenState.when(
  skipLoadingOnRefresh: true,
  loading: () => const Center(child: CircularProgressIndicator()),
  error: ...,
  data: (OverviewScreenState screenState) {
    switch (screenState) {
      case OverviewScreenState.permissionDenied:
        return const PermissionDeniedPage();
      case OverviewScreenState.dataInsufficient:
        return const DataInsufficientPage();
      case OverviewScreenState.ready:
        return const _OverviewDashboardBody();
    }
  },
);
```

- [ ] **Step 4: 运行测试，确认页面状态拆分有效**

Run: `flutter test test/features/overview/overview_refresh_preserves_content_test.dart`
Expected: PASS

- [ ] **Step 5: 提交页面壳改造**

```bash
git add lib/features/overview/pages/overview_page.dart test/features/overview/overview_refresh_preserves_content_test.dart
git commit -m "feat: 拆分首页页面状态入口"
```

### Task 4: 改 widget 为字段级订阅

**Files:**
- Modify: `lib/features/overview/widgets/health_score_hero.dart`
- Modify: `lib/features/overview/widgets/metric_cards.dart`
- Modify: `lib/features/overview/widgets/environment_snapshot_bar.dart`
- Modify: `lib/features/overview/widgets/ai_suggestion_bubble.dart`
- Test: `test/features/overview/overview_page_test.dart`

- [ ] **Step 1: 写失败测试，验证首页 ready 态仍能展示原有内容**

```dart
testWidgets('首页ready态仍展示健康分、指标卡、环境条和AI建议', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        overviewScreenStateProvider.overrideWith((Ref ref) async => OverviewScreenState.ready),
        overviewDashboardSnapshotProvider.overrideWith((Ref ref) async => _buildSnapshot()),
      ],
      child: const MaterialApp(home: OverviewPage()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('综合健康分'), findsOneWidget);
  expect(find.text('步数'), findsOneWidget);
  expect(find.textContaining('AI 建议'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `flutter test test/features/overview/overview_page_test.dart`
Expected: FAIL，widget 仍要求外部传整份 `DashboardSnapshot`

- [ ] **Step 3: 最小改造 widget**

把各 widget 改成静态壳 + 内部小 `Consumer`：

```dart
class HealthScoreHero extends StatelessWidget {
  const HealthScoreHero({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ...
  }
}

class _HealthScoreValueText extends ConsumerWidget {
  const _HealthScoreValueText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(overviewHealthScoreValueProvider);
    return Text(value, ...);
  }
}
```

同样应用到：

- `MetricCards`
- `EnvironmentSnapshotBar`
- `AiSuggestionBubble`

- [ ] **Step 4: 运行测试，确认首页展示与跳转行为保持**

Run: `flutter test test/features/overview/overview_page_test.dart`
Expected: PASS

- [ ] **Step 5: 提交 widget 粒度拆分**

```bash
git add lib/features/overview/widgets/health_score_hero.dart lib/features/overview/widgets/metric_cards.dart lib/features/overview/widgets/environment_snapshot_bar.dart lib/features/overview/widgets/ai_suggestion_bubble.dart test/features/overview/overview_page_test.dart
git commit -m "feat: 细化首页文本图标图形刷新粒度"
```

### Task 5: 收尾验证

**Files:**
- Modify: `test/features/overview/overview_refresh_on_data_revision_test.dart`
- Test: `test/features/overview/overview_field_level_refresh_test.dart`
- Test: `test/features/overview/overview_refresh_preserves_content_test.dart`
- Test: `test/features/overview/overview_page_test.dart`

- [ ] **Step 1: 检查旧测试是否仍绑定整页 provider**

把仍然直接 override `overviewViewModelProvider` 的测试迁移到新的入口：

- `overviewScreenStateProvider`
- `overviewDashboardSnapshotProvider`

- [ ] **Step 2: 运行首页相关测试**

Run: `flutter test test/features/overview/overview_field_level_refresh_test.dart`
Expected: PASS

Run: `flutter test test/features/overview/overview_refresh_preserves_content_test.dart`
Expected: PASS

Run: `flutter test test/features/overview/overview_page_test.dart`
Expected: PASS

Run: `flutter test test/features/overview/overview_refresh_on_data_revision_test.dart`
Expected: PASS

- [ ] **Step 3: 提交验证收尾**

```bash
git add test/features/overview/overview_refresh_on_data_revision_test.dart
git commit -m "test: 更新首页字段级刷新回归覆盖"
```
